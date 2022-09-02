import os
import tempfile

import yaml
import pytest
import xml.etree.ElementTree as ET
from ssg.build_cpe import ProductCPEs

import ssg.build_yaml
from ssg.constants import cpe_language_namespace
from ssg.yaml import open_raw


PROJECT_ROOT = os.path.join(os.path.dirname(__file__), "..", "..", "..", )
DATADIR = os.path.abspath(os.path.join(os.path.dirname(__file__), "data"))


def test_serialize_rule():
    filename = PROJECT_ROOT + "/linux_os/guide/system/accounts/accounts-restrictions/password_storage/no_empty_passwords/rule.yml"
    rule_ds = ssg.build_yaml.Rule.from_yaml(filename)
    rule_as_dict = rule_ds.represent_as_dict()

    with tempfile.NamedTemporaryFile("w+", delete=True) as f:
        yaml.dump(rule_as_dict, f)
        rule_ds_reloaded = ssg.build_yaml.Rule.from_yaml(f.name)

    reloaded_dict = rule_ds_reloaded.represent_as_dict()

    # Those two should be really equal if there are no jinja macros in the rule def.
    assert rule_as_dict == reloaded_dict


TEST_TEMPLATE_DICT = {
    "backends": {
        "anaconda": True,
        "anaconda@rhel7": False,
    },
    "vars": {
        "filesystem": "tmpfs",
        "filesystem@rhel7": ""
    },
}


def test_rule_platforms_inheritance():
    group1 = ssg.build_yaml.Group('gr1_id')
    group1.platforms = {'pl0', 'pl1'}
    group2 = ssg.build_yaml.Group('gr2_id')
    group2.platforms = {'pl1', 'pl2'}
    rule = ssg.build_yaml.Rule('rul_id')
    rule.platforms = {'plX'}
    group1.add_group(group2)
    group2.add_rule(rule)
    assert rule.inherited_platforms == {'pl0', 'pl1', 'pl2'}
    assert rule.platforms == {'plX'}


def test_make_items_product_specific():
    rule = ssg.build_yaml.Rule("something")

    rule.identifiers = {
        "cce@rhel7": "CCE-27445-6",
        "cce@rhel8": "CCE-80901-2",
    }

    rule.template = TEST_TEMPLATE_DICT.copy()

    rule.normalize("rhel7")
    assert "cce@rhel7" not in rule.identifiers
    assert "cce@rhel8" not in rule.identifiers
    assert rule.identifiers["cce"] == "CCE-27445-6"

    assert "filesystem@rhel7" not in rule.template["vars"]
    assert rule.template["vars"]["filesystem"] == ""
    assert "anaconda@rhel7" not in rule.template["backends"]
    assert not rule.template["backends"]["anaconda"]

    rule.identifiers = {
        "cce": "CCE-27100-7",
        "cce@rhel7": "CCE-27445-6",
    }
    with pytest.raises(Exception) as exc:
        rule.normalize("rhel7")
    assert "'cce'" in str(exc)
    assert "identifiers" in str(exc)

    rule.identifiers = {
        "cce@rhel7": "CCE-27445-6",
        "cce": "CCE-27445-6",
    }
    rule.normalize("rhel7")
    assert "cce@rhel7" not in rule.identifiers
    assert rule.identifiers["cce"] == "CCE-27445-6"

    rule.references = {
        "stigid@rhel7": "RHEL-07-040370",
        "stigid": "tralala",
    }
    with pytest.raises(ValueError) as exc:
        rule.make_refs_and_identifiers_product_specific("rhel7")
    assert "stigid" in str(exc)

    rule.references = {
        "stigid@rhel7": "RHEL-07-040370",
    }
    rule.normalize("rhel7")
    assert rule.references["stigid"] == "RHEL-07-040370"

    rule.references = {
        "stigid@rhel7": "RHEL-07-040370",
    }
    rule.template = TEST_TEMPLATE_DICT.copy()

    assert "filesystem@rhel8" not in rule.template["vars"]
    assert rule.template["vars"]["filesystem"] == "tmpfs"
    assert "anaconda@rhel8" not in rule.template["backends"]
    assert rule.template["backends"]["anaconda"]

    rule.references = {
        "stigid@rhel7": "RHEL-07-040370,RHEL-07-057364",
    }
    with pytest.raises(ValueError, match="Rules can not have multiple STIG IDs."):
        rule.make_refs_and_identifiers_product_specific("rhel7")


