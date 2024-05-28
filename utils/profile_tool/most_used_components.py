import sys
import os
from collections import defaultdict

import ssg.components

from .most_used_rules import _sorted_dict_by_num_value
from .common import generate_output, merge_dicts, remove_zero_counts

PYTHON_2 = sys.version_info[0] < 3

if not PYTHON_2:
    from .most_used_rules import _get_profiles_for_product
    from ..controleval import (
        load_controls_manager,
        load_product_yaml,
    )


def _count_rules_components(component_name, rules, used_rules_of_components_out):
    used_rules = used_rules_of_components_out[component_name]
    for rule in rules:
        used_rules[rule] += 1


def _count_components(components, rules_list, components_out, used_rules_of_components_out):
    for component_name, component in components.items():
        intersection = set(component.rules).intersection(set(rules_list))
        components_out[component_name] += 0
        if len(intersection) > 0:
            components_out[component_name] += 1
        if component_name not in used_rules_of_components_out:
            used_rules_of_components_out[component_name] = {
                rule_id: 0 for rule_id in component.rules
            }

        _count_rules_components(component_name, intersection, used_rules_of_components_out)


def load_components(product):
    product_yaml = load_product_yaml(product)
    product_dir = product_yaml.get("product_dir")
    components_root = product_yaml.get("components_root")
    if components_root is None:
        return None
    components_dir = os.path.abspath(os.path.join(product_dir, components_root))
    return ssg.components.load(components_dir)


def _process_all_products_from_controls(components_out, used_rules_of_components_out, products):
    if PYTHON_2:
        raise Exception("This feature is not supported for python2.")

    for product in products:
        components = load_components(product)
        if components is None:
            continue
        controls_manager = load_controls_manager("./controls/", product)
        for profile in _get_profiles_for_product(controls_manager, product):
            _count_components(
                components, profile.rules, components_out, used_rules_of_components_out
            )


def _sort_rules_of_components(used_rules_of_components):
    out = {}
    for key, value in used_rules_of_components.items():
        out[key] = _sorted_dict_by_num_value(value)
    return out


def _remove_zero_counts_of(used_rules_of_components):
    return {
        component_name: remove_zero_counts(rules_dict)
        for component_name, rules_dict in used_rules_of_components.items()
    }


def command_most_used_components(args):
    components = defaultdict(int)
    used_rules_of_components = {}

    _process_all_products_from_controls(components, used_rules_of_components, args.products)

    if not args.all:
        components = remove_zero_counts(components)
        used_rules_of_components = _remove_zero_counts_of(used_rules_of_components)

    sorted_components = _sorted_dict_by_num_value(components)
    csv_header = "component_name,count_of_profiles"
    if args.used_rules:
        csv_header = "component_name,count_of_profiles,used_rules:count_of_profiles"
        delim = " "
        if args.format == "csv":
            delim = ","
        sorted_used_rules_of_components = _sort_rules_of_components(used_rules_of_components)
        sorted_components = merge_dicts(sorted_components, sorted_used_rules_of_components, delim)

    generate_output(sorted_components, args.format, csv_header)
