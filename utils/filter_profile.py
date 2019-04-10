#!/usr/bin/env python3

from __future__ import print_function

import json
import argparse
import os
import os.path
import sys
import xml.etree.ElementTree as ET

from ssg.constants import XCCDF12_NS as xccdf_ns


def parse_args():
    script_desc = \
        "Removes all rules that don't belong to a particular profile from a datastream file."

    parser = argparse.ArgumentParser(description=script_desc)
    parser.add_argument("benchmark", action="store", help="Specify DataStream file to act on. "
                        "Doesn't work with plain XCCDF yet.")
    parser.add_argument("profile",
                        action="store",
                        help="The profile name of the rules that should be kept.")
    parser.add_argument("--output", "-o", required=True,
                        action="store",
                        help="Specify DataStream file name to write to.")

    args = parser.parse_args()

    return args


def tree_walk(parent, tag_name):
    for elem in list(parent):
        if elem.tag == tag_name:
            yield from tree_walk(elem, tag_name)
            yield parent, elem


def main():
    args = parse_args()

    tree = ET.parse(args.benchmark)
    bench = tree.find('.//{{{0}}}Benchmark'.format(xccdf_ns))

    selector = './/{{{0}}}Profile[@id="{1}"]/{{{0}}}select[@selected="true"]'
    selector = selector.format(xccdf_ns, args.profile.replace('"', '" || \'"\' || "'))

    profile_rules = None
    for profile in bench.findall('./{{{0}}}Profile'.format(xccdf_ns)):
        if profile.get('id') == 'xccdf_org.ssgproject.content_profile_' + args.profile:
            profile_rules = set()
            for select in list(profile):
                if select.tag != '{{{0}}}select'.format(xccdf_ns):
                    continue
                if select.get('selected') == 'true':
                    profile_rules.add(select.get('idref'))
                else:
                    profile.remove(select)
        else:
            print('removing profile ' + profile.get('id'))
            bench.remove(profile)

    if profile_rules is None:
        print("Profile {} not found in {}".format(args.profile, args.benchmark), file=sys.stderr)
        return

    used_vars = set()

    for group in bench.findall('.//{{{0}}}Group'.format(xccdf_ns)):
        for rule in group.findall('./{{{0}}}Rule'.format(xccdf_ns)):
            if rule.get('id') not in profile_rules:
                print('removing rule ' + rule.get('id'))
                group.remove(rule)

            for ref in rule.iterfind('.//{{{0}}}check-export'.format(xccdf_ns)):
                used_vars.add(ref.get('value-id'))
            for ref in rule.iterfind('.//{{{0}}}sub'.format(xccdf_ns)):
                used_vars.add(ref.get('idref'))

    for group in bench.findall('.//{{{0}}}Group'.format(xccdf_ns)):
        for var in group.findall('./{{{0}}}Value'.format(xccdf_ns)):
            if var.get('id') not in used_vars:
                print('removing variable ' + var.get('id'))
                group.remove(var)

    for parent, group in tree_walk(bench, '{{{0}}}Group'.format(xccdf_ns)):
        exceptions = {'{{{0}}}title'.format(xccdf_ns), '{{{0}}}description'.format(xccdf_ns)}
        child_tags = {c.tag for c in group} - exceptions
        if not child_tags:
            print('removing group ' + group.get('id'))
            parent.remove(group)

    tree.write(args.output)

if __name__ == '__main__':
    main()
