import collections
import copy
import os
import pytest
import xml.etree.ElementTree as ET

import ssg.id_translate
from ssg.constants import XCCDF12_NS, oval_namespace, ocil_namespace

DATADIR = os.path.abspath(os.path.join(os.path.dirname(__file__), "data"))
oval_unix_namespace = oval_namespace + "#unix"


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


def test_idtranslator_translate_oval_xmldiff(idtranslator, oval_tree):
    xmldiff_main = pytest.importorskip("xmldiff.main")
    xmldiff_actions = pytest.importorskip("xmldiff.actions")
    LET = pytest.importorskip("lxml.etree")
    old = LET.fromstring(ET.tostring(oval_tree))
    new = LET.fromstring(ET.tostring(idtranslator.translate(oval_tree)))
    inverted_new_nsmap = {v: k for k, v in old.nsmap.items()}
    o = inverted_new_nsmap[oval_namespace]
    ou = inverted_new_nsmap[oval_unix_namespace]
    diff = set(xmldiff_main.diff_trees(old, new))
    uadefid = xmldiff_actions.UpdateAttrib(
        node='/{o}:oval_definitions/{o}:definitions/{o}:definition[1]'.format(o=o),
        name='id',
        value='oval:ssg-kerberos_disable_no_keytab:def:1')
    assert uadefid in diff
    diff.remove(uadefid)
    uaftestid = xmldiff_actions.UpdateAttrib(
        node='/{o}:oval_definitions/{o}:tests/{ou}:file_test[1]'.format(o=o, ou=ou),
        name='id',
        value='oval:ssg-test_kerberos_disable_no_keytab:tst:1')
    assert uaftestid in diff
    diff.remove(uaftestid)
    uafoid = xmldiff_actions.UpdateAttrib(
        node='/{o}:oval_definitions/{o}:objects/{ou}:file_object[1]'.format(o=o, ou=ou),
        name='id',
        value='oval:ssg-obj_kerberos_disable_no_keytab:obj:1')
    assert uafoid in diff
    diff.remove(uafoid)
    uafsid = xmldiff_actions.UpdateAttrib(
        node='/{o}:oval_definitions/{o}:states/{ou}:file_state[1]'.format(o=o, ou=ou),
        name='id',
        value='oval:ssg-filter_ssh_key_owner_root:ste:1')
    assert uafsid in diff
    diff.remove(uafsid)
    uaftoref = xmldiff_actions.UpdateAttrib(
        node=(
            '/{o}:oval_definitions/{o}:tests/{ou}:file_test/'
            '{ou}:object[1]'.format(ou=ou, o=o)),
        name='object_ref',
        value='oval:ssg-obj_kerberos_disable_no_keytab:obj:1')
    assert uaftoref in diff
    diff.remove(uaftoref)
    utfofilter = xmldiff_actions.UpdateTextIn(
        node=(
            '/{o}:oval_definitions/{o}:objects/{ou}:file_object/'
            '{o}:filter[1]'.format(o=o, ou=ou)),
        text='oval:ssg-filter_ssh_key_owner_root:ste:1')
    assert utfofilter in diff
    diff.remove(utfofilter)
    uacrittref = xmldiff_actions.UpdateAttrib(
        node=(
            '/{o}:oval_definitions/{o}:definitions/{o}:definition/'
            '{o}:criteria/{o}:criterion[1]'.format(ou=ou, o=o)),
        name='test_ref',
        value='oval:ssg-test_kerberos_disable_no_keytab:tst:1')
    assert uacrittref in diff
    diff.remove(uacrittref)
    assert diff == set()


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
