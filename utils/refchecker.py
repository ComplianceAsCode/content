#!/usr/bin/env python

import sys
import os
import argparse
import json

import ssg.build_yaml
import ssg.products
import ssg.rules
import ssg.yaml
import ssg.utils
import ssg.rule_yaml

SSG_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))


def parse_args():
    parser = argparse.ArgumentParser(description="Check all rule.yml referenced in a given"
                                     "profile for a required reference identifier")
    parser.add_argument("-j", "--json", type=str, action="store",
                        default="build/rule_dirs.json", help="File to read "
                        "json output of rule_dir_json from (defaults to "
                        "build/rule_dirs.json")
    parser.add_argument("-c", "--build-config-yaml", default="build/build_config.yml",
                        help="YAML file with information about the build configuration. "
                        "Defaults to build/build_config.yml")
    parser.add_argument("-p", "--profiles-root",
                        help="Override where to look for profile files.")
    parser.add_argument("product", type=str, help="Product to check has required references")
    parser.add_argument("profile", type=str, help="Profile to iterate over")
    parser.add_argument("reference", type=str, help="Required reference system to check for")

    return parser.parse_args()


def load(rule_obj, env_yaml=None):
    """
    From the given rule_dir object, load the build_yaml.Rule associated with
    it.
    """

    yaml_file = ssg.rules.get_rule_dir_yaml(rule_obj['dir'])
    return ssg.build_yaml.Rule.from_yaml(yaml_file, env_yaml=env_yaml)


def load_for_product(rule_obj, product, env_yaml=None):
    """
    From the given rule_dir object, load the build_yaml.Rule associated with
    it, normalizing for the given product.
    """

    rule = load(rule_obj, env_yaml=env_yaml)
    rule.normalize(product)
    return rule


def reference_check(env_yaml, rule_dirs, profile_path, product, reference):
    profile = ssg.build_yaml.ProfileWithInlinePolicies.from_yaml(profile_path, env_yaml)

    ok = True
    for rule_id in profile.selected + profile.unselected:
        if rule_id not in rule_dirs:
            msg = "Unable to find rule in rule_dirs.json: {0}"
            msg = msg.format(rule_id)
            raise ValueError(msg)

        rule = load_for_product(rule_dirs[rule_id], product, env_yaml=env_yaml)

        if reference not in rule.references:
            ok = False
            msg = "Rule {0} lacks required reference {1} or {1}@{2}"
            msg = msg.format(rule_id, reference, product)
            print(msg, file=sys.stderr)

    return ok


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

    product_base = os.path.join(SSG_ROOT, args.product)
    product_yaml = os.path.join(product_base, "product.yml")
    env_yaml = ssg.yaml.open_environment(args.build_config_yaml, product_yaml)

    profiles_root = os.path.join(product_base, "profiles")
    if args.profiles_root:
        profiles_root = args.profiles_root

    profile_filename = args.profile + ".profile"
    profile_path = os.path.join(profiles_root, profile_filename)
    if not os.path.exists(profile_path):
        msg = "Unknown profile {0}: check profile, --profiles-root, and try again. "
        msg = "Note that the '.profile' suffix shouldn't be included."
        msg = msg.format(args.profile)
        raise ValueError(msg)

    ok = reference_check(env_yaml, all_rules, profile_path, args.product, args.reference)
    if not ok:
        sys.exit(1)


if __name__ == "__main__":
    main()
