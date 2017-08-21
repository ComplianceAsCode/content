#!/usr/bin/env python2

"""
Takes shorthand file and removes selects not applicable for containers from
container profiles.
"""

try:
    from xml.etree import cElementTree as ElementTree
except ImportError:
    import cElementTree as ElementTree

import sys
import argparse


def main():
    p = argparse.ArgumentParser()
    p.add_argument("--input", required=True)
    p.add_argument("--output", required=True)

    args, unknown = p.parse_known_args()
    if unknown:
        sys.stderr.write(
            "Unknown positional arguments " + ",".join(unknown) + ".\n"
        )
        sys.exit(1)

    xccdf_tree = ElementTree.parse(args.input)

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
            raise RuntimeError("Profile without id attribute, "
                               "there is something very wrong!")

        container_profile = False
        if profile_id.endswith("-container"):
            container_profile = True

        all_selects = profile.findall("./select")
        for select in all_selects:
            select_idref = select.get('idref')
            if select_idref is None:
                raise RuntimeError("Select without idref attribute, "
                                   "there is something very wrong!")

            rule = indexed_rules.get(select_idref)
            if rule is None:
                print("Dangling reference! Profile \"%s\" selects Rule \"%s\" "
                      "which cannot be found in benchmark!"
                      % (profile_id, select_idref))
                continue

            restrictions = rule.find('./environment-restriction')
            if restrictions is not None:
                if container_profile:
                    if restrictions.get("container") == "false":
                        profile.remove(select)
                else:
                    if restrictions.get("machine") == "false":
                        profile.remove(select)

    xccdf_tree.write(args.output)


if __name__ == "__main__":
    main()
