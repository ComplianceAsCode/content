#!/usr/bin/env python2

import sys
import os
import os.path
import re
import errno
import argparse
import codecs

import ssg.build_remediations as remediation
import ssg.rules
import ssg.jinja
import ssg.yaml
import ssg.utils
import ssg.xml


def parse_args():
    p = argparse.ArgumentParser()
    p.add_argument(
        "--build-config-yaml", required=True,
        help="YAML file with information about the build configuration. "
        "e.g.: ~/scap-security-guide/build/build_config.yml"
    )
    p.add_argument(
        "--product-yaml", required=True,
        help="YAML file with information about the product we are building. "
        "e.g.: ~/scap-security-guide/rhel7/product.yml"
    )
    p.add_argument(
        "--resolved-rules-dir", required=True,
        help="Directory with <rule-id>.yml resolved rule YAMLs"
    )
    p.add_argument("--remediation-type", required=True,
                   help="language or type of the remediations we are combining."
                   "example: ansible")
    p.add_argument(
        "--output-dir", required=True,
        help="output directory where all remediations will be saved"
    )
    p.add_argument("fix_dirs", metavar="FIX_DIR", nargs="+",
                   help="directory(ies) from which we will collect "
                   "remediations to combine.")

    return p.parse_args()


def main():
    args = parse_args()

    env_yaml = ssg.yaml.open_environment(
        args.build_config_yaml, args.product_yaml)

    product = ssg.utils.required_key(env_yaml, "product")

    product_dir = os.path.dirname(args.product_yaml)
    relative_guide_dir = ssg.utils.required_key(env_yaml, "benchmark_root")
    guide_dir = os.path.abspath(os.path.join(product_dir, relative_guide_dir))
    additional_content_directories = env_yaml.get("additional_content_directories", [])
    add_content_dirs = [os.path.abspath(os.path.join(product_dir, rd)) for rd in additional_content_directories]

    # As fixes is continually updated, the last seen fix that is applicable for a
    # given fix_name is chosen to replace newer fix_names
    remediation_cls = remediation.REMEDIATION_TO_CLASS[args.remediation_type]

    rule_id_to_remediation_map = collect_fixes(
        product, [guide_dir] + add_content_dirs, args.fix_dirs, args.remediation_type)

    fixes = dict()
    for rule_id, fix_path in rule_id_to_remediation_map.items():
        remediation_obj = remediation_cls(fix_path)
        rule_path = os.path.join(args.resolved_rules_dir, rule_id + ".yml")
        if os.path.isfile(rule_path):
            remediation_obj.load_rule_from(rule_path)
            # Fixes gets updated with the contents of the fix
            # if it is applicable
            remediation.process(remediation_obj, env_yaml, fixes, rule_id)

    remediation.write_fixes_to_dir(fixes, args.remediation_type,
                                   args.output_dir)

    sys.exit(0)


def collect_fixes(product, rules_dirs, fix_dirs, remediation_type):
    # path -> remediation
    # rule ID -> assoc rule
    rule_id_to_remediation_map = dict()
    for fixdir in fix_dirs:
        if os.path.isdir(fixdir):
            for filename in os.listdir(fixdir):
                file_path = os.path.join(fixdir, filename)
                rule_id, _ = os.path.splitext(filename)
                rule_id_to_remediation_map[rule_id] = file_path

    # Walk the guide last, looking for rule folders as they have the highest priority
    for _dir_path in ssg.rules.find_rule_dirs_in_paths(rules_dirs):
        rule_id = ssg.rules.get_rule_dir_id(_dir_path)

        contents = remediation.get_rule_dir_remediations(_dir_path, remediation_type, product)
        for _path in reversed(contents):
            # To be compatible with the later checks, use the rule_id
            # (i.e., the value of _dir) to create the fix_name
            rule_id_to_remediation_map[rule_id] = _path
    return rule_id_to_remediation_map


if __name__ == "__main__":
    main()
