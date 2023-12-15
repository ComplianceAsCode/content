#!/usr/bin/python3
# -*- coding: utf-8 -*-

"""
Script created to help maintainers during the release process by automating Github tasks.
"""

# References:
# - https://developer.github.com/v3/libraries/
# - https://github.com/PyGithub/PyGithub
# - https://pygithub.readthedocs.io/en/latest/github_objects.html
# - https://docs.github.com/en/rest

from datetime import datetime, timedelta
from github import Github
import argparse
import configparser
import os.path
import re
import subprocess


def get_parameter_from_ini(config_file, section, parameter) -> str:
    config = configparser.ConfigParser()
    try:
        config.read(config_file)
        return config[section][parameter]
    except Exception as e:
        print(f'Error: {e} entry was not found!')


def create_ini_file_template(creds_file):
    try:
        new_creds_file = os.path.expanduser(creds_file)
        with open(new_creds_file, mode='w', encoding='utf-8') as file:
            file.write(
                '[DEFAULT]\n'
                'github_token = <generate your token in https://github.com/settings/tokens>\n')
        print(f'Great! {new_creds_file} was created! Edit it to include your personal token.')
    except Exception as e:
        print(f'Error: {e}')


def get_github_token(creds_file) -> str:
    creds_file = os.path.expanduser(creds_file)
    if os.path.exists(creds_file):
        return get_parameter_from_ini(creds_file, "DEFAULT", "github_token")
    else:
        print(f'{creds_file} file was not found!')
        if get_confirmation(f'Would you like to create the "{creds_file}" file?'):
            create_ini_file_template(creds_file)


def create_github_session(creds_file) -> object:
    token = get_github_token(creds_file)
    if not token:
        print('WARNING: No token found. The API queries are very limited without a token.\n')
    return Github(token)


def get_confirmation(question) -> bool:
    answer = str(input(f'{question} (Y/N): ')).lower().strip()
    return answer[:1] == 'y'


def get_repo_object(session, repo_id) -> object:
    return session.get_repo(repo_id)


def get_repo_root_path() -> str:
    root_path = get_script_path()
    return os.path.dirname(root_path)


def get_script_path() -> str:
    return os.path.dirname(os.path.realpath(__file__))


def show_git_diff():
    subprocess.run(['git', 'diff'], cwd=get_repo_root_path())
    print('\nPlease, review the changes and propose a PR to "master" branch.')


# Repository Branches
def filter_repo_branch_by_name(branches, name) -> object:
    return [branch for branch in branches if branch.name == name]


def get_repo_branches(repo) -> list:
    return repo.get_branches()


def get_repo_stable_branch(repo) -> object:
    branches = get_repo_branches(repo)
    return filter_repo_branch_by_name(branches, "stable")


def get_old_stabilization_branch(repo) -> object:
    branches = get_repo_branches(repo)
    latest_version = get_latest_version(repo)
    branch_name = f'stabilization-v{latest_version}'
    return filter_repo_branch_by_name(branches, branch_name)


def remove_old_stabilization_branch(repo, branch) -> None:
    if get_confirmation(f'Are you sure about removing the "{branch.name}" branch?'):
        # https://github.com/PyGithub/PyGithub/issues/1570
        try:
            branch_ref = repo.get_git_ref(f'heads/{branch.name}')
            branch_ref.delete()
        except Exception as e:
            print(f'Error: {e}')
    else:
        print(f'Aborted! {branch.name} branch not removed.')


# Repository Contributors
def get_contributors_commit_diff(commit) -> str:
    commit_diff = subprocess.run(
        ['git', 'show', '--word-diff', commit, 'Contributors.md'],
        capture_output=True, text=True, cwd=get_repo_root_path())
    return commit_diff.stdout


def get_contributors_last_commit() -> str:
    last_commit = subprocess.run(
        ['git', 'log', '--pretty=format:%h', '-1', '--', 'Contributors.md'],
        capture_output=True, text=True, cwd=get_repo_root_path())
    return last_commit.stdout


def get_contributors_last_update() -> str:
    last_commit = get_contributors_last_commit()
    last_commit_diff = get_contributors_commit_diff(last_commit)

    for line in last_commit_diff.split('\n'):
        # The "generate_contributors.py" creates a commend in the beginning of the file.
        # This comment informs when the file was updated.
        if 'Last Modified:' in line:
            elements = line.split('{+')
            datetime = elements[1].replace('+}', '')
            return datetime


