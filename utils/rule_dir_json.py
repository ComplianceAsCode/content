#!/usr/bin/env python

from __future__ import print_function

import argparse
import os
import sys
from collections import defaultdict

import json

import ssg.build_yaml
import ssg.oval
import ssg.build_remediations
import ssg.products
import ssg.rules
import ssg.yaml


SSG_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
BUILD_OUTPUT = os.path.join(SSG_ROOT, "build", "rule_dirs.json")


def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("-r", "--root", type=str, action="store", default=SSG_ROOT,
                   help="Path to SSG root directory (defaults to %s)" % SSG_ROOT)
    parser.add_argument("-o", "--output", type=str, action="store", default=BUILD_OUTPUT,
                   help="File to write json output to (defaults to build/rule_dirs.json)")

    return parser.parse_args()


def walk_products(root, all_products):
    visited_dirs = set()

    all_rule_dirs = []
    product_yamls = {}

    for product in all_products:
        product_dir = os.path.join(root, product)
        product_yaml_path = os.path.join(product_dir, "product.yml")
        product_yaml = ssg.yaml.open_raw(product_yaml_path)
        product_yaml.update(ssg.yaml._get_implied_properties(product_yaml))
        product_yamls[product] = product_yaml

        guide_dir = os.path.join(product_dir, product_yaml['benchmark_root'])
        guide_dir = os.path.abspath(guide_dir)

        additional_content_directories = product_yaml.get("additional_content_directories", [])
        add_content_dirs = [os.path.abspath(os.path.join(product_dir, rd)) for rd in additional_content_directories]

        for cur_dir in [guide_dir] + add_content_dirs:
            if cur_dir not in visited_dirs:
                for rule_id, rule_dir in collect_rule_ids_and_dirs(cur_dir):
                    all_rule_dirs.append((rule_id, rule_dir, cur_dir, product))
                visited_dirs.add(cur_dir)

    return all_rule_dirs, product_yamls


def collect_rule_ids_and_dirs(rules_dir):
    for rule_dir in sorted(ssg.rules.find_rule_dirs(rules_dir)):
        yield ssg.rules.get_rule_dir_id(rule_dir), rule_dir


def handle_rule_yaml(product_list, product_yamls, rule_id, rule_dir, guide_dir):
    rule_obj = {'id': rule_id, 'dir': rule_dir, 'guide': guide_dir}
    rule_file = ssg.rules.get_rule_dir_yaml(rule_dir)

    prod_type = product_list[0]
    product_yaml = product_yamls[prod_type]

    rule_yaml = ssg.build_yaml.Rule.from_yaml(rule_file, product_yaml)
    rule_products = set()
    for product in product_list:
        if ssg.utils.is_applicable(rule_yaml.prodtype, product):
            rule_products.add(product)

    rule_products = sorted(rule_products)
    rule_obj['products'] = rule_products
    rule_obj['title'] = rule_yaml.title

    return rule_obj


def handle_ovals(product_list, product_yamls, rule_obj):
    rule_dir = rule_obj['dir']

    rule_ovals = {}
    oval_products = defaultdict(set)

    for oval_path in ssg.rules.get_rule_dir_ovals(rule_dir):
        oval_name = os.path.basename(oval_path)
        oval_product, _ = os.path.splitext(oval_name)
        oval_obj = {'name': oval_name, 'product': oval_product}

        platforms = ssg.oval.applicable_platforms(oval_path)
        cs_platforms = ','.join(platforms)

        oval_obj['platforms'] = platforms
        oval_obj['products'] = set()
        for product in product_list:
            if ssg.utils.is_applicable(cs_platforms, product):
                oval_products[product].add(oval_name)
                oval_obj['products'].add(product)

        oval_obj['products'] = sorted(oval_obj['products'])
        rule_ovals[oval_name] = oval_obj

    return rule_ovals, oval_products


def handle_remediations(product_list, product_yamls, rule_obj):
    rule_dir = rule_obj['dir']

    rule_remediations = {}
    r_products = defaultdict(set)
    for r_type in ssg.build_remediations.REMEDIATION_TO_EXT_MAP:
        rule_remediations[r_type] = {}
        r_paths = ssg.build_remediations.get_rule_dir_remediations(rule_dir, r_type)

        for r_path in r_paths:
            r_name = os.path.basename(r_path)
            r_product, r_ext = os.path.splitext(r_name)
            r_obj = {'type': r_type, 'name': r_name, 'product': r_product, 'ext': r_ext[1:]}

            prod_type = product_list[0]
            if r_product != 'shared' and r_product in product_list:
                prod_type = r_product
            product_yaml = product_yamls[prod_type]

            _, config = ssg.build_remediations.parse_from_file_with_jinja(
                r_path, product_yaml
            )
            platforms = config['platform']
            if not platforms:
                print(config['platform'])

            r_obj['platforms'] = sorted(map(lambda x: x.strip(), platforms.split(',')))
            r_obj['products'] = set()
            for product in product_list:
                if ssg.utils.is_applicable(platforms, product):
                    r_products[product].add(r_name)
                    r_obj['products'].add(product)

            r_obj['products'] = sorted(r_obj['products'])
            rule_remediations[r_type][r_name] = r_obj

    return rule_remediations, r_products


def main():
    args = parse_args()

    linux_products, other_products = ssg.products.get_all(args.root)
    all_products = linux_products.union(other_products)

    all_rule_dirs, product_yamls = walk_products(args.root, all_products)

    known_rules = {}
    for rule_id, rule_dir, guide_dir, given_product in all_rule_dirs:
        product_list = sorted(linux_products)
        if 'linux_os' not in guide_dir:
            product_list = [given_product]

        try:
            rule_obj = handle_rule_yaml(product_list, product_yamls, rule_id, rule_dir, guide_dir)
        except ssg.yaml.DocumentationNotComplete:
            # Happens on non-debug build when a rule is "documentation-incomplete"
            continue

        rule_obj['ovals'], oval_products = handle_ovals(product_list, product_yamls, rule_obj)
        rule_obj['remediations'], r_products = handle_remediations(product_list, product_yamls, rule_obj)

        # Validate oval products
        for key in oval_products:
            oval_products[key] = sorted(oval_products[key])
            if len(oval_products[key]) > 1:
                print("product has multiple ovals: %s - %s" % (key, ','.join(oval_products[key])), file=sys.stderr)

        rule_obj['oval_products'] = oval_products

        # Validate remediation products
        for key in r_products:
            r_products[key] = sorted(r_products[key])
            if len(r_products[key]) > 1:
                exts = sorted(map(lambda x: os.path.splitext(x)[1], r_products[key]))
                if len(exts) != len(set(exts)):
                    print("product has multiple remediations of the same type: %s - %s" % (key, ','.join(r_products[key])), file=sys.stderr)

        rule_obj['remediation_products'] = r_products

        known_rules[rule_id] = rule_obj

    f = open(args.output, 'w')
    j = json.dump(known_rules, f)
    if not f.closed:
        f.flush()
        f.close()

if __name__ == "__main__":
    main()
