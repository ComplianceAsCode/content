#!/usr/bin/python3

import argparse
import sys
import xml.etree.ElementTree as ET
import difflib

import ssg.constants

ns = {
    "ds": ssg.constants.datastream_namespace,
    "xccdf": ssg.constants.XCCDF12_NS,
    "oval": ssg.constants.oval_namespace,
    "catalog": ssg.constants.cat_namespace,
    "xlink": ssg.constants.xlink_namespace,
}
remediation_type_to_uri = {
    "bash": ssg.constants.bash_system,
    "ansible": ssg.constants.ansible_system,
    "puppet": ssg.constants.puppet_system,
    "anaconda": ssg.constants.anaconda_system,
}


def parse_args():
    parser = argparse.ArgumentParser(
        description="Compares two datastreams with regards to presence of"
        "OVAL checks and all remediations")
    parser.add_argument(
        "old", metavar="OLD_DS_PATH",
        help="Path to the old datastream")
    parser.add_argument(
        "new", metavar="NEW_DS_PATH",
        help="Path to the new datastream")
    parser.add_argument(
        "--rule", metavar="RULE_ID",
        help="Compare only the rule specified by given RULE_ID"
    )
    parser.add_argument(
        "--no-diffs", action="store_true",
        help="Do not perform detailed comparison of checks and "
        "remediations contents."
    )
    return parser.parse_args()


def get_benchmarks(root):
    for component in root.findall("ds:component", ns):
        for benchmark in component.findall("xccdf:Benchmark", ns):
            yield benchmark


def find_benchmark(root, id_):
    for component in root.findall("ds:component", ns):
        benchmark = component.find("xccdf:Benchmark[@id='%s']" % (id_), ns)
        if benchmark is not None:
            return benchmark
    return None


def find_oval_definition(oval_doc, def_id):
    definitions = oval_doc.find("oval:definitions", ns)
    definition = definitions.find("oval:definition[@id='%s']" % (def_id), ns)
    return definition


def find_oval_test(oval_doc, test_id):
    tests = oval_doc.find("oval:tests", ns)
    test = tests.find("*[@id='%s']" % (test_id))
    return test


def definition_to_elements(definition):
    criteria = definition.find("oval:criteria", ns)
    elements = []
    for child in criteria.iter():  # iter recurses
        if child.tag == "{%s}criteria" % (ns["oval"]):
            operator = child.get("operator")
            elements.append(("criteria", operator))
        elif child.tag == "{%s}criterion" % (ns["oval"]):
            test_id = child.get("test_ref")
            elements.append(("criterion", test_id))
        elif child.tag == "{%s}extend_definition" % (ns["oval"]):
            extend_def_id = child.get("definition_ref")
            elements.append(("extend_definition", extend_def_id))
    return elements


def print_offending_elements(elements, sign):
    for thing, atrribute in elements:
        print("%s %s %s" % (sign, thing, atrribute))


def compare_oval_definitions(
        old_oval_def_doc, old_oval_def_id, new_oval_def_doc, new_oval_def_id):
    old_def = find_oval_definition(old_oval_def_doc, old_oval_def_id)
    new_def = find_oval_definition(new_oval_def_doc, new_oval_def_id)
    old_els = definition_to_elements(old_def)
    new_els = definition_to_elements(new_def)
    for x in old_els.copy():
        for y in new_els.copy():
            if x[0] == y[0] and x[1] == y[1]:
                old_els.remove(x)
                new_els.remove(y)
                break
    if old_els or new_els:
        print("OVAL definition %s differs:" % (old_oval_def_id))
        print("--- old datastream")
        print("+++ new datastream")
        print_offending_elements(old_els, "-")
        print_offending_elements(new_els, "+")


def compare_ovals(
        old_rule, new_rule, old_oval_defs, new_oval_defs, show_diffs):
    old_oval_ref = old_rule.find(
        "xccdf:check[@system='%s']" % (ssg.constants.oval_namespace), ns)
    new_oval_ref = new_rule.find(
        "xccdf:check[@system='%s']" % (ssg.constants.oval_namespace), ns)
    rule_id = old_rule.get("id")
    if (old_oval_ref is None and new_oval_ref is not None):
        print("New datastream adds OVAL for rule '%s'." % (rule_id))
    elif (old_oval_ref is not None and new_oval_ref is None):
        print("New datastream is missing OVAL for rule '%s'." % (rule_id))
    elif (old_oval_ref is not None and new_oval_ref is not None):
        old_check_content_ref = old_oval_ref.find(
            "xccdf:check-content-ref", ns)
        new_check_content_ref = new_oval_ref.find(
            "xccdf:check-content-ref", ns)
        old_oval_def_id = old_check_content_ref.get("name")
        new_oval_def_id = new_check_content_ref.get("name")
        old_oval_file_name = old_check_content_ref.get("href")
        new_oval_file_name = new_check_content_ref.get("href")
        if old_oval_file_name != new_oval_file_name:
            print(
                "OVAL definition file for rule '%s' has changed from "
                "'%s' to '%s'." % (
                    rule_id, old_oval_file_name, new_oval_file_name)
            )
        if old_oval_def_id != new_oval_def_id:
            print(
                "OVAL definition ID for rule '%s' has changed from "
                "'%s' to '%s'." % (rule_id, old_oval_def_id, new_oval_def_id)
            )
        if show_diffs:
            try:
                old_oval_def_doc = old_oval_defs[old_oval_file_name]
            except KeyError:
                print(
                    "Rule '%s' points to '%s' which isn't a part of the "
                    "old datastream" % (rule_id, old_oval_file_name))
                return
            try:
                new_oval_def_doc = new_oval_defs[new_oval_file_name]
            except KeyError:
                print(
                    "Rule '%s' points to '%s' which isn't a part of the "
                    "new datastream" % (rule_id, new_oval_file_name))
                return
            compare_oval_definitions(
                old_oval_def_doc, old_oval_def_id, new_oval_def_doc,
                new_oval_def_id)


