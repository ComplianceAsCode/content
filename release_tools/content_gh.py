#!/usr/bin/env python3

import argparse
import collections
import github
import re
import sys

rn_file="release_notes.txt"

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

CHANGELOG = {"profiles": 1,
             "rules": 3,
             "tests": 2,
             "nosection":0,}

def get_repo(gh, owner, repo_name):
    try:
        repo = gh.get_repo(f"{owner}/{repo_name}")
        # By accessing a repo attribute. the PyGithub will actually query for the repo
        assert repo_name == repo.name
        return repo
    except github.UnknownObjectException:
        print(f"Repo '{owner}/{repo_name}' not found")
        sys.exit(0)

def get_milestone(repo, name):
    milestones = repo.get_milestones(state="all")
    matches = [m for m in milestones if m.title == name]
    assert len(matches) <= 1, \
        f"Expected to find at most one milestone {name}, found {len(matches)}"
    if len(matches) == 0:
        return None
    else:
        return matches[0]

def get_closed_prs(repo, milestone):
    issues_and_prs = repo.get_issues(milestone=milestone, state="closed", sort="updated")
    prs_only = [i for i in issues_and_prs if i.pull_request is not None]
    return prs_only


def generate_release_notes(repo, args):
    milestone = get_milestone(repo, args.version)

    entry = ""
    release_notes = collections.defaultdict(list)
    product_profiles = collections.defaultdict(set)
    for pr in get_closed_prs(repo, milestone):
        pr_title = pr.title
        pr_number = str(pr.number)
        pr_info = repo.get_pull(pr.number)
        section = "nosection"

        changed_files = pr_info.get_files()
        for changed_file in changed_files:
            changed_filename = changed_file.filename

            if ".profile" in changed_filename:
                # Track changes to product:profile
                profile_match = re.match(r"(\w+)/profiles/([\w-]+).profile", changed_filename)
                product, profile = profile_match.groups()
                product_profiles[product].add(profile)

                # A PR that changed .profile but not rule, check, remediation or tests,
                # go to Profiles section
                if CHANGELOG["profiles"] > CHANGELOG[section]:
                    section = "profiles"

            if "rule.yml" in changed_filename:
                # A PR that changed any rule.yml file will be in Rules section
                # Often, changes to infrastructure are done together with changes content
                    section = "rules"
            elif "tests/" in changed_filename:
                if CHANGELOG["tests"] > CHANGELOG[section]:
                    section = "tests"

        if section != "nosection":
            entry = f"- {pr_title} (#{pr_number})\n"
            release_notes[section].append(entry)

    with open(rn_file, "w") as rn:
        rn.write("### Highlights:\n")

        rn.write("### Profiles changed in this release:\n")
        for product in product_profiles:
            rn.write(f"- {product}: {', '.join(product_profiles[product])}\n")

        for section in CHANGELOG:
            if section == 'nosection':
                continue
            rn.write(f"### {section.capitalize()}:\n")
            for entry in release_notes[section]:
                rn.write(entry)
    print(f"Review release notes in '{rn_file}'")

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
                                       help="Subcommands: check, rn")
    subparsers.required = True

    check_parser = subparsers.add_parser("check")
    check_parser.set_defaults(func=check_release)

    rn_parser = subparsers.add_parser("rn")
    rn_parser.set_defaults(func=generate_release_notes)
    return parser.parse_args()


if __name__ == "__main__":
    parser = create_parser()

    gh = github.Github(parser.auth_token)
    repo = get_repo(gh, parser.owner, parser.repo)

    parser.func(repo, parser)
