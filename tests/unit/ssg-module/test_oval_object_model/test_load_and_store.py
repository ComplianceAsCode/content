import os
import pytest
import tempfile
from ssg.xml import ElementTree

from ssg.oval_object_model import load_oval_document, OVALDocument, OVALEntityProperty
from ssg.oval_object_model.oval_entities import Criterion, ExtendDefinition
from ssg.constants import OVAL_NAMESPACES
from ssg.xml import open_xml, get_namespaces_from, register_namespaces


DATA_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "data"))
OVAL_DOCUMENT_PATH = os.path.join(
    DATA_DIR, "minimal_oval_of_oval_ssg-sshd_rekey_limit_def.xml"
)
TEST_BUILD_DIR = tempfile.mkdtemp()


def _load_oval_document(path):
    root_el = open_xml(path)
    ns = get_namespaces_from(path)
    register_namespaces(ns)
    return load_oval_document(root_el)


def _read_shorthand(path_):
    if not os.path.isdir(path_):
        with open(path_, "r") as fd:
            return fd.read()
    return ""


def _list_of_shorthands():
    out = []
    dir_with_shorthands = os.path.join(DATA_DIR, "group_dir/rule_dir/oval")

    static_paths_to_shorthands = [
        os.path.join(DATA_DIR, "shorthand_with_all_components.xml"),
    ]
    for file_name in os.listdir(dir_with_shorthands):
        static_paths_to_shorthands.append(os.path.join(dir_with_shorthands, file_name))

    for path_ in static_paths_to_shorthands:
        out.append(_read_shorthand(path_))

    return out


@pytest.fixture
def oval_document():
    return _load_oval_document(OVAL_DOCUMENT_PATH)


@pytest.fixture
def oval_document_from_shorthand():
    oval_doc = OVALDocument()

    for shorthand in _list_of_shorthands():
        oval_doc.load_shorthand(shorthand, "rhel")

    return oval_doc


@pytest.fixture
def definition(oval_document):
    return oval_document.definitions.get("oval:ssg-sshd_rekey_limit:def:1")


@pytest.fixture
def metadata(definition):
    return definition.metadata


@pytest.fixture
def criteria(oval_document):
    return oval_document.definitions.get(
        "oval:ssg-sshd_not_required_or_unset:def:1"
    ).criteria


@pytest.fixture
def text_file_content_test(oval_document):
    return oval_document.tests.get("oval:ssg-test_sshd_rekey_limit_config_dir:tst:1")


@pytest.fixture
def rpm_info_test(oval_document):
    return oval_document.tests.get(
        "oval:ssg-test_package_openssh-server_installed:tst:1"
    )


@pytest.fixture
def text_file_content_object(oval_document):
    return oval_document.objects.get("oval:ssg-obj_sshd_rekey_limit:obj:1")


@pytest.fixture
def rpm_info_object(oval_document):
    return oval_document.objects.get(
        "oval:ssg-obj_test_package_openssh-server_installed:obj:1"
    )


@pytest.fixture
def local_variable(oval_document):
    return oval_document.variables.get("oval:ssg-sshd_line_regex:var:1")


@pytest.fixture
def external_variable(oval_document):
    return oval_document.variables.get("oval:ssg-var_rekey_limit_size:var:1")


@pytest.fixture
def text_file_content_state(oval_document):
    return oval_document.states.get("oval:ssg-state_sshd_rekey_limit:ste:1")


@pytest.fixture
def variable_state(oval_document):
    return oval_document.states.get("oval:ssg-state_sshd_not_required:ste:1")


# Tests:


def test_load_oval_document(oval_document):
    assert "oval:ssg-sshd_rekey_limit:def:1" in oval_document.definitions
    assert "oval:ssg-test_sshd_rekey_limit:tst:1" in oval_document.tests
    assert "oval:ssg-obj_sshd_rekey_limit:obj:1" in oval_document.objects
    assert "oval:ssg-var_rekey_limit_time:var:1" in oval_document.variables
    assert "oval:ssg-state_sshd_required:ste:1" in oval_document.states


def _assert_oval_document_str(oval_document_str):
    assert "oval:ssg-sshd_rekey_limit:def:1" in oval_document_str
    assert "oval:ssg-test_sshd_rekey_limit:tst:1" in oval_document_str
    assert (
        "oval:ssg-obj_test_package_openssh-server_installed:obj:1" in oval_document_str
    )
    assert "combine_ovals.py from SCAP Security Guide" in oval_document_str
    assert 'var_ref="oval:ssg-var_rekey_limit_size:var:1" ' in oval_document_str
    assert "<ind:filepath>/etc/ssh/sshd_config</ind:filepath>" in oval_document_str


def test_get_xml_element(oval_document):
    oval_document_el = oval_document.get_xml_element()
    oval_document_str = ElementTree.tostring(oval_document_el).decode()
    _assert_oval_document_str(oval_document_str)


