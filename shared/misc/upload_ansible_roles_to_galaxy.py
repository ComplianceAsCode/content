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

try:
    from github import Github
except ImportError:
    sys.stderr.write("Please install PyGithub, on Fedora it's in the "
                     "python-PyGithub package.\n")
    sys.exit(1)

GIT_COMMIT_AUTHOR = \
    "SSG Ansible Role Uploader <scap-security-guide@lists.fedorahosted.org>"


def create_empty_repositories(github_new_repos, github_org):
    for github_new_repo in github_new_repos:
        print("Creating new Github repository: %s" % github_new_repo)
        github_org.create_repo(
            github_new_repo,
            description="Role generated SCAP Security Guide",
            homepage="https://www.open-scap.org/",
            private=False,
            has_issues=False,
            has_wiki=False,
            has_downloads=False)


def clone_and_init_repositories(repositories_to_create):
    for repo in repositories_to_create:
        os.system(
            "git clone git@github.com:Ansible-Security-Compliance/%s.git" % repo)
        os.system("ansible-galaxy init " + repo + " --force")
        os.chdir(repo)
        try:
            os.system('git add .')
            os.system('git commit -a -m "Initial commit" --author "%s"'
                      % GIT_COMMIT_AUTHOR)
            os.system('git push origin master')
        finally:
            os.chdir("..")


def update_repository(repository, local_file_path, meta_template_path):
    print("Processing %s..." % repository.name)

    with open(local_file_path, 'r') as f:
        filedata = f.read()

    local_file_content = filedata.replace("   tasks:", "#   tasks:")
    remote_file = repository.get_file_contents("/tasks/main.yml")

    if local_file_content != remote_file.decoded_content:
        repository.update_file(
            "/tasks/main.yml",
            "Updates tasks/main.yml",
            local_file_content,
            remote_file.sha,
            author=GIT_COMMIT_AUTHOR
        )

        print("Updating tasks/main.yml in %s" % repository.name)

    separator = "#" * 79
    header = filedata[filedata.find(
        separator) + len(separator) + 3:filedata.rfind(separator) - 3]
    header = header.replace('# ', '')
    header = header.replace('#', '')
    title = re.search('Profile Title:\s+(.+)$', header, re.MULTILINE).group(1)
    header = header.replace('\n', '  \n')

    local_readme_content = title + '\n=========\n\n' + header
    remote_readme_file = repository.get_file_contents("/README.md")

    if local_readme_content != remote_readme_file.decoded_content:
        print("Updating README.md in %s" % repository.name)

        repository.update_file(
            "/README.md",
            "Updates README.md",
            local_readme_content,
            remote_readme_file.sha,
            author=GIT_COMMIT_AUTHOR
        )

    if meta_template_path:
        with open(meta_template_path, 'r') as f:
            meta_template = f.read()

        local_meta_content = meta_template.replace("@DESCRIPTION@", title)
        remote_meta_file = repository.get_file_contents("/meta/main.yml")

        if local_meta_content != remote_meta_file.decoded_content:
            print("Updating meta/main.yml in %s" % repository.name)
            repository.update_file(
                "/meta/main.yml",
                "Updates meta/main.yml",
                local_meta_content,
                remote_meta_file.sha,
                author=GIT_COMMIT_AUTHOR)


def main():
    parser = argparse.ArgumentParser(
        description='Updates SSG Galaxy Ansible Roles')
    parser.add_argument(
        "--build-roles-dir", required=True,
        help="Path to directory containing the ssg generated roles. Most "
        "likely this is going to be scap-security-guide/build/roles",
        dest="build_roles_dir")
    parser.add_argument(
        "--meta-template-path", required=True,
        help="Path to metadata file template",
        dest="meta_template_path")
    args = parser.parse_args()

    organization_name = "Ansible-Security-Compliance"

    roles = \
        [f[:-4]
         for f in os.listdir(args.build_roles_dir) if f.endswith(".yml")]

    print("Input your GitHub credentials:")
    username = raw_input("username or token: ")
    password = getpass.getpass("password (or empty for token): ")

    github = Github(username, password)
    github_org = github.get_organization(organization_name)
    github_repositories = [repo.name for repo in github_org.get_repos()]

    # Create empty repositories
    github_new_repos = sorted(list(set(roles) - set(github_repositories)))
    if github_new_repos:
        create_empty_repositories(github_new_repos, github_org)
        github_repositories = [repo.name for repo in github_org.get_repos()]

        # Locally clone and init repositories
        temp_dir = mkdtemp()
        current_dir = os.getcwd()
        try:
            os.chdir(temp_dir)
            clone_and_init_repositories(github_new_repos)
        finally:
            os.chdir(current_dir)
            shutil.rmtree(temp_dir)

    # Update repositories
    for repo in sorted(github_org.get_repos(), key=lambda repo: repo.name):
        update_repository(
            repo, os.path.join(args.build_roles_dir, repo.name + ".yml"),
            args.meta_template_path
        )


if __name__ == "__main__":
    main()
