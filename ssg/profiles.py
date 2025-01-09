from __future__ import absolute_import
from __future__ import print_function

import os
import sys
import yaml

from .controls import ControlsManager
from .products import (
    get_profile_files_from_root,
    load_product_yaml,
    product_yaml_path,
)

if sys.version_info >= (3, 9):
    list_type = list  # Python 3.9+ supports built-in generics
    dict_type = dict
else:
    from typing import List as list_type  # Fallback for older versions
    from typing import Dict as dict_type

class ProfileSelections:
    """
    A class to represent profile with sections of rules and variables.

    Attributes:
    -----------
    profile_id : str
        The unique identifier for the profile.
    product : str
        The product associated with the profile.
    variables : dict
        A dictionary containing the variables for the profile.
    """
    def __init__(self, profile_id, profile_title, product):
        self.profile_id = profile_id
        self.profile_title = profile_title
        self.product = product
        self.rules = []
        self.unselected_rules = []
        self.variables = {}


def _load_product_yaml(content_dir: str, product: str) -> object:
    """
    Load the product YAML file and return its content as a Python object.

    Args:
        content_dir (str): The directory where the content is stored.
        product (str): The name of the product.

    Returns:
        object: The loaded YAML content as a Python object.
    """
    file_yaml_path = product_yaml_path(content_dir, product)
    return load_product_yaml(file_yaml_path)


def _load_yaml_profile_file(file_path: str) -> dict_type:
    """
    Load the content of a YAML file intended to profiles definitions.

    It is not necessary to process macros in this case.

    Args:
        file_path (str): The path to the YAML file.

    Returns:
        dict: The content of the YAML file as a dictionary.
    """
    with open(file_path, 'r') as file:
        try:
            return yaml.safe_load(file)
        except yaml.YAMLError as e:
            print(f"Error loading YAML profile file {file_path}: {e}")
            return {}


def _get_extended_profile_path(profiles_files: list, profile_name: str) -> str:
    """
    Retrieve the full path of a profile file from a list of profile file paths.

    Args:
        profiles_files (list of str): A list of file paths where profile files are located.
        profile_name (str): The name of the profile to search for.

    Returns:
        str: The full path of the profile file if found, otherwise None.
    """
    profile_file = f"{profile_name}.profile"
    profile_path = next((path for path in profiles_files if profile_file in path), None)
    return profile_path


def _process_profile_extension(profile: ProfileSelections, profile_yaml: dict,
                               profiles_files: list, policies: dict) -> ProfileSelections:
    """
    Processes the extension of a profile by recursively checking if the profile extends another
    profile and updating the profile selections accordingly.

    Args:
        profile (ProfileSelections): The profile object to be processed.
        profile_yaml (dict): The YAML content of the current profile.
        profiles_files (list): List of profile file paths.
        policies (dict): The policies defined in the current profile.

    Returns:
        ProfileSelections: The updated profile object.
    """
    extended_profile = profile_yaml.get("extends")
    if isinstance(extended_profile, str):
        extended_profile = _get_extended_profile_path(profiles_files, extended_profile)
        if extended_profile is not None:
            profile_yaml = _load_yaml_profile_file(extended_profile)
            return _process_profile(profile, profile_yaml, profiles_files, policies)
    return profile


def _process_controls(profile: ProfileSelections, control_line: str, policies: dict) -> ProfileSelections:
    """
    Process a control file inheritance to update profile selections based on the given policies.

    Args:
        profile (ProfileSelections): The profile object to be processed.
        control_line (str): A string representing the control line, which contains a policy ID and
                            optionally a level, separated by colons.
        policies (dict): A dictionary of policies, where each key is a policy ID and each value is
                         a policy object containing the controls.

    Returns:
        ProfileSelections: The updated profile object.

    Raises:
        KeyError: If the policy ID from the control line is not found in the policies dictionary.
    """
    if control_line.count(":") == 2:
        policy_id, _, level = control_line.split(":")
    else:
        policy_id, _ = control_line.split(":")
        level = 'all'

    try:
        policy = policies[policy_id]
    except KeyError:
        print(f"Policy {policy_id} not found")
        return profile

    for control in policy.controls:
        if level == 'all' or level in control.levels:
            for rule in control.rules:
                if "=" in rule:
                    variable_name, variable_value = rule.split('=', 1)
                    # When a profile extends a control file, the variables explicitly defined in
                    # profiles files must be honored, so don't update variables already defined.
                    if variable_name not in profile.variables:
                        profile.variables[variable_name] = variable_value
                elif rule not in profile.unselected_rules and rule not in profile.rules:
                    profile.rules.append(rule)
    return profile


def _process_selections(profile: ProfileSelections, profile_yaml: dict, policies: dict) -> ProfileSelections:
    """
    Processes the selections from the profile YAML and updates the profile accordingly.

    Args:
        profile (ProfileSelections): The profile object to be processed.
        profile_yaml (dict): A dictionary containing the profile YAML data.
        policies (dict): A dictionary containing policy information.

    Returns:
        profile: The updated profile object.
    """
    selections = profile_yaml.get("selections")
    for selected in selections:
        if selected.startswith("!"):
            profile.unselected_rules.append(selected[1:])
        elif "=" in selected:
            variable_name, variable_value = selected.split('=', 1)
            profile.variables[variable_name] = variable_value
        elif ":" in selected:
            profile = _process_controls(profile, selected, policies)
        else:
            profile.rules.append(selected)
    return profile


def _process_profile(profile: ProfileSelections, profile_yaml: dict, profiles_files: list,
                     policies: dict) -> ProfileSelections:
    """
    Processes a profile by handling profile extensions, and processing selections.

    Args:
        profile (ProfileSelections): The profile object to be processed.
        profile_yaml (dict): The YAML content of the profile.
        profiles_files (list): A list of profile file paths.
        policies (dict): A dictionary of policies defined by control files.

    Returns:
        ProfileSelections: The processed profile object.
    """
    profile = _process_profile_extension(profile, profile_yaml, profiles_files, policies)
    profile = _process_selections(profile, profile_yaml, policies)
    return profile


def _load_controls_manager(controls_dir: str, product_yaml: dict) -> object:
    """
    Loads and initializes a ControlsManager instance.

    Args:
        controls_dir (str): The directory containing control files.
        product_yaml (dict): The product configuration in YAML format.

    Returns:
        object: An instance of ControlsManager with loaded controls.
    """
    control_mgr = ControlsManager(controls_dir, product_yaml)
    control_mgr.load()
    return control_mgr


def get_profiles_from_products(content_dir: str, products: list) -> list_type:
    """
    Retrieves profiles with respective variables from the given products.

    Args:
        content_dir (str): The directory containing the content.
        products (list): A list of product names to retrieve profiles from.

    Returns:
        list: A list of ProfileVariables objects containing profile variables for each product.
    """
    profiles = []
    controls_dir = os.path.join(content_dir, 'controls')

    for product in products:
        product_yaml = _load_product_yaml(content_dir, product)
        profiles_files = get_profile_files_from_root(product_yaml, product_yaml)
        controls_manager = _load_controls_manager(controls_dir, product_yaml)
        for file in profiles_files:
            profile_id = os.path.basename(file).split('.profile')[0]
            profile_yaml = _load_yaml_profile_file(file)
            profile_title = profile_yaml.get("title")
            profile = ProfileSelections(profile_id, profile_title, product)
            profile = _process_profile(profile, profile_yaml, profiles_files, controls_manager.policies)
            profiles.append(profile)

    return profiles
