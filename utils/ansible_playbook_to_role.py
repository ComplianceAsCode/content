#!/usr/bin/env python2
# -*- coding: utf-8 -*-

from __future__ import print_function

from tempfile import mkdtemp
import io
import os
import os.path
import sys
import shutil
import re
import argparse
import getpass
import yaml
import collections

try:
    from github import Github, InputGitAuthor
except ImportError:
    sys.stderr.write("Please install PyGithub, on Fedora it's in the "
                     "python-PyGithub package.\n")
    sys.exit(1)


import ssg.ansible
import ssg.yaml


def memoize(f):
    memo = {}

    def helper(x):
        if x not in memo:
            memo[x] = f(x)
        return memo[x]
    return helper

# The following code preserves ansible yaml order
# code from arcaduf's gist
# https://gist.github.com/arcaduf/8edbe5900372f0dd30aa037272dfe826
_mapping_tag = yaml.resolver.BaseResolver.DEFAULT_MAPPING_TAG


def dict_representer(dumper, data):
    return dumper.represent_mapping(_mapping_tag, data.items())


def dict_constructor(loader, node):
    return collections.OrderedDict(loader.construct_pairs(node))


yaml.add_representer(collections.OrderedDict, dict_representer)
yaml.add_constructor(_mapping_tag, dict_constructor)
# End arcaduf gist

PRODUCT_WHITELIST = set([
    "rhel7",
    "rhel8",
    "rhv4",
])

PROFILE_WHITELIST = set([
    "C2S",
    "cjis",
    "hipaa",
    "cui",
    "ospp",
    "pci-dss",
    "rht-ccp",
    "stig",
    "rhvh-stig",
    "rhvh-vpp",
])


ORGANIZATION_NAME = "RedHatOfficial"
GIT_COMMIT_AUTHOR_NAME = "ComplianceAsCode development team"
GIT_COMMIT_AUTHOR_EMAIL = "scap-security-guide@lists.fedorahosted.org"
META_TEMPLATE_PATH = os.path.join(
    os.path.dirname(os.path.abspath(__file__)),
    "ansible_galaxy_meta_template.yml"
)
README_TEMPLATE_PATH = os.path.join(
    os.path.dirname(os.path.abspath(__file__)),
    "ansible_galaxy_readme_template.md"
)


def create_empty_repositories(github_new_repos, github_org):
    for github_new_repo in github_new_repos:
        print("Creating new Github repository: %s" % github_new_repo)
        github_org.create_repo(
            github_new_repo,
            description="Role generated from ComplianceAsCode Project",
            homepage="https://github.com/ComplianceAsCode/content/",
            private=False,
            has_issues=False,
            has_wiki=False,
            has_downloads=False)


def clone_and_init_repository(parent_dir, organization, repo):
    os.system(
        "git clone https://github.com/%s/%s" % (organization, repo))
    os.system("ansible-galaxy init " + repo + " --force")
    os.chdir(repo)
    try:
        os.system('git add .')
        os.system('git commit -a -m "Initial commit" --author "%s <%s>"'
                  % (GIT_COMMIT_AUTHOR_NAME, GIT_COMMIT_AUTHOR_EMAIL))
        os.system('git push origin master')
    finally:
        os.chdir("..")


def update_repo_release(github, repo):
    repo_tags = [tag for tag in repo.get_tags()]
    try:
        (majv, minv, rel) = repo_tags[0].name.split(".")
        rel = int(rel) + 1
    except IndexError:
        cac = github.get_repo("ComplianceAsCode/content")
        cac_tags = [tag for tag in cac.get_tags() if tag.name != "v0.5.0-InitialDraft"]
        (majv, minv, rel) = cac_tags[0].name.strip("v").split(".")

    new_tag = ("%s.%s.%s" % (majv, minv, rel))
    commits = repo.get_commits()
    print("Tagging new release '%s' for repo '%s'" % (new_tag, repo.name))
    repo.create_git_tag_and_release(new_tag, '', '', '', commits[0].sha, 'commit')


