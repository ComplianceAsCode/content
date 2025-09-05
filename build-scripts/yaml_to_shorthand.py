#!/usr/bin/python2

from __future__ import print_function

import argparse
import os
import os.path
import sys

import ssg.build_cpe
import ssg.build_yaml
import ssg.utils
import ssg.yaml


def parse_args():
    parser = argparse.ArgumentParser(
        description="Converts SCAP Security Guide YAML benchmark data "
        "(benchmark, rules, groups) to XCCDF Shorthand Format"
    )
    parser.add_argument(
        "--build-config-yaml", required=True,
        help="YAML file with information about the build configuration. "
        "e.g.: ~/scap-security-guide/build/build_config.yml"
    )
    parser.add_argument(
        "--product-yaml", required=True,
        help="YAML file with information about the product we are building. "
        "e.g.: ~/scap-security-guide/rhel7/product.yml"
    )
    parser.add_argument("--bash-remediation-fns",
                        help="XML with the XCCDF Group containing all bash "
                        "remediation functions stored as values."
                        "e.g.: build/bash-remediation-functions.xml")
    parser.add_argument("--output", required=True,
                        help="Output XCCDF shorthand file. "
                        "e.g.: /tmp/shorthand.xml")
    parser.add_argument("--resolved-rules-dir", "-l",
                        help="To which directory to put processed rule YAMLs.")
    parser.add_argument("--profiles-root",
                        help="Override where to look for profile files.")
    return parser.parse_args()


def main():
    args = parse_args()

    env_yaml = ssg.yaml.open_environment(
        args.build_config_yaml, args.product_yaml)
    base_dir = os.path.dirname(args.product_yaml)
    benchmark_root = ssg.utils.required_key(env_yaml, "benchmark_root")
    profiles_root = ""
    if args.profiles_root:
        profiles_root = args.profiles_root
    else:
        profiles_root = ssg.utils.required_key(env_yaml, "profiles_root")
    additional_content_directories = env_yaml.get("additional_content_directories", [])

    # we have to "absolutize" the paths the right way, relative to the
    # product_yaml path
    if not os.path.isabs(benchmark_root):
        benchmark_root = os.path.join(base_dir, benchmark_root)
    if not os.path.isabs(profiles_root):
        profiles_root = os.path.join(base_dir, profiles_root)
    add_content_dirs = [os.path.join(base_dir, er_root) for er_root in additional_content_directories if not os.path.isabs(er_root)]

    loader = ssg.build_yaml.BuildLoader(
        profiles_root, args.bash_remediation_fns, env_yaml,
        args.resolved_rules_dir)
    loader.process_directory_tree(benchmark_root, add_content_dirs)

    profiles = loader.loaded_group.profiles
    for p in profiles:
        p.validate_variables(loader.all_values)
        p.validate_rules(loader.all_rules, loader.all_groups)
        p.validate_refine_rules(loader.all_rules)

    product_cpes = ssg.build_cpe.ProductCPEs(env_yaml["product"])
    loader.export_group_to_file(args.output, product_cpes)


if __name__ == "__main__":
    main()
