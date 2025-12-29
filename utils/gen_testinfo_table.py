#!/usr/bin/python3

import argparse
import os

import ssg.build_yaml
from utils.template_renderer import render_template, resolve_var_substitutions

TABLE_DIR = os.path.join(os.path.dirname(__file__), "tables")
TESTINFO_TEMPLATE = os.path.join(TABLE_DIR, "testinfo_template.html")


def parse_args():
    parser = argparse.ArgumentParser(
        description="Create a STIG testinfo table")
    parser.add_argument(
        "--build-dir", default="build", help="Path to the build directory")
    parser.add_argument(
        "product", help="Short product ID, eg. rhel8")
    parser.add_argument("testinfo", help="Output path")
    return parser.parse_args()


def get_rules(build_dir, product, profile):
    vars_root = os.path.join(build_dir, product, "values")
    rules_root = os.path.join(build_dir, product, "rules")
    rules = []
    for rule_id in profile.selected:
        rule_filename = os.path.join(rules_root, rule_id + ".json")
        rule = ssg.build_yaml.Rule.from_compiled_json(rule_filename)
        rule = resolve_var_substitutions(vars_root, rule, profile)
        rules.append(rule)
    return rules


if __name__ == "__main__":
    args = parse_args()
    data = dict()
    profile_filename = os.path.join(
        args.build_dir, args.product, "profiles", "stig.profile")
    profile = ssg.build_yaml.Profile.from_yaml(profile_filename)
    data["description"] = profile.description
    data["rules"] = get_rules(args.build_dir, args.product, profile)
    data["full_name"] = ssg.utils.product_to_name(args.product)
    render_template(data, TESTINFO_TEMPLATE, args.testinfo)
