from __future__ import absolute_import
from __future__ import print_function

import os
from collections import namedtuple

from .constants import product_directories
from .yaml import open_raw


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

        relative_guide_dirs = product_yaml['benchmark_root']
        guide_dirs = [os.path.abspath(os.path.join(product_dir, d)) for d in relative_guide_dirs]

        for guide_dir in guide_dirs:
            if 'linux_os' in guide_dir:
                linux_products.add(product)
            else:
                other_products.add(product)

    products = namedtuple('products', ['linux', 'other'])
    return products(linux_products, other_products)
