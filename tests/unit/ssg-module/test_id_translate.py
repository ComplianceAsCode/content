import collections
import copy
import os
import pytest
import xml.etree.ElementTree as ET

import ssg.id_translate
from ssg.constants import XCCDF12_NS, oval_namespace, ocil_namespace

DATADIR = os.path.abspath(os.path.join(os.path.dirname(__file__), "data"))


def test__split_namespace():
    sn = ssg.id_translate._split_namespace

    ns, n = sn("{oval}board")
    assert ns == "oval"
    assert n == "board"

    ns, n = sn("{oval#magic}board")
    assert ns == "oval"
    assert n == "board"

    ns, n = sn("nonamespace")
    assert not ns
    assert n == "nonamespace"

    ns, n = sn("{}emptynamespace")
    assert not ns
    assert n == "emptynamespace"


def test_tagname_to_abbrev():
    tag_expectations = {
        "definition": "def",
        "criteria": "crit",
        "test": "tst",
        "object": "obj",
        "state": "ste",
        "variable": "var",
    }
    for tag, expectation in tag_expectations.items():
        real = ssg.id_translate._tagname_to_abbrev(
            "{%s}%s" % (oval_namespace, tag))
        assert real == expectation


def test_tagname_to_abbrev_unknown_ns():
    with pytest.raises(RuntimeError):
        unknown_name_space = "http://world.wide.web/some/unknown/foo.php"
        ssg.id_translate._tagname_to_abbrev(
            "{%s}rationale" % unknown_name_space)


def test_tagname_to_abbrev_unknown_tag():
    with pytest.raises(KeyError):
        ssg.id_translate._tagname_to_abbrev("{%s}candy" % oval_namespace)
    with pytest.raises(KeyError):
        ssg.id_translate._tagname_to_abbrev("{%s}pizza" % ocil_namespace)


@pytest.fixture
def idtranslator():
    return ssg.id_translate.IDTranslator("ssg")


def test_idtranslator_generate_id(idtranslator):
    genid = idtranslator.generate_id(
        "{%s}object" % oval_namespace, "my_terrible_object")
    assert genid == "oval:ssg-my_terrible_object:obj:1"
    genid = idtranslator.generate_id(
        "{%s}question" % ocil_namespace, "my_terrible_face")
    assert genid == "ocil:ssg-my_terrible_face:question:1"


@pytest.fixture
def oval_tree():
    draft_oval_path = os.path.join(DATADIR, "draft_oval.xml")
    return ET.parse(draft_oval_path).getroot()


def _parse_interesting_ids(oval_tree):
    InterestingIDs = collections.namedtuple(
        "InterestingIDs", [
            "definition_id", "criterion_test_ref", "test_id",
            "object_ref", "object_id", "filter_ref", "state_id"])
    ns = {"oval": oval_namespace, "oval-unix": oval_namespace + "#unix"}
    definition_id = oval_tree.find(
        "oval:definitions/oval:definition", ns).get("id")
    criterion_test_ref = oval_tree.find(
        "oval:definitions/oval:definition/oval:criteria/oval:criterion",
        ns).get("test_ref")
    test_id = oval_tree.find(
        "oval:tests/oval-unix:file_test", ns).get("id")
    object_ref = oval_tree.find(
        "oval:tests/oval-unix:file_test/oval-unix:object",
        ns).get("object_ref")
    object_id = oval_tree.find(
        "oval:objects/oval-unix:file_object",
        ns).get("id")
    filter_ref = oval_tree.find(
        "oval:objects/oval-unix:file_object/oval:filter", ns).text
    state_id = oval_tree.find("oval:states/oval-unix:file_state", ns).get("id")
    iids = InterestingIDs(
        definition_id=definition_id, criterion_test_ref=criterion_test_ref,
        test_id=test_id, object_ref=object_ref, object_id=object_id,
        filter_ref=filter_ref, state_id=state_id)
    return iids


