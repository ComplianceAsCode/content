#!/usr/bin/python3

import argparse
import collections
import glob
import os
import sys
from typing import Optional

import ssg.build_yaml
import ssg.components
import ssg.products
import utils.template_renderer
from utils.rendering.common import resolve_var_substitutions

SSG_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
TEMPLATES_DIR = os.path.join(os.path.dirname(__file__), "rendering")
COMPONENT_TEMPLATE = os.path.join(TEMPLATES_DIR, "component-template.html")
COMPONENT_INDEX_TEMPLATE = os.path.join(
    TEMPLATES_DIR, "component-index-template.html")

ComponentData = collections.namedtuple(
    "ComponentData", ["component", "rules"])

RuleData = collections.namedtuple(
    "RuleData", ["id", "title", "description", "rationale"])

ProductData = collections.namedtuple(
    "ProductData", ["product_id", "product_full_name", "components"])


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Script that converts the component data and component "
        "-> rule mapping to a set of HTML files that can be published "
        "online.")
    parser.add_argument(
        "-r", "--root", type=str, action="store", default=SSG_ROOT,
        help="Path to SSG root directory (defaults to %s)" % SSG_ROOT)
    parser.add_argument("output", help="output directory")
    args = parser.parse_args()
    return args


def create_component_html(
        output_dir: str, component_data: ComponentData) -> None:
    component_name = component_data.component.name
    title = f"Rules Related To '{component_name}'"
    data = dict(title=title, component_data=component_data)
    output_path = os.path.join(output_dir, component_name + ".html")
    utils.template_renderer.render_template(
        data, COMPONENT_TEMPLATE, output_path)


def create_index_html(
        output_dir: str, product_components: list) -> None:
    index_path = os.path.join(output_dir, "index.html")
    title = "List of Components"
    data = dict(title=title, product_components=product_components)
    utils.template_renderer.render_template(
        data, COMPONENT_INDEX_TEMPLATE, index_path)


def load_rule_data(rule_path: str) -> RuleData:
    rule = ssg.build_yaml.Rule.from_yaml(rule_path)
    description = resolve_var_substitutions(rule.description)
    rationale = resolve_var_substitutions(rule.rationale)
    rule_data = RuleData(
        id=rule.id_,
        title=rule.title,
        description=description,
        rationale=rationale)
    return rule_data


def find_rule_paths(component_rules: list, resolved_rules_dir: str) -> list:
    rule_paths = []
    for rule_id in component_rules:
        rule_path = os.path.join(resolved_rules_dir, rule_id + ".yml")
        if os.path.exists(rule_path):
            rule_paths.append(rule_path)
    return rule_paths


def collect_rules(rule_paths: list) -> list:
    rules = []
    for rule_path in rule_paths:
        rule_data = load_rule_data(rule_path)
        rules.append(rule_data)
    return rules


def process_component(
        component_path: str, resolved_rules_dir: str,
        output_product_dir: str) -> Optional[str]:
    component = ssg.components.Component(component_path)
    rule_paths = find_rule_paths(component.rules, resolved_rules_dir)
    if len(rule_paths) == 0:
        return None
    rules = collect_rules(rule_paths)
    component_data = ComponentData(component=component, rules=rules)
    create_component_html(output_product_dir, component_data)
    return component.name


def process_components(
        components_dir: str, resolved_rules_dir: str,
        output_product_dir: str) -> list:
    component_names = []
    for component_file in os.listdir(components_dir):
        component_path = os.path.join(components_dir, component_file)
        component_name = process_component(
            component_path, resolved_rules_dir, output_product_dir)
        if component_name:
            component_names.append(component_name)
    return sorted(component_names)


def process_product(
        product_id: str, ssg_root: str,
        output_dir: str) -> Optional[ProductData]:
    build_product_dir = os.path.join(ssg_root, "build", product_id)
    if not os.path.exists(build_product_dir):
        print(f"Product {product_id} isn't built.", file=sys.stderr)
        exit(1)
    product_yaml_path = os.path.join(build_product_dir, "product.yml")
    product_yaml = ssg.products.load_product_yaml(product_yaml_path)
    product_full_name = product_yaml['full_name']
    if "components_root" not in product_yaml:
        print(
            f"Product {product_id} doesn't use components.", file=sys.stderr)
        return None
    components_dir = os.path.join(
        build_product_dir, product_yaml["components_root"])
    resolved_rules_dir = os.path.join(build_product_dir, "rules")
    output_product_dir = os.path.join(output_dir, product_id)
    os.mkdir(output_product_dir)
    components = process_components(
        components_dir, resolved_rules_dir, output_product_dir)
    product_data = ProductData(
        product_id=product_id,
        product_full_name=product_full_name,
        components=components)
    return product_data


def find_products(ssg_root: str) -> list:
    product_ids = []
    build_product_dir = os.path.join(ssg_root, "build")
    for product_yaml_path in glob.glob(build_product_dir + "/**/product.yml"):
        product_id = os.path.basename(os.path.dirname(product_yaml_path))
        product_ids.append(product_id)
    return product_ids


def process_products(ssg_root: str, output_dir: str) -> list:
    product_ids = find_products(ssg_root)
    product_components = []
    for product_id in product_ids:
        product_data = process_product(product_id, ssg_root, output_dir)
        if product_data is None:
            continue
        product_components.append(product_data)
    return product_components


def main():
    args = parse_args()
    if not os.path.exists(args.output):
        os.mkdir(args.output)
    product_components = process_products(args.root, args.output)
    create_index_html(args.output, product_components)


if __name__ == "__main__":
    main()
