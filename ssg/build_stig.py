from __future__ import absolute_import
from __future__ import print_function

import sys

from .xml import ElementTree as ET
from .constants import XCCDF11_NS, stig_ns, stig_refs


def add_references(reference, destination):
    """
    For a given reference XCCDF file and destination file, process all
    STIG references in the rules from destination and correctly link
    them to the corresponding reference rule.

    Returns the updated ElementTree containing updated reference elements.
    """
    try:
        reference_root = ET.parse(reference)
    except IOError:
        print("INFO: DISA STIG Reference file not found for this platform: %s" % reference)
        sys.exit(0)

    reference_rules = reference_root.findall('.//{%s}Rule' % XCCDF11_NS)

    dictionary = {}

    for rule in reference_rules:
        version = rule.find('.//{%s}version' % XCCDF11_NS)
        if version is not None and version.text:
            dictionary[version.text] = rule.get('id')

    target_root = ET.parse(destination)
    target_rules = target_root.findall('.//{%s}Rule' % XCCDF11_NS)

    for rule in target_rules:
        refs = rule.findall('.//{%s}reference' % XCCDF11_NS)
        for ref in refs:
            if (ref.get('href').startswith(stig_refs) and
                    ref.text in dictionary):
                index = list(rule).index(ref)
                new_ref = ET.Element(
                    '{%s}reference' % XCCDF11_NS, {'href': stig_ns})
                new_ref.text = dictionary[ref.text]
                new_ref.tail = ref.tail
                rule.insert(index + 1, new_ref)

    return target_root
