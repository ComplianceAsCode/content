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


def rule_components_mapping(components):
    rules_to_components = defaultdict(list)
    for component in components.values():
        for rule_id in component.rules:
            rules_to_components[rule_id].append(component)
    return rules_to_components


def package_component_mapping(components):
    packages_to_components = {}
    for component in components.values():
        for package in component.packages:
            packages_to_components[package] = component.name
    return packages_to_components


def template_component_mapping(components):
    template_to_component = {}
    for component in components.values():
        for template in component.templates:
            template_to_component[template] = component.name
    return template_to_component


class Component:
    def __init__(self, filepath):
        yaml_data = ssg.yaml.open_raw(filepath)
        self.name = yaml_data["name"]
        self.rules = yaml_data["rules"]
        self.packages = yaml_data["packages"]
        self.templates = yaml_data.get("templates", [])
