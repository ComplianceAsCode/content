#!/usr/bin/env python2

from __future__ import print_function

from tempfile import mkdtemp
import os
import os.path
import sys
import shutil
import re
import argparse
import getpass
import yaml

try:
    from github import Github, InputGitAuthor
except ImportError:
    sys.stderr.write("Please install PyGithub, on Fedora it's in the "
                     "python-PyGithub package.\n")
    sys.exit(1)


# Put shared python modules in path
sys.path.insert(0, os.path.join(
        os.path.dirname(os.path.dirname(os.path.realpath(__file__))),
        "modules"))
import ssgcommon

ORGANIZATION_NAME = "Ansible-Security-Compliance"
GIT_COMMIT_AUTHOR_NAME = "SCAP Security Guide development team"
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
            description="Role generated from SCAP Security Guide",
            homepage="https://www.open-scap.org/",
            private=False,
            has_issues=False,
            has_wiki=False,
            has_downloads=False)


def clone_and_init_repository(parent_dir, repo):
    os.system(
        "git clone git@github.com:%s/%s.git" % (ORGANIZATION_NAME, repo))
    os.system("ansible-galaxy init " + repo + " --force")
    os.chdir(repo)
    try:
        os.system('git add .')
        os.system('git commit -a -m "Initial commit" --author "%s <%s>"'
                  % (GIT_COMMIT_AUTHOR_NAME, GIT_COMMIT_AUTHOR_EMAIL))
        os.system('git push origin master')
    finally:
        os.chdir("..")


def update_repository(repository, local_file_path):
    print("Processing %s..." % repository.name)

    with open(local_file_path, 'r') as f:
        filedata = f.read()

    role_data = yaml.load(filedata)
    vars_data = []
    if "vars" in role_data[0]:
        vars_data = role_data[0]["vars"]

    tasks_data = []
    if "tasks" in role_data[0]:
        tasks_data = role_data[0]["tasks"]

    # ansible language doesn't allow pre_tasks for roles, if the only pre task
    # is the ansible version check we can ignore it because the minimal version
    # is in role metadata
    if "pre_tasks" in role_data[0]:
        pre_tasks_data = role_data[0]["pre_tasks"]
        if len(pre_tasks_data) == 1 and \
                pre_tasks_data[0]["name"] == \
                ssgcommon.ansible_version_requirement_pre_task_name:
            pass
        else:
            sys.stderr.write(
                "%s contains pre_tasks other than the version check. pre_tasks "
                "are not supported for ansible roles and will be skipped!.\n")

    tasks_local_content = yaml.dump(tasks_data, width=120, indent=4,
                                    default_flow_style=False)
    tasks_remote_content = repository.get_file_contents("/tasks/main.yml")

    if tasks_local_content != tasks_remote_content.decoded_content:
        repository.update_file(
            "/tasks/main.yml",
            "Updates tasks/main.yml",
            tasks_local_content,
            tasks_remote_content.sha,
            author=InputGitAuthor(
                GIT_COMMIT_AUTHOR_NAME, GIT_COMMIT_AUTHOR_EMAIL)
        )

        print("Updating tasks/main.yml in %s" % repository.name)

    vars_local_content = yaml.dump(vars_data, width=120, indent=4,
                                   default_flow_style=False)
    vars_remote_content = repository.get_file_contents("/vars/main.yml")

    if vars_local_content != vars_remote_content.decoded_content:
        repository.update_file(
            "/vars/main.yml",
            "Updates vars/main.yml",
            vars_local_content,
            vars_remote_content.sha,
            author=InputGitAuthor(
                GIT_COMMIT_AUTHOR_NAME, GIT_COMMIT_AUTHOR_EMAIL)
        )

        print("Updating vars/main.yml in %s" % repository.name)

    separator = "#" * 79
    first_separator_pos = filedata.find(separator)
    second_separator_pos = filedata.find(separator,
                                         first_separator_pos + len(separator))
    description = filedata[first_separator_pos + len(separator) + 3:
                           second_separator_pos - 3]
    description = description.replace('# ', '')
    description = description.replace('#', '')
    title = re.search('Profile Title:\s+(.+)$',
                      description, re.MULTILINE).group(1)
    description = description.replace('\n', '  \n')

    repository.edit(
        repository.name,
        description="%s - Ansible role generated from the SCAP Security Guide "
        "project" % (title),
        homepage="https://www.open-scap.org/",
    )

    with open(README_TEMPLATE_PATH, 'r') as f:
        readme_template = f.read()

    local_readme_content = readme_template.replace("@DESCRIPTION@", description)
    local_readme_content = local_readme_content.replace("@TITLE@", title)
    local_readme_content = local_readme_content.replace(
        "@MIN_ANSIBLE_VERSION@", ssgcommon.min_ansible_version)
    local_readme_content = local_readme_content.replace("@ROLE_NAME@",
                                                        repository.name)

    remote_readme_file = repository.get_file_contents("/README.md")

    if local_readme_content != remote_readme_file.decoded_content:
        print("Updating README.md in %s" % repository.name)

        repository.update_file(
            "/README.md",
            "Updates README.md",
            local_readme_content,
            remote_readme_file.sha,
            author=InputGitAuthor(
                GIT_COMMIT_AUTHOR_NAME, GIT_COMMIT_AUTHOR_EMAIL)
        )

    with open(META_TEMPLATE_PATH, 'r') as f:
        meta_template = f.read()

    local_meta_content = meta_template.replace("@DESCRIPTION@", title)
    local_meta_content = local_meta_content.replace(
        "@MIN_ANSIBLE_VERSION@", ssgcommon.min_ansible_version)
    remote_meta_file = repository.get_file_contents("/meta/main.yml")

    if local_meta_content != remote_meta_file.decoded_content:
        print("Updating meta/main.yml in %s" % repository.name)
        repository.update_file(
            "/meta/main.yml",
            "Updates meta/main.yml",
            local_meta_content,
            remote_meta_file.sha,
            author=InputGitAuthor(
                GIT_COMMIT_AUTHOR_NAME, GIT_COMMIT_AUTHOR_EMAIL)
        )