def test_save_as_xml(oval_document):
    oval_doc_path = os.path.join(TEST_BUILD_DIR, "oval.xml")
    with open(oval_doc_path, "wb") as fd:
        oval_document.save_as_xml(fd)

    with open(oval_doc_path, "r") as fd:
        oval_document_str = fd.read()
        _assert_oval_document_str(oval_document_str)


def test_load_shorthands(oval_document_from_shorthand):
    assert "service_chronyd_or_ntpd_enabled" in oval_document_from_shorthand.definitions
    assert "sudo_remove_nopasswd" in oval_document_from_shorthand.definitions

    assert "test_nopasswd_etc_sudoers" in oval_document_from_shorthand.tests
    assert "test_nopasswd_etc_sudoers_d" in oval_document_from_shorthand.tests

    assert "object_nopasswd_etc_sudoers_d" in oval_document_from_shorthand.objects
    assert "object_nopasswd_etc_sudoers" in oval_document_from_shorthand.objects

    assert (
        "var_account_password_selinux_faillock_dir_collector"
        in oval_document_from_shorthand.variables
    )
    assert (
        "state_account_password_selinux_faillock_dir"
        in oval_document_from_shorthand.states
    )


def test_content_definition(definition):
    assert definition.id_ == "oval:ssg-sshd_rekey_limit:def:1"
    assert definition.class_ == "compliance"
    assert definition.version == "1"
    assert definition.criteria is not None


def test_content_metadata(metadata):
    assert "RekeyLimit" in metadata.description
    assert "session key" in metadata.title
    assert len(metadata.array_of_affected) == 1
    assert len(metadata.array_of_references) == 1

    affected = metadata.array_of_affected[0]
    assert affected.family == "unix"
    assert "Fedora" in affected.platforms
    assert affected.products is None

    for reference in metadata.array_of_references:
        assert reference.source == "ssg"
        assert reference.ref_id == "sshd_rekey_limit"


def test_content_criteria(criteria, oval_document):
    assert criteria.operator == "OR"
    assert not criteria.negate
    assert criteria.comment == "SSH not required or not set"
    assert criteria.child_criteria_nodes

    for child_criteria_node in criteria.child_criteria_nodes:
        if isinstance(child_criteria_node, Criterion):
            assert child_criteria_node.ref == "oval:ssg-test_sshd_not_required:tst:1"
            assert child_criteria_node.prefix_ref == "test"
            assert child_criteria_node.ref in oval_document.tests
            assert not child_criteria_node.negate
            assert child_criteria_node.comment == ""
        if isinstance(child_criteria_node, ExtendDefinition):
            assert child_criteria_node.ref == "oval:ssg-sshd_requirement_unset:def:1"
            assert child_criteria_node.prefix_ref == "definition"
            assert child_criteria_node.ref in oval_document.definitions
            assert not child_criteria_node.negate
            assert child_criteria_node.comment == "SSH requirement is unset"


def test_content_text_file_content_test(text_file_content_test):
    assert "textfilecontent54_test" in text_file_content_test.tag
    assert (
        text_file_content_test.id_ == "oval:ssg-test_sshd_rekey_limit_config_dir:tst:1"
    )
    assert text_file_content_test.version == "1"
    assert text_file_content_test.check == "all"
    assert (
        text_file_content_test.comment
        == "tests the value of RekeyLimit setting in SSHD config directory"
    )
    assert not text_file_content_test.deprecated
    assert text_file_content_test.check_existence == "all_exist"
    assert text_file_content_test.state_operator == "AND"

    assert "object" in text_file_content_test.object_ref_tag
    assert (
        "oval:ssg-obj_sshd_rekey_limit_config_dir:obj:1"
        in text_file_content_test.object_ref
    )
    assert "state" in text_file_content_test.state_ref_tag
    assert "oval:ssg-state_sshd_rekey_limit:ste:1" in text_file_content_test.state_refs


def test_content_rpm_info_test(rpm_info_test):
    assert "rpminfo_test" in rpm_info_test.tag
    assert rpm_info_test.id_ == "oval:ssg-test_package_openssh-server_installed:tst:1"
    assert rpm_info_test.version == "1"
    assert rpm_info_test.check == "all"
    assert rpm_info_test.comment == "package openssh-server is installed"
    assert not rpm_info_test.deprecated
    assert rpm_info_test.check_existence == "all_exist"
    assert rpm_info_test.state_operator == "AND"

    assert "object" in rpm_info_test.object_ref_tag
    assert not rpm_info_test.state_refs
    assert (
        "oval:ssg-obj_test_package_openssh-server_installed:obj:1"
        == rpm_info_test.object_ref
    )


def test_content_info_rpm_object(rpm_info_object):
    assert "rpminfo_object" in rpm_info_object.tag
    assert (
        rpm_info_object.id_
        == "oval:ssg-obj_test_package_openssh-server_installed:obj:1"
    )
    assert rpm_info_object.version == "1"
    assert rpm_info_object.comment == ""
    assert not rpm_info_object.deprecated
    assert len(rpm_info_object.properties) == 1

    name_property = OVALEntityProperty("{{{}}}name".format(OVAL_NAMESPACES.linux))
    name_property.text = "openssh-server"
    name_property.attributes = None

    assert rpm_info_object.properties[0] == name_property


