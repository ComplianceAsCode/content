"""
Common functions for processing Products in SSG
"""

from __future__ import absolute_import
from __future__ import print_function

import os
from collections import namedtuple
from glob import glob

from .build_cpe import ProductCPEs
from .constants import (DEFAULT_PRODUCT, product_directories,
                        DEFAULT_DCONF_GDM_DIR,
                        DEFAULT_AIDE_CONF_PATH,
                        DEFAULT_AIDE_BIN_PATH,
                        DEFAULT_SSH_DISTRIBUTED_CONFIG,
                        DEFAULT_CHRONY_CONF_PATH,
                        DEFAULT_CHRONY_D_PATH,
                        DEFAULT_AUDISP_CONF_PATH,
                        DEFAULT_FAILLOCK_PATH,
                        DEFAULT_SYSCTL_REMEDIATE_DROP_IN_FILE,
                        DEFAULT_BOOTABLE_CONTAINERS_SUPPORTED,
                        DEFAULT_XWINDOWS_PACKAGES,
                        PKG_MANAGER_TO_SYSTEM,
                        PKG_MANAGER_TO_CONFIG_FILE,
                        XCCDF_PLATFORM_TO_PACKAGE,
                        SSG_REF_URIS)
from .utils import merge_dicts, required_key
from .yaml import open_raw, ordered_dump, open_and_expand


def _validate_product_oval_feed_url(contents):
    """
    Validates if the 'oval_feed_url' in the given contents dictionary uses https.

    This function checks if the 'oval_feed_url' key exists in the contents. If it exists, it
    verifies that the URL starts with 'https'. If the URL does not start with 'https', it raises
    a ValueError indicating that the OVAL feed of the product is not available through an
    encrypted channel.

    Args:
        contents (dict): A dictionary containing product information, including the
                         'oval_feed_url' and 'product' keys.

    Returns:
        None

    Raises:
        ValueError: If the 'oval_feed_url' is present but does not start with 'https'.
    """
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
    """
    Generate a dictionary of properties with default values for missing keys.

    This function takes an existing dictionary of properties and adds default values for certain
    keys if they are not already present. The function ensures that the resulting dictionary
    contains all necessary properties with appropriate default values.

    Args:
        existing_properties (dict): A dictionary containing existing properties.

    Returns:
        dict: A dictionary containing the existing properties along with any implied properties
              that were missing, populated with their default values.
    """
    result = existing_properties.copy()
    if "pkg_manager" in existing_properties:
        pkg_manager = existing_properties["pkg_manager"]
        if "pkg_system" not in existing_properties:
            result["pkg_system"] = PKG_MANAGER_TO_SYSTEM[pkg_manager]
        if "pkg_manager_config_file" not in existing_properties:
            if pkg_manager in PKG_MANAGER_TO_CONFIG_FILE:
                result["pkg_manager_config_file"] = PKG_MANAGER_TO_CONFIG_FILE[pkg_manager]

    if "groups" not in existing_properties:
        result["groups"] = dict()

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

    if "chrony_d_path" not in existing_properties:
        result["chrony_d_path"] = DEFAULT_CHRONY_D_PATH

    if "audisp_conf_path" not in existing_properties:
        result["audisp_conf_path"] = DEFAULT_AUDISP_CONF_PATH

    if "faillock_path" not in existing_properties:
        result["faillock_path"] = DEFAULT_FAILLOCK_PATH

    if "sysctl_remediate_drop_in_file" not in existing_properties:
        result["sysctl_remediate_drop_in_file"] = DEFAULT_SYSCTL_REMEDIATE_DROP_IN_FILE

    if "bootable_containers_supported" not in existing_properties:
        result["bootable_containers_supported"] = DEFAULT_BOOTABLE_CONTAINERS_SUPPORTED

    if "xwindows_packages" not in existing_properties:
        result["xwindows_packages"] = DEFAULT_XWINDOWS_PACKAGES

    return result


def product_yaml_path(ssg_root, product):
    """
    Constructs the file path to the product YAML file.

    Args:
        ssg_root (str): The root directory of the SSG.
        product (str): The name of the product.

    Returns:
        str: The full file path to the product YAML file.
    """
    return os.path.join(ssg_root, "products", product, "product.yml")