def test_idtranslator_translate_oval_ids(idtranslator, oval_tree):
    expected_definition_id = "oval:ssg-kerberos_disable_no_keytab:def:1"
    expected_test_id = "oval:ssg-test_kerberos_disable_no_keytab:tst:1"
    expected_object_id = "oval:ssg-obj_kerberos_disable_no_keytab:obj:1"
    expected_state_id = "oval:ssg-filter_ssh_key_owner_root:ste:1"
    new_tree = idtranslator.translate(oval_tree)
    real = _parse_interesting_ids(new_tree)
    assert real.definition_id == expected_definition_id
    assert real.criterion_test_ref == expected_test_id
    assert real.criterion_test_ref == real.test_id
    assert real.test_id == expected_test_id
    assert real.object_ref == expected_object_id
    assert real.object_ref == real.object_id
    assert real.object_id == expected_object_id
    assert real.filter_ref == expected_state_id
    assert real.filter_ref == real.state_id
    assert real.state_id == expected_state_id


def test_idtranslator_translate_oval_differences(idtranslator, oval_tree):
    # The goal of this test is to compare the OVAL XML tree before and after
    # the translation. The `==` operator is used in assertions where the
    # properties of the XML tree should not be affected by the translation.
    # The `!=` operator is used in assertions where the properties of the XML
    # tree should be changed by the translation.
    old = copy.deepcopy(oval_tree)
    new = idtranslator.translate(oval_tree)
    assert new is not None
    assert old.tag == new.tag
    assert len(old) == len(new)
    assert len(old.attrib) == len(new.attrib)
    definitions_xpath = "{%s}definitions" % oval_namespace
    old_definitions_els = old.findall(definitions_xpath)
    new_definitions_els = new.findall(definitions_xpath)
    assert len(old_definitions_els) == len(new_definitions_els)
    old_definitions_el = old_definitions_els[0]
    new_definitions_el = new_definitions_els[0]
    assert len(old_definitions_el) == len(new_definitions_el)
    assert len(old_definitions_el.attrib) == len(new_definitions_el.attrib)
    definition_xpath = "{%s}definition" % oval_namespace
    old_definition_els = old_definitions_el.findall(definition_xpath)
    new_definition_els = new_definitions_el.findall(definition_xpath)
    assert len(old_definition_els) == len(new_definition_els)
    old_definition_el = old_definition_els[0]
    new_definition_el = new_definition_els[0]
    assert len(old_definition_el) == len(new_definition_el)
    assert len(old_definition_el.attrib) == len(new_definition_el.attrib)
    assert old_definition_el.get("id") != new_definition_el.get("id")
    assert old_definition_el.get("class") == new_definition_el.get("class")
    assert old_definition_el.get("version") == new_definition_el.get("version")
    metadata_xpath = "{%s}metadata" % oval_namespace
    old_metadata_els = old_definition_el.findall(metadata_xpath)
    new_metadata_els = new_definition_el.findall(metadata_xpath)
    assert len(old_metadata_els) == len(new_metadata_els)
    old_metadata_el = old_metadata_els[0]
    new_metadata_el = new_metadata_els[0]
    assert len(old_metadata_el) == len(new_metadata_el)
    assert len(old_metadata_el.attrib) == len(new_metadata_el.attrib)
    title_xpath = "{%s}title" % oval_namespace
    old_title_els = old_metadata_el.findall(title_xpath)
    new_title_els = new_metadata_el.findall(title_xpath)
    assert len(old_title_els) == len(new_title_els)
    old_title_el = old_title_els[0]
    new_title_el = new_title_els[0]
    assert len(old_title_el) == len(new_title_el)
    assert old_title_el.text == new_title_el.text
    # verify that the translation doesn't add any reference
    reference_xpath = "{%s}reference" % oval_namespace
    old_reference_els = old_metadata_el.findall(reference_xpath)
    new_reference_els = new_metadata_el.findall(reference_xpath)
    assert len(old_reference_els) == len(new_reference_els)
    criteria_xpath = "{%s}criteria" % oval_namespace
    old_criteria_els = old_definition_el.findall(criteria_xpath)
    new_criteria_els = new_definition_el.findall(criteria_xpath)
    assert len(old_criteria_els) == len(new_criteria_els)
    old_criteria_el = old_criteria_els[0]
    new_criteria_el = new_criteria_els[0]
    assert len(old_criteria_el) == len(new_criteria_el)
    assert len(old_criteria_el.attrib) == len(new_criteria_el.attrib)
    criterion_xpath = "{%s}criterion" % oval_namespace
    old_criterion_els = old_criteria_el.findall(criterion_xpath)
    new_criterion_els = new_criteria_el.findall(criterion_xpath)
    assert len(old_criterion_els) == len(new_criterion_els)
    old_criterion_el = old_criterion_els[0]
    new_criterion_el = new_criterion_els[0]
    assert len(old_criterion_el) == len(new_criterion_el)
    assert len(old_criterion_el.attrib) == len(new_criterion_el.attrib)
    assert old_criterion_el.get("test_ref") != new_criterion_el.get("test_ref")
    assert old_criterion_el.get("comment") == new_criterion_el.get("comment")
    oval_unix_namespace = oval_namespace + "#unix"
    tests_xpath = "{%s}tests" % oval_namespace
    old_tests_els = old.findall(tests_xpath)
    new_tests_els = new.findall(tests_xpath)
    assert len(old_tests_els) == len(new_tests_els)
    old_tests_el = old_tests_els[0]
    new_tests_el = new_tests_els[0]
    assert len(old_tests_el) == len(new_tests_el)
    assert len(old_tests_el.attrib) == len(new_tests_el.attrib)
    file_test_xpath = "{%s}file_test" % oval_unix_namespace
    old_file_test_els = old_tests_el.findall(file_test_xpath)
    new_file_test_els = new_tests_el.findall(file_test_xpath)
    assert len(old_file_test_els) == len(new_file_test_els)
    old_file_test_el = old_file_test_els[0]
    new_file_test_el = new_file_test_els[0]
    assert old_file_test_el.get("id") != new_file_test_el.get("id")
    assert old_file_test_el.get("comment") == new_file_test_el.get("comment")
    assert old_file_test_el.get("check") == new_file_test_el.get("check")
    assert old_file_test_el.get("check_existence") == \
        new_file_test_el.get("check_existence")
    assert old_file_test_el.get("version") == new_file_test_el.get("version")
    testobject_xpath = "{%s}object" % oval_unix_namespace
    old_testobject_els = old_file_test_el.findall(testobject_xpath)
    new_testobject_els = new_file_test_el.findall(testobject_xpath)
    assert len(old_testobject_els) == len(new_testobject_els)
    old_testobject_el = old_testobject_els[0]
    new_testobject_el = new_testobject_els[0]
    assert len(old_testobject_el) == len(new_testobject_el)
    assert len(old_testobject_el.attrib) == len(new_testobject_el.attrib)
    assert old_testobject_el.get("object_ref") != \
        new_testobject_el.get("object_ref")
    objects_xpath = "{%s}objects" % oval_namespace
    old_objects_els = old.findall(objects_xpath)
    new_objects_els = new.findall(objects_xpath)
    assert len(old_objects_els) == len(new_objects_els)
    old_objects_el = old_objects_els[0]
    new_objects_el = new_objects_els[0]
    assert len(old_objects_el) == len(new_objects_el)
    file_object_xpath = "{%s}file_object" % oval_unix_namespace
    old_file_object_els = old_objects_el.findall(file_object_xpath)
    new_file_object_els = new_objects_el.findall(file_object_xpath)
    assert len(old_file_object_els) == len(new_file_object_els)
    old_file_object_el = old_file_object_els[0]
    new_file_object_el = new_file_object_els[0]
    assert len(old_file_object_el) == len(new_file_object_el)
    assert len(old_file_object_el.attrib) == len(new_file_object_el.attrib)
    assert old_file_object_el.get("id") != new_file_object_el.get("id")
    assert old_file_object_el.get("version") == \
        new_file_object_el.get("version")
    assert old_file_object_el.get("comment") == \
        new_file_object_el.get("comment")
    filepath_xpath = "{%s}filepath" % oval_unix_namespace
    old_filepath_els = old_file_object_el.findall(filepath_xpath)
    new_filepath_els = new_file_object_el.findall(filepath_xpath)
    assert len(old_filepath_els) == len(new_filepath_els)
    old_filepath_el = old_filepath_els[0]
    new_filepath_el = new_filepath_els[0]
    assert len(old_filepath_el) == len(new_filepath_el)
    assert len(old_filepath_el.attrib) == len(new_filepath_el.attrib)
    assert old_filepath_el.text == new_filepath_el.text
    filter_xpath = "{%s}filter" % oval_namespace
    old_filter_els = old_file_object_el.findall(filter_xpath)
    new_filter_els = new_file_object_el.findall(filter_xpath)
    assert len(old_filter_els) == len(new_filter_els)
    old_filter_el = old_filter_els[0]
    new_filter_el = new_filter_els[0]
    assert len(old_filter_el) == len(new_filter_el)
    assert len(old_filter_el.attrib) == len(new_filter_el.attrib)
    assert old_filter_el.get("action") == new_filter_el.get("action")
    assert old_filter_el.text != new_filter_el.text
    states_xpath = "{%s}states" % oval_namespace
    old_states_els = old.findall(states_xpath)
    new_states_els = new.findall(states_xpath)
    assert len(old_states_els) == len(new_states_els)
    old_states_el = old_states_els[0]
    new_states_el = new_states_els[0]
    assert len(old_states_el) == len(new_states_el)
    assert len(old_states_el.attrib) == len(new_states_el.attrib)
    file_state_xpath = "{%s}file_state" % oval_unix_namespace
    old_file_state_els = old_states_el.findall(file_state_xpath)
    new_file_state_els = new_states_el.findall(file_state_xpath)
    assert len(old_file_state_els) == len(new_file_state_els)
    old_file_state_el = old_file_state_els[0]
    new_file_state_el = new_file_state_els[0]
    assert len(old_file_state_el) == len(new_file_state_el)
    assert len(old_file_state_el.attrib) == len(new_file_state_el.attrib)
    assert old_file_state_el.get("id") != new_file_state_el.get("id")
    assert old_file_state_el.get("comment") == new_file_state_el.get("comment")
    assert old_file_state_el.get("version") == new_file_state_el.get("version")


