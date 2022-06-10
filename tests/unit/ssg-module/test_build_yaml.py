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
    product_cpes = ProductCPEs()
    product_cpes.load_product_cpes(product_yaml)
    product_cpes.load_content_cpes(product_yaml)
    return product_cpes


def test_platform_from_text_unknown_platform(product_cpes):
    with pytest.raises(ssg.build_cpe.CPEDoesNotExist):
        ssg.build_yaml.Platform.from_text("something_bogus", product_cpes)


def test_platform_from_text_simple(product_cpes):
    platform = ssg.build_yaml.Platform.from_text("machine", product_cpes)
    platform_el = platform.to_xml_element()
    assert platform_el.tag == "{%s}platform" % cpe_language_namespace
    assert platform_el.get("id") == '50f29e3d-05ac-5d11-be18-a001abdef4c3'  # "machine"
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
    platform_el = platform.to_xml_element()
    assert platform_el.tag == "{%s}platform" % cpe_language_namespace
    assert platform_el.get("id") == '9dedf00c-2720-5990-9649-ae7d45a6be80'  # "rhel7-workstation"
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
    platform_el = platform.to_xml_element()
    assert platform_el.tag == "{%s}platform" % cpe_language_namespace
    assert platform_el.get("id") == '07f4f9e5-61f1-5bad-a650-8057ebce023d'  # "chrony_or_ntp"
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
    platform_el = platform.to_xml_element()
    assert platform_el.tag == "{%s}platform" % cpe_language_namespace
    assert platform_el.get("id") == 'f79e17f6-a0fc-5ea7-8cea-53ef9646704f'
    # "systemd_and_chrony_or_ntp_and_not_yum"
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
    assert d["name"] == 'a37aa1d5-548f-5612-b378-3be8c3a068c9'  # "chrony_and_rhel7"
    # the "rhel7" platform doesn't have any conditionals
    # therefore the final conditional doesn't use it
    assert "xml_content" in d


def test_derive_id_from_file_name():
    assert ssg.build_yaml.derive_id_from_file_name("rule.yml") == "rule"
    assert ssg.build_yaml.derive_id_from_file_name("id.with.dots.yaml") == "id.with.dots"
    assert ssg.build_yaml.derive_id_from_file_name("my_id") == "my_id"