def test_priority_ordering():
    ORDER = ["ga", "be", "al"]
    to_order = ["alpha", "beta", "gamma"]
    ordered = ssg.build_yaml.reorder_according_to_ordering(to_order, ORDER)
    assert ordered == ["gamma", "beta", "alpha"]

    to_order = ["alpha", "beta", "gamma", "epsilon"]
    ordered = ssg.build_yaml.reorder_according_to_ordering(to_order, ORDER)
    assert ordered == ["gamma", "beta", "alpha", "epsilon"]

    to_order = ["alpha"]
    ordered = ssg.build_yaml.reorder_according_to_ordering(to_order, ORDER)
    assert ordered == ["alpha"]

    to_order = ["x"]
    ordered = ssg.build_yaml.reorder_according_to_ordering(to_order, ORDER)
    assert ordered == ["x"]

    to_order = ["alpha", "beta", "alnum", "gaha"]
    ordered = ssg.build_yaml.reorder_according_to_ordering(
        to_order, ORDER + ["gaha"], regex=".*ha")
    assert ordered[:2] == ["gaha", "alpha"]


@pytest.fixture
def product_cpes():
    product_yaml_path = os.path.join(DATADIR, "product.yml")
    product_yaml = open_raw(product_yaml_path)
    product_yaml["product_dir"] = os.path.dirname(product_yaml_path)
    return ProductCPEs(product_yaml)


def test_platform_from_text_unknown_platform(product_cpes):
    with pytest.raises(ssg.build_cpe.CPEDoesNotExist):
        ssg.build_yaml.Platform.from_text("something_bogus", product_cpes)


def test_platform_from_text_simple(product_cpes):
    platform = ssg.build_yaml.Platform.from_text("machine", product_cpes)
    assert platform.to_ansible_conditional() == \
        "ansible_virtualization_type not in [\"docker\", \"lxc\", \"openvz\", \"podman\", \"container\"]"
    assert platform.to_bash_conditional() == \
        "[ ! -f /.dockerenv ] && [ ! -f /run/.containerenv ]"
    platform_el = ET.fromstring(platform.to_xml_element())
    assert platform_el.tag == "{%s}platform" % cpe_language_namespace
    assert platform_el.get("id") == "machine"
    logical_tests = platform_el.findall(
        "{%s}logical-test" % cpe_language_namespace)
    assert len(logical_tests) == 1
    assert logical_tests[0].get("operator") == "AND"
    assert logical_tests[0].get("negate") == "false"
    fact_refs = logical_tests[0].findall(
        "{%s}fact-ref" % cpe_language_namespace)
    assert len(fact_refs) == 1
    assert fact_refs[0].get("name") == "cpe:/a:machine"


def test_platform_from_text_simple_product_cpe(product_cpes):
    platform = ssg.build_yaml.Platform.from_text("rhel7-workstation", product_cpes)
    assert platform.to_bash_conditional() == ""
    assert platform.to_ansible_conditional() == ""
    platform_el = ET.fromstring(platform.to_xml_element())
    assert platform_el.tag == "{%s}platform" % cpe_language_namespace
    assert platform_el.get("id") == "rhel7-workstation"
    logical_tests = platform_el.findall(
        "{%s}logical-test" % cpe_language_namespace)
    assert len(logical_tests) == 1
    assert logical_tests[0].get("operator") == "AND"
    assert logical_tests[0].get("negate") == "false"
    fact_refs = logical_tests[0].findall(
        "{%s}fact-ref" % cpe_language_namespace)
    assert len(fact_refs) == 1
    assert fact_refs[0].get("name") == \
        "cpe:/o:redhat:enterprise_linux:7::workstation"


