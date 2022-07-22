#!/usr/bin/python3

import argparse
import sys
import xml.etree.ElementTree as ET
import difflib

import ssg.constants

ns = {
    "ds": ssg.constants.datastream_namespace,
    "xccdf-1.1": ssg.constants.XCCDF11_NS,
    "xccdf": ssg.constants.XCCDF12_NS,
    "oval": ssg.constants.oval_namespace,
    "catalog": ssg.constants.cat_namespace,
    "xlink": ssg.constants.xlink_namespace,
    "ocil": ssg.constants.ocil_namespace,
    "cpe-lang": ssg.constants.cpe_language_namespace,
}
content_xccdf_ns = "xccdf"

remediation_type_to_uri = {
    "bash": ssg.constants.bash_system,
    "ansible": ssg.constants.ansible_system,
    "puppet": ssg.constants.puppet_system,
    "anaconda": ssg.constants.anaconda_system,
}
check_system_to_uri = {
    "OVAL": ssg.constants.oval_namespace,
    "OCIL": ssg.constants.ocil_cs
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
    parser.add_argument(
        "--only-rules", action="store_true",
        help="Print only removals from rule set."
    )
    parser.add_argument(
        "--stig-benchmark", action="store_true",
        help="Print only removals from rule set."
    )
    return parser.parse_args()


def is_benchmark(root):
    if root.tag == "{%s}Benchmark" % (ns["xccdf"]):
        return True
    elif root.tag == "{%s}Benchmark" % (ns["xccdf-1.1"]):
        global content_xccdf_ns
        content_xccdf_ns = "xccdf-1.1"
        return True


def get_benchmarks(root):
    ds_components = root.findall("ds:component", ns)
    if not ds_components:
        # The content is not a DS, maybe it is just an XCCDF Benchmark
        if is_benchmark(root):
            yield root
    for component in ds_components:
        for benchmark in component.findall("%s:Benchmark" % content_xccdf_ns, ns):
            yield benchmark


def find_benchmark(root, id_):
    ds_components = root.findall("ds:component", ns)
    if not ds_components:
        # The content is not a DS, maybe it is just an XCCDF Benchmark
        if is_benchmark(root):
            return root
    for component in ds_components:
        benchmark = component.find("%s:Benchmark[@id='%s']" % (content_xccdf_ns, id_), ns)
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


def compare_platforms(old_rule, new_rule, old_benchmark, new_benchmark):
    entries = [{
            "benchmark": old_benchmark,
            "rule": old_rule,
            "cpe": []
        }, {
            "benchmark": new_benchmark,
            "rule": new_rule,
            "cpe": []
        }]

    for entry in entries:
        for platform in entry["rule"].findall(".//%s:platform" % (content_xccdf_ns), ns):
            idref = platform.get("idref")
            if idref.startswith("#"):
                cpe_platforms = entry["benchmark"].findall(
                    ".//cpe-lang:platform[@id='{0}']".format(idref.replace("#", "")), ns)
                if len(cpe_platforms) > 1:
                    print("Platform {0} defined more than once".format(idref))
                    for cpe_p in cpe_platforms:
                        ET.dump(cpe_p)
                if len(cpe_platforms) == 0:
                    print("Platform {0} not defined in platform specification".format(idref))
                    break
                for cpe_platform in cpe_platforms:
                    fact_refs = cpe_platform.findall(".//cpe-lang:fact-ref", ns)
                    for fact_ref in fact_refs:
                        entry["cpe"].append(fact_ref.get("name"))
            else:
                entry["cpe"].append(idref)

    if entries[0]["cpe"] != entries[1]["cpe"]:
        print("Platform has been changed for rule '{0}'".format(entries[0]["rule"].get("id")))
        print("--- old datastream")
        print("+++ new datastream")
        print("-{}".format(repr(entries[0]["cpe"])))
        print("+{}".format(repr(entries[1]["cpe"])))


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


def find_boolean_question(doc, ocil_id):
    questionnaires = doc.find("ocil:questionnaires", ns)
    questionnaire = questionnaires.find(
        "ocil:questionnaire[@id='%s']" % ocil_id, ns)
    if questionnaire is None:
        raise ValueError("OCIL questionnaire %s doesn't exist" % ocil_id)
    test_action_ref = questionnaire.find(
        "ocil:actions/ocil:test_action_ref", ns).text
    test_actions = doc.find("ocil:test_actions", ns)
    test_action = test_actions.find(
        "ocil:boolean_question_test_action[@id='%s']" % test_action_ref, ns)
    if test_action is None:
        raise ValueError(
            "OCIL boolean_question_test_action %s doesn't exist" % (
                test_action_ref))
    question_id = test_action.get("question_ref")
    questions = doc.find("ocil:questions", ns)
    question = questions.find(
        "ocil:boolean_question[@id='%s']" % question_id, ns)
    if question is None:
        raise ValueError(
            "OCIL boolean_question %s doesn't exist" % question_id)
    question_text = question.find("ocil:question_text", ns)
    return question_text.text


def compare_ocils(
        old_ocil_doc, old_ocil_id, new_ocil_doc, new_ocil_id, rule_id):
    try:
        old_question = find_boolean_question(old_ocil_doc, old_ocil_id)
        new_question = find_boolean_question(new_ocil_doc, new_ocil_id)
    except ValueError as e:
        print("Rule '%s' OCIL can't be found: %s" % (rule_id, str(e)))
        return
    diff = compare_fix_texts(old_question, new_question)
    if diff:
        print("OCIL for rule '%s' differs:\n%s" % (rule_id, diff))


def compare_checks(
        old_rule, new_rule, old_checks, new_checks, show_diffs, system):
    check_system_uri = check_system_to_uri[system]
    old_check = old_rule.find(
        "%s:check[@system='%s']" % (content_xccdf_ns, check_system_uri), ns)
    new_check = new_rule.find(
        "%s:check[@system='%s']" % (content_xccdf_ns, check_system_uri), ns)
    rule_id = old_rule.get("id")
    if (old_check is None and new_check is not None):
        print("New datastream adds %s for rule '%s'." % (system, rule_id))
    elif (old_check is not None and new_check is None):
        print(
            "New datastream is missing %s for rule '%s'." % (system, rule_id))
    elif (old_check is not None and new_check is not None):
        old_check_content_ref = old_check.find(
            "%s:check-content-ref" % (content_xccdf_ns), ns)
        new_check_content_ref = new_check.find(
            "%s:check-content-ref" % (content_xccdf_ns), ns)
        old_check_id = old_check_content_ref.get("name")
        new_check_id = new_check_content_ref.get("name")
        old_check_file_name = old_check_content_ref.get("href")
        new_check_file_name = new_check_content_ref.get("href")
        if old_check_file_name != new_check_file_name:
            print(
                "%s definition file for rule '%s' has changed from "
                "'%s' to '%s'." % (
                    system, rule_id, old_check_file_name, new_check_file_name)
            )
        if old_check_id != new_check_id:
            print(
                "%s definition ID for rule '%s' has changed from "
                "'%s' to '%s'." % (
                    system, rule_id, old_check_id, new_check_id)
            )
        if show_diffs and rule_id != "xccdf_org.ssgproject.content_rule_security_patches_up_to_date":
            try:
                old_check_doc = old_checks[old_check_file_name]
            except KeyError:
                print(
                    "Rule '%s' points to '%s' which isn't a part of the "
                    "old datastream" % (rule_id, old_check_file_name))
                return
            try:
                new_check_doc = new_checks[new_check_file_name]
            except KeyError:
                print(
                    "Rule '%s' points to '%s' which isn't a part of the "
                    "new datastream" % (rule_id, new_check_file_name))
                return
            if system == "OVAL":
                compare_oval_definitions(
                    old_check_doc, old_check_id, new_check_doc,
                    new_check_id)
            elif system == "OCIL":
                compare_ocils(
                    old_check_doc, old_check_id, new_check_doc,
                    new_check_id, rule_id)
            else:
                raise RuntimeError("Unknown check system '%s'" % system)


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
    old_fix = old_rule.find("%s:fix[@system='%s']" % (content_xccdf_ns, system), ns)
    new_fix = new_rule.find("%s:fix[@system='%s']" % (content_xccdf_ns, system), ns)
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
            ".//%s:Rule[@id='%s']" % (content_xccdf_ns, rule_id), ns)
        if len(rules) == 0:
            raise ValueError("Can't find rule %s" % (rule_id))
    else:
        rules = benchmark.findall(".//%s:Rule" % (content_xccdf_ns), ns)
    return rules


