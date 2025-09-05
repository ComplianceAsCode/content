import os

from ssg.constants import BENCHMARKS
from ssg.variables import (
    get_variable_files_in_folder,
    get_variable_files,
    get_variable_options,
    get_variable_property,
    get_variables_by_products,
    get_variables_from_profiles,
    get_variable_values,
)


def setup_test_files(base_dir, benchmark_dirs, create_txt_file=False):
    """
    Create benchmark directories and populate them with .var and optionally .txt files.

    Args:
        base_dir (Path): The base temporary directory.
        benchmark_dirs (list[str]): List of benchmark folder paths to create.
        create_txt_file (bool): Whether to create an additional .txt file in each benchmark.
    """
    # Ensures the shared/macros directory exists even if in this case the testing example does
    # not use Jinja2 macros.
    os.makedirs(base_dir / "shared" / "macros", exist_ok=True)

    for benchmark_dir in benchmark_dirs:
        path = base_dir / benchmark_dir
        os.makedirs(path, exist_ok=True)
        var_file = path / "test.var"
        var_file.write_text(
            "options:\n  default: value\n  option1: value1\n  option2: value2\n"
            "title: Test Title\ndescription: Test Description\n"
        )
        if create_txt_file:
            txt_file = path / "test.txt"
            txt_file.write_text("options:\n  option: value\n")


def test_get_variable_files_in_folder(tmp_path):
    content_dir = tmp_path / "content"
    benchmark_dirs = ["app", "app/rules"]
    setup_test_files(content_dir, benchmark_dirs, create_txt_file=True)
    result = get_variable_files_in_folder(str(content_dir), benchmark_dirs[0])
    assert len(result) == 2
    assert all(os.path.basename(file) == "test.var" for file in result)


def test_get_variable_files(tmp_path):
    content_dir = tmp_path / "content"
    BENCHMARKS.add(content_dir)
    benchmark_dirs = ["app", "app/rules"]
    setup_test_files(content_dir, benchmark_dirs)
    result = get_variable_files(str(content_dir))
    assert len(result) == 2
    assert all(os.path.basename(file) == "test.var" for file in result)


def test_get_variable_options(tmp_path):
    content_dir = tmp_path / "content"
    benchmark_dirs = ["app", "app/rules"]
    setup_test_files(content_dir, benchmark_dirs)
    result = get_variable_options(str(content_dir), "test")
    assert result == {"default": "value", "option1": "value1", "option2": "value2"}


def test_get_variables_by_products():
    products = ["rhel9"]
    content_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), "../../.."))
    result = get_variables_by_products(str(content_dir), products)
    assert "var_selinux_policy_name" in result
    assert "rhel9" in result["var_selinux_policy_name"]


def test_get_variable_values(tmp_path):
    content_dir = tmp_path / "content"
    products = ["product1", "product2"]
    setup_test_files(content_dir, products)

    profiles_variables = {
        "test": {
            "product1": {"profile1": "option1"},
            "product2": {"profile2": "option2"},
        }
    }
    result = get_variable_values(str(content_dir), profiles_variables)
    assert result["test"]["product1"]["profile1"] == "value1"
    assert result["test"]["product2"]["profile2"] == "value2"


def test_get_variables_from_profiles():
    class MockProfile:
        def __init__(self, product_id, profile_id, variables):
            self.product_id = product_id
            self.profile_id = profile_id
            self.variables = variables

    profiles = [
        MockProfile("product1", "profile1", {"var1": "value1", "var2": "value2"}),
        MockProfile("product1", "profile2", {"var1": "value3"}),
        MockProfile("product2", "profile1", {"var2": "value4"}),
    ]

    expected_result = {
        "var1": {
            "product1": {
                "profile1": "value1",
                "profile2": "value3",
            }
        },
        "var2": {
            "product1": {
                "profile1": "value2",
            },
            "product2": {
                "profile1": "value4",
            }
        }
    }

    result = get_variables_from_profiles(profiles)
    assert result == expected_result


def test_get_variable_property(tmp_path):
    content_dir = tmp_path / "content"
    benchmark_dirs = ["app", "app/rules"]
    setup_test_files(content_dir, benchmark_dirs)

    result = get_variable_property(str(content_dir), "test", "title")
    assert result == "Test Title"

    # Test for a non-existent property
    result = get_variable_property(str(content_dir), "test", "non_existent_property")
    assert result == ""

    # Test for a non-existent variable
    result = get_variable_property(str(content_dir), "non_existent_variable", "property_name")
    assert result == ""
