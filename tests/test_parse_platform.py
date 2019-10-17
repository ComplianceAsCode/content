#!/usr/bin/env python

from __future__ import print_function

import os
import sys

import ssg.build_remediations
import ssg.constants
import ssg.fixes
import ssg.rules
import ssg.utils
import ssg.yaml

REMEDIATION_LANGS = list(ssg.build_remediations.REMEDIATION_TO_EXT_MAP)


def main():
    """
    Walk through all known products in the ssg root specified in sys.argv[1],
    and ensure that all fixes in all rule directories are parsable under
    ssg.fixes.parse_platform(...).
    """

    if len(sys.argv) != 2:
        print("Error! Must supply only path to root of ssg directory",
              file=sys.stderr)
        sys.exit(1)

    ssg_root = sys.argv[1]

    guide_dirs_collected = set()
    for product in ssg.constants.product_directories:
        product_dir = os.path.join(ssg_root, product)
        product_yaml_path = os.path.join(product_dir, "product.yml")
        product_yaml = ssg.yaml.open_raw(product_yaml_path)

        relative_guide_dirs = product_yaml['benchmark_root']
        guide_dirs = [os.path.abspath(os.path.join(product_dir, d)) for d in relative_guide_dirs]

        for guide_dir in guide_dirs:
            if guide_dir in guide_dirs_collected:
                continue
            for rule_dir in ssg.rules.find_rule_dirs(guide_dir):
                for lang in REMEDIATION_LANGS:
                    for fix in ssg.build_remediations.get_rule_dir_remediations(rule_dir, lang):
                        fix_contents = ssg.utils.read_file_list(fix)
                        results = ssg.fixes.parse_platform(fix_contents)

                        assert results is not None
                        assert isinstance(results, int)

        guide_dirs_collected.add(guide_dir)


if __name__ == "__main__":
    main()
