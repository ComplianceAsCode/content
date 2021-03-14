#!/usr/bin/python3

import argparse
import ssg.playbook_builder
import os


def parse_args():
    p = argparse.ArgumentParser()
    p.add_argument(
        "--input-dir",
        help="Input directory that contains all Ansible remediations "
        "snippets for the product we are building. "
        "e.g. ~/scap-security-guide/build/fedora/fixes/ansible. "
        "If --input-dir is not specified, it is derived from --ssg-root."
    )
    p.add_argument(
        "--output-dir",
        help="Output directory to which the rule-based Ansible playbooks "
        "will be generated. "
        "e.g. ~/scap-security-guide/build/fedora/playbooks. "
        "If --output-dir is not specified, it is derived from --ssg-root."
    )
    p.add_argument(
        "--resolved-rules-dir",
        help="Directory that contains preprocessed rules in YAML format "
        "eg. ~/scap-security-guide/build/fedora/rules. "
        "If --resolved-rules-dir is not specified, it is derived from "
        "--ssg-root."
    )
    p.add_argument(
        "--resolved-profiles-dir",
        help="Directory that contains preprocessed profiles in YAML format "
        "eg. ~/scap-security-guide/build/fedora/profiles. "
        "If --resolved-profiles-dir is not specified, it is derived from "
        "--ssg-root."
    )
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
        "--profile",
        help="Generate Playbooks only for given Profile ID. Accepts profile "
        "ID in the short form, eg. 'ospp'. If not specified, Playbooks are "
        "built for all available profiles."
    )
    p.add_argument(
        "--rule",
        help="Generate Ansible Playbooks only for given rule specified by "
             "a shortened Rule ID, eg. 'package_sendmail_removed'. "
             "If not specified, Playbooks are built for every rule."
    )
    return p.parse_args()


def main():
    args = parse_args()
    env_yaml = ssg.yaml.open_environment(
        args.build_config_yaml, args.product_yaml)
    ssg_root = env_yaml["ssg_root"]
    product = env_yaml["product"]
    if args.input_dir:
        input_dir = args.input_dir
    else:
        input_dir = os.path.join(
            ssg_root, "build", product, "fixes", "ansible"
        )
    if args.output_dir:
        output_dir = args.output_dir
    else:
        output_dir = os.path.join(
            ssg_root, "build", product, "playbooks"
        )
    if args.resolved_rules_dir:
        resolved_rules_dir = args.resolved_rules_dir
    else:
        resolved_rules_dir = os.path.join(
            ssg_root, "build", product, "rules"
        )
    if args.resolved_profiles_dir:
        resolved_profiles_dir = args.resolved_profiles_dir
    else:
        resolved_profiles_dir = os.path.join(
            ssg_root, "build", product, "profiles"
        )
    playbook_builder = ssg.playbook_builder.PlaybookBuilder(
        args.product_yaml, input_dir, output_dir, resolved_rules_dir, resolved_profiles_dir
    )
    playbook_builder.build(args.profile, args.rule)


if __name__ == "__main__":
    main()
