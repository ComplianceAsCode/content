#!/usr/bin/python

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
from xml.etree import cElementTree as ElementTree
import json
import sys
import copy
import codecs


XCCDF_NAMESPACE = "http://checklists.nist.gov/xccdf/1.1"
FILENAME = "PCI_DSS_v3.pdf"
REMOTE_URL = "https://www.pcisecuritystandards.org/documents/PCI_DSS_v3-1.pdf"
JSON_FILENAME = "PCI_DSS.json"


def construct_xccdf_group(id_, desc, children, rules, rule_usage_map):
    ret = ElementTree.Element("{%s}Group" % (XCCDF_NAMESPACE))
    ret.set("id", "pcidss-req-%s" % (id_))
    ret.set("selected", "true")
    title = ElementTree.Element("{%s}title" % (XCCDF_NAMESPACE))
    title.text = id_
    ret.append(title)

    for rule in rules:
        pci_dss_req_related = False
        for ref in rule.findall("./{%s}reference" % (XCCDF_NAMESPACE)):
            if ref.get("href") == REMOTE_URL and \
                    ref.text == "Req-" + id_:
                pci_dss_req_related = True
                break

        if pci_dss_req_related:
            ret.append(copy.deepcopy(rule))

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

    id_tree = None
    with open(JSON_FILENAME, "r") as f:
        id_tree = json.load(f)

    benchmark = ElementTree.parse(sys.argv[1])
    rules = []
    for rule in \
            benchmark.findall(".//{%s}Rule" % (XCCDF_NAMESPACE)):
        rules.append(rule)
    rule_usage_map = {}

    parent_map = dict((c, p) for p in benchmark.getiterator() for c in p)
    for rule in \
            benchmark.findall(".//{%s}Rule" % (XCCDF_NAMESPACE)):
        parent_map[rule].remove(rule)
    for group in \
            benchmark.findall(".//{%s}Group" % (XCCDF_NAMESPACE)):
        parent_map[group].remove(group)

    root_element = benchmark.getroot()
    for id_, desc, children in id_tree:
        element = \
            construct_xccdf_group(id_, desc, children, rules, rule_usage_map)
        root_element.append(element)

    with codecs.open(sys.argv[2], "w", encoding="utf-8") as f:
        benchmark.write(f)

if __name__ == "__main__":
    main()
