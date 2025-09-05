import contextlib
import collections
import os
import tempfile

import yaml
import pytest
import xml.etree.ElementTree as ET

from ssg.build_cpe import ProductCPEs
import ssg.build_yaml
import ssg.entities.common
from ssg.constants import XCCDF12_NS, cpe_language_namespace, xhtml_namespace
from ssg.yaml import open_raw


PROJECT_ROOT = os.path.join(os.path.dirname(__file__), "..", "..", "..", )
DATADIR = os.path.abspath(os.path.join(os.path.dirname(__file__), "data"))


def test_add_sub_element():
    parent = ET.Element("{%s}glass" % XCCDF12_NS)
    text = "Use <tt>public</tt> and<br/> private mushrooms!"
    child = ssg.build_yaml.add_sub_element(
        parent, "wall", XCCDF12_NS, text)
    assert child.tag == "{%s}wall" % XCCDF12_NS
    all_text = "".join(child.itertext())
    assert all_text == "Use public and private mushrooms!"
    assert "&lt;" not in all_text
    tt_els = child.findall("{%s}tt" % xhtml_namespace)
    assert len(tt_els) == 0
    code_els = child.findall("{%s}code" % xhtml_namespace)
    assert len(code_els) == 1
    code_el = code_els[0]
    assert code_el.text == "public"
    assert len(code_el) == 0
    assert len(code_el.attrib) == 0
    br_els = child.findall("{%s}br" % xhtml_namespace)
    assert len(br_els) == 1
    br_el = br_els[0]
    assert br_el.text is None
    assert len(br_el) == 0
    assert len(br_el.attrib) == 0


def test_add_sub_element_with_sub():
    parent = ET.Element("{%s}cheese" % XCCDF12_NS)
    text = "The horse sings <sub idref=\"green\"/> and eats my igloo"
    child = ssg.build_yaml.add_sub_element(
        parent, "shop", XCCDF12_NS, text)
    assert "".join(child.itertext()) == "The horse sings  and eats my igloo"
    sub_els = child.findall("{%s}sub" % XCCDF12_NS)
    assert len(sub_els) == 1
    sub_el = sub_els[0]
    assert len(sub_el) == 0
    assert len(sub_el.attrib) == 2
    assert sub_el.get("idref") == "xccdf_org.ssgproject.content_value_green"
    assert sub_el.get("use") == "legacy"


def test_add_warning_elements():
    rule_el = ET.Element("{%s}Rule" % XCCDF12_NS)
    warnings = [
        {"general": "hot beverage"},
        {"general": "inflammable material"}
    ]
    ssg.build_yaml.add_warning_elements(rule_el, warnings)
    assert rule_el.tag == "{%s}Rule" % XCCDF12_NS
    assert len(rule_el) == 2
    warning_els = rule_el.findall("{%s}warning" % XCCDF12_NS)
    assert len(warning_els) == 2
    for warning_el in warning_els:
        assert len(warning_el) == 0
        assert len(warning_el.attrib) == 1
        assert warning_el.get("category") == "general"
    texts = [x.text for x in warning_els]
    assert "hot beverage" in texts
    assert "inflammable material" in texts


def test_check_warnings():
    warnings = [
        {
            "general": "hot beverage",
            "error": "explosive"
        }
    ]
    XCCDFStructure = collections.namedtuple("XCCDFStructure", "warnings")
    s = XCCDFStructure(warnings=warnings)
    with pytest.raises(ValueError) as e:
        ssg.build_yaml.check_warnings(s)
    msg = "Only one key/value pair should exist for each warnings dictionary"
    assert msg in str(e)


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
    product_cpes =  ProductCPEs()
    product_cpes.load_product_cpes(product_yaml)
    product_cpes.load_content_cpes(product_yaml)
    return product_cpes


def test_platform_from_text_unknown_platform(product_cpes):
    with pytest.raises(ssg.build_cpe.CPEDoesNotExist):
        ssg.build_yaml.Platform.from_text("something_bogus", product_cpes)


