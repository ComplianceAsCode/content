import os
import pytest

import ssg.components

ssg_root = os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(__file__))))
data_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), "data"))
components_dir = os.path.join(data_dir, "components_dir")
component_file = os.path.join(components_dir, "fapolicyd.yml")


def test_load():
    cs = ssg.components.load(components_dir)
    assert isinstance(cs, dict)
    assert len(cs) == 1
    assert "fapolicyd" in cs
    assert isinstance(cs["fapolicyd"], ssg.components.Component)
    assert cs["fapolicyd"].name == "fapolicyd"


def test_package_component_mapping():
    cs = ssg.components.load(components_dir)
    package_to_component = ssg.components.package_component_mapping(cs)
    assert isinstance(package_to_component, dict)
    assert len(package_to_component.keys()) == 1
    assert "fapolicyd-server" in package_to_component
    assert package_to_component["fapolicyd-server"] == ["fapolicyd"]


def test_template_component_mapping():
    cs = ssg.components.load(components_dir)
    template_to_component = ssg.components.template_component_mapping(cs)
    assert isinstance(template_to_component, dict)
    assert len(template_to_component.keys()) == 1
    assert "file_policy_blocked" in template_to_component
    assert template_to_component["file_policy_blocked"] == ["fapolicyd"]


def test_group_components_mapping():
    cs = ssg.components.load(components_dir)
    group_to_component = ssg.components.group_component_mapping(cs)
    assert isinstance(group_to_component, dict)
    assert len(group_to_component.keys()) == 2
    assert "fapolicy" in group_to_component
    assert len(group_to_component["fapolicy"]) == 1
    assert group_to_component["fapolicy"][0] == "fapolicyd"
    assert "integrity" in group_to_component
    assert len(group_to_component["integrity"]) == 1
    assert group_to_component["integrity"][0] == "fapolicyd"


def test_component_parse():
    c = ssg.components.Component(component_file)
    assert c.name == "fapolicyd"
    assert len(c.groups) == 2
    assert "fapolicy" in c.groups
    assert "integrity" in c.groups
    assert len(c.packages) == 1
    assert "fapolicyd-server" in c.packages
    assert len(c.rules) == 3
    assert "fapolicy_default_deny" in c.rules
    assert "fapolicyd_prevent_home_folder_access" in c.rules
    assert "service_fapolicyd_enabled" in c.rules
    assert len(c.templates) == 1
    assert "file_policy_blocked" in c.templates
    assert len(c.changelog) == 1
    assert "created in 2023" in c.changelog
