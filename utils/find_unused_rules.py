#!/usr/bin/python3
import argparse
import json
import pathlib
import sys
import xml.etree.ElementTree as ET

from ssg.constants import OSCAP_RULE, XCCDF12_NS

SSG_ROOT = pathlib.Path(__file__).resolve().parent.parent
BUILD_DIR = SSG_ROOT.joinpath("build")
RULE_DIR_JSON = BUILD_DIR.joinpath("rule_dirs.json")
EPILOG = """
This script lists rules that are not used in any data streams.
It requires that all products (and derivatives) are built.
To do this run ./build_product --derivatives
The script has the following return codes:
    0 - All rules are used in the data streams,
    1 - Some rules are not used in the data streams,
    2 - Not all products are built, and
    3 - rule_dirs.json does not exist.
"""


def _parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="List rules that are not used in any "
                                                 "data streams."
                                                 "Note that script requires that all products "
                                                 "(and derivatives) are built.", epilog=EPILOG)
    parser.add_argument("--root",
                        help="Root directory of the SSG git repository", default=SSG_ROOT)
    parser.add_argument("--json", help="Path to rule_dir.json file",
                        default=RULE_DIR_JSON.absolute())
    parser.add_argument("--force",
                        help="Force the operation even if all products are not built",
                        action="store_true")
    return parser.parse_args()


def _get_ds_rules(datastream_files):
    ds_rules = set()
    for ds in datastream_files:
        root = ET.parse(ds).getroot()
        root_elements = list(root.findall(".//{%s}Rule" % XCCDF12_NS))
        for rule in root_elements:
            rule_id = rule.get("id").removeprefix(OSCAP_RULE)
            ds_rules.add(rule_id)
    return ds_rules


def _get_product_count(products_path):
    products_count = 0
    for product in products_path.iterdir():
        if product.is_dir() and product.name != "example":
            products_count += 1
    return products_count


def main() -> int:
    args = _parse_args()
    root_path = pathlib.Path(args.root)
    products_path = root_path.joinpath("products")
    build_dir = root_path.joinpath("build")
    rule_dir_path = pathlib.Path(args.json)
    if not rule_dir_path.exists():
        print(f"Rule directory {rule_dir_path} does not exist.", file=sys.stderr)
        print("Hint run: ./utils/rule_dir_json.py", file=sys.stderr)
        return 3
    rule_dir_json = json.loads(rule_dir_path.read_text())
    all_rules = set(rule_dir_json.keys())
    products_count = _get_product_count(products_path)
    datastream_files = list(build_dir.glob("ssg-*-ds.xml"))
    ds_products = set()
    for ds in datastream_files:
        ds_products.add(ds.name.split("-")[1])
    if products_count > len(datastream_files):
        print("Not all products are built, cowardly refusing to continue.", file=sys.stderr)
        print(f"Products: {products_count}, data streams: {len(datastream_files)}", file=sys.stderr)
        print("Hint: run ./build_product --derivatives", file=sys.stderr)
        return 2
    ds_rules = _get_ds_rules(datastream_files)
    disuse_rules = all_rules - ds_rules
    if not disuse_rules:
        print("All rules are used in the datastream files.")
        return 0
    print("The following rules are not used in ANY of the provided data stream files:")
    print("\n".join(disuse_rules))
    return 1


if __name__ == "__main__":
    raise SystemExit(main())
