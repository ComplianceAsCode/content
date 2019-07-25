#!/usr/bin/env python3

import argparse
import github
import sys


def version_type(string):
    components = string.split(".")
    shortest_component_len = min([len(x) for x in components])
    if len(components) != 3 or shortest_component_len == 0:
        msg = (
            "Expected version number of form X.Y.Z, where X, Y, Z are strings. "
            f"Got: '{string}'"
        )
        raise argparse.ArgumentTypeError(msg)
    return string

def get_repo(gh, owner, repo_name):
    try:
        repo = gh.get_repo(f"{owner}/{repo_name}")
        # By accessing a repo attribute. the PyGithub will actually query for the repo
        assert repo_name == repo.name
        return repo
    except github.UnknownObjectException:
        print(f"Repo '{owner}/{repo_name}' not found")
        sys.exit(0)


def check_release(repo, args):
    version = args.version
    try:
        latest_release = repo.get_latest_release()
        if latest_release.tag_name == f"v{version}":
            print(f"Release v{version} already exists")
            sys.exit(1)
    except github.UnknownObjectException:
        print(f"Release v{version} doesn't exist, good to go")
        sys.exit(0)

def create_parser():
    parser = argparse.ArgumentParser()
    parser.add_argument("--owner",default="ComplianceAscode")
    parser.add_argument("--repo", default="content")
    parser.add_argument("auth_token")
    parser.add_argument("version", type=version_type)
    subparsers = parser.add_subparsers(dest="subparser_name",
                                       help="Subcommands: check")
    subparsers.required = True

    check_parser = subparsers.add_parser("check")
    check_parser.set_defaults(func=check_release)

    return parser.parse_args()


if __name__ == "__main__":
    parser = create_parser()

    gh = github.Github(parser.auth_token)
    repo = get_repo(gh, parser.owner, parser.repo)

    parser.func(repo, parser)
