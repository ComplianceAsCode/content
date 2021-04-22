from __future__ import absolute_import
from __future__ import print_function

import os
from collections import namedtuple

from .build_cpe import ProductCPEs
from .constants import (product_directories,
                        DEFAULT_UID_MIN,
                        PKG_MANAGER_TO_SYSTEM,
                        PKG_MANAGER_TO_CONFIG_FILE,
                        XCCDF_PLATFORM_TO_PACKAGE)
from .utils import merge_dicts
from .yaml import open_raw


def _validate_product_oval_feed_url(contents):
    if "oval_feed_url" not in contents:
        return
    url = contents["oval_feed_url"]
    if not url.startswith("https"):
        msg = (
            "OVAL feed of product '{product}' is not available through an encrypted channel: {url}"
            .format(product=contents["product"], url=url)
        )
        raise ValueError(msg)


def _get_implied_properties(existing_properties):
    result = dict()
    if "pkg_manager" in existing_properties:
        pkg_manager = existing_properties["pkg_manager"]
        if "pkg_system" not in existing_properties:
            result["pkg_system"] = PKG_MANAGER_TO_SYSTEM[pkg_manager]
        if "pkg_manager_config_file" not in existing_properties:
            if pkg_manager in PKG_MANAGER_TO_CONFIG_FILE:
                result["pkg_manager_config_file"] = PKG_MANAGER_TO_CONFIG_FILE[pkg_manager]

    if "uid_min" not in existing_properties:
        result["uid_min"] = DEFAULT_UID_MIN

    if "auid" not in existing_properties:
        result["auid"] = existing_properties.get("uid_min", DEFAULT_UID_MIN)

    return result


def get_product_yaml(product_yaml_path):
    """
    Reads a product data from disk and returns it.
    The returned product dictionary also contains derived useful information.
    """

    product_yaml = open_raw(product_yaml_path)
    _validate_product_oval_feed_url(product_yaml)

    # The product directory is necessary to get absolute paths to benchmark, profile and
    # cpe directories, which are all relative to the product directory
    product_yaml["product_dir"] = os.path.dirname(product_yaml_path)

    platform_package_overrides = product_yaml.get("platform_package_overrides", {})
    # Merge common platform package mappings, while keeping product specific mappings
    product_yaml["platform_package_overrides"] = merge_dicts(XCCDF_PLATFORM_TO_PACKAGE,
                                                             platform_package_overrides)
    product_yaml.update(_get_implied_properties(product_yaml))

    # The product_yaml should be aware of the ProductCPEs
    product_yaml["product_cpes"] = ProductCPEs(product_yaml)

    return product_yaml


def get_all(ssg_root):
    """
    Analyzes all products in the SSG root and sorts them into two categories:
    those which use linux_os and those which use their own directory. Returns
    a namedtuple of sets, (linux, other).
    """

    linux_products = set()
    other_products = set()

    for product in product_directories:
        product_yaml_path = os.path.join(ssg_root, product, "product.yml")
        product_yaml = get_product_yaml(product_yaml_path)

        guide_dir = os.path.join(product_yaml["product_dir"], product_yaml['benchmark_root'])
        guide_dir = os.path.abspath(guide_dir)

        if 'linux_os' in guide_dir:
            linux_products.add(product)
        else:
            other_products.add(product)

    products = namedtuple('products', ['linux', 'other'])
    return products(linux_products, other_products)
