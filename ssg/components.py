"""
Common functions for processing Components in SSG
"""

from __future__ import print_function

from collections import defaultdict
import os

import ssg.yaml


def load(components_dir):
    """
    Load components from a specified directory.

    Args:
        components_dir (str): The directory path containing component files.

    Returns:
        dict: A dictionary where the keys are component names and the values are component objects.
    """
    components = {}
    for component_filename in os.listdir(components_dir):
        components_filepath = os.path.join(components_dir, component_filename)
        component = Component(components_filepath)
        components[component.name] = component
    return components


def _reverse_mapping(components, attribute):
    """
    Creates a reverse mapping from the given attribute of components to the component names.

    Args:
        components (dict): A dictionary where keys are component names and values are component objects.
        attribute (str): The attribute of the component object to be used for creating the reverse mapping.

    Returns:
        defaultdict: A dictionary where keys are attribute values and values are lists of
                     component names that have that attribute value.
    """
    mapping = defaultdict(list)
    for component in components.values():
        for item in getattr(component, attribute):
            mapping[item].append(component.name)
    return mapping


def package_component_mapping(components):
    """
    Maps the given components to their respective packages.

    Args:
        components (dict): A dictionary where keys are component names and values are component details.

    Returns:
        dict: A dictionary where keys are package names and values are lists of components
              associated to those packages.
    """
    return _reverse_mapping(components, "packages")


def template_component_mapping(components):
    """
    Maps the given components to their corresponding templates.

    Args:
        components (dict): A dictionary where keys are component names and values are component details.

    Returns:
        dict: A dictionary where keys are template names and values are lists of components that
              use those templates.
    """
    return _reverse_mapping(components, "templates")


def group_component_mapping(components):
    """
    Groups components by their associated groups.

    Args:
        components (dict): A dictionary where keys are component names and values are dictionaries
                           containing component attributes, including a "groups" key.

    Returns:
        dict: A dictionary where keys are group names and values are lists of component names
              that belong to each group.
    """
    return _reverse_mapping(components, "groups")


def rule_component_mapping(components):
    """
    Maps the given components to their corresponding rules.

    Args:
        components (dict): A dictionary where keys are component names and values are component details.

    Returns:
        dict: A dictionary where keys are rule names and values are the corresponding components.
    """
    return _reverse_mapping(components, "rules")


class Component:
    """
    A class to represent a component.
    With regards to the content, a component usually represents a piece of software.

    Attributes:
        name (str): The name of the component.
        rules (list): A list of rules associated with the component.
        packages (list): A list of packages associated with the component.
        templates (list, optional): A list of templates associated with the component. Defaults to an empty list.
        groups (list, optional): A list of groups associated with the component. Defaults to an empty list.
        changelog (list, optional): A list of changelog entries for the component. Defaults to an empty list.
    """
    def __init__(self, filepath):
        yaml_data = ssg.yaml.open_raw(filepath)
        self.name = yaml_data["name"]
        self.rules = yaml_data["rules"]
        self.packages = yaml_data["packages"]
        self.templates = yaml_data.get("templates", [])
        self.groups = yaml_data.get("groups", [])
        self.changelog = yaml_data.get("changelog", [])


def get_rule_to_components_mapping(components):
    """
    Generates a mapping from rule IDs to component names.

    Args:
        components (dict): A dictionary where the keys are component names and the values are component objects.
                           Each component object is expected to have a 'rules' attribute (a list of rule IDs)
                           and a 'name' attribute (the name of the component).

    Returns:
        dict: A dictionary where the keys are rule IDs and the values are lists of component names
              that include the corresponding rule ID.
    """
    rule_to_components = defaultdict(list)
    for component in components.values():
        for rule_id in component.rules:
            rule_to_components[rule_id].append(component.name)
    return rule_to_components
