#!/usr/bin/env python3

import argparse
import collections
import github
import re
import sys

rn_file = "release_notes.txt"


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
             "nosection": 0}


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


def create_new_milestone(repo, name):
    try:
        print(f"Creating milestone {name}")
        return repo.create_milestone(name, "open")
    except github.GithubException as e:
        for error in e.data['errors']:
            if 'already_exists' in error['code']:
                print(f"Reusing already existing milestone {name}")
                return get_milestone(repo, name)
            else:
                print(f"Failed to create milesone {name}: {e.data['errors']}")
                sys.exit(1)


def transfer_open_issues_and_prs_to_new_milestone(repo, old_milestone, new_milestone):
    old_milestone_issues = repo.get_issues(milestone=old_milestone, state="open")

    n_issues = old_milestone_issues.totalCount
    # totalCount doesn't seem to work
    # print(f"Moving {n_issues} to new milesone")
    print(f"Moving issues to milestone {new_milestone.title}")
    for issue in old_milestone_issues:
        issue.edit(milestone=new_milestone)


def close_milestone(milestone):
    print(f"Closing milestone {milestone.title}")
    milestone.edit(milestone.title, state="closed")


def get_closed_prs(repo, milestone):
    closed_issues = repo.get_issues(milestone=milestone, state="closed", sort="updated")
    issues_with_prs = [i for i in closed_issues if i.pull_request is not None]
    merged_prs =
    [i.as_pull_request() for i in issues_with_prs if i.as_pull_request().merged is True]
    return merged_prs


def generate_release_notes(repo, args):
    milestone = get_milestone(repo, args.version)

    entry = ""
    release_notes = collections.defaultdict(list)
    product_profiles = collections.defaultdict(set)
    for pr in get_closed_prs(repo, milestone):
        pr_title = pr.title
        pr_number = str(pr.number)
        section = "nosection"

        changed_files = pr.get_files()
        for changed_file in changed_files:
            changed_filename = changed_file.filename

            # do not include files from tests folder
            # they are part of testing mechanisms
            if changed_filename.endswith(".profile") and "tests" not in changed_filename:
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
        hl_label = repo.get_label("Highlight")
        hl_prs = repo.get_issues(milestone=milestone, state="closed", labels=[hl_label])
        for pr in hl_prs:
            pr_title = pr.title
            pr_number = str(pr.number)
            rn.write(f"- {pr_title} (#{pr_number})\n")

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


def check_release_exists(repo, args):
    version = args.version
    try:
        latest_release = repo.get_latest_release()
        if latest_release.tag_name == f"v{version}":
            print(f"Release v{version} already exists")
            return True
    except github.UnknownObjectException:
        print(f"Release v{version} doesn't exist, good to go")
    return False


def move_milestone(repo, args):
    milestone = get_milestone(repo, args.version)
    next_milestone = create_new_milestone(repo, args.next_version)

    transfer_open_issues_and_prs_to_new_milestone(repo, milestone, next_milestone)
    close_milestone(milestone)


def upload_files(release, file_paths):

    for file_path in file_paths:
        try:
            asset = release.upload_asset(file_path)
            print(f"Uploaded {asset.name} to Release {release.tag_name}")
        except FileNotFoundError as e:
            print(f"Unable to find asset {file_path}")


def upload_assets(release, args):
    release = repo.get_latest_release()
    upload_files(args.files)


def create_release(repo, args):
    version = args.version
    commit = args.commit
    git_commit = repo.get_git_commit(commit)

    gtag = repo.create_git_tag(f"v{version}", f"v{version}", commit, "commit")
    with open(rn_file, "r") as rn:
        message = rn.read()

    # Create release in Draft state
    release = repo.create_git_release(f"v{version}", f"Content {version}", message,
                                      True, False, git_commit)
    assets = [f"artifacts/scap-security-guide-{version}.zip",
              f"artifacts/scap-security-guide-{version}-oval-510.zip",
              f"artifacts/scap-security-guide-{version}.tar.bz2"]

    upload_files(release, assets)


def create_parser():
    parser = argparse.ArgumentParser()
    parser.add_argument("--owner", default="ComplianceAscode")
    parser.add_argument("--repo", default="content")
    parser.add_argument("auth_token")
    parser.add_argument("version", type=version_type)
    subparsers = parser.add_subparsers(dest="subparser_name",
                                       help="Subcommands: check, move_milestone, rn, release")
    subparsers.required = True

    check_parser = subparsers.add_parser("check")
    check_parser.set_defaults(func=check_release_exists)

    milestone_parser = subparsers.add_parser("move_milestone")
    milestone_parser.set_defaults(func=move_milestone)
    milestone_parser.add_argument("next_version", type=version_type)

    rn_parser = subparsers.add_parser("rn")
    rn_parser.set_defaults(func=generate_release_notes)

    release = subparsers.add_parser("release")
    release.set_defaults(func=create_release)
    release.add_argument("commit")

    return parser.parse_args()


if __name__ == "__main__":
    parser = create_parser()

    gh = github.Github(parser.auth_token)
    repo = get_repo(gh, parser.owner, parser.repo)

    parser.func(repo, parser)
