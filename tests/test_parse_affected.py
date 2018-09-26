#!/usr/bin/env python

from __future__ import print_function

import os
import sys

import ssg.constants
import ssg.oval
import ssg.rules
import ssg.utils
import ssg.yaml


def main():
    """
    Walk through all known products in the ssg root specified in sys.argv[1],
    and ensure that all ovals in all rule directories are parsable under
    ssg.oval.parse_affected(...).
    """

    if len(sys.argv) != 2:
        print("Error! Must supply only path to root of ssg directory",
              file=sys.stderr)
        sys.exit(1)

    ssg_root = sys.argv[1]

    guide_dirs = set()
    for product in ssg.constants.product_directories:
        product_dir = os.path.join(ssg_root, product)
        product_yaml_path = os.path.join(product_dir, "product.yml")
        product_yaml = ssg.yaml.open_raw(product_yaml_path)

        guide_dir = os.path.join(product_dir, product_yaml['benchmark_root'])
        if guide_dir in guide_dirs:
            continue

        for rule_dir in ssg.rules.find_rule_dirs(guide_dir):
            for oval in ssg.rules.get_rule_dir_ovals(rule_dir):
                oval_contents = ssg.utils.read_file_list(oval)
                results = ssg.oval.parse_affected(oval_contents)

                assert len(results) == 3
                assert isinstance(results[0], int)
                assert isinstance(results[1], int)

        guide_dirs.add(guide_dir)


if __name__ == "__main__":
    main()
