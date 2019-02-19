#!/usr/bin/python2

from __future__ import print_function

import argparse
import os
import os.path
import sys

import ssg.build_yaml
import ssg.utils
import ssg.yaml


def parse_args():
    parser = argparse.ArgumentParser(
        description="Converts SCAP Security Guide YAML benchmark data "
        "(benchmark, rules, groups) to XCCDF Shorthand Format"
    )
    parser.add_argument(
        "--build-config-yaml", required=True, dest="build_config_yaml",
        help="YAML file with information about the build configuration. "
        "e.g.: ~/scap-security-guide/build/build_config.yml"
    )
    parser.add_argument(
        "--product-yaml", required=True, dest="product_yaml",
        help="YAML file with information about the product we are building. "
        "e.g.: ~/scap-security-guide/rhel7/product.yml"
    )
    parser.add_argument("--bash_remediation_fns", required=True,
                        help="XML with the XCCDF Group containing all bash "
                        "remediation functions stored as values."
                        "e.g.: build/bash-remediation-functions.xml")
    parser.add_argument("--output", required=True,
                        help="Output XCCDF shorthand file. "
                        "e.g.: /tmp/shorthand.xml")
    parser.add_argument("action",
                        choices=["build", "list-inputs", "list-outputs"],
                        help="Which action to perform.")
    parser.add_argument("--resolve-rules-into", "-l",
                        help="To which directory to put processed rule YAMLs.")
    return parser.parse_args()


def main():
    args = parse_args()

    if args.action == "list-outputs":
        print(args.output)
        sys.exit(0)


    env_yaml = ssg.yaml.open_environment(
        args.build_config_yaml, args.product_yaml)
    base_dir = os.path.dirname(args.product_yaml)
    benchmark_root = ssg.utils.required_key(env_yaml, "benchmark_root")
    profiles_root = ssg.utils.required_key(env_yaml, "profiles_root")

    # we have to "absolutize" the paths the right way, relative to the
    # product_yaml path
    if not os.path.isabs(benchmark_root):
        benchmark_root = os.path.join(base_dir, benchmark_root)
    if not os.path.isabs(profiles_root):
        profiles_root = os.path.join(base_dir, profiles_root)

    ssg.build_yaml.add_from_directory(args.action, None, benchmark_root,
                                      profiles_root, args.bash_remediation_fns,
                                      args.output, env_yaml)


if __name__ == "__main__":
    main()
