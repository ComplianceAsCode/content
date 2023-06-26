from __future__ import print_function

import os
import json
import argparse
from glob import glob

from ssg.entities import profile


RULE_CONTENT_FILES = dict(
    ansible="fixes/ansible/{id}.yml",
    bash="fixes/bash/{id}.sh",
    oval="checks/oval/{id}.xml",
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


def add_rule_data(output_dict, main_dir):
    rules_glob = os.path.join(main_dir, "rules", "*.yml")
    filenames = glob(rules_glob)
    for path in sorted(filenames):
        rid = os.path.splitext(os.path.basename(path))[0]
        output_dict[rid] = dict()
        contents = set()
        for content_id, expected_filename_template in RULE_CONTENT_FILES.items():
            expected_filename = os.path.join(main_dir, expected_filename_template.format(id=rid))
            if os.path.exists(expected_filename):
                contents.add(content_id)
        output_dict[rid]["content"] = list(contents)


def add_profile_data(output_dict, main_dir):
    profiles_glob = os.path.join(main_dir, "profiles", "*.profile")
    filenames = glob(profiles_glob)
    for path in sorted(filenames):
        p = profile.Profile.from_yaml(path)
        output_dict[p.id_] = dict()
        output_dict[p.id_]["rules"] = sorted(p.selected)


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
