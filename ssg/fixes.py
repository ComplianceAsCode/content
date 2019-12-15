from __future__ import absolute_import
from __future__ import print_function

import os
import re

from .build_remediations import parse_from_file_without_jinja
from .constants import XCCDF11_NS
from .rule_yaml import parse_prodtype
from .utils import read_file_list

from .build_remediations import REMEDIATION_TO_EXT_MAP as REMEDIATION_MAP


def get_fix_path(rule_obj, lang, fix_id):
    """
    For the given fix_id or product, return the full path to the fix of the
    given language in the rule described by the given rule_obj.
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
    Returns the tuple (path, contents) of the fix described by the given
    fix_id or product.
    """

    fix_path = get_fix_path(rule_obj, lang, fix_id)
    fix_contents = read_file_list(fix_path)

    return fix_path, fix_contents


def applicable_platforms(fix_path):
    _, config = parse_from_file_without_jinja(fix_path)

    if 'platform' not in config:
        raise ValueError("Malformed fix: missing platform" % fix_path)

    return parse_prodtype(config['platform'])


def parse_platform(fix_contents):
    """
    Parses the platform configuration item to determine the line number that
    the platforms configuration option is on. If this key is not found, None
    is returned instead.

    Note that this performs no validation on the contents of the file besides
    this and does not return the current value of the platform.

    If the configuration specification changes any, please update the
    corresponding parsing in ssg.build_remediations.parse_from_file_with_jinja
    (...).
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
    Returns a modified contents which updates the platforms to the new
    platforms.
    """

    platform_line = parse_platform(fix_contents)
    if platform_line is None:
        raise ValueError("When parsing config file, unable to find platform "
                         "line!\n\n%s" % "\n".join(fix_contents))

    new_platforms_str = "# platform = " + ",".join(sorted(new_platforms))

    new_contents = fix_contents[0:platform_line]
    new_contents.extend([new_platforms_str])
    new_contents.extend(fix_contents[platform_line+1:])

    return new_contents