def test_idtranslator_translate_oval(idtranslator, oval_tree):
    test_id = "oval:ssg-test_kerberos_disable_no_keytab:tst:1"
    object_id = "oval:ssg-obj_kerberos_disable_no_keytab:obj:1"
    state_id = "oval:ssg-filter_ssh_key_owner_root:ste:1"
    new_tree = idtranslator.translate(oval_tree)
    assert new_tree is not None
    assert new_tree.tag == "{%s}oval_definitions" % oval_namespace
    definition_els = new_tree.findall(
        "{%s}definitions/{%s}definition" % (oval_namespace, oval_namespace))
    assert len(definition_els) == 1
    definition_el = definition_els[0]
    assert len(definition_el.attrib) == 3
    assert definition_el.get("id") == \
        "oval:ssg-kerberos_disable_no_keytab:def:1"
    assert definition_el.get("class") == "compliance"
    assert definition_el.get("version") == "1"
    ref_els = definition_el.findall(
        "{%s}metadata/{%s}reference" % (oval_namespace, oval_namespace))
    assert not ref_els
    criteria_els = definition_el.findall("{%s}criteria" % oval_namespace)
    assert len(criteria_els) == 1
    criteria_el = criteria_els[0]
    criterion_els = criteria_el.findall("{%s}criterion" % oval_namespace)
    assert len(criterion_els) == 1
    criterion_el = criterion_els[0]
    assert criterion_el.get("test_ref") == test_id
    oval_unix_namespace = oval_namespace + "#unix"
    test_els = new_tree.findall(
        "{%s}tests/{%s}file_test" % (oval_namespace, oval_unix_namespace))
    assert len(test_els) == 1
    test_el = test_els[0]
    assert test_el.get("id") == test_id
    object_els = test_el.findall("{%s}object" % oval_unix_namespace)
    assert len(object_els) == 1
    object_el = object_els[0]
    assert object_el.get("object_ref") == object_id
    file_object_els = new_tree.findall(
        "{%s}objects/{%s}file_object" % (oval_namespace, oval_unix_namespace))
    assert len(file_object_els) == 1
    file_object_el = file_object_els[0]
    assert file_object_el.get("id") == object_id
    filter_els = file_object_el.findall("{%s}filter" % oval_namespace)
    assert len(filter_els) == 1
    filter_el = filter_els[0]
    assert filter_el.get("action") == "exclude"
    assert filter_el.text == state_id
    file_state_els = new_tree.findall(
        "{%s}states/{%s}file_state" % (oval_namespace, oval_unix_namespace))
    assert len(file_state_els) == 1
    file_state_el = file_state_els[0]
    assert file_state_el.get("id") == state_id


