#!/usr/bin/env python2

"""
Takes given *resolved* XCCDF, goes through every profile. For every profile,
every group that has no selected rules in that profile gets unselected.
This tool operates in-place!

This is necessary to make HTML guides shorter and the XCCDF itself more usable
in tools such as SCAP Workbench.

NOTE: This tool does *NOT* support datastreams! Run it on the XCCDFs before you
build datastreams from them!

Author: Martin Preisler <mpreisle@redhat.com>
"""

from __future__ import print_function

import os
import sys

from optparse import OptionParser

import ssg.constants
import ssg.xml

OSCAP_PATH = "oscap"

XCCDF11_NS = ssg.constants.XCCDF11_NS
TRUE_STRINGS = ["true", "1", "True", "TRUE"]


def is_rule_selected(root_element, profile_element, rule_element):
    rule_id = rule_element.get("id")

    select_state = rule_element.get("selected") in TRUE_STRINGS

    for selector in profile_element.findall("./{%s}select" % (XCCDF11_NS)):
        if selector.get("idref") == rule_id:
            select_state = selector.get("selected") in TRUE_STRINGS

    return select_state


def any_nested_selected_rules(root_element, profile_element, group_element,
                              group_cache):
    group_id = group_element.get("id")
    if group_id in group_cache:
        return group_cache[group_id]

    for child_group in group_element.findall("./{%s}Group" % (XCCDF11_NS)):
        if any_nested_selected_rules(
            root_element, profile_element, child_group,
            group_cache
        ):
            group_cache[group_id] = True
            return True

    for child_rule in group_element.findall("./{%s}Rule" % (XCCDF11_NS)):
        if is_rule_selected(root_element, profile_element, child_rule):
            group_cache[group_id] = True
            return True

    group_cache[group_id] = False
    return False


def main():
    usage = "usage: %prog [options]"
    parser = OptionParser(usage=usage)
    parser.add_option(
        "-i", "--input", dest="input_content", type="string",
        action="store", help="INPUT can be XCCDF 1.1.4 benchmark"
    )
    parser.add_option(
        "-o", "--output", dest="output", type="string",
        action="store", help="Where the result XML tree should be written.")

    (options, args) = parser.parse_args()

    if options.input_content is None:
        parser.print_help()
        raise RuntimeError("No INPUT file provided, please use --input.")

    if options.output is None:
        parser.print_help()
        raise RuntimeError("Please specify output with --output.")

    input_tree = ssg.xml.open_xml(options.input_content)
    root_element = input_tree.getroot()
    if root_element.tag != "{%s}Benchmark" % (XCCDF11_NS):
        raise RuntimeError(
            "Make sure the input file is XCCDF 1.1.4 and the root element is "
            "a benchmark!"
        )

    if root_element.get("resolved") not in ["1", "true"]:
        raise RuntimeError(
            "Make sure the input file is a resolved XCCDF Benchmark."
        )

    # force another oscap resolve to fix namespace prefixes
    root_element.set("resolved", "0")

    affected_profiles = []
    group_elements = root_element.findall(".//{%s}Group" % (XCCDF11_NS))

    for profile_element in root_element.findall("./{%s}Profile" % (XCCDF11_NS)):
        # maps group IDs to number of nested selected XCCDF rules
        group_cache = {}

        for group_element in group_elements:
            if not any_nested_selected_rules(
                root_element, profile_element, group_element,
                group_cache
            ):
                existing_selects = \
                    list(profile_element.findall("./{%s}select" % (XCCDF11_NS)))

                new_select = None
                for existing_select in existing_selects:
                    # prevent idref duplication
                    if existing_select.get("idref") == group_element.get("id"):
                        new_select = existing_select
                        break

                if new_select is None:
                    new_select = \
                        ssg.xml.ElementTree.Element("{%s}select" % (XCCDF11_NS))
                    index = 0
                    if len(existing_selects) > 0:
                        prev_element = existing_selects[-1]
                        # insert before the first notice
                        index = list(profile_element).index(prev_element) + 1
                    profile_element.insert(index, new_select)

                new_select.set("idref", group_element.get("id"))
                new_select.set("selected", "false")
                new_select.tail = "\n"

        affected_profiles.append(profile_element.get("id"))

    input_tree.write(options.output)


if __name__ == "__main__":
    main()
