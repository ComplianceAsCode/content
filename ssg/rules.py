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

    if not product:
        return True

    return file_name == "shared" or file_name == product or product.startswith(file_name)


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
    Get a list of SCEs contained in a rule directory. If product is None,
    returns all SCEs. If product is not None, returns applicable SCEs in
    order of priority:

        {{{ product }}}.{{{ ext }}} -> shared.{{{ ext }}}

    Only returns SCEs which exist.
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
    Generator which yields all rule directories within a given base_dir, recursively
    """
    for root, dirs, _ in os.walk(base_dir):
        dirs.sort()
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
