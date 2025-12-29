#!/usr/bin/python3

import argparse
import os
import re

import ssg.build_yaml
from utils.template_renderer import render_template


TABLE_DIR = os.path.join(os.path.dirname(__file__), "tables")
CCE_TEMPLATE = os.path.join(TABLE_DIR, "cce_tables_template.html")


def parse_args():
    parser = argparse.ArgumentParser(
        description="Create a CCE table")
    parser.add_argument(
        "--build-dir", default="build", help="Path to the build directory")
    parser.add_argument(
        "product", help="Short product ID, eg. rhel8")
    parser.add_argument("output")
    return parser.parse_args()


def get_default_var_value(var_dir, varname):
    var_path = os.path.join(var_dir, varname + ".json")
    var = ssg.build_yaml.Value.from_compiled_json(var_path)
    return var.options["default"]


def fix_var_sub_in_text(text, varname, value):
    return re.sub(
        r'<sub\s+idref="{var}"\s*/>'.format(var=varname),
        r"<tt>{val}</tt>".format(val=value), text)


def resolve_var_substitutions(var_dir, rule):
    variables = set(re.findall(r'<sub\s+idref="([^"]*)"\s*/>', rule.description))
    for var in variables:
        val = get_default_var_value(var_dir, var)
        rule.description = fix_var_sub_in_text(rule.description, var, val)
    return rule


def get_rules_by_cce(build_dir, product):
    rules_root = os.path.join(build_dir, product, "rules")
    vars_root = os.path.join(build_dir, product, "values")
    rules = dict()
    for file_name in os.listdir(rules_root):
        file_path = os.path.join(rules_root, file_name)
        rule = ssg.build_yaml.Rule.from_compiled_json(file_path)
        if "cce" in rule.identifiers:
            cce = rule.identifiers["cce"]
            rules[cce] = resolve_var_substitutions(vars_root, rule)
    return rules


if __name__ == "__main__":
    args = parse_args()
    data = dict()
    data["rules_by_cce"] = get_rules_by_cce(args.build_dir, args.product)
    data["full_name"] = ssg.utils.product_to_name(args.product)
    render_template(data, CCE_TEMPLATE, args.output)