class Product(object):
    """
    A class to represent a product with primary and acquired data.

    Attributes:
        _primary_data (dict): A dictionary to store primary data loaded from a file.
        _acquired_data (dict): A dictionary to store additional data acquired after initialization.
    """
    def __init__(self, filename):
        self._primary_data = dict()
        self._acquired_data = dict()
        self._load_from_filename(filename)
        if "basic_properties_derived" not in self._primary_data:
            self._derive_basic_properties(filename)

    @property
    def _data_as_dict(self):
        """
        Combine and return acquired and primary data as a dictionary.

        This method merges the data from the `_acquired_data` and `_primary_data` attributes into
        a single dictionary and returns it.

        Returns:
            dict: A dictionary containing the combined data from `_acquired_data` and
                  `_primary_data`.
        """
        data = dict()
        data.update(self._acquired_data)
        data.update(self._primary_data)
        return data

    def write(self, filename):
        """
        Writes the data to a specified file in an ordered format.

        Args:
            filename (str): The name of the file to write the data to.

        Returns:
            None

        Raises:
            IOError: If the file cannot be opened or written to.
        """
        with open(filename, "w") as f:
            ordered_dump(self._data_as_dict, f)

    def __getitem__(self, key):
        return self._data_as_dict[key]

    def __contains__(self, key):
        return key in self._data_as_dict

    def __iter__(self):
        return iter(self._data_as_dict.items())

    def __len__(self):
        return len(self._data_as_dict)

    def get(self, key, default=None):
        """
        Retrieve the value associated with the given key from the internal data dictionary.

        Args:
            key (str): The key to look up in the dictionary.
            default (optional): The value to return if the key is not found. Defaults to None.

        Returns:
            The value associated with the key if it exists, otherwise the default value.
        """
        return self._data_as_dict.get(key, default)

    def _load_from_filename(self, filename):
        self._primary_data = open_raw(filename)

    def _derive_basic_properties(self, filename):
        """
        Derives and sets basic properties for the product based on the provided filename.

        This method performs the following tasks:
        1. Validates the product OVAL feed URL.
        2. Sets the product directory path based on the filename.
        3. Merges common platform package mappings with product-specific mappings.
        4. Updates the primary data with implied properties.
        5. Merges reference URIs with predefined SSG reference URIs.
        6. Marks the basic properties as derived.

        Args:
            filename (str): The path to the product file used to derive properties.

        Returns:
            None

        Raises:
            ValueError: If the product OVAL feed URL is invalid.
        """
        _validate_product_oval_feed_url(self._primary_data)

        # The product directory is necessary to get absolute paths to benchmark, profile and
        # cpe directories, which are all relative to the product directory
        self._primary_data["product_dir"] = os.path.dirname(filename)

        platform_package_overrides = self._primary_data.get("platform_package_overrides", {})
        # Merge common platform package mappings, while keeping product specific mappings
        self._primary_data["platform_package_overrides"] = merge_dicts(
                XCCDF_PLATFORM_TO_PACKAGE, platform_package_overrides)
        self._primary_data.update(_get_implied_properties(self._primary_data))

        reference_uris = self._primary_data.get("reference_uris", {})
        self._primary_data["reference_uris"] = merge_dicts(SSG_REF_URIS, reference_uris)

        self._primary_data["basic_properties_derived"] = True

    def expand_by_acquired_data(self, property_dict):
        """
        Expands the current object with properties from the given dictionary.

        This method updates the object's acquired data with the properties provided in the
        `property_dict`. If any property in `property_dict` already exists in the object,
        a ValueError is raised.

        Args:
            property_dict (dict): A dictionary containing properties to be added.

        Returns:
            None

        Raises:
            ValueError: If any property in `property_dict` is already defined in the object.
        """
        for specified_key in property_dict:
            if specified_key in self:
                msg = (
                    "The property {name} is already defined, "
                    "you can't define it once more elsewhere."
                    .format(name=specified_key))
                raise ValueError(msg)
        self._acquired_data.update(property_dict)

    @staticmethod
    def transform_default_and_overrides_mappings_to_mapping(mappings):
        """
        Transforms a dictionary containing 'default' and 'overrides' mappings into a single mapping.

        This function expects a dictionary with at least a 'default' key and optionally an
        'overrides' key. It merges the 'default' mapping with the 'overrides' mapping, with
        'overrides' taking precedence in case of key conflicts. If the input dictionary contains
        any other keys, a ValueError is raised.

        Args:
            mappings (dict): A dictionary containing 'default' and optionally 'overrides' mappings.

        Returns:
            dict: A merged dictionary of 'default' and 'overrides' mappings.

        Raises:
            ValueError: If the input is not a dictionary, if the 'default' key is missing, or if
                        there are any keys other than 'default' and 'overrides' in the input
                        dictionary.
        """
        result = dict()
        if not isinstance(mappings, dict):
            msg = (
                "Expected a mapping, got {type}."
                .format(type=str(type(mappings))))
            raise ValueError(msg)

        mapping = mappings.pop("default")
        if mapping:
            result.update(mapping)
        mapping = mappings.pop("overrides", dict())
        if mapping:
            result.update(mapping)
        if len(mappings):
            msg = (
                "The dictionary contains unwanted keys: {keys}"
                .format(keys=list(mappings.keys())))
            raise ValueError(msg)
        return result

    def read_properties_from_directory(self, path):
        """
        Reads YAML property files from the specified directory, processes them, and updates the
        current object with the new data.

        Args:
            path (str): The directory path containing the YAML files.

        Returns:
            None
        """
        filenames = glob(path + "/*.yml")
        for f in sorted(filenames):
            substitutions_dict = dict()
            substitutions_dict.update(self)
            new_defs = open_and_expand(f, substitutions_dict)
            new_symbols = self.transform_default_and_overrides_mappings_to_mapping(new_defs)
            self.expand_by_acquired_data(new_symbols)