def test_platform_from_text_or(product_cpes):
    platform = ssg.build_yaml.Platform.from_text("ntp or chrony", product_cpes)
    assert platform.to_bash_conditional() == "( rpm --quiet -q chrony || rpm --quiet -q ntp )"
    assert platform.to_ansible_conditional() == \
        "( \"chrony\" in ansible_facts.packages or \"ntp\" in ansible_facts.packages )"
    platform_el = ET.fromstring(platform.to_xml_element())
    assert platform_el.tag == "{%s}platform" % cpe_language_namespace
    assert platform_el.get("id") == "chrony_or_ntp"
    logical_tests = platform_el.findall(
        "{%s}logical-test" % cpe_language_namespace)
    assert len(logical_tests) == 1
    assert logical_tests[0].get("operator") == "OR"
    assert logical_tests[0].get("negate") == "false"
    fact_refs = logical_tests[0].findall(
        "{%s}fact-ref" % cpe_language_namespace)
    assert len(fact_refs) == 2
    assert fact_refs[0].get("name") == "cpe:/a:chrony"
    assert fact_refs[1].get("name") == "cpe:/a:ntp"


def test_platform_from_text_complex_expression(product_cpes):
    platform = ssg.build_yaml.Platform.from_text(
        "systemd and !yum and (ntp or chrony)", product_cpes)
    assert platform.to_bash_conditional() == "( rpm --quiet -q systemd && ( rpm --quiet -q chrony || rpm --quiet -q ntp ) && ! ( rpm --quiet -q yum ) )"
    assert platform.to_ansible_conditional() == "( \"systemd\" in ansible_facts.packages and ( \"chrony\" in ansible_facts.packages or \"ntp\" in ansible_facts.packages ) and not ( \"yum\" in ansible_facts.packages ) )"
    platform_el = ET.fromstring(platform.to_xml_element())
    assert platform_el.tag == "{%s}platform" % cpe_language_namespace
    assert platform_el.get("id") == "systemd_and_chrony_or_ntp_and_not_yum"
    logical_tests = platform_el.findall(
        "{%s}logical-test" % cpe_language_namespace)
    assert len(logical_tests) == 1
    assert logical_tests[0].get("operator") == "AND"
    assert logical_tests[0].get("negate") == "false"
    logical_tests_2 = logical_tests[0].findall(
        "{%s}logical-test" % cpe_language_namespace)
    assert len(logical_tests_2) == 2
    assert logical_tests_2[0].get("operator") == "OR"
    assert logical_tests_2[0].get("negate") == "false"
    fact_refs = logical_tests_2[0].findall(
        "{%s}fact-ref" % cpe_language_namespace)
    assert len(fact_refs) == 2
    assert fact_refs[0].get("name") == "cpe:/a:chrony"
    assert fact_refs[1].get("name") == "cpe:/a:ntp"
    assert logical_tests_2[1].get("operator") == "AND"
    assert logical_tests_2[1].get("negate") == "true"
    fact_refs_2 = logical_tests_2[1].findall(
        "{%s}fact-ref" % cpe_language_namespace)
    assert len(fact_refs_2) == 1
    assert fact_refs_2[0].get("name") == "cpe:/a:yum"
    fact_refs_3 = logical_tests[0].findall(
        "{%s}fact-ref" % cpe_language_namespace)
    assert len(fact_refs_3) == 1
    assert fact_refs_3[0].get("name") == "cpe:/a:systemd"


def test_platform_equality(product_cpes):
    platform1 = ssg.build_yaml.Platform.from_text("ntp or chrony", product_cpes)
    platform2 = ssg.build_yaml.Platform.from_text("chrony or ntp", product_cpes)
    assert platform1 == platform2
    platform3 = ssg.build_yaml.Platform.from_text("(chrony and ntp)", product_cpes)
    platform4 = ssg.build_yaml.Platform.from_text("chrony and ntp", product_cpes)
    assert platform3 == platform4


def test_platform_as_dict(product_cpes):
    pl = ssg.build_yaml.Platform.from_text("chrony and rhel7", product_cpes)
    # represent_as_dict is used during dump_yaml
    d = pl.represent_as_dict()
    assert d["name"] == "chrony_and_rhel7"
    # the "rhel7" platform doesn't have any conditionals
    # therefore the final conditional doesn't use it
    assert d["ansible_conditional"] == "( \"chrony\" in ansible_facts.packages )"
    assert d["bash_conditional"] == "( rpm --quiet -q chrony )"
    assert "xml_content" in d


def test_derive_id_from_file_name():
    assert ssg.build_yaml.derive_id_from_file_name("rule.yml") == "rule"
    assert ssg.build_yaml.derive_id_from_file_name("id.with.dots.yaml") == "id.with.dots"
    assert ssg.build_yaml.derive_id_from_file_name("my_id") == "my_id"
