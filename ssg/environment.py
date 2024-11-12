"""
Common functions for processing Environment in SSG
"""

from __future__ import absolute_import
from __future__ import print_function


from .products import load_product_yaml
from .yaml import open_raw


def open_environment(build_config_yaml_path, product_yaml_path, product_properties_path=None):
    """
    Opens and merges environment configurations from given YAML files.

    Args:
        build_config_yaml_path (str): The file path to the build configuration YAML file.
        product_yaml_path (str): The file path to the product YAML file.
        product_properties_path (str, optional): The directory path containing product properties
                                                 files. Defaults to None.

    Returns:
        dict: A dictionary containing the merged contents of the build configuration and product
              YAML files.
    """
    contents = open_raw(build_config_yaml_path)
    product = load_product_yaml(product_yaml_path)
    if product_properties_path:
        product.read_properties_from_directory(product_properties_path)
    contents.update(product)
    return contents
