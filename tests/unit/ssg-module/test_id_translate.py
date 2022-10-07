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