def get_new_contributors(commit) -> str:
    last_commit_diff = get_contributors_commit_diff(commit)
    new_contributors = []

    for line in last_commit_diff.split('\n'):
        if line.startswith('{+'):
            for chars in ['{+', '+}']:
                line = line.replace(chars, '')
            new_contributors.append(line)
    return '\n'.join(new_contributors)


def is_contributors_list_updated(date_string) -> bool:
    date = datetime.strptime(date_string[:16], '%Y-%m-%d %H:%M')
    # As a rule of thumbs, this function consider contributors list
    # updated if not older than 2 weeks.
    two_weeks_back = datetime.now() - timedelta(days=15)
    if date < two_weeks_back:
        return False
    return True


def update_contributors():
    last_update = get_contributors_last_update()
    # Currently, this script considers contributors lists is already updated if not
    # older than 2 weeks.
    if is_contributors_list_updated(last_update):
        print(f'It is all fine, the contributors list was updated in {last_update}')
    else:
        print(f'Contributors list last update was in {last_update}. I can update it for you.')
        utils_scripts_path = get_script_path()
        contributors_script = os.path.join(utils_scripts_path, 'generate_contributors.py')
        subprocess.run(
            [f'PYTHONPATH=. {contributors_script}'], shell=True, cwd=get_repo_root_path())
        show_git_diff()


# Repository Milestones
def has_milestone_version_format(milestone) -> bool:
    regex = re.compile(r'\d\.\d\.\d')
    return regex.match(milestone.title)


def filter_version_milestones(milestones) -> list:
    version_milestones = []
    for milestone in milestones:
        if has_milestone_version_format(milestone):
            version_milestones.append(milestone)
    return version_milestones


def get_repo_milestones(repo) -> list:
    return repo.get_milestones(state="all", direction="desc")


def get_latest_version_milestone(repo) -> object:
    milestones = get_repo_milestones(repo)
    version_milestones = filter_version_milestones(milestones)
    latest_version_milestone = version_milestones[0]
    # It is not ensured the returned milestones list is ordered as expected.
    # This function ensures the last milestone based on titles.
    for milestone in version_milestones:
        if milestone.title > latest_version_milestone.title:
            latest_version_milestone = milestone
    return latest_version_milestone


def get_version_milestone(repo, version) -> object:
    milestones = get_repo_milestones(repo)
    version_milestones = filter_version_milestones(milestones)
    for milestone in version_milestones:
        if milestone.title == version:
            return milestone


def close_milestone(milestone) -> None:
    if milestone.state == "closed":
        print(f'Nice. The "{milestone}" milestone is already closed.')
        return

    if get_confirmation(f'The "{milestone}" milestone should be closed. Ok?'):
        try:
            milestone.edit(milestone.title, state="closed")
        except Exception as e:
            print(f'Error: {e}')
            exit(1)
    else:
        print(f'Aborted! {milestone} milestone not closed.')


def create_repo_milestone(repo, name) -> None:
    if get_version_milestone(repo, name):
        print(f'Great! The "{name}" milestone is already created.')
        return

    latest_release = get_latest_release(repo)
    estimated_release_date = get_next_release_date(latest_release.published_at)
    if get_confirmation(f'Are you sure about creating the "{name}" milestone?'):
        try:
            repo.create_milestone(
                title=name, description=f'Milestone for the release {name}',
                due_on=estimated_release_date)
        except Exception as e:
            print(f'Error: {e}')
            exit(1)
    else:
        print(f'Aborted! {name} milestone not created.')


# Repository Releases
def get_repo_releases(repo) -> list:
    return repo.get_releases()


def get_latest_release(repo) -> object:
    releases = get_repo_releases(repo)
    # The API returns the list already ordered by published date.
    return releases[0]


# Repository Versions
def extract_version_from_tag_name(version) -> str:
    return version.split("v")[1]


def get_latest_version(repo) -> str:
    release = get_latest_release(repo)
    return extract_version_from_tag_name(release.tag_name)


