import argparse
import git
import github
import re
import yaml
import subprocess
import sys

import content_gh
from jenkins_ci import JenkinsCI

def load_env(env_path):
    with open(env_path, 'r') as env_stream:
        env = yaml.safe_load(env_stream)
    return env

def validate_env(env, env_path):
    env_ok = True
    mandatory_fields = ['github_token', 'jenkins_user', 'jenkins_token']
    for field in mandatory_fields:
        if field not in env:
            print(f"Add your {field} in {env_path} file. Check the README.md for how to obtain it.")
            env_ok = True
    return env_ok

def parse_version(cmakelists_path):
    regex = re.compile(r'set\(SSG_(.*)_VERSION (\d+)\)')

    with open(cmakelists_path, 'r') as cmakelists_stream:
        cmakelists_content = cmakelists_stream.read()

        matches = re.findall(regex, cmakelists_content)
    version = { v_name.lower():v_value for v_name,v_value in matches }
    return version

def get_version_string(d):
    return f"{d['major']}.{d['minor']}.{d['patch']}"

def check_release(env, jenkins_ci, args):
    '''
    Check repo and project state for release
    '''

    local_repo = git.Repo('../')
    if local_repo.is_dirty():
        print("The repository is not clean, stash your changes before proceeding.")
        return

    gh = github.Github(env['github_token'])
    remote_repo = content_gh.get_repo(gh, args.owner, args.repo)
    release_exists = content_gh.check_release_exists(remote_repo, args)
    if release_exists:
        print(f"Version {args.version} was released already, "
                "bump the version in the CMakeLists.txt file before releasing.")
        return

    print("Checking Jenkins Jobs")
    jenkins_ci.check_all_green()

    # Run shell script that builds RHEL and checks for mising STIG IDS
    subprocess.call("./check_rhel_stig_ids.sh")

def create_parser():
    parser = argparse.ArgumentParser()
    parser.add_argument('--env', default='.env.yml', dest='env_path',
                        help="Environment file with GitHub token and Jenkins username and token. "
                             "Check the README.md file to know what to put in the file")
    parser.add_argument("--owner", default="ComplianceAsCode")
    parser.add_argument("--repo", default="content")
    subparsers = parser.add_subparsers(dest="subparser_name",
                                       help="Subcommands: check")
    subparsers.required = True

    check_parser = subparsers.add_parser("check")
    check_parser.set_defaults(func=check_release)

    return parser.parse_args()


if __name__ == "__main__":
    parser = create_parser()

    try:
        env = load_env(parser.env_path)
        if not validate_env(env, parser.env_path):
            sys.exit(1)
    except FileNotFoundError as e:
        print("Create a .env.yaml file and populate it. Check the README.md file for details.")
        sys.exit(1)

    version_dict = parse_version('../CMakeLists.txt')
    parser.version = get_version_string(version_dict)

    jenkins_ci = JenkinsCI(username=env['jenkins_user'], password=env['jenkins_token'])

    parser.func(env, jenkins_ci, parser)
