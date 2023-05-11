import os

import pytest

import ssg.products
import ssg.yaml


@pytest.fixture
def ssg_root():
    return os.path.abspath(os.path.join(os.path.dirname(__file__), "../../.."))


@pytest.fixture
def testing_datadir():
    return os.path.abspath(os.path.join(os.path.dirname(__file__), "data"))


@pytest.fixture
def testing_product_yaml_path(testing_datadir):
    return os.path.abspath(os.path.join(testing_datadir, "product.yml"))


@pytest.fixture
def testing_product(testing_product_yaml_path):
    return ssg.products.Product(testing_product_yaml_path)


def test_get_all(ssg_root):
    products = ssg.products.get_all(ssg_root)

    assert "fedora" in products.linux
    assert "fedora" not in products.other

    assert "rhel7" in products.linux
    assert "rhel7" not in products.other

    assert "firefox" in products.other
    assert "firefox" not in products.linux


def test_product_yaml(testing_product):
    assert "product" in testing_product
    assert testing_product["pkg_system"] == "rpm"
    assert testing_product["product_dir"].endswith("data")
    assert testing_product.get("X", "x") == "x"

    copied_product = dict()
    copied_product.update(testing_product)
    assert copied_product["pkg_system"] == "rpm"


@pytest.fixture
def product_filename_py2(tmpdir):
    return str(tmpdir.join("tmp_product.yml"))


@pytest.fixture
def product_filename_py3(tmp_path):
    return tmp_path / "tmp_product.yml"


def test_product_yaml_write(testing_product, product_filename_py2):
    testing_product.write(product_filename_py2)
    second_product = ssg.products.Product(product_filename_py2)
    assert testing_product["product_dir"] == second_product["product_dir"]


def test_product_updates_with_dict(testing_product):
    assert "property_one" not in testing_product
    properties = dict(property_one="one")
    testing_product.expand_by(properties)
    assert testing_product["property_one"] == "one"
    overriding_property = dict(property_one="two")
    testing_product.expand_by(overriding_property)
    assert testing_product["property_one"] == "two"


def test_product_updates_with_files(testing_product, testing_datadir):
    properties_dir = os.path.join(testing_datadir, "properties")
    testing_product.read_properties_from_directory(properties_dir)
    assert testing_product["property_one"] == "one"
    assert testing_product["product"] == "rhel7"
    assert testing_product["rhel_version"] == "seven"
    assert testing_product["property_two"] == "two"
