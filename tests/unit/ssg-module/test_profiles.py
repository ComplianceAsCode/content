import os

from ssg.products import get_profile_files_from_root
from ssg.profiles import (
    get_profiles_from_products,
    _load_product_yaml,
)


content_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), "data/content_dir"))


def count_profiles_in_products_dir(product):
    product_yaml = _load_product_yaml(content_dir, product)
    profiles_files = get_profile_files_from_root(product_yaml, product_yaml)
    return len(profiles_files)


def test_get_profiles_from_products():
    products = ["rhel8"]
    profiles = get_profiles_from_products(content_dir, products, sorted=True)

    assert len(profiles) == count_profiles_in_products_dir(products[0])
    assert 'rhel' in profiles[0].product_id
    assert len(profiles[0].rules) > 0
    assert len(profiles[0].variables) > 0
