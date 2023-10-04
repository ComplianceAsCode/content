#!/usr/bin/python3

import os
import argparse
import json

import ssg.build_yaml
import ssg.environment
import ssg.products
import ssg.rules
import ssg.yaml
import ssg.utils
import ssg.rule_yaml

from mod_prodtype import add_products

SSG_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))


def parse_args():
    parser = argparse.ArgumentParser(description="Automatically add a missing product "
                                     "reference to the prodtype key of a rule.yml based "
                                     "on inclusion in a specified profile")
    parser.add_argument("-j", "--json", type=str, action="store",
                        default="build/rule_dirs.json", help="File to read "
                        "json output of rule_dir_json from (defaults to "
                        "build/rule_dirs.json")
    parser.add_argument("-c", "--build-config-yaml", default="build/build_config.yml",
                        help="YAML file with information about the build configuration. "
                        "Defaults to build/build_config.yml")
    parser.add_argument("-p", "--profiles-root",
                        help="Override where to look for profile files.")
    parser.add_argument("product", type=str, help="Product to add prod types for")
    parser.add_argument("profile", type=str, help="Profile to iterate over")

    return parser.parse_args()


def autoprodtype(env_yaml, rule_dirs, profile_path, product):
    profile = ssg.build_yaml.ProfileWithInlinePolicies.from_yaml(profile_path, env_yaml)

    for rule_id in profile.selected + profile.unselected:
        if rule_id not in rule_dirs:
            msg = "Unable to find rule in rule_dirs.json: {0}"
            msg = msg.format(rule_id)
            raise ValueError(msg)

        add_products(rule_dirs[rule_id], [product], silent=True)


def main():
    args = parse_args()

    json_file = open(args.json, 'r')
    all_rules = json.load(json_file)

    linux_products, other_products = ssg.products.get_all(SSG_ROOT)
    all_products = linux_products.union(other_products)
    if args.product not in all_products:
        msg = "Unknown product {0}: check SSG_ROOT and try again"
        msg = msg.format(args.product)
        raise ValueError(msg)

    product_base = os.path.join(SSG_ROOT, "products", args.product)
    product_yaml = os.path.join(product_base, "product.yml")
    env_yaml = ssg.environment.open_environment(
            args.build_config_yaml, product_yaml, os.path.join(SSG_ROOT, "product_properties"))

    profiles_root = os.path.join(product_base, "profiles")
    if args.profiles_root:
        profiles_root = args.profiles_root

    profile_filename = args.profile + ".profile"
    profile_path = os.path.join(profiles_root, profile_filename)
    if not os.path.exists(profile_path):
        msg = "Unknown profile {0}: check profile, --profiles-root, and try again. "
        msg += "Note that profiles should not include '.profile' suffix."
        msg = msg.format(args.profile)
        raise ValueError(msg)

    autoprodtype(env_yaml, all_rules, profile_path, args.product)


if __name__ == "__main__":
    main()
