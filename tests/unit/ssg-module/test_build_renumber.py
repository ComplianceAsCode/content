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


def test_get_nonexisting_check_definition_extends(oval_def_pear):
    index = dict()
    ext_ref = ssg.build_renumber.get_nonexisting_check_definition_extends(
        oval_def_pear, index)
    assert ext_ref == "apple"


def test_get_nonexisting_check_definition_extends_existing(
        oval_def_apple, oval_def_pear):
    index = {"apple": oval_def_apple}
    ext_ref = ssg.build_renumber.get_nonexisting_check_definition_extends(
        oval_def_pear, index)
    assert ext_ref is None


def test_get_nonexisting_check_definition_extends_no_extends(
        oval_def_apple, oval_def_pear):
    index = {"apple": oval_def_apple}
    ext_ref = ssg.build_renumber.get_nonexisting_check_definition_extends(
        oval_def_pear, index)
    assert ext_ref is None


@pytest.fixture
def oval_with_broken_extend_definition():
    name = "oval_with_broken_extend_definition.xml"
    file_path = os.path.join(DATADIR, name)
    return ET.parse(file_path).getroot()


def test_get_oval_checks_extending_non_existing_checks(
        oval_with_broken_extend_definition):
    index = ssg.xml.map_elements_to_their_ids(
        oval_with_broken_extend_definition,
        ".//{%s}definition" % oval_namespace)
    miss = ssg.build_renumber.get_oval_checks_extending_non_existing_checks(
        oval_with_broken_extend_definition, index)
    assert len(miss) == 2
    defs = set.union(*miss.values())
    assert "oval:ssg-package_httpd_removed:def:1" in defs
    assert "oval:ssg-service_postfix_enabled:def:1" in defs


@pytest.fixture
def oval_with_correct_extend_definition():
    name = "oval_with_correct_extend_definition.xml"
    file_path = os.path.join(DATADIR, name)
    return ET.parse(file_path).getroot()


def test_get_oval_checks_extending_non_existing_checks_correct(
        oval_with_correct_extend_definition):
    index = ssg.xml.map_elements_to_their_ids(
        oval_with_correct_extend_definition,
        ".//{%s}definition" % oval_namespace)
    miss = ssg.build_renumber.get_oval_checks_extending_non_existing_checks(
        oval_with_correct_extend_definition, index)
    assert len(miss) == 0


def test_transpose_dict_with_sets():
    d1 = {
        "animals": {"dog", "cat", "mouse"},
        "fruit": {"banana", "plum"}
    }
    t1 = ssg.build_renumber.transpose_dict_with_sets(d1)
    assert len(t1) == 5
    assert len(t1["dog"]) == 1
    assert "animals" in t1["dog"]
    assert len(t1["cat"]) == 1
    assert "animals" in t1["cat"]
    assert len(t1["mouse"]) == 1
    assert "animals" in t1["mouse"]
    assert len(t1["banana"]) == 1
    assert "fruit" in t1["banana"]
    assert len(t1["plum"]) == 1
    assert "fruit" in t1["plum"]

    d2 = {
        "food": {"apple", "pizza"},
        "fruit": {"apple", "pear"}
    }
    t2 = ssg.build_renumber.transpose_dict_with_sets(d2)
    assert len(t2) == 3
    assert len(t2["apple"]) == 2
    assert "food" in t2["apple"]
    assert "fruit" in t2["apple"]
    assert len(t2["pizza"]) == 1
    assert "food" in t2["pizza"]
    assert len(t2["pear"]) == 1
    assert "fruit" in t2["pear"]

    d3 = dict()
    t3 = ssg.build_renumber.transpose_dict_with_sets(d3)
    assert len(t3) == 0


@pytest.fixture
def xccdf_with_value():
    bench = ET.Element("{%s}Benchmark" % XCCDF12_NS)
    val = ET.SubElement(bench, "{%s}Value" % XCCDF12_NS)
    val.set("id", "var_password_age")
    val.set("type", "string")
    return bench


