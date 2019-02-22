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
        "--build-config-yaml", required=True, dest="build_config_yaml",
        help="YAML file with information about the build configuration. "
        "e.g.: ~/scap-security-guide/build/build_config.yml"
    )
    p.add_argument(
        "--product-yaml", required=True, dest="product_yaml",
        help="YAML file with information about the product we are building. "
        "e.g.: ~/scap-security-guide/rhel7/product.yml"
    )
    p.add_argument(
        "--resolved-rules", required=True,
        help="Directory with <rule-id>.yml resolved rule YAMLs"
    )
    p.add_argument("--remediation_type", required=True,
                   help="language or type of the remediations we are combining."
                   "example: ansible")
    p.add_argument(
        "--output_dir", required=True,
        help="output directory where all remediations will be saved"
    )
    p.add_argument("fixdirs", metavar="FIX_DIR", nargs="+",
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

    # As fixes is continually updated, the last seen fix that is applicable for a
    # given fix_name is chosen to replace newer fix_names
    remediation_cls = remediation.REMEDIATION_TO_CLASS[args.remediation_type]

    fixes = dict()
    for fixdir in args.fixdirs:
        if os.path.isdir(fixdir):
            for filename in os.listdir(fixdir):
                file_path = os.path.join(fixdir, filename)
                fix_name, _ = os.path.splitext(filename)

                remediation_obj = remediation_cls(
                    env_yaml, args.resolved_rules, product, file_path, fix_name)
                # Fixes gets updated with the contents of the fix, if it is applicable
                remediation_obj.process(fixes)

    # Walk the guide last, looking for rule folders as they have the highest priority
    for _dir_path in ssg.rules.find_rule_dirs(guide_dir):
        rule_id = ssg.rules.get_rule_dir_id(_dir_path)

        contents = ssg.rules.get_rule_dir_remediations(_dir_path, args.remediation_type, product)
        for _path in reversed(contents):
            # To be compatible with the later checks, use the rule_id
            # (i.e., the value of _dir) to create the fix_name

            remediation_obj = remediation_cls(
                env_yaml, args.resolved_rules, product, _path, rule_id)
            # Fixes gets updated with the contents of the fix, if it is applicable
            remediation_obj.process(fixes)

    remediation.write_fixes_to_dir(fixes, args.remediation_type,
                                   args.output_dir)

    sys.stderr.write("Collected %d %s remediations.\n" % (len(fixes), args.remediation_type))

    sys.exit(0)


if __name__ == "__main__":
    main()
