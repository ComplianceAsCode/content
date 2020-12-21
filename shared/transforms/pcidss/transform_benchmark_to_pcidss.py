#!/usr/bin/env python2

# Copyright 2016 Red Hat Inc., Durham, North Carolina.
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2 of the License, or (at your option) any later version.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
#
# Authors:
#      Martin Preisler <mpreisle@redhat.com>

import logging
try:
    from xml.etree import cElementTree as ElementTree
except ImportError:
    from xml.etree import ElementTree as ElementTree
import json
import sys
import os
import copy

import ssg.constants

XCCDF_NAMESPACE = ssg.constants.XCCDF12_NS
FILENAME = "PCI_DSS_v3.pdf"
REMOTE_URL = "https://www.pcisecuritystandards.org/documents/PCI_DSS_v3-1.pdf"


def construct_xccdf_group(id_, desc, children, rules, rule_usage_map):
    ret = ElementTree.Element("{%s}Group" % (XCCDF_NAMESPACE))
    ret.set("id", ssg.constants.OSCAP_GROUP_PCIDSS + "-%s" % (id_))
    ret.set("selected", "true")
    title = ElementTree.Element("{%s}title" % (XCCDF_NAMESPACE))
    title.text = id_
    ret.append(title)
    description = ElementTree.Element("{%s}description" % (XCCDF_NAMESPACE))
    description.text = desc
    ret.append(description)

    for rule in rules:
        pci_dss_req_related = False
        for ref in rule.findall("./{%s}reference" % (XCCDF_NAMESPACE)):
            if ref.get("href") == REMOTE_URL and \
                    ref.text == "Req-" + id_:
                pci_dss_req_related = True
                break

        if pci_dss_req_related:
            suffix = ""
            if rule.get("id") not in rule_usage_map:
                rule_usage_map[rule.get("id")] = 1
            else:
                rule_usage_map[rule.get("id")] += 1
                suffix = "_%i" % (rule_usage_map[rule.get("id")])

            copied_rule = copy.deepcopy(rule)
            copied_rule.set("id", rule.get("id") + suffix)
            ret.append(copied_rule)

    for child_id, child_desc, child_children in children:
        child_element = construct_xccdf_group(
            child_id, child_desc, child_children,
            rules, rule_usage_map
        )
        ret.append(child_element)

    return ret


def main():
    logging.basicConfig(format='%(levelname)s:%(message)s',
                        level=logging.DEBUG)

    if len(sys.argv) < 4:
        sys.stderr.write("transform_benchmark_to_pcidss.py PCI_DSS.json "
                         "SOURCE_XCCDF DESTINATION_XCCDF\n")
        sys.exit(1)

    id_tree = None
    with open(sys.argv[1], "r") as f:
        id_tree = json.load(f)

    benchmark = ElementTree.parse(sys.argv[2])

    rules = []
    for rule in \
            benchmark.findall(".//{%s}Rule" % (XCCDF_NAMESPACE)):
        rules.append(rule)
    rule_usage_map = {}

    # only PCI-DSS related rules in that list, to speed-up processing
    filtered_rules = []
    for rule in rules:
        for ref in rule.findall("./{%s}reference" % (XCCDF_NAMESPACE)):
            if ref.get("href") == REMOTE_URL:
                filtered_rules.append(rule)
                break

    values = []
    for value in \
            benchmark.findall(".//{%s}Value" % (XCCDF_NAMESPACE)):
        values.append(value)

    # decide on usage of .iter or .getiterator method of elementtree class.
    # getiterator is deprecated in Python 3.9, but iter is not available in
    # older versions
    if getattr(benchmark, "iter", None) == None:
        parent_map = dict((c, p) for p in benchmark.getiterator() for c in p)
    else:
        parent_map = dict((c, p) for p in benchmark.iter() for c in p)
    for rule in \
            benchmark.findall(".//{%s}Rule" % (XCCDF_NAMESPACE)):
        parent_map[rule].remove(rule)
    for value in \
            benchmark.findall(".//{%s}Value" % (XCCDF_NAMESPACE)):
        parent_map[value].remove(value)
    for group in \
            benchmark.findall(".//{%s}Group" % (XCCDF_NAMESPACE)):
        parent_map[group].remove(group)

    root_element = benchmark.getroot()
    for id_, desc, children in id_tree:
        element = \
            construct_xccdf_group(id_, desc, children,
                                  filtered_rules, rule_usage_map)
        root_element.append(element)

    if len(values) > 0:
        group = ElementTree.Element("{%s}Group" % (XCCDF_NAMESPACE))
        group.set("id", ssg.constants.OSCAP_GROUP_VAL)
        group.set("selected", "true")
        title = ElementTree.Element("{%s}title" % (XCCDF_NAMESPACE))
        title.text = "Values"
        group.append(title)
        description = ElementTree.Element("{%s}description" % (XCCDF_NAMESPACE))
        description.text = "Group of values used in PCI-DSS profile"
        group.append(description)

        for value in values:
            copied_value = copy.deepcopy(value)
            group.append(copied_value)

        root_element.append(group)

    unused_rules = []
    for rule in rules:
        if rule.get("id") not in rule_usage_map:
            # this rule wasn't added yet, it would be lost unless we added it
            # to a special non-PCI-DSS group
            unused_rules.append(rule)

            for ref in rule.findall("./{%s}reference" % (XCCDF_NAMESPACE)):
                if ref.get("href") == REMOTE_URL:
                    logging.error(
                        "Rule '%s' references PCI-DSS '%s' but doesn't match "
                        "any Group ID in our requirement tree. Perhaps it's "
                        "referencing something we don't consider applicable on "
                        "the Operating System level?",
                        rule.get("id"), ref.text
                    )
                    sys.exit(1)

    if len(unused_rules) > 0:
        group = ElementTree.Element("{%s}Group" % (XCCDF_NAMESPACE))
        group.set("id", ssg.constants.OSCAP_GROUP_NON_PCI)
        group.set("selected", "true")
        title = ElementTree.Element("{%s}title" % (XCCDF_NAMESPACE))
        title.text = "Non PCI-DSS"
        group.append(title)
        description = ElementTree.Element("{%s}description" % (XCCDF_NAMESPACE))
        description.text = "Rules that are not part of PCI-DSS"
        group.append(description)

        for rule in unused_rules:
            copied_rule = copy.deepcopy(rule)
            group.append(copied_rule)

        root_element.append(group)

    # change the Benchmark ID to avoid validation issues
    root_element.set(
        "id",
        root_element.get("id").replace("_benchmark_", "_benchmark_PCIDSS-")
    )

    for title_element in \
            root_element.findall("./{%s}title" % (XCCDF_NAMESPACE)):
        title_element.text += " (PCI-DSS centric)"

    # filter out all profiles except PCI-DSS
    for profile in \
            benchmark.findall("./{%s}Profile" % (XCCDF_NAMESPACE)):
        if profile.get("id").endswith("pci-dss"):
            # change the profile ID to avoid validation issues
            profile.set(
                "id",
                profile.get("id").replace("pci-dss", "pci-dss_centric")
            )
        else:
            root_element.remove(profile)
            continue

        # filter out old group selectors from the PCI-DSS profile
        for select in profile.findall("./{%s}select" % (XCCDF_NAMESPACE)):
            if select.get("idref").startswith(ssg.constants.OSCAP_GROUP):
                # we will remove all group selectors, all PCI-DSS groups are
                # selected by default so we don't need any in the final
                # PCI-DSS Benchmark
                profile.remove(select)

    benchmark.write(sys.argv[3])

if __name__ == "__main__":
    main()
