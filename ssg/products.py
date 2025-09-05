from __future__ import absolute_import
from __future__ import print_function

import os
from collections import namedtuple
from glob import glob

from .build_cpe import ProductCPEs
from .constants import (DEFAULT_PRODUCT, product_directories,
                        DEFAULT_GID_MIN,
                        DEFAULT_UID_MIN,
                        DEFAULT_NOBODY_GID,
                        DEFAULT_NOBODY_UID,
                        DEFAULT_GRUB2_BOOT_PATH,
                        DEFAULT_GRUB2_UEFI_BOOT_PATH,
                        DEFAULT_DCONF_GDM_DIR,
                        DEFAULT_AIDE_CONF_PATH,
                        DEFAULT_AIDE_BIN_PATH,
                        DEFAULT_SSH_DISTRIBUTED_CONFIG,
                        DEFAULT_CHRONY_CONF_PATH,
                        DEFAULT_AUDISP_CONF_PATH,
                        DEFAULT_FAILLOCK_PATH,
                        PKG_MANAGER_TO_SYSTEM,
                        PKG_MANAGER_TO_CONFIG_FILE,
                        XCCDF_PLATFORM_TO_PACKAGE,
                        SSG_REF_URIS)
from .utils import merge_dicts, required_key
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
    result = existing_properties.copy()
    if "pkg_manager" in existing_properties:
        pkg_manager = existing_properties["pkg_manager"]
        if "pkg_system" not in existing_properties:
            result["pkg_system"] = PKG_MANAGER_TO_SYSTEM[pkg_manager]
        if "pkg_manager_config_file" not in existing_properties:
            if pkg_manager in PKG_MANAGER_TO_CONFIG_FILE:
                result["pkg_manager_config_file"] = PKG_MANAGER_TO_CONFIG_FILE[pkg_manager]

    if "gid_min" not in existing_properties:
        result["gid_min"] = DEFAULT_GID_MIN

    if "uid_min" not in existing_properties:
        result["uid_min"] = DEFAULT_UID_MIN

    if "nobody_gid" not in existing_properties:
        result["nobody_gid"] = DEFAULT_NOBODY_GID

    if "nobody_uid" not in existing_properties:
        result["nobody_uid"] = DEFAULT_NOBODY_UID

    if "auid" not in existing_properties:
        result["auid"] = existing_properties.get("uid_min", DEFAULT_UID_MIN)

    if "groups" not in existing_properties:
        result["groups"] = dict()

    if "grub2_boot_path" not in existing_properties:
        result["grub2_boot_path"] = DEFAULT_GRUB2_BOOT_PATH

    if "grub2_uefi_boot_path" not in existing_properties:
        result["grub2_uefi_boot_path"] = DEFAULT_GRUB2_UEFI_BOOT_PATH

    if "dconf_gdm_dir" not in existing_properties:
        result["dconf_gdm_dir"] = DEFAULT_DCONF_GDM_DIR

    if "aide_conf_path" not in existing_properties:
        result["aide_conf_path"] = DEFAULT_AIDE_CONF_PATH

    if "aide_bin_path" not in existing_properties:
        result["aide_bin_path"] = DEFAULT_AIDE_BIN_PATH

    if "sshd_distributed_config" not in existing_properties:
        result["sshd_distributed_config"] = DEFAULT_SSH_DISTRIBUTED_CONFIG

    if "product" not in existing_properties:
        result["product"] = DEFAULT_PRODUCT

    if "chrony_conf_path" not in existing_properties:
        result["chrony_conf_path"] = DEFAULT_CHRONY_CONF_PATH

    if "audisp_conf_path" not in existing_properties:
        result["audisp_conf_path"] = DEFAULT_AUDISP_CONF_PATH

    if "faillock_path" not in existing_properties:
        result["faillock_path"] = DEFAULT_FAILLOCK_PATH

    return result


def product_yaml_path(ssg_root, product):
    return os.path.join(ssg_root, "products", product, "product.yml")


def load_product_yaml(product_yaml_path):
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

    reference_uris = product_yaml.get("reference_uris", {})
    product_yaml["reference_uris"] = merge_dicts(SSG_REF_URIS,
                                                 reference_uris)

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
        product_yaml_path = os.path.join(ssg_root, "products", product, "product.yml")
        product_yaml = load_product_yaml(product_yaml_path)

        guide_dir = os.path.join(product_yaml["product_dir"], product_yaml['benchmark_root'])
        guide_dir = os.path.abspath(guide_dir)

        if 'linux_os' in guide_dir:
            linux_products.add(product)
        else:
            other_products.add(product)

    products = namedtuple('products', ['linux', 'other'])
    return products(linux_products, other_products)


def get_profiles_directory(env_yaml):
    profiles_root = None
    if env_yaml:
        profiles_root = required_key(env_yaml, "profiles_root")
    return profiles_root


def get_profile_files_from_root(env_yaml, product_yaml):
    profile_files = []
    if env_yaml:
        profiles_root = get_profiles_directory(env_yaml)
        base_dir = os.path.dirname(product_yaml)
        profile_files = sorted(glob("{base_dir}/{profiles_root}/*.profile"
                               .format(profiles_root=profiles_root, base_dir=base_dir)))
    return profile_files
