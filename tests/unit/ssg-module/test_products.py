import os

import pytest

import ssg.products


@pytest.fixture
def ssg_root():
    return os.path.abspath(os.path.join(os.path.dirname(__file__), "../../.."))


@pytest.fixture
def testing_product_yaml_path():
    return os.path.abspath(os.path.join(os.path.dirname(__file__), "data", "product.yml"))


def test_get_all(ssg_root):
    products = ssg.products.get_all(ssg_root)

    assert "fedora" in products.linux
    assert "fedora" not in products.other

    assert "rhel7" in products.linux
    assert "rhel7" not in products.other

    assert "firefox" in products.other
    assert "firefox" not in products.linux


def test_product_yaml_load(testing_product_yaml_path):
    product = ssg.products.Product(testing_product_yaml_path)
    assert "product" in product
    assert product["product"] == "rhel7"
    assert product["pkg_system"] == "rpm"
    assert product["product_dir"].endswith("data")

    copied_product = dict()
    copied_product.update(product)
    assert copied_product["pkg_system"] == "rpm"


def test_product_yaml_write(testing_product_yaml_path, tmp_path):
    product = ssg.products.Product(testing_product_yaml_path)
    filename = tmp_path / "tmp_product.yml"
    product.write(filename)
    second_product = ssg.products.Product(filename)
    assert product["product_dir"] == second_product["product_dir"]
