import os
import io
import pytest

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


def test_duplicate_key_detection_top_level():
    """Test that duplicate keys at the top level are detected."""
    yaml_content = """
title: First Title
description: A description
title: Second Title
"""
    stream = io.StringIO(yaml_content)

    with pytest.raises(SystemExit) as exc_info:
        ssg.yaml._open_yaml(stream)

    assert exc_info.value.code == 1


def test_duplicate_key_detection_nested():
    """Test that duplicate keys in nested structures are detected."""
    yaml_content = """
metadata:
    name: test
    version: 1.0
    name: duplicate
"""
    stream = io.StringIO(yaml_content)

    with pytest.raises(SystemExit) as exc_info:
        ssg.yaml._open_yaml(stream)

    assert exc_info.value.code == 1


def test_duplicate_key_detection_in_rule_yml():
    """Test duplicate key detection with a realistic rule.yml structure."""
    yaml_content = """
documentation_complete: true
title: Test Rule
description: First description
rationale: A rationale
severity: medium
description: Second description
"""
    stream = io.StringIO(yaml_content)

    with pytest.raises(SystemExit) as exc_info:
        ssg.yaml._open_yaml(stream)

    assert exc_info.value.code == 1


def test_no_duplicate_keys_valid_yaml():
    """Test that valid YAML without duplicates is parsed correctly."""
    yaml_content = """
documentation_complete: true
title: Test Rule
description: A description
rationale: A rationale
severity: medium
identifiers:
    cce@rhel9: CCE-12345-6
references:
    nist: CM-6
"""
    stream = io.StringIO(yaml_content)
    result = ssg.yaml._open_yaml(stream)

    # documentation_complete is removed by _open_yaml
    assert result['title'] == 'Test Rule'
    assert result['description'] == 'A description'
    assert result['severity'] == 'medium'


def test_duplicate_keys_in_nested_mapping():
    """Test duplicate key detection in deeply nested structures."""
    yaml_content = """
template:
    name: yamlfile_value
    vars:
        filepath: /api/path
        yamlpath: .spec.field
        filepath: /duplicate/path
"""
    stream = io.StringIO(yaml_content)

    with pytest.raises(SystemExit) as exc_info:
        ssg.yaml._open_yaml(stream)

    assert exc_info.value.code == 1


def test_list_items_not_treated_as_duplicates():
    """Test that list items are not incorrectly flagged as duplicates."""
    yaml_content = """
selections:
    - rule_one
    - rule_two
    - rule_three
values:
    - value: first
      type: string
    - value: second
      type: string
"""
    stream = io.StringIO(yaml_content)
    result = ssg.yaml._open_yaml(stream)

    assert len(result['selections']) == 3
    assert len(result['values']) == 2


def test_open_raw_with_duplicates(tmpdir):
    """Test that open_raw also detects duplicate keys."""
    yaml_file = tmpdir / "test_dup.yaml"
    yaml_file.write("""
key1: value1
key2: value2
key1: duplicate_value
""")

    with pytest.raises(SystemExit) as exc_info:
        ssg.yaml.open_raw(str(yaml_file))

    assert exc_info.value.code == 1


def test_open_raw_without_duplicates(tmpdir):
    """Test that open_raw works correctly with valid YAML."""
    yaml_file = tmpdir / "test_valid.yaml"
    yaml_file.write("""
documentation_complete: true
key1: value1
key2: value2
key3: value3
""")

    result = ssg.yaml.open_raw(str(yaml_file))

    assert result['key1'] == 'value1'
    assert result['key2'] == 'value2'
    assert result['key3'] == 'value3'