def load_product_yaml(product_yaml_path):
    """
    Reads a product data from disk and returns it.

    The returned product dictionary also contains derived useful information.

    Args:
        product_yaml_path (str): The file path to the product YAML file.

    Returns:
        dict: A dictionary containing the product data and derived useful information.
    """
    product_yaml = Product(product_yaml_path)
    return product_yaml


def get_all(ssg_root):
    """
    Analyzes all products in the SSG root and sorts them into two categories.

    Those which use linux_os and those which use their own directory.

    Args:
        ssg_root (str): The root directory of the SSG.

    Returns:
        namedtuple: A namedtuple containing two sets:
            - linux (set): A set of products that use linux_os.
            - other (set): A set of products that use their own directory.
    """
    linux_products = set()
    other_products = set()

    for product in product_directories:
        path = product_yaml_path(ssg_root, product)
        product_yaml = load_product_yaml(path)

        guide_dir = os.path.join(product_yaml["product_dir"], product_yaml['benchmark_root'])
        guide_dir = os.path.abspath(guide_dir)

        if 'linux_os' in guide_dir:
            linux_products.add(product)
        else:
            other_products.add(product)

    products = namedtuple('products', ['linux', 'other'])
    return products(linux_products, other_products)


def get_all_product_yamls(ssg_root):
    """
    Generator function that yields product names and their corresponding YAML data.

    Args:
        ssg_root (str): The root directory where the product directories are located.

    Yields:
        tuple: A tuple containing the product name and its corresponding YAML data.
    """
    for product in product_directories:
        path = product_yaml_path(ssg_root, product)
        product_yaml = load_product_yaml(path)
        yield product, product_yaml


def get_all_products_with_same_guide_directory(ssg_root, product_yaml):
    """
    Generator function that yields product YAMLs of all products that share the same guide directory.

    Args:
        ssg_root (str): The root directory of the SSG.
        product_yaml (dict): The YAML data of the current product, containing at least
                             'product_dir', 'benchmark_root', and 'product' keys.

    Yields:
        dict: The YAML data of products that have the same guide directory but different product IDs.
    """
    for extra_product_id, extra_product_yaml in get_all_product_yamls(ssg_root):
        guide_dir = os.path.join(product_yaml["product_dir"], product_yaml['benchmark_root'])
        extra_guide_dir = os.path.join(extra_product_yaml["product_dir"],
                                       extra_product_yaml['benchmark_root'])
        if os.path.abspath(guide_dir) == os.path.abspath(extra_guide_dir):
            if extra_product_id != product_yaml["product"]:
                yield extra_product_yaml


def get_profiles_directory(env_yaml):
    """
    Retrieves the profiles directory path from the given environment configuration.

    Args:
        env_yaml (dict): A dictionary containing environment configuration.

    Returns:
        str: The path to the profiles directory if found, otherwise None.
    """
    profiles_root = None
    if env_yaml:
        profiles_root = required_key(env_yaml, "profiles_root")
    return os.path.normpath(profiles_root)


def get_profile_files_from_root(env_yaml, product_yaml):
    """
    Retrieves a list of profile files from the specified root directory.

    Args:
        env_yaml (dict): A dictionary containing environment configuration.
        product_yaml (dict): A dictionary containing product configuration, including the base
                             directory under the key "product_dir".

    Returns:
        list: A sorted list of profile file paths found in the profiles directory.
    """
    profile_files = []
    if env_yaml:
        profiles_root = get_profiles_directory(env_yaml)
        base_dir = product_yaml["product_dir"]
        profile_files = sorted(glob("{base_dir}/{profiles_root}/*.profile"
                               .format(profiles_root=profiles_root, base_dir=base_dir)))
    return profile_files