def test_content_text_file_content_object(text_file_content_object):
    assert "textfilecontent54_object" in text_file_content_object.tag
    assert text_file_content_object.id_ == "oval:ssg-obj_sshd_rekey_limit:obj:1"
    assert text_file_content_object.version == "1"
    assert text_file_content_object.comment == ""
    assert not text_file_content_object.deprecated
    assert text_file_content_object.properties

    property_file_path = OVALEntityProperty("filepath")
    property_file_path.namespace = OVAL_NAMESPACES.independent
    property_file_path.attributes = None
    property_file_path.text = "/etc/ssh/sshd_config"
    property_pattern = OVALEntityProperty("pattern")
    property_pattern.namespace = OVAL_NAMESPACES.independent
    property_pattern.attributes = {"operation": "pattern match"}
    property_pattern.text = r"^[\s]*RekeyLimit[\s]+(.*)$"
    property_instance = OVALEntityProperty("instance")
    property_instance.namespace = OVAL_NAMESPACES.independent
    property_instance.attributes = {
        "datatype": "int",
        "operation": "greater than or equal",
    }
    property_instance.text = "1"
    properties = [property_file_path, property_pattern, property_instance]

    assert all(i in properties for i in text_file_content_object.properties)


def test_content_external_variable(external_variable):
    assert external_variable.id_ == "oval:ssg-var_rekey_limit_size:var:1"
    assert external_variable.version == "1"
    assert external_variable.comment == "Size component of the rekey limit"
    assert external_variable.data_type == "string"
    assert not external_variable.properties


def test_content_local_variable(local_variable):
    assert local_variable.id_ == "oval:ssg-sshd_line_regex:var:1"
    assert local_variable.version == "1"
    assert local_variable.comment == "The regex of the directive"
    assert local_variable.data_type == "string"
    assert len(local_variable.properties) == 1
    concat = local_variable.properties.pop()
    assert "concat" in concat.tag
    assert len(concat.properties) == 5

    property_literal_component = OVALEntityProperty("literal_component")
    property_literal_component.namespace = OVAL_NAMESPACES.definition
    property_literal_component.attributes = None
    property_literal_component.text = "^"
    property_variable_component = OVALEntityProperty("variable_component")
    property_variable_component.namespace = OVAL_NAMESPACES.definition
    property_variable_component.attributes = {
        "var_ref": "oval:ssg-var_rekey_limit_size:var:1"
    }
    property_variable_component.text = None
    property_literal_component_1 = OVALEntityProperty("literal_component")
    property_literal_component_1.namespace = OVAL_NAMESPACES.definition
    property_literal_component_1.attributes = None
    property_literal_component_1.text = r"[\s]+"
    property_variable_component_1 = OVALEntityProperty("variable_component")
    property_variable_component_1.namespace = OVAL_NAMESPACES.definition
    property_variable_component_1.attributes = {
        "var_ref": "oval:ssg-var_rekey_limit_time:var:1"
    }
    property_variable_component_1.text = None
    property_literal_component_2 = OVALEntityProperty("literal_component")
    property_literal_component_2.namespace = OVAL_NAMESPACES.definition
    property_literal_component_2.attributes = None
    property_literal_component_2.text = r"[\s]*$"
    properties = [
        property_literal_component,
        property_variable_component,
        property_literal_component_1,
        property_variable_component_1,
        property_literal_component_2,
    ]
    assert all(i in properties for i in concat.properties)


def test_content_text_file_content_state(text_file_content_state):
    assert text_file_content_state.id_ == "oval:ssg-state_sshd_rekey_limit:ste:1"
    assert text_file_content_state.version == "1"
    assert text_file_content_state.comment == ""
    assert text_file_content_state.operator == "AND"
    assert len(text_file_content_state.properties) == 1

    property_subexpression = OVALEntityProperty("subexpression")
    property_subexpression.namespace = OVAL_NAMESPACES.independent
    property_subexpression.attributes = {
        "operation": "pattern match",
        "var_ref": "oval:ssg-sshd_line_regex:var:1",
    }
    property_subexpression.text = None

    assert text_file_content_state.properties[0] == property_subexpression


def test_content_variable_state(variable_state):
    assert variable_state.id_ == "oval:ssg-state_sshd_not_required:ste:1"
    assert variable_state.version == "1"
    assert variable_state.comment == ""
    assert variable_state.operator == "AND"
    assert len(variable_state.properties) == 1

    property_value = OVALEntityProperty("value")
    property_value.namespace = OVAL_NAMESPACES.independent
    property_value.attributes = {"operation": "equals", "datatype": "int"}
    property_value.text = "1"

    assert variable_state.properties[0] == property_value
