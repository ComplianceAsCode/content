from __future__ import absolute_import
from __future__ import print_function

import os
from collections import namedtuple

from .constants import product_directories
from .yaml import open_raw


def get_product_yaml(ssg_root, product):
    """
    Given a project root directory and product name.
    Reads the product data from disk and returns it.
    """
    product_yaml_path = os.path.join(ssg_root, product, "product.yml")
    return open_raw(product_yaml_path)


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
        product_yaml = get_product_yaml(ssg_root, product)

        guide_dir = os.path.join(product_dir, product_yaml['benchmark_root'])
        guide_dir = os.path.abspath(guide_dir)

        if 'linux_os' in guide_dir:
            linux_products.add(product)
        else:
            other_products.add(product)

    products = namedtuple('products', ['linux', 'other'])
    return products(linux_products, other_products)