class PlaybookToRoleConverter():
    PRODUCED_FILES = ('defaults/main.yml', 'meta/main.yml', 'tasks/main.yml', 'vars/main.yml',
                      'README.md')

    def __init__(self, local_playbook_filename):
        self._local_playbook_filename = local_playbook_filename

        # ansible language doesn't allow pre_tasks for roles, if the only pre task
        # is the ansible version check we can ignore it because the minimal version
        # is in role metadata
        if "pre_tasks" in self._playbook[0]:
            pre_tasks_data = self._playbook[0]["pre_tasks"]
            if len(pre_tasks_data) == 1 and \
                    pre_tasks_data[0]["name"] == \
                    ssg.ansible.ansible_version_requirement_pre_task_name:
                pass
            else:
                sys.stderr.write(
                    "%s contains pre_tasks other than the version check. "
                    "pre_tasks are not supported for ansible roles and "
                    "will be skipped!.\n")

    @property
    @memoize
    def name(self):
        root, _ = os.path.splitext(os.path.basename(self._local_playbook_filename))
        product, _, profile = root.split("-", 2)
        return "%s_%s" % (product, profile.replace("-", "_"))

    @property
    @memoize
    def tasks_data(self):
        return self._playbook[0]["tasks"] if "tasks" in self._playbook[0] else []

    @property
    @memoize
    def tasks_local_content(self):
        return yaml.dump(self.tasks_data, width=120, default_flow_style=False) \
            .replace('\n- ', '\n\n- ')

    @property
    @memoize
    def default_vars_data(self):
        return self._playbook[0]["vars"] if "vars" in self._playbook[0] else []

    @property
    @memoize
    def added_variables(self):
        variables = set()
        for task in self.tasks_data:
            if "tags" not in task:
                next
            if "when" not in task:
                task["when"] = []
            elif isinstance(task["when"], str):
                task["when"] = [task["when"]]

            variables_to_add = {tag for tag in task["tags"] if self._tag_is_valid_variable(tag)}
            task["when"] = ["{varname} | bool".format(varname=v) for v in variables_to_add] + task["when"]
            variables.update(variables_to_add)

            if not task["when"]:
                del task["when"]
        return variables

    @property
    def vars_data(self):
        return []

    @property
    @memoize
    def title(self):
        try:
            title = re.search(r'Profile Title:\s+(.+)$', self._description, re.MULTILINE).group(1)
            return '"' + title + '"'
        except AttributeError:
            return re.search(r'Ansible Playbook for\s+(.+)$', self._description, re.MULTILINE) \
                     .group(1)

    @property
    @memoize
    def description_md(self):
        # This is for a role and not a playbook
        description = re.sub(r'Playbook', "Role", self._description)

        # Fix the description format for markdown so that it looks pretty
        return description.replace('\n', '  \n')

    @property
    @memoize
    def _playbook(self):
        return ssg.yaml.ordered_load(self._raw_playbook)

    @property
    @memoize
    def _raw_playbook(self):
        with io.open(self._local_playbook_filename, 'r', encoding="utf-8") as f:
            return f.read()

    @property
    @memoize
    def _description(self):
        separator = "#" * 79
        offset_from_separator = 3
        first_separator_pos = self._raw_playbook.find(separator)
        second_separator_pos = self._raw_playbook.find(separator,
                                                       first_separator_pos + len(separator))
        description_start = first_separator_pos + len(separator) + offset_from_separator
        description_stop = second_separator_pos - offset_from_separator
        description = self._raw_playbook[description_start:description_stop]
        description = description.replace('# ', '')
        description = description.replace('#', '')

        desc = ""
        # Remove SCAP and Playbook examples from description as they don't belong in roles.
        for line in description.split("\n"):
            if line.startswith("Profile ID:"):
                break
            else:
                desc += (line + "\n")
        return desc.strip("\n\n")

    def _tag_is_valid_variable(self, tag):
        return '-' not in tag and tag != 'always'

    def file(self, filepath):
        if filepath == 'tasks/main.yml':
            return self.tasks_local_content
        elif filepath == 'vars/main.yml':
            if len(self.vars_data) < 1:
                return "---\n# defaults file for {role_name}\n".format(role_name=self.name)
            else:
                return yaml.dump(self.vars_data, width=120, indent=4, default_flow_style=False)
        elif filepath == 'README.md':
            return self._generate_readme_content()
        elif filepath == 'defaults/main.yml':
            return self._generate_defaults_content()
        elif filepath == 'meta/main.yml':
            return self._generate_meta_content()

    def _generate_readme_content(self):
        with io.open(README_TEMPLATE_PATH, 'r',  encoding="utf-8") as f:
            readme_template = f.read()

        local_readme_content = readme_template.replace(
            "@DESCRIPTION@", self.description_md)
        local_readme_content = local_readme_content.replace(
            "@TITLE@", self.title)
        local_readme_content = local_readme_content.replace(
            "@MIN_ANSIBLE_VERSION@", ssg.ansible.min_ansible_version)
        local_readme_content = local_readme_content.replace(
            "@ROLE_NAME@", self.name)
        return local_readme_content

    def _generate_meta_content(self):
        with open(META_TEMPLATE_PATH, 'r') as f:
            meta_template = f.read()
        local_meta_content = meta_template.replace("@ROLE_NAME@",
                                                   self.name)
        local_meta_content = local_meta_content.replace("@DESCRIPTION@", self.title)
        return local_meta_content.replace("@MIN_ANSIBLE_VERSION@", ssg.ansible.min_ansible_version)

    def _generate_defaults_content(self):
        default_vars_to_add = sorted(self.added_variables)
        default_vars_local_content = yaml.dump(self.default_vars_data, width=120, indent=4,
                                               default_flow_style=False)
        header = [
            "---", "# defaults file for {role_name}\n".format(role_name=self.name),
        ]
        lines = ["{var_name}: true".format(var_name=var_name) for var_name in default_vars_to_add]
        lines.append("")

        return ("%s%s%s" % ("\n".join(header), default_vars_local_content, "\n".join(lines)))

    def save_to_disk(self, directory):
        print("Converting Ansible Playbook {} to Ansible Role {}".format(self._local_playbook_filename, os.path.join(directory, self.name)))
        for filename in self.PRODUCED_FILES:
            abs_path = os.path.join(directory, self.name, filename)
            ssg.utils.mkdir_p(os.path.dirname(abs_path))
            open(abs_path, 'wb').write(self.file(filename).encode("utf-8"))


