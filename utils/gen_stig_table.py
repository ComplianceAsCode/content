#!/usr/bin/python3
import argparse
from utils.gen_tables_common import create_table
from ssg.constants import XCCDF11_NS, XCCDF12_NS
from ssg.xml import ElementTree as ET


def parse_args():
    parser = argparse.ArgumentParser(
        description="Create a HTML STIG table")
    parser.add_argument("input", help="Input XCCDF file")
    parser.add_argument("output", help="Output HTML file")
    return parser.parse_args()


def determine_xccdf_tree_namespace(tree):
    root = tree.getroot()
    if root.tag == "{%s}Benchmark" % XCCDF11_NS:
        xccdf_ns = XCCDF11_NS
    elif root.tag == "{%s}Benchmark" % XCCDF12_NS:
        xccdf_ns = XCCDF12_NS
    else:
        raise ValueError("Unknown root element '%s'" % root.tag)
    return xccdf_ns


def get_stats(root, ns):
    total = 0
    missing = 0
    missing_rules = []
    for rule in root.findall("xccdf:Group/xccdf:Rule", ns):
        total += 1
        if rule.get("id") == "Missing Rule":
            missing += 1
            version_text = rule.find("xccdf:version", ns).text
            missing_rules.append(version_text)
    implemented = total - missing
    stats = dict()
    stats["total"] = total
    stats["missing"] = missing
    stats["implemented"] = implemented
    stats["coverage"] = implemented / total * 100
    stats["missing_rules"] = missing_rules
    return stats


def subtree_texts(el):
    if el is None:
        return ""
    else:
        return "".join(el.itertext())


def get_rules(root, ns):
    rules = []
    for group in root.findall(".//xccdf:Group", ns):
        rule = dict()
        rule_el = group.find("./xccdf:Rule", ns)
        rule["V-ID"] = group.get("id")
        ident = rule_el.find("./xccdf:ident", ns)
        rule["CCI"] = ident.text if ident.text is not None else ""
        rule["CAT"] = rule_el.get("severity")
        rule["title"] = rule_el.find("./xccdf:title", ns).text
        rule["SRG"] = group.find("./xccdf:title", ns).text
        description = subtree_texts(rule_el.find("./xccdf:description", ns))
        if description is None:
            rule["description"] = ""
        elif "<VulnDiscussion>" in description:
            _, _, after_open = description.partition("<VulnDiscussion>")
            before_close, _, _ = after_open.partition("</VulnDiscussion>")
            rule["description"] = before_close
        else:
            rule["description"] = description
        check = rule_el.find("./xccdf:check/xccdf:check-content", ns)
        rule["check"] = check.text if check.text is not None else ""
        rule["fixtext"] = subtree_texts(rule_el.find("./xccdf:fixtext", ns))
        rule["version"] = rule_el.find("./xccdf:version", ns).text
        rule["mapped_rule"] = rule_el.get("id")
        rules.append(rule)
    return rules


def main():
    args = parse_args()
    tree = ET.parse(args.input)
    xccdf = determine_xccdf_tree_namespace(tree)
    ns = {"xccdf": xccdf}
    data = dict()
    root = tree.getroot()
    data["title"] = "Rules in " + root.find("./xccdf:title", ns).text
    data["stats"] = get_stats(root, ns)
    data["rules"] = get_rules(root, ns)
    create_table(data, "stig_template.html", args.output)


if __name__ == "__main__":
    main()
