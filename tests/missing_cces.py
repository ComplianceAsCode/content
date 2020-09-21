from __future__ import print_function

import argparse
import os.path
import sys

import ssg.xml
from ssg.constants import cce_uri, OSCAP_RULE, XCCDF12_NS


def get_selected_rules(benchmark):
    rules = set()
    for profile in benchmark.findall(".//{%s}Profile" % (XCCDF12_NS)):
        for selection in profile.findall(".//{%s}select" % (XCCDF12_NS)):
            idref = selection.get("idref")
            selected = selection.get("selected")
            if idref.startswith(OSCAP_RULE) and selected == "true":
                rules.add(idref)
    return rules


def check_all_rules(root):
    rules_missing_cce = []
    root = ssg.xml.parse_file(args.datastream_path)
    for benchmark in root.findall(".//{%s}Benchmark" % (XCCDF12_NS)):
        selected_rules = get_selected_rules(benchmark)
        for rule in benchmark.findall(".//{%s}Rule" % (XCCDF12_NS)):
            rule_id = rule.get("id")
            if rule_id not in selected_rules:
                continue
            match = False
            for ident in rule.findall("{%s}ident" % (XCCDF12_NS)):
                if ident.get("system") == cce_uri:
                    match = True
                    break
            if not match:
                rules_missing_cce.append(rule_id)
    return rules_missing_cce


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Checks the all rules that are part of at least one "
        "profile have a CCE assigned.")
    parser.add_argument(
        "datastream_path", help="Path to a SCAP source datastream")
    args = parser.parse_args()
    root = ssg.xml.parse_file(args.datastream_path)
    rules_missing_cce = check_all_rules(root)
    ds = os.path.basename(args.datastream_path)
    if len(rules_missing_cce) > 0:
        print("The following rules in %s are missing CCEs:" % (ds))
        for rule in rules_missing_cce:
            print(rule)
        sys.exit(1)
    else:
        print("%s is OK" % (ds))
