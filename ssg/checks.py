"""
Common functions for processing Checks in SSG
"""

from __future__ import absolute_import
from __future__ import print_function

import os

from .constants import XCCDF12_NS
from .oval import parse_affected
from .utils import read_file_list


def get_content_ref_if_exists_and_not_remote(check):
    """
    Given an OVAL check element, examine the ``xccdf_ns:check-content-ref``.

    If the check-content-ref element exists and it isn't remote, return it.

    Args:
        check (Element): An OVAL check element to be examined.

    Returns:
        Element or None: The check-content-ref element if it exists and is not remote, otherwise None.

    See Also:
        is_content_href_remote: Function to determine if the content reference is remote.
    """
    checkcontentref = check.find("./{%s}check-content-ref" % XCCDF12_NS)
    if checkcontentref is None:
        return None
    if is_content_href_remote(checkcontentref):
        return None
    return checkcontentref


def is_content_href_remote(check_content_ref):
    """
    Given an OVAL check-content-ref element, examine the 'href' attribute.

    Args:
        check_content_ref (Element): An XML element representing the OVAL check-content-ref.

    Returns:
        bool: True if the 'href' attribute starts with 'http://' or 'https://', otherwise False.

    Raises:
        RuntimeError: If the 'href' attribute does not exist in the check_content_ref element.
    """
    hrefattr = check_content_ref.get("href")
    if hrefattr is None:
        # @href attribute of <check-content-ref> is required by XCCDF standard
        msg = "Invalid OVAL <check-content-ref> detected - missing the " \
              "'href' attribute!"
        raise RuntimeError(msg)

    return hrefattr.startswith("http://") or hrefattr.startswith("https://")


def get_oval_path(rule_obj, oval_id):
    """
    Returns the full path to the OVAL check file for the given rule object and OVAL ID.

    Args:
        rule_obj (dict): A dictionary containing rule information.
                         It must include the keys 'dir', 'id', and 'ovals'.
        oval_id (str): A string representing the ID of the OVAL check file.
                       If it does not end with ".xml", the extension will be appended.

    Returns:
        str: The full path to the OVAL check file.

    Raises:
        ValueError: If the rule_obj is malformed or if the oval_id is unknown for the given rule.
    """
    if not oval_id.endswith(".xml"):
        oval_id += ".xml"

    if 'dir' not in rule_obj or 'id' not in rule_obj:
        raise ValueError("Malformed rule_obj")

    if 'ovals' not in rule_obj or oval_id not in rule_obj['ovals']:
        raise ValueError("Unknown oval_id:%s for rule_id" % oval_id)

    return os.path.join(rule_obj['dir'], 'oval', oval_id)


def get_oval_contents(rule_obj, oval_id):
    """
    Returns the tuple (path, contents) of the check described by the given oval_id or product.

    Parameters:
        rule_obj (object): The rule object containing the OVAL definitions.
        oval_id (str): The identifier of the OVAL check.

    Returns:
        tuple: A tuple containing the path to the OVAL file and its contents.
    """
    oval_path = get_oval_path(rule_obj, oval_id)
    oval_contents = read_file_list(oval_path)

    return oval_path, oval_contents


def set_applicable_platforms(oval_contents, new_platforms):
    """
    Modifies the given OVAL contents to update the platforms to the new platforms.

    Args:
        oval_contents (list of str): The original OVAL content lines.
        new_platforms (list of str): The new platforms to be set in the OVAL content.

    Returns:
        list of str: The modified OVAL content lines with updated platforms.
    """
    start_affected, end_affected, indent = parse_affected(oval_contents)

    platforms = sorted(new_platforms)
    new_platforms_xml = map(lambda x: indent + "<platform>%s</platform>" % x, platforms)
    new_platforms_xml = list(new_platforms_xml)

    new_contents = oval_contents[0:start_affected+1]
    new_contents.extend(new_platforms_xml)
    new_contents.extend(oval_contents[end_affected:])

    return new_contents
