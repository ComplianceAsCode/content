import os
import tempfile

import yaml
import pytest
import xml.etree.ElementTree as ET
from ssg.build_cpe import ProductCPEs

import ssg.build_yaml
from ssg.constants import (
    OVAL_SUB_NS, XCCDF12_NS, cpe_language_namespace, oval_namespace, ocil_cs
)
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


@pytest.fixture
def rule_accounts_tmout():
    rule_file = os.path.join(DATADIR, "accounts_tmout.yml")
    return ssg.build_yaml.Rule.from_yaml(rule_file)


def test_rule_to_xml_element(rule_accounts_tmout):
    rule_el = rule_accounts_tmout.to_xml_element()

    assert rule_el is not None
    assert rule_el.tag == "{%s}Rule" % XCCDF12_NS
    assert len(rule_el.attrib) == 3
    assert rule_el.get("id") == \
        "xccdf_org.ssgproject.content_rule_accounts_tmout"
    assert rule_el.get("selected") == "false"
    assert rule_el.get("selected") == "false"

    title_els = rule_el.findall("{%s}title" % XCCDF12_NS)
    assert len(title_els) == 1
    title_el = title_els[0]
    assert title_el is not None
    assert title_el.text == "Set Interactive Session Timeout"
    assert len(title_el.attrib) == 0

    description_els = rule_el.findall("{%s}description" % XCCDF12_NS)
    assert len(description_els) == 1
    description_el = description_els[0]
    assert description_el is not None
    assert "Setting the TMOUT option in /etc/profile" in \
        "".join(description_el.itertext())
    assert len(description_el.attrib) == 0

    sub_el = description_el.find(".//{%s}sub" % XCCDF12_NS)
    assert sub_el is not None

    reference_els = rule_el.findall("{%s}reference" % XCCDF12_NS)
    assert len(reference_els) == 50
    for reference_el in reference_els:
        assert reference_el.get("href") is not None
    pp_href = "https://www.niap-ccevs.org/Profile/PP.cfm"
    pp = rule_el.find("{%s}reference[@href='%s']" % (XCCDF12_NS, pp_href))
    assert pp is not None
    assert pp.text == "FMT_MOF_EXT.1"

    rationale_els = rule_el.findall("{%s}rationale" % XCCDF12_NS)
    assert len(rationale_els) == 1
    rationale_el = rationale_els[0]
    assert len(rationale_el.attrib) == 0
    assert rationale_el.text == \
        """Terminating an idle session within a short time period reduces
the window of opportunity for unauthorized personnel to take control of a
management session enabled on the console or console port that has been
left unattended."""

    ident_els = rule_el.findall("{%s}ident" % XCCDF12_NS)
    assert len(ident_els) == 1
    ident_el = ident_els[0]
    assert len(ident_el.attrib) == 1
    assert ident_el.get("system") == "https://nvd.nist.gov/cce/index.cfm"
    assert ident_el.text == "CCE-83633-8"

    check_els = rule_el.findall("./{%s}check" % XCCDF12_NS)
    assert len(check_els) == 2

    ocil_check_el = rule_el.find(
        "{%s}check[@system='%s']" % (XCCDF12_NS, ocil_cs))
    assert ocil_check_el.text is None
    ocil_check_content_ref = ocil_check_el.find(
        "{%s}check-content-ref" % XCCDF12_NS)
    assert len(ocil_check_content_ref.attrib) == 2
    assert ocil_check_content_ref.get("href") == "ocil-unlinked.xml"
    assert ocil_check_content_ref.get("name") == "accounts_tmout_ocil"
    assert ocil_check_content_ref.text is None

    oval_check_el = rule_el.find(
        "{%s}check[@system='%s']" % (XCCDF12_NS, oval_namespace))
    assert oval_check_el.text is None
    oval_check_content_ref = oval_check_el.find(
        "{%s}check-content-ref" % XCCDF12_NS)
    assert len(oval_check_content_ref.attrib) == 2
    assert oval_check_content_ref.get("href") == "oval-unlinked.xml"
    assert oval_check_content_ref.get("name") == "accounts_tmout"
    assert oval_check_content_ref.text is None


@pytest.fixture
def group_selinux():
    rule_file = os.path.join(DATADIR, "selinux.yml")
    return ssg.build_yaml.Group.from_yaml(rule_file)


def test_group_to_xml_element(group_selinux):
    group_el = group_selinux.to_xml_element()
    assert group_el is not None
    assert group_el.tag == "{%s}Group" % XCCDF12_NS
    assert len(group_el.attrib) == 1
    assert group_el.get("id") == "xccdf_org.ssgproject.content_group_selinux"
    assert group_el.text is None

    title_els = group_el.findall("{%s}title" % XCCDF12_NS)
    assert len(title_els) == 1
    title_el = title_els[0]
    assert title_el.text == "SELinux"
    assert len(title_el.attrib) == 0

    description_els = group_el.findall("{%s}description" % XCCDF12_NS)
    assert len(description_els) == 1
    description_el = description_els[0]
    assert description_el.text.startswith(
        "SELinux is a feature of the Linux kernel")
    assert len(description_el.attrib) == 0

    platform_els = group_el.findall("{%s}platform" % XCCDF12_NS)
    assert len(platform_els) == 1
    platform_el = platform_els[0]
    assert len(platform_el.attrib) == 1
    assert platform_el.get("idref") == "#machine"

    conflicts_els = group_el.findall("{%s}conflicts" % XCCDF12_NS)
    assert len(conflicts_els) == 1
    conflicts_el = conflicts_els[0]
    assert len(conflicts_el.attrib) == 1
    assert conflicts_el.get("idref") == \
        "xccdf_org.ssgproject.content_group_apparmor"


