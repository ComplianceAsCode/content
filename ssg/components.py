from __future__ import print_function

from collections import defaultdict
import os

import ssg.yaml


def load(components_dir):
    components = {}
    for component_filename in os.listdir(components_dir):
        components_filepath = os.path.join(components_dir, component_filename)
        component = Component(components_filepath)
        components[component.name] = component
    return components


def _reverse_mapping(components, attribute):
    mapping = defaultdict(list)
    for component in components.values():
        for item in getattr(component, attribute):
            mapping[item].append(component.name)
    return mapping


def package_component_mapping(components):
    return _reverse_mapping(components, "packages")


def template_component_mapping(components):
    return _reverse_mapping(components, "templates")


def group_component_mapping(components):
    return _reverse_mapping(components, "groups")


def rule_component_mapping(components):
    return _reverse_mapping(components, "rules")


class Component:
    def __init__(self, filepath):
        yaml_data = ssg.yaml.open_raw(filepath)
        self.name = yaml_data["name"]
        self.rules = yaml_data["rules"]
        self.packages = yaml_data["packages"]
        self.templates = yaml_data.get("templates", [])
        self.groups = yaml_data.get("groups", [])
        self.changelog = yaml_data.get("changelog", [])


def get_rule_to_components_mapping(components):
    rule_to_components = defaultdict(list)
    for component in components.values():
        for rule_id in component.rules:
            rule_to_components[rule_id].append(component.name)
    return rule_to_components