class RoleGithubUpdater(object):
    def __init__(self, repo, local_playbook_filename):
        self.remote_repo = repo
        self.role = PlaybookToRoleConverter(local_playbook_filename)

    def _local_content(self, filepath):
        new_content = self.role.file(filepath)

        if filepath == 'README.md':
            remote_readme_file, _ = self._remote_content("README.md")
            if not remote_readme_file:
                return new_content

            local_readme_content = re.sub(r'Ansible version (\d*\.\d+|\d+)',
                                          "Ansible version %s" % ssg.ansible.min_ansible_version,
                                          remote_readme_file)
            return re.sub(r'%s\.[a-zA-Z0-9\-_]+' % ORGANIZATION_NAME,
                          "%s.%s" % (ORGANIZATION_NAME, self.role.name),
                          local_readme_content)
        elif filepath == 'meta/main.yml':
            remote_meta_file, _ = self._remote_content(filepath)
            if not remote_meta_file:
                return new_content

            with open(META_TEMPLATE_PATH, 'r') as f:
                meta_template = f.read()
            author = re.search(r'author:.*', meta_template).group(0)
            description = re.search(r'description:.*', meta_template).group(0)
            issue_tracker_url = re.search(r'issue_tracker_url:.*', meta_template).group(0)
            local_meta_content = remote_meta_file
            local_meta_content = re.sub(r'role_name:.*',
                                        "role_name: %s" % self.role.name,
                                        local_meta_content)
            local_meta_content = re.sub(r'author:.*',
                                        author,
                                        local_meta_content)
            local_meta_content = re.sub(r'min_ansible_version: (\d*\.\d+|\d+)',
                                        "min_ansible_version: %s" % ssg.ansible.min_ansible_version,
                                        local_meta_content)
            local_meta_content = re.sub(r'description:.*',
                                        "description: %s" % self.role.title,
                                        local_meta_content)
            return re.sub(r'issue_tracker_url:.*',
                          issue_tracker_url,
                          local_meta_content)
        return new_content

    def _remote_content(self, filepath):
        remote = self.remote_repo.get_contents(filepath)
        content = remote.decoded_content
        if filepath == 'README.md':
            content = content.decode("utf-8")
        return content, remote.sha

    def _update_content_if_needed(self, filepath):
        remote_content, sha = self._remote_content(filepath)

        if self._local_content(filepath) != remote_content:
            self.remote_repo.update_file(
                "/" + filepath,
                "Updates " + filepath,
                self._local_content(filepath),
                sha,
                author=InputGitAuthor(
                    GIT_COMMIT_AUTHOR_NAME, GIT_COMMIT_AUTHOR_EMAIL)
            )
            print("Updating %s in %s" % (filepath, self.remote_repo.name))

    def update_repository(self):
        print("Processing %s..." % self.remote_repo.name)

        for path in PlaybookToRoleConverter.PRODUCED_FILES:
            self._update_content_if_needed(path)

        repo_description = (
            "{title} - Ansible role generated from ComplianceAsCode Project"
            .format(title=self.role.title))
        self.remote_repo.edit(
            self.remote_repo.name,
            description=repo_description,
            homepage="https://github.com/complianceascode/content",
        )


