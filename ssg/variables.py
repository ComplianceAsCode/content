from __future__ import absolute_import
from __future__ import print_function

import os
import glob
import yaml

from collections import defaultdict
from .constants import BENCHMARKS
from .controls import ControlsManager
from .products import (
    get_profile_files_from_root,
    load_product_yaml,
    product_yaml_path,
)
from .yaml import open_and_macro_expand

# Cache variable files to avoid multiple reads
_var_files_cache = {}


def get_variable_files_in_folder(content_dir: str, subfolder: str) -> list[str]:
    """
    Retrieve a list of variable files within a specified folder in the project.

    Args:
        content_dir (str): The root directory of the content.
        subfolder (str): The folder within the project to search for variable files.

    Returns:
        list: A list of paths to variable files found within the specified folder.
    """
    rules_base_dir = os.path.join(content_dir, subfolder)
    search_dir = os.path.normpath(rules_base_dir)
    pattern = os.path.join(search_dir, '**', '*.var')
    return glob.glob(pattern, recursive=True)


def get_variable_files(content_dir: str) -> list[str]:
    """
    Retrieves all variable files from the specified content root directory.

    This function iterates through a predefined list of benchmark directories and collects all
    variable files within those directories.

    Args:
        content_dir (str): The root directory containing benchmark directories.

    Returns:
        list: A list of paths to all variable files found within the benchmark directories.
    """
    if content_dir in _var_files_cache:
        return _var_files_cache[content_dir]

    variable_files = []
    for benchmark_directory in BENCHMARKS:
        variable_files.extend(get_variable_files_in_folder(content_dir, benchmark_directory))
    _var_files_cache[content_dir] = variable_files
    return variable_files


def get_all_variables_options(content_dir: str) -> dict[str, dict]:
    """
    Retrieve all variable options from the specified content root directory.

    This function collects all variable files and extracts their options.

    Args:
        content_dir (str): The root directory containing benchmark directories.

    Returns:
        dict: A dictionary where keys are variable IDs and values are their options.
    """
    all_variable_files = get_variable_files(content_dir)
    all_options = {}

    for var_file in all_variable_files:
        try:
            yaml_content = open_and_macro_expand(var_file)
        except Exception as e:
            print(f"Error processing file {var_file}: {e}")
            continue

        variable_id = os.path.basename(var_file).split('.var')[0]
        options = yaml_content.get('options', {})
        all_options[variable_id] = options

    return all_options


def get_variable_options(content_dir: str, variable_id: str) -> dict[dict]:
    """
    Retrieve the options for a specific variable from the content root directory.

    Args:
        content_dir (str): The root directory containing benchmark directories.
        variable_id (str): The ID of the variable to retrieve options for.

    Returns:
        dict: A dictionary of options for the specified variable.
    """
    all_variable_files = get_variable_files(content_dir)

    for var_file in all_variable_files:
        var_id = os.path.basename(var_file).split('.var')[0]
        if var_id == variable_id:
            yaml_content = open_and_macro_expand(var_file)
            options = yaml_content.get('options', {})
            return options

    print(f"Variable {variable_id} not found")
    return {}


class ProfileVariables:
    """
    A class to represent profile variables.

    Attributes:
    -----------
    id : str
        The unique identifier for the profile.
    product : str
        The product associated with the profile.
    variables : dict
        A dictionary containing the variables for the profile.
    """
    def __init__(self, id, product, variables):
        self.id = id
        self.product = product
        self.variables = variables


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


def _load_yaml_profile_file(file_path: str) -> dict:
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


def _process_profile_extension(profiles_files: list, profile_yaml: dict,
                               profile_variables: dict, policies: dict) -> dict:
    """
    Processes the extension of a profile by recursively checking if the profile extends another
    profile and updating the profile variables accordingly.

    Args:
        profiles_files (list): List of profile file paths.
        profile_yaml (dict): The YAML content of the current profile.
        profile_variables (dict): The variables already defined in the current profile.
        policies (dict): The policies defined in the current profile.

    Returns:
        dict: The updated profile variables after processing the extended profile,
              or the original profile variables if no extension is found.
    """
    extended_profile = profile_yaml.get("extends", None)
    if isinstance(extended_profile, str):
        extended_profile = _get_extended_profile_path(profiles_files, extended_profile)
        if extended_profile is not None:
            return _process_profile(profiles_files, extended_profile, policies, profile_variables)
    return profile_variables


def _process_controls(control_line: str, profile_variables: dict, policies: dict) -> dict:
    """
    Process a control file inheritance to update profile variables based on the given policies.

    Args:
        control_line (str): A string representing the control line, which contains a policy ID and
                            optionally a level, separated by colons.
        profile_variables (dict): A dictionary of profile variables to be updated.
        policies (dict): A dictionary of policies, where each key is a policy ID and each value is
                         a policy object containing the controls.

    Returns:
        dict: The updated profile variables dictionary.

    Raises:
        KeyError: If the policy ID from the control line is not found in the policies dictionary.
    """
    if control_line.count(":") == 2:
        policy_id, _, level = control_line.split(":")
    else:
        policy_id, _ = control_line.split(":")
        level = None

    try:
        policy = policies[policy_id]
    except KeyError:
        print(f"Policy {policy_id} not found")
        return profile_variables

    for control in policy.controls:
        if level in control.levels:
            for rule in control.rules:
                if "=" in rule:
                    variable_name, variable_value = rule.split('=', 1)
                    # When a profile extends a control file, the variables explicitly defined in
                    # profiles files must be honored, so don't update variables already defined.
                    if variable_name not in profile_variables:
                        profile_variables[variable_name] = variable_value
    return profile_variables


