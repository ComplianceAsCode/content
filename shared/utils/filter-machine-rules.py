#!/usr/bin/env python2

"""
Takes shorthand file and removes selects not applicable for containers from container profiles.
"""


try:
    from xml.etree import cElementTree as ElementTree
except ImportError:
    import cElementTree as ElementTree

import sys

def parse_xml_file(xmlfile):
    with open(xmlfile, 'r') as xml_file:
        files_tring = xml_file.read()
        tree = ElementTree.fromstring(files_tring)
    return tree

def main():
    xccdf_file = sys.argv[1]
    xccdf_out_file = sys.argv[2]

    xccdf_tree = parse_xml_file(xccdf_file)

    indexed_rules = {}
    for rule in xccdf_tree.findall(".//Rule"):
        rule_id = rule.get("id")
        if rule_id is None:
            raise RuntimeError("Can't index a rule with no id attribute!")

        assert(rule_id not in indexed_rules)
        indexed_rules[rule_id] = rule

    all_profiles = xccdf_tree.findall("./Profile")
    for profile in all_profiles:
        profile_id = profile.get('id')
        if profile_id is None:
            raise RuntimeError("Profile without id attribute, there is something very wrong!")

        # Only filter Rules in profiles for containers
        if not profile_id.endswith("-container"):
            continue

        all_selects = profile.findall("./select")
        for select in all_selects:
            select_idref = select.get('idref')
            if select_idref is None:
                raise RuntimeError("Profile without id attribute, there is something very wrong!")

            rule = indexed_rules.get(select_idref)
            if rule is None:
                print("Dangling reference! Profile \"%s\" selects Rule \"%s\" "
                        "which cannot be found in benchmark!"
                        % (profile_id, select_idref))
                continue

            x = rule.find('./machine')
            if x is not None:
                profile.remove(select)

    ElementTree.ElementTree(xccdf_tree).write(xccdf_out_file)


if __name__ == "__main__":
    main()
