from __future__ import absolute_import
from __future__ import print_function

import os
from collections import namedtuple

from .constants import product_directories
from .yaml import open_raw


def get_all_product_yamls(ssg_root):
    product_yamls = []
    for product in product_directories:
        product_dir = os.path.join(ssg_root, product)
        product_yaml_path = os.path.join(product_dir, "product.yml")
        product_yamls.append(open_raw(product_yaml_path))

    return product_yamls

def get_all(ssg_root):
    """
    Analyzes all products in the SSG root and sorts them into two categories:
    those which use linux_os and those which use their own directory. Returns
    a namedtuple of sets, (linux, other).
    """

    linux_products = set()
    other_products = set()

    product_yamls = get_all_product_yamls(ssg_root)
    for product_yaml in product_yamls:
        product = product_yaml["product"]
        product_dir = os.path.join(ssg_root, product)
        guide_dir = os.path.join(product_dir, product_yaml['benchmark_root'])
        guide_dir = os.path.abspath(guide_dir)

        if 'linux_os' in guide_dir:
            linux_products.add(product)
        else:
            other_products.add(product)

    products = namedtuple('products', ['linux', 'other'])
    return products(linux_products, other_products)
