#!/usr/bin/python3

import argparse
import pathlib
import yaml
from collections import namedtuple

# Helper script used to generate an HTML page to display guides.

Product = namedtuple("Product", ["id", "name", "profiles"])
Profile = namedtuple("Profile", ["id", "title"])


def get_data(ssg_root):
    data = []
    p = pathlib.Path(ssg_root)
    for product_file in p.glob("**/product.yml"):
        product_dir = product_file.parent
        product_id = product_dir.name
        if product_id in ["example", "test_playbook_builder_data"]:
            continue
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
        data.append(product)
    return data


def print_data(data):
    for product in data:
        print(f'<h4>{product.name}</h4>')
        print(f'<ul>')
        for profile in product.profiles:
            print(f'<li><a class="light-link" href="ssg-{product.id}-guide-{profile.id}.html">{profile.title}</a></li>')
        print('</ul>')
        print('<div class="brSpace"></div>')


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "ssg_root",
        help="Path to the root directory of scap-security-guide")
    args = parser.parse_args()
    data = get_data(args.ssg_root)
    print_data(data)