def test_idtranslator_translate_oval_store_defname(idtranslator, oval_tree):
    new_tree = idtranslator.translate(oval_tree, True)
    definition_el = new_tree.find(
        "{%s}definitions/{%s}definition" % (oval_namespace, oval_namespace))
    ref_els = definition_el.findall(
        "{%s}metadata/{%s}reference" % (oval_namespace, oval_namespace))
    assert len(ref_els) == 1
    ref_el = ref_els[0]
    assert ref_el is not None
    assert len(ref_el.attrib) == 2
    assert ref_el.get("ref_id") == "kerberos_disable_no_keytab"
    assert ref_el.get("source") == "ssg"


@pytest.fixture
def ocil_tree():
    draft_ocil_path = os.path.join(DATADIR, "draft_ocil.xml")
    return ET.parse(draft_ocil_path).getroot()


def test_idtranslator_translate_ocil(idtranslator, ocil_tree):
    questionnaire_id = "ocil:ssg-service_cockpit_disabled_ocil:questionnaire:1"
    test_action_id = "ocil:ssg-service_cockpit_disabled_action:testaction:1"
    question_id = "ocil:ssg-service_cockpit_disabled_question:question:1"
    new_tree = idtranslator.translate(ocil_tree)
    assert new_tree is not None
    assert new_tree.tag == "{%s}ocil" % ocil_namespace
    questionnaires_els = new_tree.findall(
        "{%s}questionnaires" % ocil_namespace)
    assert len(questionnaires_els) == 1
    questionnaires_el = questionnaires_els[0]
    assert len(questionnaires_el.attrib) == 0
    questionnaire_els = questionnaires_el.findall(
        "{%s}questionnaire" % ocil_namespace)
    assert len(questionnaire_els) == 1
    questionnaire_el = questionnaires_el[0]
    assert len(questionnaire_el.attrib) == 1
    assert questionnaire_el.get("id") == questionnaire_id
    test_action_ref_els = questionnaire_el.findall(
        "{%s}actions/{%s}test_action_ref" % (ocil_namespace, ocil_namespace))
    assert len(test_action_ref_els) == 1
    test_action_ref_el = test_action_ref_els[0]
    assert len(test_action_ref_el.attrib) == 0
    assert test_action_ref_el.text == test_action_id
    test_actions_els = new_tree.findall("{%s}test_actions" % ocil_namespace)
    assert len(test_actions_els) == 1
    test_actions_el = test_actions_els[0]
    assert len(test_actions_el.attrib) == 0
    boolean_question_test_action_els = test_actions_el.findall(
        "{%s}boolean_question_test_action" % ocil_namespace)
    assert len(boolean_question_test_action_els) == 1
    boolean_question_test_action_el = boolean_question_test_action_els[0]
    assert len(boolean_question_test_action_el.attrib) == 2
    assert boolean_question_test_action_el.get("id") == test_action_id
    assert boolean_question_test_action_el.get("question_ref") == question_id
    questions_els = new_tree.findall("{%s}questions" % ocil_namespace)
    assert len(questions_els) == 1
    questions_el = questions_els[0]
    boolean_question_els = questions_el.findall(
        "{%s}boolean_question" % ocil_namespace)
    assert len(boolean_question_els) == 1
    boolean_question_el = boolean_question_els[0]
    assert len(boolean_question_el.attrib) == 1
    assert boolean_question_el.get("id") == question_id