def compare_fix_texts(old_r, new_r):
    if old_r != new_r:
        diff = "".join(difflib.unified_diff(
            old_r.splitlines(keepends=True), new_r.splitlines(keepends=True),
            fromfile="old datastream", tofile="new datastream"))
        return diff
    return None


def compare_fix_elements(
        old_fix, new_fix, remediation_type, rule_id, show_diffs):
    old_fix_id = old_fix.get("id")
    new_fix_id = new_fix.get("id")
    if old_fix_id != new_fix_id:
        print(
            "%s remediation ID for rule '%s' has changed from "
            "'%s' to '%s'." % (
                remediation_type, rule_id, old_fix_id, new_fix_id)
        )
    if show_diffs:
        old_fix_text = "".join(old_fix.itertext())
        new_fix_text = "".join(new_fix.itertext())
        diff = compare_fix_texts(old_fix_text, new_fix_text)
        if diff:
            print("%s remediation for rule '%s' differs:\n%s" % (
                remediation_type, rule_id, diff))


def compare_remediations(old_rule, new_rule, remediation_type, show_diffs):
    system = remediation_type_to_uri[remediation_type]
    old_fix = old_rule.find("xccdf:fix[@system='%s']" % (system), ns)
    new_fix = new_rule.find("xccdf:fix[@system='%s']" % (system), ns)
    rule_id = old_rule.get("id")
    if (old_fix is None and new_fix is not None):
        print("New datastream adds %s remediation for rule '%s'." % (
            remediation_type, rule_id))
    elif (old_fix is not None and new_fix is None):
        print("New datastream is missing %s remediation for rule '%s'." % (
            remediation_type, rule_id))
    elif (old_fix is not None and new_fix is not None):
        compare_fix_elements(
            old_fix, new_fix, remediation_type, rule_id, show_diffs)


def get_rules_to_compare(benchmark, rule_id):
    if rule_id:
        if not rule_id.startswith(ssg.constants.OSCAP_RULE):
            rule_id = ssg.constants.OSCAP_RULE + rule_id
        rules = benchmark.findall(
            ".//xccdf:Rule[@id='%s']" % (rule_id), ns)
        if len(rules) == 0:
            raise ValueError("Can't find rule %s" % (rule_id))
    else:
        rules = benchmark.findall(".//xccdf:Rule", ns)
    return rules


def compare_rules(
        old_rule, new_rule, old_oval_defs, new_oval_defs, show_diffs):
    compare_ovals(
        old_rule, new_rule, old_oval_defs, new_oval_defs, show_diffs)
    for remediation_type in remediation_type_to_uri.keys():
        compare_remediations(old_rule, new_rule, remediation_type, show_diffs)


def process_benchmarks(
        old_benchmark, new_benchmark, old_oval_defs, new_oval_defs,
        rule_id, show_diffs):
    missing_rules = []
    try:
        rules_in_old_benchmark = get_rules_to_compare(old_benchmark, rule_id)
    except ValueError as e:
        print(str(e))
        return
    for old_rule in rules_in_old_benchmark:
        rule_id = old_rule.get("id")
        new_rule = new_benchmark.find(
            ".//xccdf:Rule[@id='%s']" % (rule_id), ns)
        if new_rule is None:
            missing_rules.append(rule_id)
            print("%s is missing in new datastream." % (rule_id))
            continue
        compare_rules(
            old_rule, new_rule, old_oval_defs, new_oval_defs, show_diffs)


def find_all_oval_defs(root):
    component_refs = dict()
    for ds in root.findall("ds:data-stream", ns):
        checks = ds.find("ds:checks", ns)
        for component_ref in checks.findall("ds:component-ref", ns):
            component_ref_href = component_ref.get("{%s}href" % (ns["xlink"]))
            component_ref_id = component_ref.get("id")
            component_refs[component_ref_href] = component_ref_id
    uris = dict()
    for ds in root.findall("ds:data-stream", ns):
        checklists = ds.find("ds:checklists", ns)
        catalog = checklists.find(".//catalog:catalog", ns)
        for uri in catalog.findall("catalog:uri", ns):
            uri_uri = uri.get("uri")
            uri_name = uri.get("name")
            uris[uri_uri] = uri_name
    def_doc_dict = dict()
    for component in root.findall("ds:component", ns):
        oval_def_doc = component.find("oval:oval_definitions", ns)
        if oval_def_doc is not None:
            comp_id = component.get("id")
            comp_href = "#" + comp_id
            try:
                filename = uris["#" + component_refs[comp_href]]
            except KeyError:
                continue
            def_doc_dict[filename] = oval_def_doc
    return def_doc_dict


def main():
    args = parse_args()
    old_tree = ET.parse(args.old)
    old_root = old_tree.getroot()
    new_tree = ET.parse(args.new)
    new_root = new_tree.getroot()
    old_oval_defs = find_all_oval_defs(old_root)
    new_oval_defs = find_all_oval_defs(new_root)
    for old_benchmark in get_benchmarks(old_root):
        new_benchmark = find_benchmark(new_root, old_benchmark.get("id"))
        process_benchmarks(
            old_benchmark, new_benchmark, old_oval_defs, new_oval_defs,
            args.rule, not args.no_diffs)
    return 0


if __name__ == "__main__":
    sys.exit(main())
