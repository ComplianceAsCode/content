#!/usr/bin/python3

import argparse
import csv
import os
import json
import sys

import ssg.rule_yaml
import ssg.yaml
import ssg.products
from utils.fix_rules import add_to_the_section


SSG_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
JSON_PATH = os.path.join(SSG_ROOT, "build", "rule_dir.json")

def _parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("csv", help="Path the CSV file the STIGD,Rules column")
    parser.add_argument("-r","--root", help="Root the root of CaC. Defaults to {ROOT}", default=SSG_ROOT)
    parser.add_argument(
        "-j", "--json", type=str, action="store",
        default="build/rule_dirs.json", help="File to read json "
        "output of rule_dir_json.py from (defaults to "
        "build/rule_dirs.json")
    parser.add_argument("-p", "--product", default="rhel9")
    return parser.parse_args()


def has_no_stigid(rule, product_yaml=None):
    product = product_yaml["product"]
    if "prodtype" in rule and product not in rule["prodtype"]:
        return False
    if 'references' in rule and rule['references'] is None:
        return True

    if 'references' in rule and rule['references'] is not None:
        for ident in rule['references']:
            if ident == "stigid@" + product:
                return False
    return True

def main():
    args = _parse_args()
    subst_dict = dict()
    product_path = os.path.join(args.root, 'products', args.product, 'product.yml')
    product = ssg.products.load_product_yaml(product_path)
    product.read_properties_from_directory(os.path.join(args.root, "product_properties"))
    subst_dict.update(product)
    csv_path = args.csv
    json_path = args.json
    product = args.product
    print(product)
    with open(json_path, 'r') as json_fp:
        json_dict = json.load(json_fp)
    with open(csv_path, 'r') as csv_fp:
        csv_reader = csv.DictReader(csv_fp)
        for stigid in csv_reader:
            stig_id = stigid["STIGID"]
            ident = dict()
            ident[f'stigid@{product}'] = stig_id
            rules = stigid["Rules"].split(",")
            for rule in rules:
                rule_json = json_dict.get(rule)
                if not rule_json:
                    print(f"Rule id {rule} was not found.", file=sys.stderr)
                    continue
                rule_path = os.path.join(rule_json['dir'], 'rule.yml')
                with open(rule_path, 'r') as rule_fp:
                    file_contents = rule_fp.read().split("\n")
                with open(rule_path, 'r', encoding="utf-8"):
                    yaml_contents = ssg.yaml.open_and_macro_expand(rule_path, subst_dict)
                if not has_no_stigid(yaml_contents, subst_dict):
                    continue
                new_contents = add_to_the_section(file_contents, yaml_contents, "references", ident)
                with open(rule_path, 'w') as f:
                    for line in new_contents:
                        print(line, file=f)

if __name__ == "__main__":
    main()