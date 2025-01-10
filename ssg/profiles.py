from __future__ import absolute_import
from __future__ import print_function

import os
import sys
import yaml

from .controls import ControlsManager, Policy
from .products import (
    get_profile_files_from_root,
    load_product_yaml,
    product_yaml_path,
)


if sys.version_info >= (3, 9):
    dict_type = dict    # Python 3.9+ supports built-in generics
    list_type = list
    tuple_type = tuple
else:
    from typing import Dict as dict_type    # Fallback for older versions
    from typing import List as list_type
    from typing import Tuple as tuple_type


class ProfileSelections:
    """
    A class to represent profile with sections of rules and variables.

    Attributes:
    -----------
    profile_id : str
        The unique identifier for the profile.
    profile_title : str
        The profile title associated with the profile id.
    product_id : str
        The product id associated with the profile.
    product_title : str
        The product title associated with the product id.
    """
    def __init__(self, profile_id, profile_title, product_id, product_title):
        self.profile_id = profile_id
        self.profile_title = profile_title
        self.product_id = product_id
        self.product_title = product_title
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


def _parse_control_line(control_line: str) -> tuple_type[str, str]:
    """
    Parses a control line string and returns a tuple containing the first and third parts of the
    string, separated by a colon. If the string does not contain three parts, the second element
    of the tuple defaults to 'all'.

    Args:
        control_line (str): The control line string to be parsed.

    Returns:
        tuple[str, str]: A tuple containing the first part of the control line and either the
                         third part or 'all' if the third part is not present.
    """
    parts = control_line.split(":")
    if len(parts) == 3:
        return parts[0], parts[2]
    return parts[0], 'all'


def _process_selected_variable(profile: ProfileSelections, variable: str) -> None:
    """
    Processes a selected variable and updates the profile's variables.

    Args:
        profile (ProfileSelections): The profile object containing variables.
        variable (str): The variable in the format 'name=value'.

    Raises:
        ValueError: If the variable is not in the correct format.
    """
    variable_name, variable_value = variable.split('=', 1)
    if variable_name not in profile.variables:
        profile.variables[variable_name] = variable_value


def _process_selected_rule(profile: ProfileSelections, rule: str) -> None:
    """
    Adds a rule to the profile's selected rules if it is not already selected or unselected.

    Args:
        profile (ProfileSelections): The profile containing selected and unselected rules.
        rule (str): The rule to be added to the profile's selected rules.

    Returns:
        None
    """
    if rule not in profile.unselected_rules and rule not in profile.rules:
        profile.rules.append(rule)


def _process_control(profile: ProfileSelections, control: object) -> None:
    """
    Processes a control by iterating through its rules and applying the appropriate processing
    function. Not that at this level rules list in control can include both variables and rules.
    The function distinguishes between variable and rules based on the presence of an '='
    character in the rule.

    Args:
        profile (ProfileSelections): The profile selections to be processed.
        control: The control object containing rules to be processed.
    """
    for rule in control.rules:
        if "=" in rule:
            _process_selected_variable(profile, rule)
        else:
            _process_selected_rule(profile, rule)


def _update_profile_with_policy(profile: ProfileSelections, policy: Policy, level: str) -> None:
    """
    Updates the given profile with controls from the specified policy based on the provided level.

    Args:
        profile (ProfileSelections): The profile to be updated.
        policy (Policy): The policy containing controls to update the profile with.
        level (str): The level of controls to be processed. If 'all', all controls are processed.
                     Otherwise, only controls matching the specified level are processed.

    Returns:
        None
    """
    for control in policy.controls:
        if level == 'all' or level in control.levels:
            _process_control(profile, control)


def _process_controls(profile: ProfileSelections, control_line: str,
                      policies: dict) -> ProfileSelections:
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
    """
    policy_id, level = _parse_control_line(control_line)
    policy = policies.get(policy_id)

    if policy is None:
        print(f"Policy {policy_id} not found")
        return profile

    _update_profile_with_policy(profile, policy, level)
    return profile


def _process_selections(profile: ProfileSelections, profile_yaml: dict,
                        policies: dict) -> ProfileSelections:
    """
    Processes the selections from the profile YAML and updates the profile accordingly.

    Args:
        profile (ProfileSelections): The profile object to be processed.
        profile_yaml (dict): A dictionary containing the profile YAML data.
        policies (dict): A dictionary containing policy information.

    Returns:
        profile: The updated profile object.
    """
    selections = profile_yaml.get("selections", [])
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


def _sort_profiles_selections(profiles: list) -> ProfileSelections:
    """
    Sorts profiles selections (rules and variables) by selections ids.

    Args:
        profiles (list): A list of ProfileSelections objects to be sorted.

    Returns:
        ProfileSelections: The sorted list of ProfileSelections objects.
    """
    for profile in profiles:
        profile.rules = sorted(profile.rules)
        profile.unselected_rules = sorted(profile.unselected_rules)
        profile.variables = dict(sorted(profile.variables.items()))
    return profiles


def get_profiles_from_products(content_dir: str, products: list,
                               sorted: bool = False) -> list_type:
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
        product_title = product_yaml.get("full_name")
        profiles_files = get_profile_files_from_root(product_yaml, product_yaml)
        controls_manager = _load_controls_manager(controls_dir, product_yaml)
        for file in profiles_files:
            profile_id = os.path.basename(file).split('.profile')[0]
            profile_yaml = _load_yaml_profile_file(file)
            profile_title = profile_yaml.get("title")
            profile = ProfileSelections(profile_id, profile_title, product, product_title)
            profile = _process_profile(profile, profile_yaml, profiles_files,
                                       controls_manager.policies)
            profiles.append(profile)

    if sorted:
        profiles = _sort_profiles_selections(profiles)

    return profiles
