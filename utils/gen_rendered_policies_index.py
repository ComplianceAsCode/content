#!/usr/bin/python3

import argparse
import os
import pathlib
import yaml
from collections import namedtuple

from utils.template_renderer import render_template

# Helper script used to generate an HTML page to display rendered policies.

Product = namedtuple("Product", ["id", "name", "policy_ids"])

TEMPLATE = os.path.join(os.path.dirname(__file__), "html_rendered_policies_index_template.html")


def get_rendered_policies_ids(rendered_policies_dir):
    policy_ids = []
    for html_filename in rendered_policies_dir.glob("*.html"):
        policy_id = html_filename.stem
        policy_ids.append(policy_id)
    return policy_ids


def get_policy_names(ssg_root, products):
    policy_names = dict()
    for product in products:
        p = pathlib.Path(ssg_root, "build", product.id)
        for control_file in p.glob("controls/*.yml"):
            policy_id = pathlib.Path(control_file).stem
            if policy_id not in policy_names:
                with open(control_file, "r") as f:
                    policy_yaml = yaml.full_load(f)
                policy_name = policy_yaml["policy"]
                policy_names[policy_id] = policy_name
    return policy_names


def get_products(ssg_root):
    products = []
    p = pathlib.Path(ssg_root)
    for product_file in p.glob("products/**/product.yml"):
        product_dir = product_file.parent
        product_id = product_dir.name
        rendered_policies_dir = p / "build" / product_id / "rendered-policies"
        # skip if there are not built rendered-polices
        if not rendered_policies_dir.is_dir():
            continue
        with open(product_file, "r") as f:
            product_yaml = yaml.full_load(f)
        product_name = product_yaml["full_name"]
        policy_ids = get_rendered_policies_ids(rendered_policies_dir)
        product = Product(
            id=product_id,
            name=product_name,
            policy_ids=policy_ids)
        products.append(product)
    return products


def get_data(ssg_root):
    products = get_products(ssg_root)
    policy_names = get_policy_names(ssg_root, products)
    data = {"products": products, "policy_names": policy_names}
    return data


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "ssg_root",
        help="Path to the root directory of scap-security-guide")
    parser.add_argument(
        "output",
        help="Path where the output HTML file should be generated")
    args = parser.parse_args()
    data = get_data(args.ssg_root)
    render_template(data, TEMPLATE, args.output)
