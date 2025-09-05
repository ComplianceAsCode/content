#!/usr/bin/env python

from __future__ import print_function

import os
import sys

import ssg.constants
import ssg.jinja
import ssg.oval
import ssg.rules
import ssg.utils
import ssg.yaml
import ssg.build_yaml
import ssg.rule_yaml


def main():
    """
    Walk through all known products in the ssg root specified in sys.argv[1],
    and ensure that all ovals in all rule directories are parsable under
    ssg.oval.parse_affected(...).
    """

    if len(sys.argv) != 3:
        print("Error! Must supply only path to root of ssg directory and the build_config.yml file path",
              file=sys.stderr)
        sys.exit(1)

    ssg_root = sys.argv[1]
    ssg_build_config_yaml = sys.argv[2]

    known_dirs = set()
    for product in ssg.constants.product_directories:
        product_dir = os.path.join(ssg_root, product)
        product_yaml_path = os.path.join(product_dir, "product.yml")
        product_yaml = ssg.yaml.open_raw(product_yaml_path)

        env_yaml = ssg.yaml.open_environment(ssg_build_config_yaml, product_yaml_path)
        ssg.jinja.add_python_functions(env_yaml)

        guide_dir = os.path.join(product_dir, product_yaml['benchmark_root'])
        additional_content_directories = product_yaml.get("additional_content_directories", [])
        add_content_dirs = [os.path.abspath(os.path.join(product_dir, rd)) for rd in additional_content_directories]

        for cur_dir in [guide_dir] + add_content_dirs:
            if cur_dir not in known_dirs:
                parse_affected(cur_dir, env_yaml)
                known_dirs.add(cur_dir)


def parse_affected(cur_dir, env_yaml):
    for rule_dir in ssg.rules.find_rule_dirs(cur_dir):
        rule_path = os.path.join(rule_dir, "rule.yml")
        try:
            rule = ssg.build_yaml.Rule.from_yaml(rule_path, env_yaml)
        except ssg.build_yaml.DocumentationNotComplete:
            # Happens on non-debug build when a rule is "documentation-incomplete"
            continue
        prodtypes = ssg.rule_yaml.parse_prodtype(rule.prodtype)

        env_yaml['rule_id'] = rule.id_
        env_yaml['rule_title'] = rule.title
        env_yaml['products'] = prodtypes  # default is all

        for oval in ssg.rules.get_rule_dir_ovals(rule_dir):
            xml_content = ssg.jinja.process_file_with_macros(oval, env_yaml)
            # Some OVAL definitions may render to an empty definition
            # when building OVAL 5.10 only content
            # Macros may leave empty new lines behind, lets strip them.
            xml_content = xml_content.strip()
            if not xml_content:
                continue

            oval_contents = ssg.utils.split_string_content(xml_content)

            try:
                results = ssg.oval.parse_affected(oval_contents)

                assert len(results) == 3
                assert isinstance(results[0], int)
                assert isinstance(results[1], int)

            except ValueError as e:
                print("No <affected> element found in file {}. "
                      " Parsed XML was:\n{}".format(oval, xml_content))
                raise e


if __name__ == "__main__":
    main()
