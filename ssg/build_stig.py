from __future__ import absolute_import
from __future__ import print_function

import sys

from .xml import ElementTree as ET
from .constants import XCCDF11_NS, stig_ns, stig_refs


def get_versions(reference_file_name):
    try:
        reference_root = ET.parse(reference_file_name)
    except IOError:
        print(
            "INFO: DISA STIG Reference file not found for this platform: %s" %
            reference_file_name)
        sys.exit(0)

    reference_rules = reference_root.findall('.//{%s}Rule' % XCCDF11_NS)

    dictionary = {}

    for rule in reference_rules:
        version = rule.find('.//{%s}version' % XCCDF11_NS)
        if version is not None and version.text:
            dictionary[version.text] = rule.get('id')
    return dictionary
