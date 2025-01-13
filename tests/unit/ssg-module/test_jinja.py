import os
import pytest
import ssg.jinja


def get_definitions_with_substitution(subs_dict=None):
    if subs_dict is None:
        subs_dict = dict()

    definitions = os.path.join(os.path.dirname(__file__), "data", "definitions.jinja")
    ssg.jinja.update_substitutions_dict(definitions, subs_dict)
    return subs_dict


def test_macro_presence():
    actual_defs = get_definitions_with_substitution()
    assert "expand_to_bar" in actual_defs
    assert actual_defs["expand_to_bar"]() == "bar"


def test_macro_expansion():
    incomplete_defs = get_definitions_with_substitution()
    assert incomplete_defs["expand_to_global_var"]() == ""

    complete_defs = get_definitions_with_substitution(dict(global_var="value"))
    assert complete_defs["expand_to_global_var"]() == "value"


def test_load_macros_with_valid_directory(tmpdir):
    macros_dir = tmpdir.mkdir("macros")
    macro_file = macros_dir.join("test_macro.jinja")
    macro_file.write("{{% macro test_macro() %}}test{{% endmacro %}}")
    substitutions_dict = ssg.jinja._load_macros(str(macros_dir))

    assert "test_macro" in substitutions_dict
    assert substitutions_dict["test_macro"]() == "test"


def test_load_macros_with_nonexistent_directory():
    non_existent_dir = "/non/existent/directory"
    with pytest.raises(RuntimeError, match=f"The directory '{non_existent_dir}' does not exist."):
        ssg.jinja._load_macros(non_existent_dir)


def test_load_macros_with_existing_substitutions_dict(tmpdir):
    macros_dir = tmpdir.mkdir("macros")
    macro_file = macros_dir.join("test_macro.jinja")
    macro_file.write("{{% macro test_macro() %}}test{{% endmacro %}}")
    existing_dict = {"existing_key": "existing_value"}
    substitutions_dict = ssg.jinja._load_macros(str(macros_dir), existing_dict)

    assert "test_macro" in substitutions_dict
    assert substitutions_dict["test_macro"]() == "test"
    assert "existing_key" in substitutions_dict
    assert substitutions_dict["existing_key"] == "existing_value"
