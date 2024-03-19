import json
import sys
import os
from ssg.components import Component
from .most_used_rules import _sorted_dict_by_num_value

PYTHON_2 = sys.version_info[0] < 3

if not PYTHON_2:
    from .most_used_rules import _get_profiles_for_product
    from ..controleval import (
        load_controls_manager,
        get_available_products,
    )


def _count_components(components, rules_list, components_out):
    for rule in rules_list:
        component = get_component_name_by_rule_id(rule, components)
        if component in components_out:
            components_out[component] += 1
        else:
            components_out[component] = 1


def get_component_name_by_rule_id(rule_id, components):
    for component in components.values():
        if rule_id in component.rules:
            return component.name
    return "without_component"


def load_components(components_dir):
    components = {}
    for component_file in os.listdir(os.path.abspath(components_dir)):
        component_path = os.path.join(components_dir, component_file)
        component = Component(component_path)
        components[component.name] = component
    return components


def _process_all_products_from_controls(components_out):
    components = load_components("./components/")
    if PYTHON_2:
        raise Exception("This feature is not supported for python2.")

    for product in get_available_products():
        controls_manager = load_controls_manager("./controls/", product)
        for profile in _get_profiles_for_product(controls_manager, product):
            _count_components(components, profile.rules, components_out)


def command_most_used_components(args):
    components = {}

    _process_all_products_from_controls(components)

    sorted_components = _sorted_dict_by_num_value(components)

    f_string = "{}: {}"

    if args.format == "json":
        print(json.dumps(sorted_components, indent=4))
        return
    elif args.format == "csv":
        print("component_name,count_of_rules")
        f_string = "{},{}"

    for rule_id, rule_count in sorted_components.items():
        print(f_string.format(rule_id, rule_count))