# Repository Next Release
def bump_version(current_version, bump_position) -> str:
    # version format example: 0.1.64
    if bump_position == 'minor':
        position = 2
    elif bump_position == 'major':
        position = 1
    else:
        position = 0

    split_version = current_version.split('.')
    bumped = int(split_version[position]) + 1
    split_version[position] = str(bumped)
    return ".".join(split_version)


def bump_master_version(repo):
    content_changed = False
    old_version = get_next_release_version(repo)
    new_version = bump_version(old_version, 'minor')
    old_minor_version = old_version.split('.')[2]
    new_minor_version = new_version.split('.')[2]
    repo_root = get_repo_root_path()
    with open(os.path.join(repo_root, "CMakeLists.txt"), mode='r', encoding='utf-8') as file:
        content = file.readlines()

    for ln, line in enumerate(content):
        if f'set(SSG_PATCH_VERSION {old_minor_version}' in line:
            content[ln] = content[ln].replace(old_minor_version, new_minor_version)
            content_changed = True

    if content_changed:
        with open(os.path.join(repo_root, "CMakeLists.txt"), mode='w', encoding='utf-8') as file:
            file.writelines(content)
        show_git_diff()
    else:
        print('Great! The version in CMakeLists.txt file is already updated.')


def describe_next_release_state(repo) -> str:
    if is_next_release_in_progress(repo):
        return 'In Stabilization Phase'
    else:
        return 'Scheduled'


def get_friday_that_follows(date) -> datetime:
    return date + timedelta((4 - date.weekday()) % 7)


def get_monday_that_follows(date) -> datetime:
    return date + timedelta((0 - date.weekday()) % 7)


def get_next_stabilization_date(release_date) -> datetime:
    two_weeks_before = release_date - timedelta(weeks=2)
    stabilization_monday = get_monday_that_follows(two_weeks_before)
    return stabilization_monday.date()


def get_next_release_date(latest_release_date) -> datetime:
    two_months_ahead = latest_release_date + timedelta(days=60)
    return get_friday_that_follows(two_months_ahead)


def is_next_release_in_progress(repo) -> bool:
    stabilization_branch = get_next_stabilization_branch(repo)
    branches_names = [branch.name for branch in get_repo_branches(repo)]
    if stabilization_branch in branches_names:
        return True
    else:
        return False


def get_next_release_version(repo) -> str:
    current_version = get_latest_version(repo)
    next_version = bump_version(current_version, 'minor')
    return next_version


def get_next_stabilization_branch(repo) -> str:
    next_release = get_next_release_version(repo)
    return f'stabilization-v{next_release}'


# Communication
def get_date_for_message(date) -> datetime:
    return date.strftime("%B %d, %Y")


def get_release_highlights(release) -> str:
    highlights = []
    for line in release.body.split('\r\n'):
        if '### Important Highlights' in line:
            continue
        if '###' in line:
            break
        if line:
            highlights.append(line)
    return '\n'.join(highlights)


def get_release_start_message(repo) -> str:
    latest_release = get_latest_release(repo)
    next_release_version = get_next_release_version(repo)
    next_release_date = get_next_release_date(latest_release.published_at)
    date = get_date_for_message(next_release_date)
    branch = get_next_stabilization_branch(repo)

    future_version = bump_version(next_release_version, 'minor')
    future_release_date = get_next_release_date(next_release_date)
    future_date = get_date_for_message(future_release_date)
    future_stabilization_date = get_next_stabilization_date(future_release_date)
    future_date_stabilization = get_date_for_message(future_stabilization_date)

    template = f'''
        Subject: stabilization of v{next_release_version}

        Hello all,

        The release of Content version {next_release_version} is scheduled for {date}.
        As part of the release process, a stabilization branch was created.
        Issues and PRs that were not solved were moved to the {future_version} milestone.

        Any bug fixes you would like to include in release {next_release_version} should be
        proposed for the *{branch}* and *master* branches as a measure to avoid
        potential conflicts between these branches.

        The next version, {future_version}, is scheduled to be released on {future_date},
        with the stabilization phase starting on {future_date_stabilization}.

        Regards,'''
    return template