def parse_args():
    parser = argparse.ArgumentParser(
        description='Generates Ansible Roles and pushes them to Github')
    parser.add_argument(
        "--build-playbooks-dir", required=True,
        help="Path to directory containing the generated Ansible Playbooks. "
        "Most likely this is going to be ./build/ansible",
        dest="build_playbooks_dir")
    parser.add_argument(
        "--dry-run", "-d", dest="dry_run",
        help="Do not push Ansible Roles to the Github, store them only to local directory"
    )
    parser.add_argument(
        "--organization", "-o", default=ORGANIZATION_NAME,
        help="Name of the Github organization")
    parser.add_argument(
        "--profile", "-p", default=[], action="append",
        metavar="PROFILE", choices=PROFILE_WHITELIST,
        help="What profiles to upload, if not specified, upload all that are applicable.")
    parser.add_argument(
        "--product", "-r", default=[], action="append",
        metavar="PRODUCT", choices=PRODUCT_WHITELIST,
        help="What products to upload, if not specified, upload all that are applicable.")
    parser.add_argument(
        "--tag-release", "-n", default=False, action="store_true",
        help="Tag a new release in GitHub")
    parser.add_argument(
        "--token", "-t", dest="token",
        help="GitHub token used for organization authorization")
    return parser.parse_args()


def locally_clone_and_init_repositories(organization, repo_list):
    temp_dir = mkdtemp()
    current_dir = os.getcwd()
    os.chdir(temp_dir)
    try:
        for repo in repo_list:
            clone_and_init_repository(temp_dir, organization, repo)
    finally:
        os.chdir(current_dir)
        shutil.rmtree(temp_dir)


def select_roles_to_upload(product_whitelist, profile_whitelist,
                           build_playbooks_dir):
    selected_roles = dict()
    for filename in os.listdir(build_playbooks_dir):
        root, ext = os.path.splitext(filename)
        if ext == ".yml":
            # the format is product-playbook-profile.yml
            product, _, profile = root.split("-", 2)
            if product in product_whitelist and profile in profile_whitelist:
                role_name = "ansible-role-%s-%s" % (product, profile)
                selected_roles[role_name] = (product, profile)
    return selected_roles


def main():
    args = parse_args()

    product_whitelist = set(PRODUCT_WHITELIST)
    profile_whitelist = set(PROFILE_WHITELIST)

    potential_roles = {
        ("ansible-role-%s-%s" % (product, profile))
        for product in product_whitelist for profile in profile_whitelist
    }

    if args.product:
        product_whitelist &= set(args.product)
    if args.profile:
        profile_whitelist &= set(args.profile)

    selected_roles = select_roles_to_upload(
        product_whitelist, profile_whitelist, args.build_playbooks_dir
    )

    if args.dry_run:
        for product_profile in selected_roles.values():
            playbook_filename = "%s-playbook-%s.yml" % product_profile
            playbook_full_path = os.path.join(
                args.build_playbooks_dir, playbook_filename)
            PlaybookToRoleConverter(playbook_full_path).save_to_disk(args.dry_run)
    else:
        if not args.token:
            print("Input your GitHub credentials:")
            username = raw_input("username or token: ")
            password = getpass.getpass("password (or empty for token): ")
        else:
            username = args.token
            password = ""

        github = Github(username, password)
        github_org = github.get_organization(args.organization)
        github_repositories = [repo.name for repo in github_org.get_repos()]

        # Create empty repositories
        github_new_repos = sorted(list(set(map(str.lower, selected_roles.keys())) - set(map(unicode.lower, github_repositories))))
        if github_new_repos:
            create_empty_repositories(github_new_repos, github_org)

            locally_clone_and_init_repositories(args.organization, github_new_repos)

        # Update repositories
        for repo in sorted(github_org.get_repos(), key=lambda repo: repo.name):
            if repo.name in selected_roles:
                playbook_filename = "%s-playbook-%s.yml" % selected_roles[repo.name]
                playbook_full_path = os.path.join(
                    args.build_playbooks_dir, playbook_filename)
                RoleGithubUpdater(repo, playbook_full_path).update_repository()
                if args.tag_release:
                    update_repo_release(github, repo)
            elif repo.name not in potential_roles:
                print("Repo '%s' is not managed by this script. "
                      "It may need to be deleted, please verify and do that "
                      "manually!" % repo.name)


if __name__ == "__main__":
    main()