def test_platform_from_text_simple(product_cpes):
    platform = ssg.build_yaml.Platform.from_text("machine", product_cpes)
    assert platform.get_remediation_conditional("ansible") == \
        "ansible_virtualization_type not in [\"docker\", \"lxc\", \"openvz\", \"podman\", \"container\"]"
    assert platform.get_remediation_conditional("bash") == \
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
    assert platform.get_remediation_conditional("bash") == ""
    assert platform.get_remediation_conditional("ansible") == ""
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
    assert platform.get_remediation_conditional("bash") == "( rpm --quiet -q chrony || rpm --quiet -q ntp )"
    assert platform.get_remediation_conditional("ansible") == \
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


def test_platform_from_text_and_empty_conditionals(product_cpes):
    platform = ssg.build_yaml.Platform.from_text(
        "krb5_server_older_than_1_17-18 and krb5_workstation_older_than_1_17-18", product_cpes)
    assert platform.get_remediation_conditional("bash") == ""
    assert platform.get_remediation_conditional("ansible") == ""


def test_platform_from_text_complex_expression(product_cpes):
    platform = ssg.build_yaml.Platform.from_text(
        "systemd and !yum and (ntp or chrony)", product_cpes)
    assert platform.get_remediation_conditional("bash") == "( rpm --quiet -q systemd && ( rpm --quiet -q chrony || rpm --quiet -q ntp ) && ! ( rpm --quiet -q yum ) )"
    assert platform.get_remediation_conditional("ansible") == "( \"systemd\" in ansible_facts.packages and ( \"chrony\" in ansible_facts.packages or \"ntp\" in ansible_facts.packages ) and not ( \"yum\" in ansible_facts.packages ) )"
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

def test_platform_get_invalid_conditional_language(product_cpes):
    platform = ssg.build_yaml.Platform.from_text("ntp or chrony", product_cpes)
    with pytest.raises(AttributeError):
        assert platform.get_remediation_conditional("foo")

def test_parametrized_platform(product_cpes):
    platform = ssg.build_yaml.Platform.from_text("package[test]", product_cpes)
    assert platform.test.cpe_name != "cpe:/a:{arg}"
    assert platform.test.cpe_name == "cpe:/a:test"
    cpe_item = product_cpes.get_cpe(platform.test.cpe_name)
    assert cpe_item.name == "cpe:/a:test"
    assert cpe_item.title == "Package test is installed"
    assert cpe_item.check_id == "installed_env_has_test_package"




def test_derive_id_from_file_name():
    assert ssg.entities.common.derive_id_from_file_name("rule.yml") == "rule"
    assert ssg.entities.common.derive_id_from_file_name("id.with.dots.yaml") == "id.with.dots"
    assert ssg.entities.common.derive_id_from_file_name("my_id") == "my_id"


def test_rule_triage_policy_files():
    product = "example"
    filenames = [
        "policy/po/shared.yml",
        "policy/po/example.yml",
        "policy/li/sample.yml",
        "policy/li/shared.yml",
        "policy/cy/sample.yml",
    ]
    rule = ssg.build_yaml.Rule("id")
    triaged = rule.triage_policy_specific_content(product, filenames)
    number_of_applicable_policies = 2
    assert len(triaged) == number_of_applicable_policies
    assert triaged["po"].endswith(product + ".yml")
    assert triaged["li"].endswith("shared" + ".yml")
    triaged = rule.triage_policy_specific_content("", filenames)
    number_of_applicable_policies = 2
    assert len(triaged) == number_of_applicable_policies
    assert triaged["po"].endswith("shared" + ".yml")
    assert triaged["li"].endswith("shared" + ".yml")


@contextlib.contextmanager
def temporary_filename():
    import tempfile
    try:
        tmp = tempfile.NamedTemporaryFile(delete=False)
        tmp_name = tmp.name
        tmp.close()
        yield tmp_name
    finally:
        os.unlink(tmp_name)