def get_release_end_message(repo) -> str:
    latest_release = get_latest_release(repo)
    latest_release_url = latest_release.html_url
    highlights = get_release_highlights(latest_release)
    last_commit = get_contributors_last_commit()
    new_contributors = get_new_contributors(last_commit)
    released_version = get_latest_version(repo)

    for asset in latest_release.get_assets():
        if asset.content_type == 'application/x-bzip2':
            source_tarball = asset.browser_download_url
        elif asset.content_type == 'application/zip':
            prebuild_zip = asset.browser_download_url
        elif '.tar.bz2.sha512' in asset.name:
            source_tarball_hash = asset.browser_download_url
        else:
            prebuild_zip_hash = asset.browser_download_url

    # It would be more readable if this multiline string would be indented. However, this makes
    # the final text weird, after the "format" substitutions, when highlights and new_contributors
    # have multilines too. So, the readability was compromised in favor of simplicity and user
    # experience. The user only needs to copy and paste, without removing leading spaces.
    template = f'''
Subject: ComplianceAsCode/content v{released_version}

Hello all,

ComplianceAsCode/Content v{released_version} is out.

Some of the highlights of this release are:
{highlights}

Welcome to the new contributors:
{new_contributors}

For full release notes, please have a look at:
{latest_release_url}

Pre-built content: {prebuild_zip}
SHA-512 hash: {prebuild_zip_hash}

Source tarball: {source_tarball}
SHA-512 hash: {source_tarball_hash}

Thank you to everyone who contributed!

Regards,'''
    return template


def print_communication_channels(phase='release') -> None:
    gitter_lnk = 'https://gitter.im/Compliance-As-Code-The/content'
    ghd_lnk = 'https://github.com/ComplianceAsCode/content/discussions/new?category=announcements'
    twitter_lnk = 'https://twitter.com/openscap'
    ssg_mail = 'scap-security-guide@lists.fedorahosted.org'
    openscap_mail = 'open-scap-list@redhat.com'

    print('Please, share the following message in:\n'
          f'* Gitter ({gitter_lnk})\n'
          f'* Github Discussion ({ghd_lnk})\n'
          f'* SCAP Security Guide Mail List ({ssg_mail})')

    if phase == "finish":
        print(f'* OpenSCAP Mail List ({openscap_mail})\n'
              f'* Twitter ({twitter_lnk})')


# Issues and PRs
def filter_items_outdated_milestone(objects_list, milestone) -> list:
    items_old_milestone = []
    for item in objects_list:
        if has_milestone_version_format(item.milestone) and \
                item.milestone.title != milestone.title:
            items_old_milestone.append(item)
    return items_old_milestone


def show_outdated_items(items_to_update):
    count = len(items_to_update)
    print(f'{count} open issues have an outdated milestone. Here are their links:')
    for item in items_to_update:
        print(f'{item.number:5} - {item.html_url:65} - {item.milestone.title} - {item.title}')


def filter_outdated_items(repo, objects_list) -> list:
    latest_milestone = get_latest_version_milestone(repo)
    items_to_update = filter_items_outdated_milestone(objects_list, latest_milestone)
    print('INFO: Please, note that in Github API the Pull Requests are also Issues objects but '
          'with some few differences in properties.')
    if items_to_update:
        show_outdated_items(items_to_update)
        if get_confirmation(
                'Are you sure about updating the milestone in these open issues?'):
            return items_to_update
        else:
            print('Aborted! Milestones not updated in open issues.')
    else:
        print('Great! There is no open issue with an outdated milestone.')
        return []


def get_items_with_milestone(object_list) -> list:
    with_milestone = []
    for item in object_list:
        if item.milestone:
            with_milestone.append(item)
    return with_milestone


def get_open_issues_with_milestone(repo) -> list:
    open_issues = repo.get_issues(state='open', direction='asc')
    return get_items_with_milestone(open_issues)


def get_open_prs_with_milestone(repo) -> list:
    open_prs = repo.get_pulls(state='open', direction='asc')
    return get_items_with_milestone(open_prs)


def update_milestone(repo, object_list) -> None:
    milestone = get_latest_version_milestone(repo)
    for item in object_list:
        try:
            item.edit(milestone=milestone)
        except Exception as e:
            print(f'Error: {e}')


def update_milestone_in_issues(repo, issues_list) -> None:
    outdate_issues = filter_outdated_items(repo, issues_list)
    if outdate_issues:
        update_milestone(repo, outdate_issues)


