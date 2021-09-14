import argparse
import git
import github
import os
import re
import yaml
import subprocess
import sys

import content_gh


def load_env(env_path):
    with open(env_path, 'r') as env_stream:
        env = yaml.safe_load(env_stream)
    return env


def validate_env(env, env_path):
    env_ok = True
    mandatory_fields = ['github_token']
    for field in mandatory_fields:
        if field not in env:
            print(f"Add your {field} in {env_path} file. "
                  "Check the README.md for how to obtain it.")
            env_ok = True
    return env_ok


def parse_version(cmakelists_path):
    regex = re.compile(r'set\(SSG_(.*)_VERSION (\d+)\)')

    with open(cmakelists_path, 'r') as cmakelists_stream:
        cmakelists_content = cmakelists_stream.read()

        matches = re.findall(regex, cmakelists_content)
    version = {v_name.lower(): v_value for v_name, v_value in matches}
    return version


def get_version_string(d):
    return f"{d['major']}.{d['minor']}.{d['patch']}"


def get_next_version_string(d):
    d['patch'] = int(d['patch']) + 1
    return get_version_string(d)


def get_gh_repo(env, args):
    gh = github.Github(env['github_token'])
    gh_repo = content_gh.get_repo(gh, args.owner, args.repo)

    return gh_repo


def move_milestone(env, args):
    gh_repo = get_gh_repo(env, args)
    content_gh.move_milestone(gh_repo, args)


def prep_next_release(env, args):
    print(f"Creating commit for version bump")
    local_repo = git.Repo('../')

    bump_branch = local_repo.create_head(
        'bump_version_{0}'.format(args.next_version), local_repo.heads.master
    )
    local_repo.head.reference = bump_branch
    # reset the index and working tree to match the pointed-to commit
    local_repo.head.reset(index=True, working_tree=True)

    # Call script that bumps version in CMakeLists.txt
    subprocess.call(["./bump_release_in_cmake.sh", f"{args.next_version}"])

    index = local_repo.index
    cmakelists_path = os.path.join(local_repo.working_tree_dir, 'CMakeLists.txt')
    index.add([cmakelists_path])
    index.commit(f"Bump version to {args.next_version}")

    print(":: Push to your fork and make a PR to bump the version")


def create_parser():
    parser = argparse.ArgumentParser()
    parser.add_argument('--env', default='.env.yml', dest='env_path',
                        help="File with GitHub token. "
                             "Check the README.md file to know what to put in the file")
    parser.add_argument("--owner", default="ComplianceAsCode")
    parser.add_argument("--repo", default="content")
    subparsers = parser.add_subparsers(dest="subparser_name",
                                       help="Subcommands: move_milestone, prep_next_release")
    subparsers.required = True

    build_parser = subparsers.add_parser("move_milestone")
    build_parser.set_defaults(func=move_milestone)
    build_parser = subparsers.add_parser("prep_next_release")
    build_parser.set_defaults(func=prep_next_release)

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
    parser.next_version = get_next_version_string(version_dict)

    parser.func(env, parser)
