from __future__ import absolute_import
from __future__ import print_function

import re
import os
from collections import namedtuple

from .constants import product_directories
from .yaml import open_raw


# SSG Makefile to official product name mapping
_version_name_map = {
    'chromium': 'Google Chromium Browser',
    'fedora': 'Fedora',
    'firefox': 'Mozilla Firefox',
    'jre': 'Java Runtime Environment',
    'rhel-osp': 'Red Hat OpenStack Platform',
    'rhel': 'Red Hat Enterprise Linux',
    'debian': 'Debian',
    'ubuntu': 'Ubuntu',
    'eap': 'JBoss Enterprise Application Platform',
    'fuse': 'JBoss Fuse',
    'opensuse': 'openSUSE',
    'sle': 'SUSE Linux Enterprise',
    'wrlinux': 'Wind River Linux',
    'example': 'Example Linux Content',
    'ol': 'Oracle Linux',
    'ocp': 'Red Hat OpenShift Container Platform',
}

multi_list = ["rhel", "fedora", "rhel-osp", "debian", "ubuntu",
              "wrlinux", "opensuse", "sle", "ol", "ocp", "example"]

PRODUCT_NAME_PARSER = re.compile(r"([a-zA-Z\-]+)([0-9]+)")


def parse_name(product):
    """
    Returns a namedtuple of (name, version) from parsing a given product;
    e.g., "rhel7" -> ("rhel", "7")
    """

    prod_tuple = namedtuple('product', ['name', 'version'])

    _product = product
    _product_version = None
    match = PRODUCT_NAME_PARSER.match(product)

    if match:
        _product = match.group(1)
        _product_version = match.group(2)

    return prod_tuple(_product, _product_version)


def get_all(ssg_root):
    """
    Analyzes all products in the SSG root and sorts them into two categories:
    those which use linux_os and those which use their own directory. Returns
    a namedtuple of sets, (linux, other).
    """

    linux_products = set()
    other_products = set()

    for product in product_directories:
        product_dir = os.path.join(ssg_root, product)
        product_yaml_path = os.path.join(product_dir, "product.yml")
        product_yaml = open_raw(product_yaml_path)

        guide_dir = os.path.join(product_dir, product_yaml['benchmark_root'])
        guide_dir = os.path.abspath(guide_dir)

        if 'linux_os' in guide_dir:
            linux_products.add(product)
        else:
            other_products.add(product)

    products = namedtuple('products', ['linux', 'other'])
    return products(linux_products, other_products)


def map_name(version):
    """Maps SSG Makefile internal product name to official product name"""

    if version.startswith("multi_platform_"):
        trimmed_version = version[len("multi_platform_"):]
        if trimmed_version not in multi_list:
            raise RuntimeError(
                "%s is an invalid product version. If it's multi_platform the "
                "suffix has to be from (%s)."
                % (version, ", ".join(multi_list))
            )
        return map_name(trimmed_version)

    # By sorting in reversed order, keys which are a longer version of other keys are
    # visited first (e.g., rhel-osp vs. rhel)
    for key in sorted(_version_name_map, reverse=True):
        if version.startswith(key):
            return _version_name_map[key]

    raise RuntimeError("Can't map version '%s' to any known product!"
                       % (version))
