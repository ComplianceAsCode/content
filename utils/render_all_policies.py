#!/usr/bin/python3

import argparse
import os

import ssg.build_yaml
import ssg.controls
import ssg.entities.profile_base
import utils.template_renderer


TEMPLATES_DIR = os.path.join(os.path.dirname(__file__), "rendering")
CONTROLS_TEMPLATE = os.path.join(TEMPLATES_DIR, "controls-template.html")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Build HTML pages for all policies that are used in the "
        "given product")
    parser.add_argument("--product", required=True, help="Product ID")
    parser.add_argument(
        "--ssg-root", default=".",
        help="Path to the project's build directory")
    parser.add_argument(
        "--output-dir", required=True,
        help="Path to the output directory where the HTML pages will "
        "be stored")
    return parser.parse_args()


def get_used_policies(built_product_dir: str) -> set:
    policies = set()
    profiles_dir = os.path.join(built_product_dir, "profiles")
    for profile_file_name in os.listdir(profiles_dir):
        profile_file_path = os.path.join(profiles_dir, profile_file_name)
        profile = ssg.entities.profile_base.Profile.from_yaml(profile_file_path)
        for policy_id in profile.policies:
            policies.add(policy_id)
    return policies


def get_rules(root_abspath: str, built_product_dir: str) -> dict:
    resolved_rules_dir = os.path.join(built_product_dir, "rules")
    rules = dict()
    for r_file in os.listdir(resolved_rules_dir):
        r_file_path = os.path.join(resolved_rules_dir, r_file)
        rule = ssg.build_yaml.Rule.from_yaml(r_file_path)
        rule.relative_definition_location = rule.definition_location.replace(
            root_abspath, "")
        rules[rule.id_] = rule
    return rules


def get_values(root_abspath: str, built_product_dir: str) -> dict:
    resolved_values_dir = os.path.join(built_product_dir, "values")
    values = dict()
    for v_file in os.listdir(resolved_values_dir):
        v_file_path = os.path.join(resolved_values_dir, v_file)
        val = ssg.build_yaml.Value.from_yaml(v_file_path)
        val.relative_definition_location = val.definition_location.replace(
            root_abspath, "")
        values[val.id_] = val
    return values


def load_policy(controls_dir: str, policy_id: str) -> ssg.controls.Policy:
    policy_file = os.path.join(controls_dir, policy_id + ".yml")
    policy = ssg.controls.Policy(policy_file)
    policy.load()
    return policy


def render_policy(
        policy: ssg.controls.Policy, product_id: str, rules: dict,
        values: dict, output_dir: str) -> None:
    output_path = os.path.join(output_dir, policy.id + ".html")
    data = {
        "policy": policy,
        "title": f"Definition of {policy.title} for {product_id}",
        "rules": rules,
        "values": values
    }
    utils.template_renderer.render_template(
        data, CONTROLS_TEMPLATE, output_path)


def main():
    args = parse_args()
    root_path = os.path.abspath(args.ssg_root)
    build_dir = os.path.join(root_path, "build")
    built_product_dir = os.path.join(build_dir, args.product)
    policies_used_in_product = get_used_policies(built_product_dir)
    controls_dir = os.path.join(built_product_dir, "controls")
    rules = get_rules(root_path, built_product_dir)
    values = get_values(root_path, built_product_dir)
    if not os.path.exists(args.output_dir):
        os.mkdir(args.output_dir)
    for policy_id in policies_used_in_product:
        policy = load_policy(controls_dir, policy_id)
        render_policy(policy, args.product, rules, values, args.output_dir)


if __name__ == "__main__":
    main()
