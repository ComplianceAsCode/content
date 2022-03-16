#!/usr/bin/python3

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
from ssg.build_cpe import ProductCPEs


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
    p.add_argument(
        "--platforms-dir", required=True,
        help="directory from which we collect compiled platforms")
    p.add_argument(
        "--cpe-items-dir", required=True,
        help="directory from which we collect compiled CPE items")

    return p.parse_args()


def prepare_output_dirs(output_dir, remediation_types):
    output_dirs = dict()
    for lang in remediation_types:
        language_output_dir = os.path.join(output_dir, lang)
        if not os.path.exists(language_output_dir):
            os.makedirs(language_output_dir)
        output_dirs[lang] = language_output_dir
    return output_dirs


def find_remediation(
        fixes_from_templates_dir, rule_dir, lang, product, expected_file_name):
    language_fixes_from_templates_dir = os.path.join(
        fixes_from_templates_dir, lang)
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
                language_fixes_from_templates_dir, expected_file_name)
            if os.path.exists(templated_fix_path):
                fix_path = templated_fix_path
    return fix_path


def process_remediation(
        rule, fix_path, lang, output_dirs, expected_file_name, env_yaml, cpe_platforms):
    remediation_cls = remediation.REMEDIATION_TO_CLASS[lang]
    remediation_obj = remediation_cls(fix_path)
    remediation_obj.associate_rule(rule)
    fix = remediation.process(remediation_obj, env_yaml, cpe_platforms)
    if fix:
        output_file_path = os.path.join(output_dirs[lang], expected_file_name)
        remediation.write_fix_to_file(fix, output_file_path)


def collect_remediations(
        rule, langs, fixes_from_templates_dir, product, output_dirs,
        env_yaml, cpe_platforms):
    rule_dir = os.path.dirname(rule.definition_location)
    for lang in langs:
        ext = remediation.REMEDIATION_TO_EXT_MAP[lang]
        expected_file_name = rule.id_ + ext
        fix_path = find_remediation(
            fixes_from_templates_dir, rule_dir, lang, product,
            expected_file_name)
        if fix_path is None:
            # neither static nor templated remediation found
            continue
        process_remediation(
            rule, fix_path, lang, output_dirs, expected_file_name, env_yaml, cpe_platforms)


def main():
    args = parse_args()

    env_yaml = ssg.environment.open_environment(
        args.build_config_yaml, args.product_yaml)

    product = ssg.utils.required_key(env_yaml, "product")
    output_dirs = prepare_output_dirs(args.output_dir, args.remediation_type)
    product_cpes = ProductCPEs()
    product_cpes.load_cpes_from_directory_tree(args.cpe_items_dir, env_yaml)
    cpe_platforms = dict()
    for platform_file in os.listdir(args.platforms_dir):
        platform_path = os.path.join(args.platforms_dir, platform_file)
        try:
            platform = ssg.build_yaml.Platform.from_yaml(platform_path, env_yaml, product_cpes)
        except ssg.build_yaml.DocumentationNotComplete:
            # Happens on non-debug build when a platform is
            # "documentation-incomplete"
            continue
        cpe_platforms[platform.name] = platform

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
            product, output_dirs, env_yaml, cpe_platforms)
    sys.exit(0)


if __name__ == "__main__":
    main()
