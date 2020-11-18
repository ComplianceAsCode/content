import argparse
import git
import github
import os
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


def get_jenkins_ci(env):
    return JenkinsCI(username=env['jenkins_user'], password=env['jenkins_token'])


def check_release(env, args):
    '''
    Check repo and project state for release
    '''

    gh_repo = get_gh_repo(env, args)
    release_exists = content_gh.check_release_exists(gh_repo, args)
    if release_exists:
        print(f"Version {args.version} was released already, "
              "bump the version in the CMakeLists.txt file before releasing.")
        return

    print("Checking Jenkins Jobs")
    jenkins_ci = get_jenkins_ci(env)
    jenkins_ci.check_all_green()

    # Run shell script that builds RHEL and checks for mising STIG IDS
    subprocess.call("./check_rhel_stig_ids.sh")


def build_release(env, args):
    '''
    Build assets for release
    '''
    # Jenkins build should be done from the stabilization branch
    build_parameters = [('GIT_BRANCH', f"stabilization-v{args.version}")]

    jenkins_ci = get_jenkins_ci(env)
    all_built = jenkins_ci.build_jobs_for_release(build_parameters)
    if all_built:
        print(":: You can continue to next step and generate the release notes, run "
              "'python3 release_content.py release_notes'")
    else:
        print("Builds are still running, wait for them to finish")


def generate_release_notes(env, args):
    '''
    Generate Release Notes
    '''

    gh_repo = get_gh_repo(env, args)
    content_gh.generate_release_notes(gh_repo, args)


def create_release(env, args):
    '''
    Create Release
    '''

    gh_repo = get_gh_repo(env, args)
    content_gh.move_milestone(gh_repo, args)

    jenkins_ci = get_jenkins_ci(env)
    jenkins_ci.download_release_artifacts(parser.version)

    print(f"Creating release for version {args.version}")
    local_repo = git.Repo('../')
    args.commit = local_repo.heads[f"stabilization-v{args.version}"].commit.hexsha
    content_gh.create_release(gh_repo, args)
    print(f":: Review Release {args.version} in GitHub and publish it.")


def prep_next_release(env, args):

    jenkins_ci = get_jenkins_ci(env)
    jenkins_ci.forget_release_builds()

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
                        help="File with GitHub token and Jenkins username and token. "
                             "Check the README.md file to know what to put in the file")
    parser.add_argument("--owner", default="ComplianceAsCode")
    parser.add_argument("--repo", default="content")
    subparsers = parser.add_subparsers(dest="subparser_name",
                                       help="Subcommands: check, build, release_notes, "
                                            "release, prep_next_release")
    subparsers.required = True

    check_parser = subparsers.add_parser("check")
    check_parser.set_defaults(func=check_release)

    build_parser = subparsers.add_parser("build")
    build_parser.set_defaults(func=build_release)

    build_parser = subparsers.add_parser("release_notes")
    build_parser.set_defaults(func=generate_release_notes)

    build_parser = subparsers.add_parser("release")
    build_parser.set_defaults(func=create_release)

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
