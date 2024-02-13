#!/usr/bin/python3

import argparse
import collections
import os

import ssg.build_stig
import ssg.build_yaml
import ssg.constants
import ssg.jinja
from utils.template_renderer import render_template


TABLE_DIR = os.path.join(os.path.dirname(__file__), "tables")
SRGMAP_TEMPLATE = os.path.join(TABLE_DIR, "srgmap_template.html")
SRGMAP_FLAT_TEMPLATE = os.path.join(TABLE_DIR, "srgmap_flat_template.html")


def parse_args():
    parser = argparse.ArgumentParser(
        description="Create a SRG map and a SRG flat map, both at once")
    parser.add_argument(
        "--build-dir", default="build", help="Path to the build directory")
    parser.add_argument(
        "product", help="Short product ID, eg. rhel8")
    parser.add_argument(
        "srgs", help="SRG file, eg. /shared/references/disa-os-srg-v2r1.xml")
    parser.add_argument("srgmap", help="Output SRG map path")
    parser.add_argument("srgmap_flat", help="Output flat SRG map path")
    return parser.parse_args()


def get_rules_by_srgid(build_dir, product):
    profile_filename = os.path.join(
        build_dir, product, "profiles", "stig.profile")
    profile = ssg.build_yaml.Profile.from_yaml(profile_filename)
    rules_root = os.path.join(build_dir, product, "rules")
    rules = collections.defaultdict(list)
    for rule_id in profile.selected:
        rule_filename = os.path.join(rules_root, rule_id + ".yml")
        rule = ssg.build_yaml.Rule.from_yaml(rule_filename)
        if "srg" in rule.references:
            for srgid in rule.references["srg"]:
                rules[srgid].append(rule)
    return rules


if __name__ == "__main__":
    args = parse_args()
    data = dict()
    data["srgs"] = ssg.build_stig.parse_srgs(args.srgs)
    data["rules_by_srgid"] = get_rules_by_srgid(args.build_dir, args.product)
    data["full_name"] = ssg.utils.product_to_name(args.product)
    render_template(data, SRGMAP_TEMPLATE, args.srgmap)
    render_template(data, SRGMAP_FLAT_TEMPLATE, args.srgmap_flat)