# Repo Stats
def collect_release_info(repo) -> dict:
    data = dict()
    latest_release = get_latest_release(repo)
    data["latest_release_created"] = latest_release.created_at
    data["latest_release_published"] = latest_release.published_at
    data["latest_release_url"] = latest_release.html_url
    data["latest_version"] = get_latest_version(repo)

    next_release_date = get_next_release_date(latest_release.published_at)
    next_release_remaining_days = next_release_date - datetime.today()
    data["next_release_date"] = next_release_date
    data["next_release_remaining_days"] = next_release_remaining_days.days
    data["next_release_state"] = describe_next_release_state(repo)
    data["next_release_version"] = get_next_release_version(repo)
    next_stabilization_date = get_next_stabilization_date(next_release_date)
    next_stabilization_remaining_days = next_stabilization_date - datetime.today().date()
    data["next_stabilization_date"] = next_stabilization_date
    data["next_stabilization_remaining_days"] = next_stabilization_remaining_days.days

    previous_milestone = get_version_milestone(repo, data["latest_version"])
    data["previous_milestone"] = previous_milestone.title
    data["previous_milestone_closed_issues"] = previous_milestone.closed_issues
    data["previous_milestone_open_issues"] = previous_milestone.open_issues
    data["previous_milestone_total_issues"] = data["previous_milestone_closed_issues"]\
        + data["previous_milestone_open_issues"]

    active_milestone = get_latest_version_milestone(repo)
    data["active_milestone"] = active_milestone.title
    data["active_milestone_closed_issues"] = active_milestone.closed_issues
    data["active_milestone_open_issues"] = active_milestone.open_issues
    data["active_milestone_total_issues"] = data["active_milestone_closed_issues"]\
        + data["active_milestone_open_issues"]
    return data


def print_specific_stat(status, current, total) -> None:
    if current > 0:
        percent = round((current / total) * 100.00, 2)
        print(f'{status:23.23} {current} / {total} = {percent}%')


def print_last_release_stats(data):
    version = data['latest_version']
    created_at = data['latest_release_created']
    published_at = data['latest_release_published']
    url_download = data['latest_release_url']
    closed_issues = data["previous_milestone_closed_issues"]
    total_issues = data["previous_milestone_total_issues"]

    print('Information based on the latest published release:')
    print(f'Current Version:        {version}')
    print(f'Created at:             {created_at}')
    print(f'Published at:           {published_at}')
    print(f'Release Notes:          {url_download}')
    print_specific_stat("Closed Issues/PRs:", closed_issues, total_issues)


def print_next_release_stats(data):
    now = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    milestone = data['active_milestone']
    next_release_version = data['next_release_version']
    next_release_date = data['next_release_date']
    next_release_days = data['next_release_remaining_days']
    next_release_state = data['next_release_state']
    next_stab_date = data['next_stabilization_date']
    next_stab_days = data['next_stabilization_remaining_days']
    closed_issues = data["active_milestone_closed_issues"]
    total_issues = data["active_milestone_total_issues"]

    print(f'\nNext release information in {now}:')
    print(f'Next Version:           {next_release_version}')
    print(f'Current State:          {next_release_state}')
    print(f'Estimated Release Date: {next_release_date} ({next_release_days} remaining days)')
    print(f'Stabilization Date:     {next_stab_date} ({next_stab_days} remaining days)')
    print(f'Working Milestone:      {milestone}')

    print_specific_stat("Closed Issues/PRs:", closed_issues, total_issues)


# Functions to specific phases of the process
def stats(repo, args):
    try:
        rel_data = collect_release_info(repo)
        print_last_release_stats(rel_data)
        print_next_release_stats(rel_data)
    except Exception as e:
        print(f'Error: {e}')


def cleanup(repo, args) -> None:
    if args.branch:
        branches_to_remove = get_old_stabilization_branch(repo)
        if branches_to_remove:
            for branch in branches_to_remove:
                remove_old_stabilization_branch(repo, branch)
        else:
            print('Great! There is no branch to be removed.')


