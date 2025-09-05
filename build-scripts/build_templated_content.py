#!/usr/bin/env python2

from __future__ import print_function

import os
import argparse

import ssg.yaml
import ssg.templates


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
        help="Directory with <rule-id>.yml resolved rule YAMLs. "
        "e.g.: ~/scap-security-guide/build/rhel7/rules"
    )
    p.add_argument(
        "--templates-dir", required=True,
        help="Path to directory which contains content templates. "
        "e.g.: ~/scap-security-guide/shared/templates"
    )
    p.add_argument(
        "--checks-dir", required=True,
        help="Path to which OVAL checks will be generated. "
        "e.g.: ~/scap-security-guide/build/rhel7/checks"
    )
    p.add_argument(
        "--remediations-dir", required=True,
        help="Path to which remediations will be generated. "
        "e.g.: ~/scap-security-guide/build/rhel7/fixes_from_templates"
    )
    args = p.parse_args()
    return args


if __name__ == "__main__":
    args = parse_args()

    env_yaml = ssg.yaml.open_environment(
        args.build_config_yaml, args.product_yaml)
    builder = ssg.templates.Builder(
        env_yaml, args.resolved_rules_dir, args.templates_dir,
        args.remediations_dir, args.checks_dir)
    builder.build()
