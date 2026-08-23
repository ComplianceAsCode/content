#!/usr/bin/python3
import argparse
import copy
import ssg.yaml
from ssg.xml import ElementTree as ET
import ssg.xml
from ssg.constants import XCCDF11_NS, XCCDF12_NS, OSCAP_RULE, ocil_namespace

ns = {
    "xccdf-1.1": XCCDF11_NS,
    "xccdf-1.2": XCCDF12_NS,
    "ocil": ocil_namespace,
}


def copy_contents(source_element, target_element):
    if source_element.text:
        target_element.text = (target_element.text or "") + source_element.text
    children_copy = [copy.deepcopy(child) for child in source_element]
    target_element.extend(children_copy)


def parse_args():
    parser = argparse.ArgumentParser(description="Create unlinked STIG XCCDF")
    parser.add_argument(
        "--product-yaml", required=True,
        help="Resolved product YAML file, eg. build/rhel9/product.yml")
    parser.add_argument("--xccdf", required=True, help="Input XCCDF file")
    parser.add_argument(
        "--overlay", required=True, help="Input STIG overlay file")
    parser.add_argument("--ocil", required=True, help="Input OCIL file")
    parser.add_argument(
        "--output", required=True, help="Output unlinked STIG XCCDF file")
    return parser.parse_args()


def get_xccdf_rules(xccdf_root):
    rules = {}
    for rule_el in xccdf_root.findall(".//xccdf-1.2:Rule", ns):
        rule_id = rule_el.get("id").replace(OSCAP_RULE, "")
        rules[rule_id] = rule_el
    return rules


def convert_overlay_to_xccdf_group(overlay, xccdf_rules, ocil_questions):
    overlay_rule = overlay.get("ruleid")
    overlay_id = overlay.find("xccdf-1.1:VMSinfo", ns).get("VKey")
    group = ET.Element("xccdf-1.2:Group")
    group.set("id", f"V-{overlay_id}")
    group_title = ET.SubElement(group, "xccdf-1.2:title")
    group_title.text = "SRG-OS-ID"
    ET.SubElement(group, "xccdf-1.2:description")
    rule = ET.SubElement(group, "xccdf-1.2:Rule")
    if overlay_rule != "XXXX":
        rule.set("id", overlay_rule)
    else:
        rule.set("id", "Missing Rule")
    overlay_severity = overlay.get("severity")
    rule.set("severity", overlay_severity)
    version = ET.SubElement(rule, "xccdf-1.2:version")
    overlay_version = overlay.get("ownerid")
    version.text = overlay_version
    title = ET.SubElement(rule, "xccdf-1.2:title")
    overlay_title = overlay.find("xccdf-1.1:title", ns).get("text")
    title.text = overlay_title
    rule_description = ET.SubElement(rule, "xccdf-1.2:description")
    if overlay_rule != "XXXX":
        rationale = xccdf_rules[overlay_rule].find("xccdf-1.2:rationale", ns)
        copy_contents(rationale, rule_description)
    check = ET.SubElement(rule, "xccdf-1.2:check")
    check.set("system", f"C-{overlay_id}_chk")
    check_content = ET.SubElement(check, "xccdf-1.2:check-content")
    if overlay_rule != "XXXX":
        check_content.text = ocil_questions.get(overlay_rule, "")
    ident = ET.SubElement(rule, "xccdf-1.2:ident")
    if overlay_rule != "XXXX":
        ident.set("system", "https://www.cyber.mil/stigs/cci")
    overlay_ref = overlay.get("disa")
    ident.text = overlay_ref
    fixtext = ET.SubElement(rule, "xccdf-1.2:fixtext")
    if overlay_rule != "XXXX":
        description = xccdf_rules[overlay_rule].find("xccdf-1.2:description", ns)
        copy_contents(description, fixtext)
    return group


def create_output_root(benchmark_id, product):
    output_root = ET.Element("xccdf-1.2:Benchmark")
    output_root.set("id", benchmark_id)
    title = ET.SubElement(output_root, "xccdf-1.2:title")
    title.text = "DISA STIG for " + product["full_name"]
    return output_root


def add_overlays_to_output(overlays_root, xccdf_rules, ocil_questions, output_root):
    for overlay in overlays_root.findall("./xccdf-1.1:overlay", ns):
        group = convert_overlay_to_xccdf_group(overlay, xccdf_rules, ocil_questions)
        if group is not None:
            output_root.append(group)


def get_ocil_questions(ocil_filepath):
    ocil_root = ET.parse(ocil_filepath).getroot()
    questions = {}
    for bool_q_el in ocil_root.findall(".//ocil:boolean_question", ns):
        q_id = bool_q_el.get("id")
        rule_id = q_id.replace("ocil:ssg-", "").replace("_question:question:1", "")
        question_text_el = bool_q_el.find("ocil:question_text", ns)
        if question_text_el is not None:
            questions[rule_id] = question_text_el.text
    return questions


def main():
    ssg.xml.register_namespaces(ns)
    args = parse_args()
    product = ssg.yaml.open_raw(args.product_yaml)
    xccdf_root = ET.parse(args.xccdf).getroot()
    xccdf_rules = get_xccdf_rules(xccdf_root)
    benchmark_id = xccdf_root.get("id")
    overlays_root = ET.parse(args.overlay).getroot()
    ocil_questions = get_ocil_questions(args.ocil)
    output_root = create_output_root(benchmark_id, product)
    add_overlays_to_output(overlays_root, xccdf_rules, ocil_questions, output_root)
    out_tree = ET.ElementTree(output_root)
    if hasattr(ET, "indent"):
        ET.indent(out_tree)
    out_tree.write(args.output)


if __name__ == "__main__":
    main()