def compare_rules(
        old_rule, new_rule, old_oval_defs, new_oval_defs, old_ocils, new_ocils,
        show_diffs, stig_benchmark):
    compare_checks(
        old_rule, new_rule, old_oval_defs, new_oval_defs, show_diffs, "OVAL")
    compare_checks(
        old_rule, new_rule, old_ocils, new_ocils, show_diffs, "OCIL")
    for remediation_type in remediation_type_to_uri.keys():
        compare_remediations(old_rule, new_rule, remediation_type, show_diffs)


def process_benchmarks(
        old_benchmark, new_benchmark, old_oval_defs, new_oval_defs,
        old_ocils, new_ocils, rule_id, show_diffs, only_rules, stig_benchmark):
    missing_rules = []
    try:
        rules_in_old_benchmark = get_rules_to_compare(old_benchmark, rule_id)
        rules_in_new_benchmark = get_rules_to_compare(new_benchmark, rule_id)
        if stig_benchmark:
            # The rules in STIG Benchmarks will have their IDS changed whenever there is an update.
            # However, only the release number changes, the SV number stays the same.
            # This creates map the SV numbers to their equivalent full IDs in the new Benchmark.
            new_rule_mapping = {get_stig_rule_SV(rule.get("id")): rule.get("id")
                                for rule in rules_in_new_benchmark}

    except ValueError as e:
        print(str(e))
        return
    for old_rule in rules_in_old_benchmark:
        if stig_benchmark:
            rule_id = new_rule_mapping[get_stig_rule_SV(old_rule.get("id"))]
        else:
            rule_id = old_rule.get("id")
        new_rule = new_benchmark.find(
            ".//%s:Rule[@id='%s']" % (content_xccdf_ns, rule_id), ns)
        if new_rule is None:
            missing_rules.append(rule_id)
            print("%s is missing in new datastream." % (rule_id))
            continue
        if only_rules:
            continue
        compare_rules(old_rule, new_rule,
                      old_oval_defs, new_oval_defs,
                      old_ocils, new_ocils, show_diffs, stig_benchmark)
        compare_platforms(old_rule, new_rule,
                          old_benchmark, new_benchmark)


