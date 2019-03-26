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
