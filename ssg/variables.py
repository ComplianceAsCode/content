from __future__ import absolute_import
from __future__ import print_function

import glob
import os
import sys

from collections import defaultdict
from .constants import BENCHMARKS
from .profiles import get_profiles_from_products
from .yaml import open_and_macro_expand_from_dir


if sys.version_info >= (3, 9):
    list_type = list  # Python 3.9+ supports built-in generics
    dict_type = dict
else:
    from typing import List as list_type  # Fallback for older versions
    from typing import Dict as dict_type


# Cache variable files and respective content to avoid multiple reads
_var_files_cache = {}
_vars_content_cache = {}


def get_variable_files_in_folder(content_dir: str, subfolder: str) -> list_type[str]:
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


def get_variable_files(content_dir: str) -> list_type[str]:
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


def _get_variables_content(content_dir: str) -> dict_type:
    """
    Retrieve the content of all variable files from the specified content root directory.

    Args:
        content_dir (str): The root directory containing benchmark directories.

    Returns:
        dict: A dictionary where keys are variable IDs and values are the content of the variable
              files.
    """
    if content_dir in _vars_content_cache:
        return _vars_content_cache[content_dir]

    variables_content = {}

    for var_file in get_variable_files(content_dir):
        try:
            yaml_content = open_and_macro_expand_from_dir(var_file, content_dir)
        except Exception as e:
            print(f"Error processing file {var_file}: {e}")
            continue

        var_id = os.path.basename(var_file).split('.var')[0]
        variables_content[var_id] = yaml_content

    _vars_content_cache[content_dir] = variables_content
    return variables_content


def get_variable_property(content_dir: str, variable_id: str, property_name: str) -> str:
    """
    Retrieve a specific property of a variable from the content root directory.

    Args:
        content_dir (str): The root directory containing benchmark directories.
        variable_id (str): The ID of the variable to retrieve the property for.
        property_name (str): The name of the property to retrieve.

    Returns:
        str: The value of the specified property for the variable.
    """
    variables_content = _get_variables_content(content_dir)
    variable_content = variables_content.get(variable_id, {})
    return variable_content.get(property_name, '')


def get_variable_options(content_dir: str, variable_id: str = None) -> dict_type:
    """
    Retrieve the options for specific or all variables from the content root directory.

    If `variable_id` is provided, returns options for that variable only.
    If `variable_id` is not provided, returns a dictionary of all variables with their options.

    Args:
        content_dir (str): The root directory containing benchmark directories.
        variable_id (str, optional): The ID of the variable to retrieve options for.
                                     Defaults to None.

    Returns:
        dict: If `variable_id` is None, a dictionary where keys are variable IDs and values are
              their options. Otherwise, a dictionary of options for the specified variable.
    """
    variables_content = _get_variables_content(content_dir)
    all_options = {}

    for var_id, var_yaml in variables_content.items():
        options = var_yaml.get("options", {})

        if variable_id:
            if var_id == variable_id:
                return options
        else:
            all_options[var_id] = options

    if variable_id:
        print(f"Variable {variable_id} not found")
        return {}

    return all_options


def get_variables_from_profiles(profiles: list) -> dict_type:
    """
    Extracts variables from a list of profiles and organizes them into a nested dictionary.

    Args:
        profiles (list): A list of profile objects, each containing selections and id attributes.

    Returns:
        dict: A nested dictionary where the first level keys are variable names, the second level
              keys are product names, and the third level keys are profile IDs, with the
              corresponding values being the variable values.
    """
    variables = defaultdict(lambda: defaultdict(dict))
    for profile in profiles:
        for variable, value in profile.variables.items():
            variables[variable][profile.product_id][profile.profile_id] = value
    return _convert_defaultdict_to_dict(variables)


def _convert_defaultdict_to_dict(dictionary: defaultdict) -> dict_type:
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


def get_variables_by_products(content_dir: str, products: list) -> dict_type[str, dict]:
    """
    Retrieve variables by products from the specified content root directory.

    This function collects profiles for the given products and extracts variables from these
    profiles. If you already have a list of Profiles obtained by get_profiles_from_products()
    defined in profiles.py, consider to use get_variables_from_profiles() instead.

    Args:
        content_dir (str): The root directory of the content.
        products (list): A list of products to retrieve variables for.

    Returns:
        dict: A dictionary where keys are variable names and values are dictionaries of
              product-profile pairs.
    """
    profiles = get_profiles_from_products(content_dir, products)
    profiles_variables = get_variables_from_profiles(profiles)
    return _convert_defaultdict_to_dict(profiles_variables)


def get_variable_values(content_dir: str, profiles_variables: dict) -> dict_type:
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
    all_variables_options = get_variable_options(content_dir)

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
