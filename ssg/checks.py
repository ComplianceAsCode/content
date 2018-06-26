from __future__ import absolute_import
from __future__ import print_function

import re

from .constants import XCCDF11_NS


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


def is_cce_valid(cceid):
    """
    IF CCE ID IS IN VALID FORM (either 'CCE-XXXX-X' or 'CCE-XXXXX-X'
    where each X is a digit, and the final X is a check-digit)
    based on Requirement A17:

    http://people.redhat.com/swells/nist-scap-validation/scap-val-requirements-1.2.html
    """
    match = re.match(r'^CCE-\d{4,5}-\d$', cceid)
    return match is not None
