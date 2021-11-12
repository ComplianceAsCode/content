#!/usr/bin/env python

import sys
import os
import os.path
import argparse

import ssg.build_remediations as remediation
import ssg.build_yaml
import ssg.rules
import ssg.jinja
import ssg.environment
import ssg.utils
import ssg.xml


def parse_args():
    p = argparse.ArgumentParser(
        description="This script collects all remediation scripts, both "
        "static and templated, processes them with Jinja and puts them to "
        "the given output directory.")
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
    p.add_argument(
        "--remediation-type", required=True, action="append",
        help="language or type of the remediations we are combining."
        "example: ansible")
    p.add_argument(
        "--output-dir", required=True,
        help="output directory where all remediations will be saved"
    )
    p.add_argument(
        "--fixes-from-templates-dir", required=True,
        help="directory from which we will collect fixes generated from "
        "templates")

    return p.parse_args()


def prepare_output_dirs(output_dir, remediation_types):
    output_dirs = dict()
    for lang in remediation_types:
        language_output_dir = os.path.join(output_dir, lang)
        if not os.path.exists(language_output_dir):
            os.makedirs(language_output_dir)
        output_dirs[lang] = language_output_dir
    return output_dirs


def collect_remediations(
        rule, langs, fixes_from_templates_dirs, product, output_dirs,
        env_yaml):
    for lang in langs:
        rule_dir = os.path.dirname(rule.definition_location)
        ext = remediation.REMEDIATION_TO_EXT_MAP[lang]
        remediation_cls = remediation.REMEDIATION_TO_CLASS[lang]
        language_fixes_from_templates_dir = os.path.join(
            fixes_from_templates_dirs, lang)
        fix_path = None
        # first look for a static remediation
        rule_dir_remediations = remediation.get_rule_dir_remediations(
            rule_dir, lang, product)
        if len(rule_dir_remediations) > 0:
            # first item in the list has the highest priority
            fix_path = rule_dir_remediations[0]
        if fix_path is None:
            # check if we have a templated remediation instead
            if os.path.isdir(language_fixes_from_templates_dir):
                templated_fix_path = os.path.join(
                    language_fixes_from_templates_dir, rule.id_ + ext)
                if os.path.exists(templated_fix_path):
                    fix_path = templated_fix_path
        if fix_path is None:
            # neither static nor templated remediation found
            continue
        remediation_obj = remediation_cls(fix_path)
        remediation_obj.associate_rule(rule)
        fix = remediation.process(remediation_obj, env_yaml)
        if fix:
            output_file_path = os.path.join(output_dirs[lang], rule.id_ + ext)
            remediation.write_fix_to_file(fix, output_file_path)


def main():
    args = parse_args()

    env_yaml = ssg.environment.open_environment(
        args.build_config_yaml, args.product_yaml)

    product = ssg.utils.required_key(env_yaml, "product")
    output_dirs = prepare_output_dirs(args.output_dir, args.remediation_type)

    for rule_file in os.listdir(args.resolved_rules_dir):
        rule_path = os.path.join(args.resolved_rules_dir, rule_file)
        try:
            rule = ssg.build_yaml.Rule.from_yaml(rule_path, env_yaml)
        except ssg.build_yaml.DocumentationNotComplete:
            # Happens on non-debug build when a rule is
            # "documentation-incomplete"
            continue
        collect_remediations(
            rule, args.remediation_type, args.fixes_from_templates_dir,
            product, output_dirs, env_yaml)
    sys.exit(0)


if __name__ == "__main__":
    main()
