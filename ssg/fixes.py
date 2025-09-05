"""
Common functions for processing Fixes in SSG
"""

from __future__ import absolute_import
from __future__ import print_function

import os

from .build_remediations import parse_from_file_without_jinja
from .utils import read_file_list, parse_platform

from .build_remediations import REMEDIATION_TO_EXT_MAP as REMEDIATION_MAP


def get_fix_path(rule_obj, lang, fix_id):
    """
    Return the full path to the fix for the given language and fix_id in the rule described by rule_obj.

    Args:
        rule_obj (dict): A dictionary containing information about the rule, including dir', 'id',
                         and 'remediations'.
        lang (str): The language for which the fix is required.
        fix_id (str): The identifier for the specific fix.

    Returns:
        str: The full path to the fix file.

    Raises:
        ValueError: If the rule_obj is malformed or if the fix_id is unknown for the given rule_id
                    and language.
    """
    if not fix_id.endswith(REMEDIATION_MAP[lang]):
        fix_id += REMEDIATION_MAP[lang]

    if ('dir' not in rule_obj or 'id' not in rule_obj or
        'remediations' not in rule_obj or lang not in rule_obj['remediations']):
        raise ValueError("Malformed rule_obj")

    if fix_id not in rule_obj['remediations'][lang]:
        raise ValueError("Unknown fix_id:%s for rule_id:%s and lang:%s" %
                         (fix_id, rule_obj['id'], lang))

    return os.path.join(rule_obj['dir'], lang, fix_id)


def get_fix_contents(rule_obj, lang, fix_id):
    """
    Retrieve the path and contents of a specific fix.

    Args:
        rule_obj (object): The rule object containing the fix information.
        lang (str): The language of the fix.
        fix_id (str): The identifier of the fix.

    Returns:
        tuple: A tuple containing the path to the fix and the contents of the fix.
    """
    fix_path = get_fix_path(rule_obj, lang, fix_id)
    fix_contents = read_file_list(fix_path)

    return fix_path, fix_contents


def applicable_platforms(fix_path):
    """
    Determines the applicable platforms for a given fix.

    Args:
        fix_path (str): The file path to the fix configuration file.

    Returns:
        list: A list of platforms that the fix applies to.

    Raises:
        ValueError: If the fix configuration is malformed or missing the 'platform' key.
    """
    _, config = parse_from_file_without_jinja(fix_path)

    if 'platform' not in config:
        raise ValueError("Malformed fix: missing platform" % fix_path)

    return parse_platform(config['platform'])


def find_platform_line(fix_contents):
    """
    Parses the fix content to determine the line number that the platforms configuration option is on.

    Note:
        If the configuration specification changes, please update the corresponding parsing in
        ssg.build_remediations.parse_from_file_with_jinja(...).

    Args:
        fix_contents (list of str): The contents of the configuration file as a list of strings.

    Returns:
        int or None: The line number of the platform configuration option, or None if not found.
    """
    matched_line = None
    for line_num in range(0, len(fix_contents)):
        line = fix_contents[line_num]
        if line.startswith('#') and '=' in line:
            key, value = line.strip('#').split('=', 1)
            if key.strip() == 'platform':
                matched_line = line_num

    return matched_line

def set_applicable_platforms(fix_contents, new_platforms):
    """
    Modifies the given fix contents to update the platforms to the new platforms.

    Args:
        fix_contents (list of str): The contents of the fix file as a list of strings.
        new_platforms (list of str): A list of new platforms to set in the fix file.

    Returns:
        list of str: The modified contents with the updated platforms.

    Raises:
        ValueError: If the platform line cannot be found in the fix contents.
    """
    platform_line = find_platform_line(fix_contents)
    if platform_line is None:
        raise ValueError("When parsing config file, unable to find platform "
                         "line!\n\n%s" % "\n".join(fix_contents))

    new_platforms_str = "# platform = " + ",".join(sorted(new_platforms))

    new_contents = fix_contents[0:platform_line]
    new_contents.extend([new_platforms_str])
    new_contents.extend(fix_contents[platform_line+1:])

    return new_contents
