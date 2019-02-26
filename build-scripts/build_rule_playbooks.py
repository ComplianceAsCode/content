#!/usr/bin/python3

import argparse
import ssg.playbook_builder


def parse_args():
    p = argparse.ArgumentParser()
    p.add_argument(
        "--input-dir", required=True, dest="input_dir",
        help="Input directory that contains all Ansible remediations"
        "snippets for the product we are building. "
        "e.g. ~/scap-security-guide/build/fedora/fixes/ansible"
    )
    p.add_argument(
        "--output-dir", required=True, dest="output_dir",
        help="Output directory to which the rule-based Ansible playbooks "
        "will be generated. "
        "e.g. ~/scap-security-guide/build/fedora/playbooks"
    )
    p.add_argument(
        "--product-yaml", required=True, dest="product_yaml",
        help="YAML file with information about the product we are building. "
        "e.g.: ~/scap-security-guide/rhel7/product.yml"
    )
    p.add_argument(
        "--profile",
        help="Generate Playbooks only for given Profile ID"
    )
    p.add_argument(
        "--rule",
        help="Generate Ansible Playbooks only for given rule specified by"
             "a shortened Rule ID"
    )
    return p.parse_args()


def main():
    args = parse_args()
    playbook_builder = ssg.playbook_builder.PlaybookBuilder(
        args.product_yaml, args.input_dir, args.output_dir
    )
    playbook_builder.build(args.profile, args.rule)


if __name__ == "__main__":
    main()
