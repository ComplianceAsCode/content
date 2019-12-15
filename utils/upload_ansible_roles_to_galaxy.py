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

# The following code preserves ansible yaml order
# code from arcaduf's gist
# https://gist.github.com/arcaduf/8edbe5900372f0dd30aa037272dfe826
_mapping_tag = yaml.resolver.BaseResolver.DEFAULT_MAPPING_TAG


def dict_representer(dumper, data):
    return dumper.represent_mapping(_mapping_tag, data.iteritems())


def dict_constructor(loader, node):
    return collections.OrderedDict(loader.construct_pairs(node))


yaml.add_representer(collections.OrderedDict, dict_representer)
yaml.add_constructor(_mapping_tag, dict_constructor)
# End arcaduf gist

PRODUCT_WHITELIST = set([
    "rhel7",
    "rhel8",
    "rhv4",
    "ocp3",
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


class Role(object):
    def __init__(self, repo, local_playbook_filename):
        self.remote_repo = repo
        self.local_playbook_filename = local_playbook_filename

        self.role_data = None
        self.vars_data = []
        self.default_vars_data = []
        self.tasks_data = []
        self.pre_tasks_data = []
        self.added_variables = set()

        self.tasks_local_content = None

        self.description = None
        self.title = None
        self.role_name = None

    def gather_data(self):
        with io.open(self.local_playbook_filename, 'r', encoding="utf-8") as f:
            filedata = f.read()

        self.role_data = ssg.yaml.ordered_load(filedata)
        if "vars" in self.role_data[0]:
            self.default_vars_data = self.role_data[0]["vars"]

        if "tasks" in self.role_data[0]:
            self.tasks_data = self.role_data[0]["tasks"]

        # ansible language doesn't allow pre_tasks for roles, if the only pre task
        # is the ansible version check we can ignore it because the minimal version
        # is in role metadata
        if "pre_tasks" in self.role_data[0]:
            pre_tasks_data = self.role_data[0]["pre_tasks"]
            if len(pre_tasks_data) == 1 and \
                    pre_tasks_data[0]["name"] == \
                    ssg.ansible.ansible_version_requirement_pre_task_name:
                pass
            else:
                sys.stderr.write(
                    "%s contains pre_tasks other than the version check. "
                    "pre_tasks are not supported for ansible roles and "
                    "will be skipped!.\n")

        description = self.get_description_from_filedata(filedata)
        self.description = description

    def add_variables_to_tasks(self):
        for task in self.tasks_data:
            if "when" not in task:
                task["when"] = []
            elif isinstance(task["when"], str):
                task["when"] = [task["when"]]

            self.add_variables_to_task(task)

            if not task["when"]:
                del task["when"]

    def tag_is_valid_variable(self, tag):
        if "-" in tag:
            return False
        if tag == "always":
            return False
        return True

    def add_variables_to_task(self, task):
        if "tags" not in task:
            return
        variables_to_add = {tag for tag in task["tags"] if self.tag_is_valid_variable(tag)}
        task["when"] += ["{varname} | bool".format(varname=v) for v in variables_to_add]
        self.added_variables.update(variables_to_add)

    def add_task_variables_to_default_variables_if_needed(self):
        default_vars_to_add = sorted(self.added_variables)
        default_vars_local_content = yaml.dump(self.default_vars_data, width=120, indent=4,
                                               default_flow_style=False)
        header = [
            "---", "# defaults file for {role_name}\n".format(role_name=self.role_name),
        ]
        lines = ["{var_name}: true".format(var_name=var_name) for var_name in default_vars_to_add]
        lines.append("")

        default_vars_local_content = ("%s%s%s" % ("\n".join(header),
                                                  default_vars_local_content,
                                                  "\n".join(lines)))

        default_vars_remote_content = self.remote_repo.get_contents("defaults/main.yml")
        if default_vars_local_content != default_vars_remote_content.decoded_content:
            self.remote_repo.update_file(
                "defaults/main.yml",
                "Updates defaults/main.yml",
                default_vars_local_content,
                default_vars_remote_content.sha,
                author=InputGitAuthor(
                    GIT_COMMIT_AUTHOR_NAME, GIT_COMMIT_AUTHOR_EMAIL)
            )
            print("Updating defaults/main.yml in %s" % self.remote_repo.name)

    def _reformat_local_content(self):
        description = ""
        # Add \n in between tasks to increase readability
        self.tasks_local_content = self.tasks_local_content.replace('\n- ', '\n\n- ')

        self.description = self.description.replace('# ', '')
        self.description = self.description.replace('#', '')

        # Remove SCAP and Playbook examples from description as they don't belong in roles.
        for line in self.description.split("\n"):
            if line.startswith("Profile ID:"):
                break
            else:
                description += (line + "\n")
        self.description = description.strip("\n\n")

        # Ansible prefers underscores
        self.role_name = self.remote_repo.name.replace("-", "_")
        # Don't include role in role_name for simplicity
        self.role_name = self.role_name.replace('ansible_role_', '')

    def get_description_from_filedata(self, filedata):
        separator = "#" * 79
        offset_from_separator = 3

        first_separator_pos = filedata.find(
            separator)
        second_separator_pos = filedata.find(
            separator, first_separator_pos + len(separator))

        description_start = first_separator_pos + len(separator) + offset_from_separator
        description_stop = second_separator_pos - offset_from_separator
        description = filedata[description_start:description_stop]

        return description

    def _update_tasks_content_if_needed(self):
        tasks_remote_content = self.remote_repo.get_contents("tasks/main.yml")

        if self.tasks_local_content != tasks_remote_content.decoded_content:
            self.remote_repo.update_file(
                "tasks/main.yml",
                "Updates tasks/main.yml",
                self.tasks_local_content,
                tasks_remote_content.sha,
                author=InputGitAuthor(
                    GIT_COMMIT_AUTHOR_NAME, GIT_COMMIT_AUTHOR_EMAIL)
            )
            print("Updating tasks/main.yml in %s" % self.remote_repo.name)

    def _update_vars_content_if_needed(self):
        if len(self.vars_data) < 1:
            vars_local_content = "---\n# defaults file for {role_name}\n".format(role_name=self.role_name)
        else:
             vars_local_content = yaml.dump(self.vars_data, width=120, indent=4,
                                            default_flow_style=False)

        vars_remote_content = self.remote_repo.get_contents("vars/main.yml")

        if vars_local_content != vars_remote_content.decoded_content and \
           vars_local_content.splitlines()[0] != "null":
            self.remote_repo.update_file(
                "vars/main.yml",
                "Updates vars/main.yml",
                vars_local_content,
                vars_remote_content.sha,
                author=InputGitAuthor(
                    GIT_COMMIT_AUTHOR_NAME, GIT_COMMIT_AUTHOR_EMAIL)
            )

            print("Updating vars/main.yml in %s" % self.remote_repo.name)

    def _generate_readme_content(self):
        with io.open(README_TEMPLATE_PATH, 'r',  encoding="utf-8") as f:
            readme_template = f.read()

        # This is for a role and not a playbook
        self.description = re.sub(r'Playbook', "Role", self.description)

        local_readme_content = readme_template.replace(
            "@DESCRIPTION@", self.description)
        local_readme_content = local_readme_content.replace(
            "@TITLE@", self.title)
        local_readme_content = local_readme_content.replace(
            "@MIN_ANSIBLE_VERSION@", ssg.ansible.min_ansible_version)
        local_readme_content = local_readme_content.replace(
            "@ROLE_NAME@", self.role_name)
        return local_readme_content

    def _update_readme_content_if_needed(self, repo_status):
        local_readme_content = self._generate_readme_content()
        remote_readme_file = self.remote_repo.get_contents("README.md")

        if repo_status == "update":
            local_readme_content = remote_readme_file.decoded_content.decode("utf-8")
            local_readme_content = re.sub(r'Ansible version (\d*\.\d+|\d+)',
                                          "Ansible version %s" % ssg.ansible.min_ansible_version,
                                          local_readme_content)
            local_readme_content = re.sub(r'%s\.[a-zA-Z0-9\-_]+' % ORGANIZATION_NAME,
                                          "%s.%s" % (ORGANIZATION_NAME, self.role_name),
                                          local_readme_content)

        if local_readme_content != remote_readme_file.decoded_content.decode("utf-8"):
            print("Updating README.md in %s" % self.remote_repo.name)

            self.remote_repo.update_file(
                "README.md",
                "Updates README.md",
                local_readme_content,
                remote_readme_file.sha,
                author=InputGitAuthor(
                    GIT_COMMIT_AUTHOR_NAME, GIT_COMMIT_AUTHOR_EMAIL)
            )

    def _update_meta_content_if_needed(self, repo_status):
        remote_meta_file = self.remote_repo.get_contents("meta/main.yml")

        with open(META_TEMPLATE_PATH, 'r') as f:
            meta_template = f.read()

        if repo_status == "new":
            local_meta_content = meta_template.replace("@ROLE_NAME@",
                                                       self.role_name)
            local_meta_content = local_meta_content.replace("@DESCRIPTION@", self.title)
            local_meta_content = local_meta_content.replace(
                "@MIN_ANSIBLE_VERSION@", ssg.ansible.min_ansible_version)
        else:
            author = re.search(r'author:.*', meta_template).group(0)
            description = re.search(r'description:.*', meta_template).group(0)
            issue_tracker_url = re.search(r'issue_tracker_url:.*', meta_template).group(0)
            local_meta_content = remote_meta_file.decoded_content
            local_meta_content = re.sub(r'role_name:.*',
                                        "role_name: %s" % self.role_name,
                                        local_meta_content)
            local_meta_content = re.sub(r'author:.*',
                                        author,
                                        local_meta_content)
            local_meta_content = re.sub(r'min_ansible_version: (\d*\.\d+|\d+)',
                                        "min_ansible_version: %s" % ssg.ansible.min_ansible_version,
                                        local_meta_content)
            local_meta_content = re.sub(r'description:.*',
                                        "description: %s" % self.title,
                                        local_meta_content)
            local_meta_content = re.sub(r'issue_tracker_url:.*',
                                        issue_tracker_url,
                                        local_meta_content)

        if local_meta_content != remote_meta_file.decoded_content:
            print("Updating meta/main.yml in %s" % self.remote_repo.name)
            self.remote_repo.update_file(
                "meta/main.yml",
                "Updates meta/main.yml",
                local_meta_content,
                remote_meta_file.sha,
                author=InputGitAuthor(
                    GIT_COMMIT_AUTHOR_NAME, GIT_COMMIT_AUTHOR_EMAIL)
            )

    def update_repository(self, repo_status):
        print("Processing %s..." % self.remote_repo.name)

        self.gather_data()

        self.add_variables_to_tasks()
        self.tasks_local_content = yaml.dump(
            self.tasks_data, width=120, default_flow_style=False)

        self._reformat_local_content()
        try:
            self.title = re.search(
                r'Profile Title:\s+(.+)$', self.description, re.MULTILINE).group(1)
        except AttributeError:
            self.title = re.search(
                r'Ansible Playbook for\s+(.+)$', self.description, re.MULTILINE).group(1)

        # Fix the description format for markdown so that it looks pretty
        self.description = self.description.replace('\n', '  \n')

        self._update_tasks_content_if_needed()
        self._update_vars_content_if_needed()
        self._update_readme_content_if_needed(repo_status)
        self._update_meta_content_if_needed(repo_status)
        self.add_task_variables_to_default_variables_if_needed()

        repo_description = (
            "{title} - Ansible role generated from ComplianceAsCode Project"
            .format(title=self.title))
        self.remote_repo.edit(
            self.remote_repo.name,
            description=repo_description,
            homepage="https://github.com/complianceascode/content",
        )


def parse_args():
    parser = argparse.ArgumentParser(
        description='Updates Galaxy Ansible Roles')
    parser.add_argument(
        "--build-playbooks-dir", required=True,
        help="Path to directory containing the generated Ansible Playbooks. "
        "Most likely this is going to be ./build/ansible",
        dest="build_playbooks_dir")
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
    github_new_repos = sorted(list(set(selected_roles.keys()) - set(github_repositories)))
    if github_new_repos:
        create_empty_repositories(github_new_repos, github_org)

        locally_clone_and_init_repositories(args.organization, github_new_repos)

    # Update repositories
    for repo in sorted(github_org.get_repos(), key=lambda repo: repo.name):
        if repo.name in github_new_repos:
            repo_status = "new"
        else:
            repo_status = "update"

        if repo.name in selected_roles:
            playbook_filename = "%s-playbook-%s.yml" % selected_roles[repo.name]
            playbook_full_path = os.path.join(
                args.build_playbooks_dir, playbook_filename)
            Role(repo, playbook_full_path).update_repository(repo_status)
            if args.tag_release:
                update_repo_release(github, repo)
        elif repo.name not in potential_roles:
            print("Repo '%s' is not managed by this script. "
                  "It may need to be deleted, please verify and do that "
                  "manually!" % repo.name)


if __name__ == "__main__":
    main()
