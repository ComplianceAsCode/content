#!/usr/bin/env python

from __future__ import print_function

import argparse
import os
import os.path

import ssg.build_yaml
import ssg.utils
import ssg.environment


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
    parser.add_argument("--output", required=True,
                        help="Output XCCDF shorthand file. "
                        "e.g.: /tmp/shorthand.xml")
    parser.add_argument("--resolved-base",
                        help="To which directory to put processed rule/group/value YAMLs.")
    return parser.parse_args()


def main():
    args = parse_args()

    env_yaml = ssg.environment.open_environment(
        args.build_config_yaml, args.product_yaml)
    base_dir = os.path.dirname(args.product_yaml)
    benchmark_root = ssg.utils.required_key(env_yaml, "benchmark_root")

    # we have to "absolutize" the paths the right way, relative to the
    # product_yaml path
    if not os.path.isabs(benchmark_root):
        benchmark_root = os.path.join(base_dir, benchmark_root)

    loader = ssg.build_yaml.LinearLoader(
        env_yaml, args.resolved_base)
    loader.load_compiled_content()
    loader.load_benchmark(benchmark_root)

    loader.export_benchmark_to_file(args.output)


if __name__ == "__main__":
    main()