@pytest.fixture
def value_system_crypto_policy():
    value_file = os.path.join(DATADIR, "var_system_crypto_policy.yml")
    return ssg.build_yaml.Value.from_yaml(value_file)


def test_value_to_xml_element(value_system_crypto_policy):
    value_el = value_system_crypto_policy.to_xml_element()
    assert value_el.tag == "{%s}Value" % XCCDF12_NS
    assert len(value_el.attrib) == 2
    assert value_el.get("id") == \
        "xccdf_org.ssgproject.content_value_var_system_crypto_policy"
    assert value_el.get("type") == "string"

    title_els = value_el.findall("{%s}title" % XCCDF12_NS)
    assert len(title_els) == 1
    title_el = title_els[0]
    assert len(title_el.attrib) == 0
    assert title_el.text == "The system-provided crypto policies"

    description_els = value_el.findall("{%s}description" % XCCDF12_NS)
    assert len(description_els) == 1
    description_el = description_els[0]
    assert len(description_el.attrib) == 0
    assert description_el.text == "Specify the crypto policy for the system."

    vv_els = value_el.findall("{%s}value" % XCCDF12_NS)
    assert len(vv_els) == 4
    vv1 = value_el.find("{%s}value" % XCCDF12_NS)
    assert len(vv1.attrib) == 0
    assert vv1.text == "DEFAULT"
    vv6 = value_el.find("{%s}value[@selector='legacy']" % XCCDF12_NS)
    assert len(vv6.attrib) == 1
    assert vv6.text == "LEGACY"
    vv7 = value_el.find("{%s}value[@selector='future']" % XCCDF12_NS)
    assert len(vv7.attrib) == 1
    assert vv7.text == "FUTURE"
    vv8 = value_el.find("{%s}value[@selector='next']" % XCCDF12_NS)
    assert len(vv8.attrib) == 1
    assert vv8.text == "NEXT"


@pytest.fixture
def profile_ospp():
    value_file = os.path.join(DATADIR, "ospp.profile")
    return ssg.build_yaml.Profile.from_yaml(value_file)


def test_profile_to_xml_element(profile_ospp):
    profile_el = profile_ospp.to_xml_element()
    assert profile_el.tag == "{%s}Profile" % XCCDF12_NS
    assert len(profile_el.attrib) == 1
    assert profile_el.get("id") == "xccdf_org.ssgproject.content_profile_ospp"
    assert profile_el.get("extends") is None
    assert profile_el.text is None

    title_els = profile_el.findall("{%s}title" % XCCDF12_NS)
    assert len(title_els) == 1
    title_el = title_els[0]
    assert len(title_el.attrib) == 1
    assert title_el.get("override") == "true"
    assert title_el.text == \
        "Protection Profile for General Purpose Operating Systems"

    description_els = profile_el.findall("{%s}description" % XCCDF12_NS)
    assert len(description_els) == 1
    description_el = description_els[0]
    assert len(description_el.attrib) == 1
    assert title_el.get("override") == "true"
    assert description_el.text.startswith(
        "This profile is part of Red Hat Enterprise Linux 9")

    reference_els = profile_el.findall("{%s}reference" % XCCDF12_NS)
    assert len(reference_els) == 1
    assert reference_els[0].text == \
        "https://www.niap-ccevs.org/Profile/Info.cfm?PPID=442&id=442"

    r1_id = "xccdf_org.ssgproject.content_rule_accounts_password_pam_dcredit"
    r1 = profile_el.find("{%s}select[@idref='%s']" % (XCCDF12_NS, r1_id))
    assert r1 is not None
    assert len(r1.attrib) == 2
    assert r1.get("idref") == r1_id
    assert r1.get("selected") == "true"

    rr1_id = "xccdf_org.ssgproject.content_rule_accounts_password_pam_dcredit"
    rr1 = profile_el.find("{%s}refine-rule[@idref='%s']" % (XCCDF12_NS, r1_id))
    assert rr1 is not None
    assert len(rr1.attrib) == 2
    assert rr1.get("idref") == rr1_id
    assert rr1.get("severity") == "info"

    v1_id = "xccdf_org.ssgproject.content_value_var_password_pam_dcredit"
    rv1 = profile_el.find("{%s}refine-value[@idref='%s']" % (XCCDF12_NS, v1_id))
    assert rv1 is not None
    assert len(rv1.attrib) == 2
    assert rv1.get("idref") == v1_id
    assert rv1.get("selector") == "1"


@pytest.fixture
def profile_ospp_with_extends(profile_ospp):
    profile_ospp.extends = "xccdf_org.ssgproject.content_profile_standard"
    return profile_ospp


def test_profile_to_xml_element_extends(profile_ospp_with_extends):
    profile_el = profile_ospp_with_extends.to_xml_element()
    assert profile_el.get("extends") == \
        "xccdf_org.ssgproject.content_profile_standard"
