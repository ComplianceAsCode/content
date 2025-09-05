"""
Common functions for processing rules in SSG
"""

from __future__ import absolute_import
from __future__ import print_function

import os


def get_rule_dir_yaml(dir_path):
    """
    Constructs the path to the YAML metadata file for a given rule directory,
    regardless of if it exists.

    Args:
        dir_path (str): The path to the rule directory.

    Returns:
        str: The path to the "rule.yml" file within the specified directory.
    """
    return os.path.join(dir_path, "rule.yml")


def get_rule_dir_id(path):
    """
    Returns the base name of a rule directory.

    This function takes a file path and returns the base name of the directory.
    It correctly handles being passed either the directory path or the YAML metadata
    file path (ending with 'rule.yml').

    Args:
        path (str): The file or directory path.

    Returns:
        str: The base name of the rule directory.
    """
    dir_path = path

    if path.endswith("rule.yml"):
        dir_path = os.path.dirname(path)

    return os.path.basename(dir_path)


def is_rule_dir(dir_path):
    """
    Check if a given directory path is a valid rule directory.

    A valid rule directory must:
    1. Exist as a directory.
    2. Contain a specific YAML file as determined by get_rule_dir_yaml().

    Args:
        dir_path (str): The path to the directory to check.

    Returns:
        bool: True if dir_path is a valid rule directory, False otherwise.
    """
    rule_yaml = get_rule_dir_yaml(dir_path)

    is_dir = os.path.isdir(dir_path)
    has_rule_yaml = os.path.exists(rule_yaml)

    return is_dir and has_rule_yaml


def applies_to_product(file_name, product):
    """
    Determines if a given file applies to a specified product.

    An OVAL or fix is considered applicable to a product if any of the following conditions are met:
    - The product parameter is Falsy (e.g., None, False, or an empty string).
    - The file_name is "shared".
    - The file_name matches the product.
    - The product starts with the file_name.

    Note that this function only filters based on the file name and does not consider the contents
    of the fix or check.

    Args:
        file_name (str): The name of the file to check.
        product (str): The product to check against.

    Returns:
        bool: True if the file applies to the product, False otherwise.
    """
    if not product:
        return True

    return file_name == "shared" or file_name == product or product.startswith(file_name)


def get_rule_dir_ovals(dir_path, product=None):
    """
    Gets a list of OVALs contained in a rule directory.

    If product is None, returns all OVALs. Only returns OVALs which exist.

    Args:
        dir_path (str): The path to the rule directory.
        product (str, optional): The product name to filter OVALs. Defaults to None.

    Returns:
        list: A list of paths to OVAL files in the specified directory, ordered by priority.
    """
    if not is_rule_dir(dir_path):
        return []

    oval_dir = os.path.join(dir_path, "oval")
    has_oval_dir = os.path.isdir(oval_dir)
    if not has_oval_dir:
        return []

    # Two categories of results: those for a product and those that are shared
    # to multiple products. Within common results, there's two types:
    # those shared to multiple versions of the same type (added up front) and
    # those shared across multiple product types (e.g., RHEL and Ubuntu).
    product_results = []
    common_results = []
    for oval_file in sorted(os.listdir(oval_dir)):
        file_name, ext = os.path.splitext(oval_file)
        oval_path = os.path.join(oval_dir, oval_file)

        if ext == ".xml" and applies_to_product(file_name, product):
            # applies_to_product ensures we only have three entries:
            # 1. shared
            # 2. <product>
            # 3. <product><version>
            if file_name == 'shared':
                # Shared are the lowest priority items, add them to the end of
                # the common results.
                common_results.append(oval_path)
            elif file_name != product:
                # Here, the filename is a subset of the product, but isn't
                # the full product. Product here is both the product name
                # (e.g., ubuntu) and its version (2004). Filename could be
                # either "ubuntu" or "ubuntu2004" so we want this branch
                # to trigger when it is the former, not the latter. It is
                # the highest priority of common results, so insert it
                # before any shared ones.
                common_results.insert(0, oval_path)
            else:
                # Finally, this must be a product-specific result.
                product_results.append(oval_path)

    # Combine the two sets in priority order.
    return product_results + common_results


def get_rule_dir_sces(dir_path, product=None):
    """
    Get a list of SCEs contained in a rule directory.

    Only returns SCEs which exist.

    Args:
        dir_path (str): The path to the rule directory.
        product (str, optional): The product name to filter SCEs. If None, returns all SCEs.

    Returns:
        list: A list of paths to applicable SCE files. If product is specified, returns SCEs
              in the order of priority:
              - {product}.{ext}
              - shared.{ext}

    The function performs the following steps:
        1. Checks if the provided directory is a valid rule directory.
        2. Checks if the "sce" subdirectory exists within the rule directory.
        3. Iterates over the files in the "sce" directory, filtering and prioritizing them based
           on the product.
        4. Returns a list of applicable SCE file paths, with product-specific SCEs listed before
           shared SCEs.
    """
    if not is_rule_dir(dir_path):
        return []

    sce_dir = os.path.join(dir_path, "sce")
    has_sce_dir = os.path.isdir(sce_dir)
    if not has_sce_dir:
        return []

    results = []
    common_results = []
    for sce_file in sorted(os.listdir(sce_dir)):
        file_name, ext = os.path.splitext(sce_file)
        sce_path = os.path.join(sce_dir, sce_file)

        if applies_to_product(file_name, product):
            if file_name == 'shared':
                common_results.append(sce_path)
            elif file_name != product:
                common_results.insert(0, sce_path)
            else:
                results.append(sce_path)

    return results + common_results


def find_rule_dirs(base_dir):
    """
    Generator which yields all rule directories within a given base_dir, recursively.

    Args:
        base_dir (str): The base directory to start searching for rule directories.

    Yields:
        str: The path to each rule directory found within the base directory.
    """
    for root, dirs, _ in os.walk(base_dir):
        dirs.sort()
        for dir_name in dirs:
            dir_path = os.path.join(root, dir_name)
            if is_rule_dir(dir_path):
                yield dir_path


def find_rule_dirs_in_paths(base_dirs):
    """
    Generator which yields all rule directories within a given directories list, recursively.

    Args:
        base_dirs (list): A list of base directories to search for rule directories.

    Yields:
        str: Paths to rule directories found within the base directories.
    """
    if base_dirs:
        for cur_dir in base_dirs:
            for d in find_rule_dirs(cur_dir):
                yield d
