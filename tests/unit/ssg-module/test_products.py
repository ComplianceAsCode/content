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


@pytest.fixture
def product_with_updated_properties(testing_product, testing_datadir):
    properties_dir = os.path.join(testing_datadir, "properties")
    testing_product.read_properties_from_directory(properties_dir)
    return testing_product


def test_default_and_overrides_mappings_to_mapping():
    converter = ssg.products.Product.transform_default_and_overrides_mappings_to_mapping
    assert converter(dict(default=[])) == dict()
    assert converter(dict(default=dict(one=1))) == dict(one=1)
    assert converter(dict(default=dict(one=2), overrides=dict(one=1))) == dict(one=1)
    with pytest.raises(ValueError):
        converter([dict(one=2), 5])
    with pytest.raises(KeyError):
        converter(dict(deflaut=dict(one=2)))


def test_get_all(ssg_root):
    products = ssg.products.get_all(ssg_root)

    assert "fedora" in products.linux
    assert "fedora" not in products.other

    assert "rhel10" in products.linux
    assert "rhel10" not in products.other

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
    testing_product.expand_by_acquired_data(properties)
    assert testing_product["property_one"] == "one"


def test_product_updates_with_files(product_with_updated_properties):
    product = product_with_updated_properties
    assert product["property_one"] == "one"
    assert product["product"] == "rhel7"
    assert product["rhel_version"] == "seven"


def test_updates_have_access_to_previously_defined_properties(product_with_updated_properties):
    product = product_with_updated_properties
    assert product["property_two"] == "two"


def test_product_properties_set_only_in_one_place(product_with_updated_properties):
    product = product_with_updated_properties
    existing_data = dict(pkg_manager=product["pkg_manager"])
    with pytest.raises(ValueError):
        product.expand_by_acquired_data(existing_data)

    existing_data = dict(property_one=1)
    with pytest.raises(ValueError):
        product.expand_by_acquired_data(existing_data)

    new_data = dict(new_one=1)
    product.expand_by_acquired_data(new_data)
    with pytest.raises(ValueError):
        product.expand_by_acquired_data(new_data)


def test_product_updating_twice_doesnt_work(product_with_updated_properties, testing_datadir):
    testing_product = product_with_updated_properties
    properties_dir = os.path.join(testing_datadir, "properties")
    with pytest.raises(ValueError):
        testing_product.read_properties_from_directory(properties_dir)