def get_component_refs(root):
    component_refs = dict()
    for ds in root.findall("ds:data-stream", ns):
        checks = ds.find("ds:checks", ns)
        for component_ref in checks.findall("ds:component-ref", ns):
            component_ref_href = component_ref.get("{%s}href" % (ns["xlink"]))
            component_ref_id = component_ref.get("id")
            component_refs[component_ref_href] = component_ref_id
    return component_refs


def get_uris(root):
    uris = dict()
    for ds in root.findall("ds:data-stream", ns):
        checklists = ds.find("ds:checklists", ns)
        catalog = checklists.find(".//catalog:catalog", ns)
        for uri in catalog.findall("catalog:uri", ns):
            uri_uri = uri.get("uri")
            uri_name = uri.get("name")
            uris[uri_uri] = uri_name
    return uris


def find_all(root, component_refs, uris, component_root_element_tag):
    def_doc_dict = dict()
    for component in root.findall("ds:component", ns):
        oval_def_doc = component.find(component_root_element_tag, ns)
        if oval_def_doc is not None:
            comp_id = component.get("id")
            comp_href = "#" + comp_id
            try:
                filename = uris["#" + component_refs[comp_href]]
            except KeyError:
                continue
            def_doc_dict[filename] = oval_def_doc
    return def_doc_dict


def find_all_oval_defs(root, component_refs, uris):
    return find_all(root, component_refs, uris, "oval:oval_definitions")


def find_all_ocils(root, component_refs, uris):
    return find_all(root, component_refs, uris, "ocil:ocil")


def main():
    args = parse_args()
    old_tree = ET.parse(args.old)
    old_root = old_tree.getroot()
    new_tree = ET.parse(args.new)
    new_root = new_tree.getroot()
    old_component_refs = get_component_refs(old_root)
    old_uris = get_uris(old_root)
    old_oval_defs = find_all_oval_defs(old_root, old_component_refs, old_uris)
    old_ocils = find_all_ocils(old_root, old_component_refs, old_uris)
    new_component_refs = get_component_refs(new_root)
    new_uris = get_uris(new_root)
    new_oval_defs = find_all_oval_defs(new_root, new_component_refs, new_uris)
    new_ocils = find_all_ocils(new_root, new_component_refs, new_uris)
    for old_benchmark in get_benchmarks(old_root):
        old_benchmark_id = old_benchmark.get("id")
        new_benchmark = find_benchmark(new_root, old_benchmark_id)
        if not new_benchmark:
            print(
                "Warning: Skipping comparison of the following benchmark "
                "because it was not found in the new datastream: {}".format(old_benchmark_id))
            continue
        process_benchmarks(
            old_benchmark, new_benchmark, old_oval_defs, new_oval_defs,
            old_ocils, new_ocils,
            args.rule, not args.no_diffs, args.only_rules, args.stig_benchmark)
    return 0


if __name__ == "__main__":
    sys.exit(main())