def release_prep(repo, args) -> None:
    if args.contributors:
        update_contributors()

    stab_branch_name = get_next_stabilization_branch(repo)
    if args.branch:
        print('git checkout master\n'
              'git pull upstream master\n'
              f'git checkout -b {stab_branch_name}\n'
              f'git push -u upstream {stab_branch_name}')

    if args.milestone:
        if is_next_release_in_progress(repo):
            stab_milestone = get_latest_version_milestone(repo)
            next_release_version = get_next_release_version(repo)
            new_milestone = bump_version(next_release_version, 'minor')
            close_milestone(stab_milestone)
            create_repo_milestone(repo, new_milestone)
        else:
            print(f'Milestones can be managed after the "{stab_branch_name}" branch is created.')

    if args.issues:
        issues_list = get_open_issues_with_milestone(repo)
        update_milestone_in_issues(repo, issues_list)

    if args.bump_version:
        bump_master_version(repo)


def release(repo, args) -> None:
    if is_next_release_in_progress(repo):
        if args.tag:
            next_version = get_next_release_version(repo)
            tag_name = f'v{next_version}'
            stab_branch = get_next_stabilization_branch(repo)
            print('Release process starts when a version tag is added to the branch.\n'
                  'It is better to do it manually. But here are the commands you need:\n')
            print(f'git tag {tag_name} {stab_branch}\n'
                  'git push --tags')

        if args.message:
            message = get_release_start_message(repo)
            print_communication_channels('release')
            print(message)
    else:
        print('Please, ensure that all steps in the Release Preparation are concluded.')


def finish(repo, args) -> None:
    if not is_next_release_in_progress(repo):
        if args.message:
            message = get_release_end_message(repo)
            print_communication_channels('finish')
            print(message)
    else:
        print('Please, ensure that all steps in the Release process are concluded.')


def parse_arguments():
    '''Call argparse to process input parameters and return parsed args'''
    parser = argparse.ArgumentParser(
        description="Automate Github tasks included in the Release Process.",
        epilog="Example: release_helper.py -c ~/secrets.ini -r ComplianceAsCode/content stats",
        formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    parser.add_argument(
        '-c', '--creds-file', default='~/secrets.ini',
        help="INI file containing Github token.")
    parser.add_argument(
        '-r', '--repository', action='store', default='ComplianceAsCode/content',
        help="Project repository name.")

    subparsers = parser.add_subparsers(dest='subcmd', required=True)
    subparsers.add_parser(
        'stats', help="Return information about the repository current state.")

    cleanup_parser = subparsers.add_parser(
        'cleanup', help="Cleanup after completing a release.")
    cleanup_parser.add_argument(
        '-b', '--branch', action='store_true',
        help="Remove temporary branch used during stabilization phase.")

    release_prep_parser = subparsers.add_parser(
        'release_prep', help="Prepare the repository for the next release.")
    release_prep_parser.add_argument(
        '-c', '--contributors', action='store_true',
        help="Update the contributors lists. Do it before creating the stabilization branch.")
    release_prep_parser.add_argument(
        '-b', '--branch', action='store_true',
        help="Create the stabilization branch for the next release.")
    release_prep_parser.add_argument(
        '-m', '--milestone', action='store_true',
        help="Create the next milestone and close the current milestone.")
    release_prep_parser.add_argument(
        '-i', '--issues', action='store_true',
        help="Move Open Issues and PRs with a milestone to the next milestone.")
    release_prep_parser.add_argument(
        '-v', '--bump-version', action='store_true',
        help="Bump the project version in *master* branch.")

    release_parser = subparsers.add_parser(
        'release', help="Tasks to be done during the stabilization phase.")
    release_parser.add_argument(
        '-m', '--message', action='store_true',
        help="Prepare a message to communicate the stabilization process has started.")
    release_parser.add_argument(
        '-t', '--tag', action='store_true',
        help="Show commands to properly tag the branch and start the release.")

    finish_parser = subparsers.add_parser(
        'finish', help="Tasks to be done when the release is out.")
    finish_parser.add_argument(
        '-m', '--message', action='store_true',
        help="Prepare a message to communicate the release is out.")
    return parser.parse_args()


def main():
    subcmds = dict(
        stats=stats,
        cleanup=cleanup,
        release_prep=release_prep,
        release=release,
        finish=finish)

    args = parse_arguments()

    try:
        ghs = create_github_session(args.creds_file)
        repo = get_repo_object(ghs, args.repository)
    except Exception as e:
        print(f'Error when getting the repository {args.repository}: {e}')
        exit(1)

    subcmds[args.subcmd](repo, args)


if __name__ == "__main__":
    main()
