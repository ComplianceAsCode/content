#!/usr/bin/env python2

from __future__ import print_function

import os

try:
    from xml.etree import cElementTree as etree
except ImportError:
    import cElementTree as etree

import sys
import argparse

# Put shared python modules in path
sys.path.insert(0, os.path.join(
        os.path.dirname(os.path.dirname(os.path.realpath(__file__))),
        "modules"))
import ssgcommon

parser = argparse.ArgumentParser(
    description='Add STIG references to XCCDF files.')
parser.add_argument(
    "--disa-stig", help="DISA STIG Reference XCCDF file",dest="reference")
parser.add_argument(
    "--unlinked-xccdf", help="unlinked SSG XCCDF file", dest="destination")
args = parser.parse_args()

reference = args.reference
destination = args.destination

xccdf_namespace = ssgcommon.XCCDF11_NS
stig_href = 'http://iase.disa.mil/stigs/Pages/stig-viewing-guidance.aspx'
stig_references_beginning = 'http://iase.disa.mil/stigs/'

try:
    reference_root = etree.parse(reference)
except IOError as exception:
    print("INFO: DISA STIG Reference file not found for this platform")
    sys.exit(0)

reference_rules = reference_root.findall('.//{%s}Rule' % xccdf_namespace)

dictionary = {}

for rule in reference_rules:
    version = rule.find('.//{%s}version' % xccdf_namespace)
    if version is not None and version.text:
        dictionary[version.text] = rule.get('id')

target_root = etree.parse(destination)
target_rules = target_root.findall('.//{%s}Rule' % xccdf_namespace)

for rule in target_rules:
    refs = rule.findall('.//{%s}reference' % xccdf_namespace)
    for ref in refs:
        if (ref.get('href').startswith(stig_references_beginning) and
                ref.text in dictionary):
            index = rule.getchildren().index(ref)
            new_ref = etree.Element(
                '{%s}reference' % xccdf_namespace, {'href': stig_href})
            new_ref.text = dictionary[ref.text]
            new_ref.tail = ref.tail
            rule.insert(index + 1, new_ref)

target_root.write(destination)
