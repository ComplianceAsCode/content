#!/usr/bin/python3

import argparse
import os
import pathlib
import yaml
from collections import namedtuple

from utils.template_renderer import render_template

# Helper script used to generate an HTML page to display guides.

Product = namedtuple("Product", ["id", "name", "profiles"])
Profile = namedtuple("Profile", ["id", "title"])

TEMPLATE = os.path.join(os.path.dirname(__file__), "html_guides_index_template.html")


def get_data(ssg_root):
    products = []
    p = pathlib.Path(ssg_root)
    for product_file in p.glob("products/**/product.yml"):
        product_dir = product_file.parent
        product_id = product_dir.name
        with open(product_file, "r") as f:
            product_yaml = yaml.full_load(f)
        product_name = product_yaml["full_name"]
        product = Product(id=product_id, name=product_name, profiles=[])
        profiles_dir = product_dir / "profiles"
        for profile_file in profiles_dir.glob("*.profile"):
            with open(profile_file, "r") as g:
                profile_yaml = yaml.full_load(g)
            documentation_complete = profile_yaml["documentation_complete"]
            if not documentation_complete:
                continue
            profile_id = profile_file.stem
            profile_title = profile_yaml["title"]
            profile = Profile(id=profile_id, title=profile_title)
            product.profiles.append(profile)
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
    render_template(data, TEMPLATE, args.output)