def _process_selections(profile_yaml: dict, profile_variables: dict, policies: dict) -> dict:
    """
    Processes the selections from the profile YAML and updates the profile variables accordingly.

    Args:
        profile_yaml (dict): A dictionary containing the profile YAML data.
        profile_variables (dict): A dictionary to store the profile variables.
        policies (dict): A dictionary containing policy information.

    Returns:
        dict: The updated profile variables dictionary.
    """
    selections = profile_yaml.get("selections", None)
    for selected in selections:
        if "=" in selected and "!" not in selected:
            variable_name, variable_value = selected.split('=', 1)
            profile_variables[variable_name] = variable_value
        elif ":" in selected:
            profile_variables = _process_controls(selected, profile_variables, policies)
    return profile_variables


def _process_profile(profiles_files: list, file: str, policies: dict,
                     profile_variables=None) -> dict:
    """
    Processes a profile by loading its YAML file, handling profile extensions, and processing
    selections.

    Args:
        profiles_files (list): A list of profile file paths.
        file (str): The path to the profile file to be processed.
        policies (dict): A dictionary of policies defined by control files.
        profile_variables (dict, optional): A dictionary of profile variables. Defaults to None.

    Returns:
        dict: A dictionary containing the processed profile variables.
    """
    if profile_variables is None:
        profile_variables = {}

    profile_yaml = _load_yaml_profile_file(file)
    profile_variables = _process_profile_extension(profiles_files, profile_yaml,
                                                   profile_variables, policies)
    profile_variables = _process_selections(profile_yaml, profile_variables, policies)
    return profile_variables


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


def _get_profiles_from_products(content_dir: str, products: list) -> list:
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
            profile_variables = _process_profile(profiles_files, file, controls_manager.policies)
            profile = ProfileVariables(profile_id, product, profile_variables)
            profiles.append(profile)

    return profiles


def _get_variables_from_profiles(profiles: list) -> dict:
    """
    Extracts variables from a list of profiles and organizes them into a nested dictionary.

    Args:
        profiles (list): A list of profile objects, each containing variables, product, and id
                         attributes.

    Returns:
        dict: A nested dictionary where the first level keys are variable names, the second level
              keys are product names, and the third level keys are profile IDs, with the
              corresponding values being the variable values.
    """
    variables = defaultdict(lambda: defaultdict(dict))
    for profile in profiles:
        for variable, value in profile.variables.items():
            variables[variable][profile.product][profile.id] = value
    return variables


def _convert_defaultdict_to_dict(dictionary: defaultdict) -> dict:
    """
    Recursively converts a defaultdict to a regular dictionary.

    Args:
        dictionary (defaultdict): The defaultdict to convert.

    Returns:
        dict: The converted dictionary.
    """
    if isinstance(dictionary, defaultdict):
        dictionary = {k: _convert_defaultdict_to_dict(v) for k, v in dictionary.items()}
    return dictionary


def get_variables_by_products(content_dir: str, products: list) -> dict[str, dict]:
    """
    Retrieve variables by products from the specified content root directory.

    This function collects profiles for the given products and extracts variables from these
    profiles.

    Args:
        content_dir (str): The root directory of the content.
        products (list): A list of products to retrieve variables for.

    Returns:
        dict: A dictionary where keys are variable names and values are dictionaries of
              product-profile pairs.
    """
    profiles = _get_profiles_from_products(content_dir, products)
    profiles_variables = _get_variables_from_profiles(profiles)
    return _convert_defaultdict_to_dict(profiles_variables)


def get_variable_values(content_dir: str, profiles_variables: dict) -> dict:
    """
    Update the variables dictionary with actual values for each variable option.

    Given a content root directory and a dictionary of variables, this function retrieves the
    respective options values from variable files and updates the variables dictionary with
    these values.

    Args:
        content_dir (str): The root directory of the content.
        variables (dict): A dictionary where keys are variable names and values are dictionaries
                          of product-profile pairs.

    Returns:
        dict: The updated variables dictionary with possible values for each variable.
    """
    all_variables_options = get_all_variables_options(content_dir)

    for variable in profiles_variables:
        variable_options = all_variables_options.get(variable, {})
        for product, profiles in profiles_variables[variable].items():
            for profile in profiles:
                profile_option = profiles.get(profile, None)
                profiles_variables[variable][product][profile] = variable_options.get(
                    profile_option, 'default'
                )

        if 'any' not in profiles_variables[variable] or not isinstance(
                profiles_variables[variable]['any'], dict):
            profiles_variables[variable]['any'] = {}
        profiles_variables[variable]['any']['default'] = variable_options.get('default', None)
    return profiles_variables