@pytest.fixture
def xccdf_with_incomplete_value():
    bench = ET.Element("{%s}Benchmark" % XCCDF12_NS)
    val = ET.SubElement(bench, "{%s}Value" % XCCDF12_NS)
    val.set("id", "var_password_age")
    return bench


@pytest.fixture
def oval_with_external_variable_without_id_or_datatype():
    oval = ET.Element("{%s}oval_definitions" % oval_namespace)
    vars = ET.SubElement(oval, "{%s}variables" % oval_namespace)
    e_var = ET.SubElement(vars, "{%s}external_variable" % oval_namespace)
    return oval


@pytest.fixture
def oval_with_external_variable_without_id():
    oval = ET.Element("{%s}oval_definitions" % oval_namespace)
    vars = ET.SubElement(oval, "{%s}variables" % oval_namespace)
    e_var = ET.SubElement(vars, "{%s}external_variable" % oval_namespace)
    e_var.set("datatype", "string")
    return oval


@pytest.fixture
def oval_with_external_variable_without_datatype():
    oval = ET.Element("{%s}oval_definitions" % oval_namespace)
    vars = ET.SubElement(oval, "{%s}variables" % oval_namespace)
    e_var = ET.SubElement(vars, "{%s}external_variable" % oval_namespace)
    e_var.set("id", "var_password_age")
    return oval


@pytest.fixture
def oval_with_external_variable():
    oval = ET.Element("{%s}oval_definitions" % oval_namespace)
    vars = ET.SubElement(oval, "{%s}variables" % oval_namespace)
    e_var = ET.SubElement(vars, "{%s}external_variable" % oval_namespace)
    e_var.set("id", "var_password_age")
    e_var.set("datatype", "string")
    e_var.set("comment", "this is your long age")
    e_var.set("version", "1")
    return oval


def test_check_and_correct_xccdf_to_oval_data_export_matching_constraints_1(
        xccdf_with_value, oval_with_external_variable_without_id_or_datatype):
    with pytest.raises(SSGError) as e:
        ssg.build_renumber.check_and_correct_xccdf_to_oval_data_export_matching_constraints(
            xccdf_with_value,
            oval_with_external_variable_without_id_or_datatype)
    assert (
        "Invalid OVAL <external_variable> found - either without "
        "'id' or 'datatype'") in str(e)


def test_check_and_correct_xccdf_to_oval_data_export_matching_constraints_2(
        xccdf_with_value, oval_with_external_variable_without_id):
    with pytest.raises(SSGError) as e:
        ssg.build_renumber.check_and_correct_xccdf_to_oval_data_export_matching_constraints(
            xccdf_with_value, oval_with_external_variable_without_id)
    assert (
        "Invalid OVAL <external_variable> found - either without "
        "'id' or 'datatype'") in str(e)


def test_check_and_correct_xccdf_to_oval_data_export_matching_constraints_3(
        xccdf_with_value, oval_with_external_variable_without_datatype):
    with pytest.raises(SSGError) as e:
        ssg.build_renumber.check_and_correct_xccdf_to_oval_data_export_matching_constraints(
            xccdf_with_value, oval_with_external_variable_without_datatype)
    assert (
        "Invalid OVAL <external_variable> found - either without "
        "'id' or 'datatype'") in str(e)


def test_check_and_correct_xccdf_to_oval_data_export_matching_constraints_4(
        xccdf_with_incomplete_value, oval_with_external_variable):
    with pytest.raises(SSGError) as e:
        ssg.build_renumber.check_and_correct_xccdf_to_oval_data_export_matching_constraints(
            xccdf_with_incomplete_value, oval_with_external_variable)
    assert (
        "Invalid XCCDF variable 'var_password_age': Missing the"
        " 'type' attribute") in str(e)


def test_check_and_correct_xccdf_to_oval_data_export_matching_constraints_5(
        xccdf_with_value, oval_with_external_variable):
    ssg.build_renumber.check_and_correct_xccdf_to_oval_data_export_matching_constraints(
        xccdf_with_value, oval_with_external_variable)
    assert xccdf_with_value is not None


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
