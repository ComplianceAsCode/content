#!/usr/bin/env python

from __future__ import print_function

import os
import argparse

import ssg.build_sce
import ssg.environment


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
        "--output", required=True)
    p.add_argument(
        "scedirs", metavar="SCE_DIR", nargs="+",
        help="SCE definition scripts to build for the specified product.")
    args = p.parse_args()
    return args


if __name__ == "__main__":
    args = parse_args()

    # Create output directory if it doesn't yet exist.
    if not os.path.exists(args.output):
        os.makedirs(args.output)

    env_yaml = ssg.environment.open_environment(
        args.build_config_yaml, args.product_yaml)
    ssg.build_sce.checks(env_yaml, args.product_yaml, args.scedirs, args.output)
