from __future__ import print_function

import os
import json
import argparse
from glob import glob

from ssg.entities import profile
from ssg import build_yaml


RULE_CONTENT_FILES = (
    ("ansible", "fixes/ansible/{id}.yml"),
    ("bash", "fixes/bash/{id}.sh"),
    ("oval", "checks/oval/{id}.xml"),
    ("oval", "checks_from_templates/oval/{id}.xml"),
)

RULE_ATTRIBUTES = dict(
    platform_expression="",
)


def create_parser():
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--build-root", required=True,
        help="The root of the built product"
    )
    parser.add_argument(
        "--output", required=True,
        help="Where to save the manifest"
    )
    return parser


def add_rule_attributes(main_dir, output_dict, rule_id):
    rule_filename = os.path.join(main_dir, "rules", rule_id + ".yml")
    r = build_yaml.Rule.from_yaml(rule_filename)
    platform_names = r.cpe_platform_names.union(r.inherited_cpe_platform_names)
    output_dict["platform_names"] = sorted(list(platform_names))


def add_rule_associated_content(main_dir, output_dict, rule_id):
    contents = set()
    for content_id, expected_filename_template in RULE_CONTENT_FILES:
        expected_filename = os.path.join(main_dir, expected_filename_template.format(id=rule_id))
        if os.path.exists(expected_filename):
            contents.add(content_id)
    output_dict["content"] = list(contents)


def add_rule_data(output_dict, main_dir):
    rules_glob = os.path.join(main_dir, "rules", "*.yml")
    filenames = glob(rules_glob)
    for path in sorted(filenames):
        rid = os.path.splitext(os.path.basename(path))[0]
        output_dict[rid] = dict()
        add_rule_associated_content(main_dir, output_dict[rid], rid)
        add_rule_attributes(main_dir, output_dict[rid], rid)


def add_profile_data(output_dict, main_dir):
    profiles_glob = os.path.join(main_dir, "profiles", "*.profile")
    filenames = glob(profiles_glob)
    for path in sorted(filenames):
        p = profile.Profile.from_yaml(path)
        output_dict[p.id_] = dict()
        output_dict[p.id_]["rules"] = sorted(p.selected)

        value_assignments = list()
        for name, value in p.variables.items():
            value_assignments.append("{name}={value}".format(name=name, value=value))
        output_dict[p.id_]["values"] = sorted(value_assignments)


def main():
    parser = create_parser()
    args = parser.parse_args()

    main_dir = args.build_root
    product_name = os.path.basename(main_dir.rstrip("/"))
    output_dict = dict(product_name=product_name)

    rules_dict = dict()
    add_rule_data(rules_dict, main_dir)
    output_dict["rules"] = rules_dict

    profiles_dict = dict()
    add_profile_data(profiles_dict, main_dir)
    output_dict["profiles"] = profiles_dict

    with open(args.output, "w") as f:
        json.dump(output_dict, f)


if __name__ == "__main__":
    main()
