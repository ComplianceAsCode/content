import os
import pytest

from ssg.products import (
    get_all,
    get_profile_files_from_root,
)
from ssg.profiles import (
    get_profiles_from_products,
    _load_product_yaml,
)


# The get_profiles_from_products function interacts with many objects and other functions that
# would be complex to mock. So it will be tested with a real content directory. To make it
# predictable, all existing products will be collected and the first rhel product will be used
# for testing. The decision to use a rhel product is that I am more used to them and I know their
# profiles also use control files.
content_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), "../../.."))

def get_first_rhel_product_from_products_dir():
    products = get_all(content_dir)
    rhel_products = [product for product in products.linux if "rhel" in product]
    return rhel_products[0]


def count_profiles_in_products_dir(product):
    product_yaml = _load_product_yaml(content_dir, product)
    profiles_files = get_profile_files_from_root(product_yaml, product_yaml)
    return len(profiles_files)


def test_get_profiles_from_products():
    products = [get_first_rhel_product_from_products_dir()]
    profiles = get_profiles_from_products(content_dir, products, sorted=True)

    assert len(profiles) == count_profiles_in_products_dir(products[0])
    assert 'rhel' in profiles[0].product_id
    assert len(profiles[0].rules) > 0
    assert len(profiles[0].variables) > 0
