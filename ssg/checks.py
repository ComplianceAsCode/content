from __future__ import absolute_import
from __future__ import print_function

import os
import re

from .constants import XCCDF11_NS
from .oval import parse_affected
from .utils import read_file_list


def get_content_ref_if_exists_and_not_remote(check):
    """
    Given an OVAL check element, examine the ``xccdf_ns:check-content-ref``

    If it exists and it isn't remote, pass it as the return value.
    Otherwise, return None.

    ..see-also:: is_content_href_remote
    """
    checkcontentref = check.find("./{%s}check-content-ref" % XCCDF11_NS)
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


def is_cce_format_valid(cceid):
    """
    IF CCE ID IS IN VALID FORM (either 'CCE-XXXX-X' or 'CCE-XXXXX-X'
    where each X is a digit, and the final X is a check-digit)
    based on Requirement A17:

    http://people.redhat.com/swells/nist-scap-validation/scap-val-requirements-1.2.html
    """
    match = re.match(r'^CCE-\d{4,5}-\d$', cceid)
    return match is not None


def is_cce_value_valid(cceid):
    # For context, see:
    # https://github.com/ComplianceAsCode/content/issues/3044#issuecomment-420844095

    # concat(substr ... , substr ...) -- just remove non-digit characters.
    # Since we've already validated format, this hack suffices:
    cce = re.sub(r'(CCE|-)', '', cceid)

    # The below is an implementation of Luhn's algorithm as this is what the
    # XPath code does.

    # First, map string numbers to integers. List cast is necessary to be able
    # to index it.
    digits = list(map(int, cce))

    # Even indices are doubled. Coerce to list for list addition. However,
    # XPath uses 1-indexing so "evens" and "odds" are swapped from Python.
    # We handle both the idiv and the mod here as well; note that we only
    # hvae to do this for evens: no single digit is above 10, so the idiv
    # always returns 0 and the mod always returns the original number.
    evens = list(map(lambda i: (i*2)//10 + (i*2) % 10, digits[-2::-2]))
    odds = digits[-1::-2]

    # The checksum value is now the sum of the evens and the odds.
    value = sum(evens + odds) % 10

    # Valid CCE <=> value == 0
    return value == 0


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
