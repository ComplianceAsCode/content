from __future__ import absolute_import
from __future__ import print_function

import os


def get_rule_dir_yaml(dir_path):
    """
    Returns the path to the yaml metadata for a rule directory,
    regardless of if it exists.
    """
    return os.path.join(dir_path, "rule.yml")


def get_rule_dir_id(path):
    """
    Returns the ID of a rule directory; correctly handles being passed
    either the directory path or the yaml metadata path.
    """
    dir_path = path

    if path.endswith("rule.yml"):
        dir_path = os.path.dirname(path)

    return os.path.basename(dir_path)


def is_rule_dir(dir_path):
    """
    Returns True iff dir_path is a valid rule directory which exists

    To be valid, dir_path must exist and be a directory and the file
    returned by get_rule_dir_yaml(dir_path) must exist.
    """
    rule_yaml = get_rule_dir_yaml(dir_path)

    is_dir = os.path.isdir(dir_path)
    has_rule_yaml = os.path.exists(rule_yaml)

    return is_dir and has_rule_yaml


def applies_to_product(file_name, product):
    """
    A OVAL or fix is filtered by product iff product is Falsy, file_name is
    "shared", or file_name is product. Note that this does not filter by
    contents of the fix or check, only by the name of the file.
    """

    return not product or (file_name == "shared" or file_name == product)


def get_rule_dir_ovals(dir_path, product=None):
    """
    Gets a list of OVALs contained in a rule directory. If product is
    None, returns all OVALs. If product is not None, returns applicable
    OVALs in order of priority:

        {{{ product }}}.xml -> shared.xml

    Only returns OVALs which exist.
    """

    if not is_rule_dir(dir_path):
        return []

    oval_dir = os.path.join(dir_path, "oval")
    has_oval_dir = os.path.isdir(oval_dir)
    if not has_oval_dir:
        return []

    results = []
    for oval_file in os.listdir(oval_dir):
        file_name, ext = os.path.splitext(oval_file)
        oval_path = os.path.join(oval_dir, oval_file)

        if ext == ".xml" and applies_to_product(file_name, product):
            if file_name == 'shared':
                results.append(oval_path)
            else:
                results.insert(0, oval_path)

    return results


def find_rule_dirs(base_dir):
    """
    Generator which yields all rule directories within a given base_dir, recursively
    """
    for root, dirs, _ in os.walk(base_dir):
        for dir_name in dirs:
            dir_path = os.path.join(root, dir_name)
            if is_rule_dir(dir_path):
                yield dir_path


def find_rule_dirs_in_paths(base_dirs):
    """
    Generator which yields all rule directories within a given directories list, recursively
    """
    if base_dirs:
        for cur_dir in base_dirs:
            for d in find_rule_dirs(cur_dir):
                yield d
