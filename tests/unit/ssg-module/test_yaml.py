import os

import ssg.yaml


def test_list_or_string_update():
    assert ssg.yaml.update_yaml_list_or_string(
        "",
        "",
    ) == ""

    assert ssg.yaml.update_yaml_list_or_string(
        "something",
        "",
    ) == "something"

    assert ssg.yaml.update_yaml_list_or_string(
        ["something"],
        "",
    ) == "something"

    assert ssg.yaml.update_yaml_list_or_string(
        "",
        "else",
    ) == "else"

    assert ssg.yaml.update_yaml_list_or_string(
        "something",
        "else",
    ) == ["something", "else"]

    assert ssg.yaml.update_yaml_list_or_string(
        "",
        ["something", "else"],
    ) == ["something", "else"]

    assert ssg.yaml.update_yaml_list_or_string(
        ["something", "else"],
        "",
    ) == ["something", "else"]

    assert ssg.yaml.update_yaml_list_or_string(
        "something",
        ["entirely", "else"],
    ) == ["something", "entirely", "else"]

    assert ssg.yaml.update_yaml_list_or_string(
        ["something", "entirely"],
        ["entirely", "else"],
    ) == ["something", "entirely", "entirely", "else"]


def test_open_and_macro_expand_from_dir(tmpdir):
    # Setup: Create directory structure
    content_dir = tmpdir / "content_dir"
    macros_dir = content_dir / "shared" / "macros"
    os.makedirs(macros_dir, exist_ok=True)

    # Create YAML file with macro
    yaml_file = content_dir / "test.yaml"
    yaml_file.write("macro: {{{ test_macro() }}}")

    # Create macro file with macro definition
    macro_file = macros_dir / "test_macro.jinja"
    macro_file.write("{{% macro test_macro() %}}test{{% endmacro %}}")

    result = ssg.yaml.open_and_macro_expand_from_dir(str(yaml_file), str(content_dir))
    assert result['macro'] == 'test'
