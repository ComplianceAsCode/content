"""
Common functions for processing Contributors in SSG
"""

from __future__ import absolute_import
from __future__ import print_function

import collections
import datetime
import re
import os.path

from .shims import subprocess_check_output


MANUAL_EDIT_WARNING = """This file is generated using the %s script. DO NOT MANUALLY EDIT!!!!
Last Modified: %s UTC
""" % (os.path.basename(__file__), datetime.datetime.utcnow().strftime("%Y-%m-%d %H:%M"))

ignored_emails = (
    # No idea / ignore
    "lyd@chippy.(none)",
    "nick@null.net",
    "root@localhost.localdomain",
    "root@rhel6.(none)",
    "root@ip-10-0-8-36.ec2.internal",
    "badger@gitter.im",
    "46447321+allcontributors[bot]@users.noreply.github.com",
    "konflux@no-reply.konflux-ci.dev",
    "126015336+red-hat-konflux[bot]@users.noreply.github.com",
)


def _get_contributions_by_canonical_email(output):
    """
    Parses the given output to extract contributions by canonical email.

    Args:
        output (str): The string output containing contribution details. Each line should be in the format:
                      "<commits_count> <author_name> <email>".

    Returns:
        dict: A dictionary where the keys are email addresses and the values are lists of tuples. Each tuple contains
              the number of commits (int) and the author's name (str).

    Notes:
        - Lines that do not match the expected format are ignored.
        - Emails listed in the `ignored_emails` set are ignored.
    """
    contributions_by_email = collections.defaultdict(list)
    for line in output.split("\n"):
        match = re.match(r"[\s]*([0-9]+)\s+(.+)\s+\<(.+)\>", line)
        if match is None:
            continue

        commits_count, author_name, email = match.groups()

        if email in ignored_emails:
            continue  # ignored

        contributions_by_email[email].append((int(commits_count), author_name))
    return contributions_by_email


def _get_name_used_most_in_contributions(contribution_sets):
    """
    Determines the name that appears most frequently in the given contribution sets.

    Args:
        contribution_sets (list of tuples): A list where each tuple contains a count and a name.

    Returns:
        str: The name that is used most frequently in the contributions.
    """
    _, name_used_most = sorted(contribution_sets, reverse=True)[0]
    return name_used_most


def _get_contributor_email_mapping(contributions_by_email):
    """
    Generates a mapping of contributor names to their email addresses.

    Args:
        contributions_by_email (dict): A dictionary where the keys are email addresses
                                       and the values are lists of contributions associated
                                       with those email addresses.

    Returns:
        dict: A dictionary where the keys are the names used most frequently in the contributions
              and the values are the corresponding email addresses.
    """
    contributors = {}
    for email in contributions_by_email:
        name_used_most = _get_name_used_most_in_contributions(contributions_by_email[email])

        contributors[name_used_most] = email
    return contributors


def _names_sorted_by_last_name(names):
    """
    Sorts a list of names by their last names in ascending order.

    Args:
        names (list of str): A list of names where each name is a string.

    Returns:
        list of str: A list of names sorted by last name.
    """
    return sorted(names, key=lambda x: tuple(n.upper() for n in x.split(" "))[::-1])


def generate():
    """
    Generates a list of contributors in both Markdown and XML formats.

    This function retrieves the list of contributors from the 'git shortlog -se' command,
    processes the contributions by email, and maps them to contributor names.
    It then formats the contributors' information into Markdown and XML strings.

    Returns:
        tuple: A tuple containing two strings:
            - contributors_md (str): The contributors list in Markdown format.
            - contributors_xml (str): The contributors list in XML format.
    """
    output = subprocess_check_output(["git", "shortlog", "-se"]).decode("utf-8")
    contributions_by_email = _get_contributions_by_canonical_email(output)
    contributors = _get_contributor_email_mapping(contributions_by_email)

    contributors_md = "<!---%s--->\n\n" % MANUAL_EDIT_WARNING
    contributors_md += \
        "The following people have contributed to the SCAP Security Guide project\n"
    contributors_md += "(listed in alphabetical order):\n\n"

    contributors_xml = "<!--%s-->\n\n" % MANUAL_EDIT_WARNING
    contributors_xml += "<text>\n"

    for name in _names_sorted_by_last_name(list(contributors.keys())):
        email = contributors[name]
        contributors_md += "* %s <%s>\n" % (name, email)
        contributors_xml += "<contributor>%s &lt;%s&gt;</contributor>\n" % (name, email)

    contributors_xml += "</text>\n"

    return contributors_md, contributors_xml
