#!/usr/bin/python3

import argparse
import os
import pathlib
import sys
import yaml
from collections import namedtuple

import ssg.jinja
from utils.template_renderer import FlexibleLoader

# Helper script used to generate an HTML page to display rendered policies.

Product = namedtuple("Product", ["id", "name"])
Policy = namedtuple("Policy", ["id", "name"])


def create_index(data, template_name, output_filename):
    html_jinja_template = os.path.join(
        os.path.dirname(__file__), template_name)
    env = ssg.jinja._get_jinja_environment(dict())
    env.loader = FlexibleLoader(os.path.dirname(html_jinja_template))
    result = ssg.jinja.process_file(html_jinja_template, data)
    with open(output_filename, "wb") as f:
        f.write(result.encode('utf8', 'replace'))


def get_control_files(ssg_root):
    control_files = []
    p = pathlib.Path(ssg_root)
    for control_file in p.glob("controls/*.yml"):
        # only process files, ignore controls directories
        if not os.path.isfile(control_file):
            continue
        policy_id = pathlib.Path(control_file).stem
        with open(control_file, "r") as f:
            policy_yaml = yaml.full_load(f)
        policy_name = policy_yaml["policy"]
        policy = Policy(id=policy_id, name=policy_name)
        control_files.append(policy)
    return control_files


def get_data(ssg_root):
    products = []
    p = pathlib.Path(ssg_root)
    for product_file in p.glob("products/**/product.yml"):
        product_dir = product_file.parent
        product_id = product_dir.name

        # skip if there are not built rendered-polices
        if not os.path.isdir(os.path.join(ssg_root, "build", product_id, "rendered-policies")):
            continue
        with open(product_file, "r") as f:
            product_yaml = yaml.full_load(f)
        product_name = product_yaml["full_name"]
        product = Product(id=product_id, name=product_name)
        products.append(product)
    data = {"products": products}
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
    data.update({"control_files": get_control_files(args.ssg_root)})
    create_index(data, "html_rendered_policies_index_template.html", args.output)
