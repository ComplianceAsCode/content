#!/usr/bin/python3

import xml.etree.ElementTree as ET
import os
import os.path
import argparse

XCCDF_NS = "http://checklists.nist.gov/xccdf/1.2"


def compare_ds_with_playbooks_dir(ds_path, playbooks_dir_path):
    tree = ET.parse(ds_path)
    root = tree.getroot()
    rules_in_ds_with_ansible_fix = []
    # uses the first benchmark if multiple benchmarks are present
    benchmark = root.find(".//{%s}Benchmark" % XCCDF_NS)
    for rule in benchmark.findall(".//{%s}Rule" % XCCDF_NS):
        for fix in rule.findall("./{%s}fix" % XCCDF_NS):
            system = fix.get("system")
            if system == "urn:xccdf:fix:script:ansible":
                id_ = rule.get("id")
                id_ = id_.replace("xccdf_org.ssgproject.content_rule_", "")
                rules_in_ds_with_ansible_fix.append(id_)
    playbooks_in_dir = []
    for filename in os.listdir(playbooks_dir_path):
        id_, _ = os.path.splitext(filename)
        playbooks_in_dir.append(id_)
    assert set(rules_in_ds_with_ansible_fix) == set(playbooks_in_dir)


def main():
    parser = argparse.ArgumentParser(
        description="Tests if Ansible Playbooks were generated for all rules"
        "that have an Ansible remediation available in datastream."
    )
    parser.add_argument("--build-dir", required=True,
                        help="Build directory containing built datastreams"
                        "and playbooks subdirectory")
    parser.add_argument("--product", required=True,
                        help="Product ID")
    args = parser.parse_args()
    ds_path = os.path.join(args.build_dir, "ssg-" + args.product + "-ds.xml")
    playbooks_dir_path = os.path.join(args.build_dir, args.product,
                                      "playbooks", "all")
    compare_ds_with_playbooks_dir(ds_path, playbooks_dir_path)


if __name__ == "__main__":
    main()
