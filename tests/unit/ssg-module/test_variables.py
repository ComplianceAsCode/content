import os
import pytest

from ssg.constants import BENCHMARKS
from ssg.variables import (
    get_variable_files_in_folder,
    get_variable_files,
    get_variable_options,
    get_variables_by_products,
    get_variable_values,
)


def test_get_variable_files_in_folder(tmp_path):
    content_dir = tmp_path / "content"
    benchmarks = ["app", "app/rules"]
    for benchmark_folder in benchmarks:
        path = content_dir / benchmark_folder
        os.makedirs(content_dir / benchmark_folder)
        var_file = path / "test.var"
        var_file.write_text("options:\n  option: value\n")
        txt_file = path / "test.txt"
        txt_file.write_text("options:\n  option: value\n")

    result = get_variable_files_in_folder(str(content_dir), benchmarks[0])
    assert len(result) == 2
    assert all(os.path.basename(file) == "test.var" for file in result)


def test_get_variable_files(tmp_path):
    content_dir = tmp_path / "content"
    benchmarks = ["app", "app/rules"]
    for benchmark_folder in benchmarks:
        path = content_dir / benchmark_folder
        os.makedirs(content_dir / benchmark_folder)
        var_file = path / "test.var"
        var_file.write_text("options:\n  option: value\n")

    BENCHMARKS.add(content_dir)
    result = get_variable_files(str(content_dir))
    assert len(result) == 2
    assert all(os.path.basename(file) == "test.var" for file in result)


def test_get_variable_options(tmp_path):
    content_dir = tmp_path / "content"
    benchmarks = ["app", "app/rules"]
    for benchmark_folder in benchmarks:
        path = content_dir / benchmark_folder
        os.makedirs(content_dir / benchmark_folder)
        var_file = path / "test.var"
        var_file.write_text("options:\n  option: value\n")

    result = get_variable_options(str(content_dir), "test")
    assert result == {"option": "value"}


def test_get_variables_by_products():
    products = ["rhel9"]
    content_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), "../../.."))

    result = get_variables_by_products(str(content_dir), products)
    assert "var_selinux_policy_name" in result
    assert "rhel9" in result["var_selinux_policy_name"]


def test_get_variable_values(tmp_path):
    content_dir = tmp_path / "content"
    products = ["product1", "product2"]
    for product in products:
        path = content_dir / product
        os.makedirs(path)
        var_file = path / "test.var"
        var_file.write_text("options:\n  option: value\n")

    profiles_variables = {
        "test": {
            "product1": {"profile1": "option"},
            "product2": {"profile2": "option"},
        }
    }
    result = get_variable_values(str(content_dir), profiles_variables)
    assert result["test"]["product1"]["profile1"] == "value"
    assert result["test"]["product2"]["profile2"] == "value"
