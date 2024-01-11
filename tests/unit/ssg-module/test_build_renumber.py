import os
import pytest
import xml.etree.ElementTree as ET

import ssg.build_renumber
from ssg.constants import XCCDF12_NS, cce_uri, oval_namespace
from ssg.utils import SSGError

DATADIR = os.path.abspath(os.path.join(os.path.dirname(__file__), "data"))


@pytest.fixture
def rule_el():
    rule = ET.Element("{%s}Rule" % XCCDF12_NS)
    rule.set("id", "xccdf_org.ssgproject_content_rule_selinux_state")
    return rule


@pytest.fixture
def rule_el2():
    rule = ET.Element("{%s}Rule" % XCCDF12_NS)
    rule.set("id", "xccdf_org.ssgproject_content_rule_accounts_tmout")
    return rule


@pytest.fixture
def rule_el_with_cce(rule_el):
    ident = ET.SubElement(rule_el, "{%s}ident" % XCCDF12_NS)
    ident.set("system", cce_uri)
    ident.text = "CCE-1234-789"
    return rule_el


@pytest.fixture
def rule_el2_with_cce(rule_el2):
    ident = ET.SubElement(rule_el2, "{%s}ident" % XCCDF12_NS)
    ident.set("system", cce_uri)
    ident.text = "CCE-666666"
    return rule_el2


def test_find_identcce(rule_el_with_cce):
    ident = ssg.build_renumber._find_identcce(rule_el_with_cce)
    assert ident is not None
    assert ident.get("system") == cce_uri
    assert ident.text == "CCE-1234-789"


@pytest.fixture
def rule_el_without_cce(rule_el):
    ident = ET.SubElement(rule_el, "{%s}ident" % XCCDF12_NS)
    ident.set("system", "http://seventy.com")
    ident.text = "70SS7070707070"
    return rule_el


def test_find_identcce_no_cce(rule_el_without_cce):
    ident = ssg.build_renumber._find_identcce(rule_el_without_cce)
    assert ident is None


@pytest.fixture
def benchmark_el():
    benchmark = ET.Element("{%s}Benchmark" % XCCDF12_NS)
    return benchmark


def test_rules_with_ids_generator_empty(benchmark_el):
    generator = ssg.build_renumber.rules_with_ids_generator(benchmark_el)
    assert list(generator) == []


@pytest.fixture
def benchmark_with_single_rule(benchmark_el, rule_el):
    benchmark_el.append(rule_el)
    return benchmark_el


@pytest.fixture
def benchmark_with_many_rules(benchmark_el, rule_el, rule_el2):
    benchmark_el.append(rule_el)
    benchmark_el.append(rule_el2)
    return benchmark_el


def test_rules_with_ids_generator_single_rule(benchmark_with_single_rule):
    generator = ssg.build_renumber.rules_with_ids_generator(
        benchmark_with_single_rule)
    items = list(generator)
    assert len(items) == 1
    id_, rule = items[0]
    assert id_ == "xccdf_org.ssgproject_content_rule_selinux_state"
    assert rule is not None
    assert rule.tag == "{%s}Rule" % XCCDF12_NS
    assert rule.get("id") == id_


def test_rules_with_ids_generator_(benchmark_with_many_rules):
    generator = ssg.build_renumber.rules_with_ids_generator(
        benchmark_with_many_rules)
    items = list(generator)
    assert len(items) == 2
    id_, rule = items[0]
    assert id_ == "xccdf_org.ssgproject_content_rule_selinux_state"
    assert rule is not None
    assert rule.tag == "{%s}Rule" % XCCDF12_NS
    assert rule.get("id") == id_
    id_, rule = items[1]
    assert id_ == "xccdf_org.ssgproject_content_rule_accounts_tmout"
    assert rule is not None
    assert rule.tag == "{%s}Rule" % XCCDF12_NS
    assert rule.get("id") == id_


@pytest.fixture
def benchmark_with_many_rules_cces(
        benchmark_el, rule_el_with_cce, rule_el2_with_cce):
    benchmark_el.append(rule_el_with_cce)
    benchmark_el.append(rule_el2_with_cce)
    return benchmark_el


def test_create_xccdf_id_to_cce_id_mapping(benchmark_with_many_rules_cces):
    mapping = ssg.build_renumber.create_xccdf_id_to_cce_id_mapping(
        benchmark_with_many_rules_cces)
    assert len(mapping) == 2
    assert mapping["xccdf_org.ssgproject_content_rule_selinux_state"] == \
        "CCE-1234-789"
    assert mapping["xccdf_org.ssgproject_content_rule_accounts_tmout"] == \
        "CCE-666666"


@pytest.fixture
def benchmark_with_many_rules_but_not_all_have_cces(
        benchmark_el, rule_el_without_cce, rule_el2_with_cce):
    benchmark_el.append(rule_el_without_cce)
    benchmark_el.append(rule_el2_with_cce)
    return benchmark_el


def test_create_xccdf_id_to_cce_id_mapping_2(
        benchmark_with_many_rules_but_not_all_have_cces):
    mapping = ssg.build_renumber.create_xccdf_id_to_cce_id_mapping(
        benchmark_with_many_rules_but_not_all_have_cces)
    assert len(mapping) == 1
    assert mapping["xccdf_org.ssgproject_content_rule_accounts_tmout"] == \
        "CCE-666666"


@pytest.fixture
def oval_def_apple():
    odef = ET.Element("{%s}definition" % oval_namespace)
    odef.set("id", "apple")
    return odef


@pytest.fixture
def oval_def_pear():
    odef = ET.Element("{%s}definition" % oval_namespace)
    odef.set("id", "pear")
    criteria = ET.SubElement(odef, "{%s}criteria" % oval_namespace)
    edef = ET.SubElement(criteria, "{%s}extend_definition" % oval_namespace)
    edef.set("definition_ref", "apple")
    return odef


@pytest.fixture
def xccdf_with_invalid_cce():
    bench = ET.Element("{%s}Benchmark" % XCCDF12_NS)
    rule = ET.SubElement(bench, "{%s}Rule" % XCCDF12_NS)
    rule.set("id", "errata_devel")
    ident = ET.SubElement(rule, "{%s}ident" % XCCDF12_NS)
    ident.set("system", cce_uri)
    ident.text = "RHEL7-CCE-TBD"
    return bench


def test_verify_correct_form_of_referenced_cce_identifiers(
        xccdf_with_invalid_cce):
    with pytest.raises(SSGError) as e:
        ssg.build_renumber.verify_correct_form_of_referenced_cce_identifiers(
            xccdf_with_invalid_cce)
    assert (
        "Warning: CCE 'RHEL7-CCE-TBD' is invalid for rule 'errata_devel'. "
        "Removing CCE...") in str(e)


@pytest.fixture
def xccdf_with_no_cce():
    bench = ET.Element("{%s}Benchmark" % XCCDF12_NS)
    rule = ET.SubElement(bench, "{%s}Rule" % XCCDF12_NS)
    rule.set("id", "errata_devel")
    return bench


def test_verify_correct_form_of_referenced_cce_identifiers_no_cce(
        xccdf_with_no_cce):
    try:
        ssg.build_renumber.verify_correct_form_of_referenced_cce_identifiers(
            xccdf_with_no_cce)
    except SSGError as e:
        assert False, "Raised SSGError: " + str(e)
