import sys
import os
from collections import defaultdict

import ssg.components

from .most_used_rules import _sorted_dict_by_num_value
from .common import generate_output

PYTHON_2 = sys.version_info[0] < 3

if not PYTHON_2:
    from .most_used_rules import _get_profiles_for_product
    from ..controleval import (
        load_controls_manager,
        load_product_yaml,
    )


def _count_components(components, rules_list, components_out):
    for rule in rules_list:
        component = get_component_name_by_rule_id(rule, components)
        components_out[component] += 1


def get_component_name_by_rule_id(rule_id, components):
    for component in components.values():
        if rule_id in component.rules:
            return component.name
    return "without_component"


def load_components(product):
    product_yaml = load_product_yaml(product)
    product_dir = product_yaml.get("product_dir")
    components_root = product_yaml.get("components_root")
    if components_root is None:
        return None
    components_dir = os.path.abspath(os.path.join(product_dir, components_root))
    return ssg.components.load(components_dir)


def _process_all_products_from_controls(components_out, products):
    if PYTHON_2:
        raise Exception("This feature is not supported for python2.")

    for product in products:
        components = load_components(product)
        if components is None:
            continue
        controls_manager = load_controls_manager("./controls/", product)
        for profile in _get_profiles_for_product(controls_manager, product):
            _count_components(components, profile.rules, components_out)


def command_most_used_components(args):
    components = defaultdict(int)

    _process_all_products_from_controls(components, args.products)

    sorted_components = _sorted_dict_by_num_value(components)
    csv_header = "component_name,count_of_rules"
    generate_output(sorted_components, args.format, csv_header)
