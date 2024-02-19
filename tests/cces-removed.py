#!/usr/bin/python3

import argparse
import json
import os
import sys
from typing import Set

SSG_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
JSON_PATH = os.path.join(SSG_ROOT, "build", "rule_dirs.json")


def _parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Given a list of products and CCE available list error and output if an "
                    "assigned CCE is in the available list. This scripts needs rule_dirs.json to "
                    "run.")
    parser.add_argument('-p', '--products', required=True,
                        help='Comma separated list (no spaces) of products to check')
    parser.add_argument('-l', '--cce-list', type=str, required=True,
                        help='Path to cce avail list')
    parser.add_argument('-j', '--json', type=str, default=JSON_PATH,
                        help='Path to rule_dirs.json file')
    parser.add_argument('-r', '--root', type=str, default=SSG_ROOT,
                        help='Path to the root of the content repo')
    return parser.parse_args()


def _process_rule(cces_in_use: Set[str], products: str, rule_obj: dict):
    for identifier_key, identifier_value in rule_obj['identifiers'].items():
        for product in products.split(","):
            if identifier_key.endswith(product):
                cces_in_use.add(identifier_value)


def _get_cces_in_use(data: dict, products: str) -> Set[str]:
    cces_in_use: Set[str] = set()
    for _, rule_obj in data.items():
        _process_rule(cces_in_use, products, rule_obj)
    return cces_in_use


def _get_avail_cces(cce_list: str) -> Set[str]:
    avail_cces: Set[str] = set()
    with open(cce_list) as f:
        for line in f.readlines():
            avail_cces.add(line.strip())
    return avail_cces


def main():
    args = _parse_args()
    products = args.products
    with open(args.json) as f:
        data = json.load(f)
    cces_in_use = _get_cces_in_use(data, products)

    if len(cces_in_use) == 0:
        print(f"Test is useless, no CCEs were found for products in {','.join(products)}")
        exit(2)

    avail_cces = _get_avail_cces(args.cce_list)

    not_removed = avail_cces.intersection(cces_in_use)
    if len(not_removed) != 0:
        for cce in not_removed:
            print(f"CCE {cce} not removed from {args.cce_list}.", file=sys.stderr)
        exit(1)


if __name__ == '__main__':
    main()
