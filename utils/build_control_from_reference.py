#!/usr/bin/python3

import argparse
import os
import json
import sys
from typing import List, Dict
import yaml

import ssg.environment
import ssg.yaml

SSG_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
BUILD_ROOT = os.path.join(SSG_ROOT, "build")
RULES_JSON = os.path.join(BUILD_ROOT, "rule_dirs.json")
BUILD_CONFIG = os.path.join(BUILD_ROOT, "build_config.yml")
OUTPUT_PATH = os.path.join(BUILD_ROOT, "reference_control.yml")


def _parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Given a reference this script will create an control file.")
    parser.add_argument("-j", "--json", type=str,
                        help=f"Path to the rule_dirs.json file. (Defaults to {RULES_JSON})",
                        default=RULES_JSON)
    parser.add_argument("-p", "--product", type=str, help="Product to build the control with",
                        required=True)
    parser.add_argument("-r", "--root", type=str,
                        help=f"Path to the root of the project. (Defaults to {SSG_ROOT}.",
                        default=SSG_ROOT)
    parser.add_argument("-ref", "--reference", type=str,
                        help="Reference to use for the profile. Example: ospp", required=True)
    parser.add_argument("-c", "--build-config-yaml", default=BUILD_CONFIG,
                        help=f"YAML file with information about the build configuration."
                             f"Defaults to (BUILD_CONFIG)")
    parser.add_argument("-o", "--output", type=str,
                        help=f"Path to output the control file. (Defaults to {OUTPUT_PATH})",
                        default=OUTPUT_PATH)
    return parser.parse_args()


def _get_rule_dirs(json_path: str) -> Dict[str, str]:
    with open(json_path, "r") as f:
        return json.load(f)


def _check_rule_dirs_path(json: str):
    if not os.path.exists(json):
        print(f"Path {json} does not exist.", file=sys.stderr)
        raise SystemExit(1)


def _get_env_yaml(root: str, product: str, build_config_yaml: str) -> str:
    product_dir = os.path.join(root, "products", product)
    product_yaml_path = os.path.join(product_dir, "product.yml")
    env_yaml = ssg.environment.open_environment(
        build_config_yaml, product_yaml_path, os.path.join(root, "product_properties"))
    return env_yaml


def _get_id_mapping(env_yaml, reference, json_path: str) -> Dict:
    rule_dir_json: Dict = _get_rule_dirs(json_path)
    id_mapping: Dict[str, list[str]] = {}
    for rule_id, rule_obj in rule_dir_json.items():
        rule_yaml = os.path.join(rule_obj["dir"], "rule.yml")
        rule = ssg.yaml.open_and_macro_expand(rule_yaml, env_yaml)
        if "references" not in rule:
            continue
        ref_id = rule["references"].get(reference)
        if not ref_id:
            continue
        ids: List[str] = ref_id.split(",")
        for _id in ids:
            if _id not in id_mapping:
                id_mapping[_id] = list()
            id_mapping[_id].append(rule_id)
    return id_mapping


def main() -> int:
    args = _parse_args()
    _check_rule_dirs_path(args.json)
    env_yaml = _get_env_yaml(args.root, args.product, args.build_config_yaml)
    id_mapping = _get_id_mapping(env_yaml, args.reference, args.json)
    output = dict()
    output["levels"] = [{'id': 'base'}]
    output["controls"] = list()
    for _id in sorted(id_mapping.keys()):
        rules = id_mapping[_id]
        control = dict()
        control["id"] = _id
        control["levels"] = ["base"]
        control["rules"] = rules
        control["status"] = "automated"
        output["controls"].append(control)

    with open(args.output, "w") as f:
        f.write(yaml.dump(output, sort_keys=False))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