@pytest.fixture
def rule_accounts_tmout():
    rule_file = os.path.join(DATADIR, "accounts_tmout.yml")
    return ssg.build_yaml.Rule.from_yaml(rule_file)


def test_rule_to_xml_element(rule_accounts_tmout):
    xmldiff_main = pytest.importorskip("xmldiff.main")
    rule_el = rule_accounts_tmout.to_xml_element()
    with temporary_filename() as real:
        ET.ElementTree(rule_el).write(real)
        expected = os.path.join(DATADIR, "accounts_tmout.xml")
        diff = xmldiff_main.diff_files(real, expected)
        assert diff == []


@pytest.fixture
def group_selinux():
    rule_file = os.path.join(DATADIR, "selinux.yml")
    return ssg.build_yaml.Group.from_yaml(rule_file)


def test_group_to_xml_element(group_selinux):
    xmldiff_main = pytest.importorskip("xmldiff.main")
    group_el = group_selinux.to_xml_element()
    with temporary_filename() as real:
        ET.ElementTree(group_el).write(real)
        expected = os.path.join(DATADIR, "selinux.xml")
        diff = xmldiff_main.diff_files(real, expected)
        assert diff == []


@pytest.fixture
def value_system_crypto_policy():
    value_file = os.path.join(DATADIR, "var_system_crypto_policy.yml")
    return ssg.build_yaml.Value.from_yaml(value_file)


def test_value_to_xml_element(value_system_crypto_policy):
    xmldiff_main = pytest.importorskip("xmldiff.main")
    value_el = value_system_crypto_policy.to_xml_element()
    with temporary_filename() as real:
        ET.ElementTree(value_el).write(real)
        expected = os.path.join(DATADIR, "var_system_crypto_policy.xml")
        diff = xmldiff_main.diff_files(real, expected)
        assert diff == []


@pytest.fixture
def profile_ospp():
    value_file = os.path.join(DATADIR, "ospp.profile")
    return ssg.build_yaml.Profile.from_yaml(value_file)


def test_profile_to_xml_element(profile_ospp):
    xmldiff_main = pytest.importorskip("xmldiff.main")
    profile_el = profile_ospp.to_xml_element()
    with temporary_filename() as real:
        ET.ElementTree(profile_el).write(real)
        expected = os.path.join(DATADIR, "ospp.xml")
        diff = xmldiff_main.diff_files(real, expected)
        assert diff == []


@pytest.fixture
def profile_ospp_with_extends(profile_ospp):
    profile_ospp.extends = "xccdf_org.ssgproject.content_profile_standard"
    return profile_ospp


def test_profile_to_xml_element_extends(profile_ospp_with_extends):
    profile_el = profile_ospp_with_extends.to_xml_element()
    assert profile_el.get("extends") == \
        "xccdf_org.ssgproject.content_profile_standard"


@pytest.fixture
def rule_without_ocil():
    rule_file = os.path.join(DATADIR, "accounts_tmout_without_ocil.yml")
    return ssg.build_yaml.Rule.from_yaml(rule_file)


def test_rule_to_ocil_without_ocil(rule_without_ocil):
    with pytest.raises(ValueError) as e:
        rule_without_ocil.to_ocil()
    assert "Rule accounts_tmout_without_ocil doesn't have OCIL" in str(e)


def test_rule_to_ocil(rule_accounts_tmout):
    xmldiff_main = pytest.importorskip("xmldiff.main")
    questionnaire, action, boolean_question = rule_accounts_tmout.to_ocil()
    testables = {
        questionnaire: "accounts_tmout_questionnaire.xml",
        action: "accounts_tmout_action.xml",
        boolean_question: "accounts_tmout_boolean_question.xml"
    }
    for element, expected_filename in testables.items():
        with temporary_filename() as real_file_path:
            ET.ElementTree(element).write(real_file_path)
            expected_file_path = os.path.join(DATADIR, expected_filename)
            diff = xmldiff_main.diff_files(real_file_path, expected_file_path)
            assert diff == []