def main():
    parser = argparse.ArgumentParser(
        description='Updates SSG Galaxy Ansible Roles')
    parser.add_argument(
        "--build-roles-dir", required=True,
        help="Path to directory containing the ssg generated roles. Most "
        "likely this is going to be scap-security-guide/build/roles",
        dest="build_roles_dir")
    args = parser.parse_args()

    role_whitelist = set([
        "rhel7-role-C2S",
        "rhel7-role-hipaa",
        "rhel7-role-nist-800-171-cui",
        "rhel7-role-ospp-rhel7",
        "rhel7-role-pci-dss",
        "rhel7-role-rht-ccp",
        "rhel7-role-stig-rhel7-disa"
    ])

    # the first 4 cut chars are for "ssg-"
    # the last 4 cut chars are for ".yml"
    available_roles = set(
        [f[4:-4]
         for f in os.listdir(args.build_roles_dir) if f.endswith(".yml")]
    )
    # print(available_roles)
    roles = available_roles.intersection(role_whitelist)

    print("Input your GitHub credentials:")
    username = raw_input("username or token: ")
    password = getpass.getpass("password (or empty for token): ")

    github = Github(username, password)
    github_org = github.get_organization(ORGANIZATION_NAME)
    github_repositories = [repo.name for repo in github_org.get_repos()]

    # Create empty repositories
    github_new_repos = sorted(list(set(roles) - set(github_repositories)))
    if github_new_repos:
        create_empty_repositories(github_new_repos, github_org)
        github_repositories = [repo.name for repo in github_org.get_repos()]

        # Locally clone and init repositories
        temp_dir = mkdtemp()
        current_dir = os.getcwd()
        os.chdir(temp_dir)
        try:
            for repo in github_new_repos:
                clone_and_init_repository(temp_dir, repo)
        finally:
            os.chdir(current_dir)
            shutil.rmtree(temp_dir)

    # Update repositories
    for repo in sorted(github_org.get_repos(), key=lambda repo: repo.name):
        if repo.name in roles:
            update_repository(
                repo, os.path.join(args.build_roles_dir,
                                   "ssg-" + repo.name + ".yml")
            )
        else:
            print("Repo %s should be deleted, please verify and do that "
                  "manually!" % repo.name)


if __name__ == "__main__":
    main()
