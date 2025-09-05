from __future__ import absolute_import
from __future__ import print_function

import os

from .constants import XCCDF12_NS
from .oval import parse_affected
from .utils import read_file_list


def get_content_ref_if_exists_and_not_remote(check):
    """
    Given an OVAL check element, examine the ``xccdf_ns:check-content-ref``

    If it exists and it isn't remote, pass it as the return value.
    Otherwise, return None.

    ..see-also:: is_content_href_remote
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

    If it starts with 'http://' or 'https://', return True, otherwise
    return False.

    Raises RuntimeError if the ``href`` element doesn't exist.
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
    For the given oval_id or product, return the full path to the check in the
    given rule.
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
    Returns the tuple (path, contents) of the check described by the given
    oval_id or product.
    """

    oval_path = get_oval_path(rule_obj, oval_id)
    oval_contents = read_file_list(oval_path)

    return oval_path, oval_contents


def set_applicable_platforms(oval_contents, new_platforms):
    """
    Returns a modified contents which updates the platforms to the new
    platforms.
    """

    start_affected, end_affected, indent = parse_affected(oval_contents)

    platforms = sorted(new_platforms)
    new_platforms_xml = map(lambda x: indent + "<platform>%s</platform>" % x, platforms)
    new_platforms_xml = list(new_platforms_xml)

    new_contents = oval_contents[0:start_affected+1]
    new_contents.extend(new_platforms_xml)
    new_contents.extend(oval_contents[end_affected:])

    return new_contents
