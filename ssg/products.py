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
                        DEFAULT_AUDISP_CONF_PATH,
                        DEFAULT_FAILLOCK_PATH,
                        DEFAULT_SYSCTL_REMEDIATE_DROP_IN_FILE,
                        PKG_MANAGER_TO_SYSTEM,
                        PKG_MANAGER_TO_CONFIG_FILE,
                        XCCDF_PLATFORM_TO_PACKAGE,
                        SSG_REF_URIS)
from .utils import merge_dicts, required_key
from .yaml import open_raw, ordered_dump, open_and_expand


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

    if "audisp_conf_path" not in existing_properties:
        result["audisp_conf_path"] = DEFAULT_AUDISP_CONF_PATH

    if "faillock_path" not in existing_properties:
        result["faillock_path"] = DEFAULT_FAILLOCK_PATH

    if "sysctl_remediate_drop_in_file" not in existing_properties:
        result["sysctl_remediate_drop_in_file"] = DEFAULT_SYSCTL_REMEDIATE_DROP_IN_FILE

    return result


def product_yaml_path(ssg_root, product):
    return os.path.join(ssg_root, "products", product, "product.yml")


class Product(object):
    def __init__(self, filename):
        self._primary_data = dict()
        self._acquired_data = dict()
        self._load_from_filename(filename)
        if "basic_properties_derived" not in self._primary_data:
            self._derive_basic_properties(filename)

    @property
    def _data_as_dict(self):
        data = dict()
        data.update(self._acquired_data)
        data.update(self._primary_data)
        return data

    def write(self, filename):
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
        return self._data_as_dict.get(key, default)

    def _load_from_filename(self, filename):
        self._primary_data = open_raw(filename)

    def _derive_basic_properties(self, filename):
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
    """

    product_yaml = Product(product_yaml_path)
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
    for product in product_directories:
        path = product_yaml_path(ssg_root, product)
        product_yaml = load_product_yaml(path)
        yield product, product_yaml


def get_all_products_with_same_guide_directory(ssg_root, product_yaml):
    for extra_product_id, extra_product_yaml in get_all_product_yamls(ssg_root):
        guide_dir = os.path.join(product_yaml["product_dir"], product_yaml['benchmark_root'])
        extra_guide_dir = os.path.join(extra_product_yaml["product_dir"],
                                       extra_product_yaml['benchmark_root'])
        if os.path.abspath(guide_dir) == os.path.abspath(extra_guide_dir):
            if extra_product_id != product_yaml["product"]:
                yield extra_product_yaml


def get_profiles_directory(env_yaml):
    profiles_root = None
    if env_yaml:
        profiles_root = required_key(env_yaml, "profiles_root")
    return profiles_root


def get_profile_files_from_root(env_yaml, product_yaml):
    profile_files = []
    if env_yaml:
        profiles_root = get_profiles_directory(env_yaml)
        base_dir = product_yaml["product_dir"]
        profile_files = sorted(glob("{base_dir}/{profiles_root}/*.profile"
                               .format(profiles_root=profiles_root, base_dir=base_dir)))
    return profile_files
