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

import subprocess
import logging
import re
import json
import codecs

import ssg.xml


FILENAME = "PCI_DSS_v3-1.pdf"
JSON_FILENAME = "PCI_DSS.json"


def autocorrect_pci_id(id_):
    if id_ == "8.2.3a":
        return "8.2.3.a"

    return id_


def is_applicable_to_os(id_):
    if id_.startswith("1."):
        return False
    elif id_.startswith("9."):
        return False
    # Category "11." is supposedly not applicable on OS level but we do have
    # rules referencing it, therefore let's keep it in our Benchmarks for the
    # time being
    #elif id_.startswith("11."):
    #    return False
    elif id_.startswith("12."):
        return False

    return True


def harvest_ids_descriptions(page, id_map):
    logging.debug("Harvesting page %s", page.get("number", "unknown"))

    for text in page.findall("./text"):
        # every text element describing a PCI DSS requirement will have
        # several properties we will exploit here

        # 1) some elements present
        if len(text) == 0:
            continue

        # 2) first element is b
        if text[0].tag != "b":
            continue

        # 3) the first element is b and contains a PCI-DSS requirement ID
        id_candidate = text[0].text.strip()

        # PCI-DSS PDF contains ID mistakes, let's fix the known ones
        id_candidate = autocorrect_pci_id(id_candidate)

        # It is my understanding that this will match all valid PCI-DSS IDs
        id_pattern = ""

        # number followed by a dot
        id_pattern += "^[1-9][0-9]*\\."
        # second section, number plus optional letter
        id_pattern += "([1-9][0-9]*[a-z]?"
        # third section only if second section is present, number plus
        # optional letter
        id_pattern += "(\\.[1-9][0-9]*[a-z]?)?)"
        # sometimes there is a suffix with just a letter, preceded by a dot
        id_pattern += "?(\\.[a-z])?$"

        if re.match(id_pattern, id_candidate) is None:
            continue

        # now we are reasonably sure the text element describes a req ID
        logging.debug("This text describes req of ID '%s'.", id_candidate)

        if not is_applicable_to_os(id_candidate):
            logging.debug(
                "Req ID '%s' is not applicable on OS level.", id_candidate
            )
            continue

        # TODO: Would be great to get the entire description but that's very
        # complex to achieve
        description_excerpt = text[0].tail

        if description_excerpt is None:
            continue

        description_excerpt = description_excerpt.strip()

        if id_candidate not in id_map:
            logging.debug(
                "Assigning '%s' as description excerpt for ID '%s'.",
                description_excerpt, id_candidate
            )
            id_map[id_candidate] = description_excerpt

        else:
            # It is normal to encounter this. The second encounters are
            # rationale guidances, the first encounter are descriptions
            logging.debug(
                "Not assigning '%s' as description excerpt for ID '%s'. This "
                "ID is already in the map!", description_excerpt, id_candidate
            )


def sort_pci_subtree(subtree):
    return sorted(subtree, key=lambda item: item[0].rsplit(".", 1)[1])


def handle_id(id_, desc_, id_map, handled_ids):
    handled_ids.append(id_)

    full_prefix = id_
    if not full_prefix.endswith("."):
        full_prefix += "."

    children = []
    for child_id, child_desc in id_map.items():
        if child_id in handled_ids:
            continue

        if not child_id.startswith(full_prefix):
            continue

        id_suffix = child_id[len(full_prefix):]

        if "." in id_suffix:
            # not a direct child
            continue

        # it passed all our requirements, it must be a direct child
        children.append(handle_id(child_id, child_desc, id_map, handled_ids))

    return (id_, desc_, sort_pci_subtree(children))


def main():
    logging.basicConfig(format='%(levelname)s:%(message)s',
                        level=logging.DEBUG)

    xml_string = subprocess.check_output(
        ["pdftohtml", "-xml", "-i", "-stdout", FILENAME],
        shell=False
    )

    tree = ssg.xml.ElementTree.fromstring(xml_string)
    id_map = {}

    for page in tree.findall("./page"):
        harvest_ids_descriptions(page, id_map)

    handled_ids = []
    id_tree = []

    # start with top level IDs
    for id_, desc in id_map.items():
        if re.match("^[1-9][0-9]*\\.$", id_) is None:
            continue

        handled_ids.append(id_)
        # for every top level ID, handle all direct children
        id_tree.append(handle_id(id_, desc, id_map, handled_ids))

    # top level IDs have different sorting rules
    id_tree = sorted(id_tree, key=lambda item: int(item[0].split(".", 1)[0]))

    for id_ in id_map.keys():
        if id_ in handled_ids:
            continue

        logging.warning(
            "id '%s' wasn't handled during PCI tree reconstruction!", id_
        )

    with codecs.open(JSON_FILENAME, "w", encoding="utf-8") as f:
        json.dump(id_tree, f)


if __name__ == "__main__":
    main()
