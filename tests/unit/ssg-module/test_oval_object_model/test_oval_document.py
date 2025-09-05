import pytest
import os
import tempfile

from test_load_and_store import _load_oval_document


DATA_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "data"))
OVAL_DOCUMENT_PATH = os.path.join(
    DATA_DIR, "minimal_oval_of_oval_ssg-sshd_rekey_limit_def.xml"
)
TEST_BUILD_DIR = tempfile.mkdtemp()


@pytest.fixture
def oval_document():
    return _load_oval_document(OVAL_DOCUMENT_PATH)


def test_all_references_of_definition(oval_document):
    ref = oval_document.get_all_references_of_definition(
        "oval:ssg-sshd_not_required_or_unset:def:1"
    )
    assert ref.is_done()
    assert ref.definitions == [
        "oval:ssg-sshd_not_required_or_unset:def:1",
        "oval:ssg-sshd_requirement_unset:def:1",
    ]
    assert ref.tests == [
        "oval:ssg-test_sshd_not_required:tst:1",
        "oval:ssg-test_sshd_requirement_unset:tst:1",
    ]
    assert ref.objects == [
        "oval:ssg-object_sshd_requirement_unknown:obj:1",
        "oval:ssg-object_sshd_not_required:obj:1",
    ]
    assert ref.states == [
        "oval:ssg-state_sshd_requirement_unset:ste:1",
        "oval:ssg-state_sshd_not_required:ste:1",
    ]
    assert ref.variables == [
        "oval:ssg-sshd_required:var:1",
    ]


def _assert_filtered_oval_document(oval_document_, def_id):
    assert def_id in oval_document_.definitions
    assert "oval:ssg-sshd_rekey_limit:def:1" not in oval_document_.definitions
    assert "oval:ssg-test_sshd_not_required:tst:1" in oval_document_.tests
    assert "oval:ssg-test_sshd_rekey_limit:tst:1" not in oval_document_.tests
    assert "oval:ssg-object_sshd_requirement_unknown:obj:1" in oval_document_.objects
    assert "oval:ssg-obj_sshd_rekey_limit:obj:1" not in oval_document_.objects
    assert "oval:ssg-state_sshd_requirement_unset:ste:1" in oval_document_.states
    assert "oval:ssg-state_sshd_rekey_limit:ste:1" not in oval_document_.states
    assert "oval:ssg-sshd_required:var:1" in oval_document_.variables
    assert "oval:ssg-var_rekey_limit_size:var:1" not in oval_document_.variables


def test_keep_referenced_components(oval_document):
    def_id = "oval:ssg-sshd_not_required_or_unset:def:1"
    ref = oval_document.get_all_references_of_definition(def_id)
    oval_document.keep_referenced_components(ref)
    _assert_filtered_oval_document(oval_document, def_id)


@pytest.mark.parametrize(
    "path, expected_result",
    [
        (
           OVAL_DOCUMENT_PATH, True,
        ),
        (
            os.path.join(DATA_DIR, "oval_with_broken_extend_definition.xml"),
            False
        ),
        (
            os.path.join(DATA_DIR, "oval_with_correct_extend_definition.xml"),
            True
        )
    ]
)
def test_validation(path, expected_result):
    oval_doc = _load_oval_document(path)
    assert oval_doc.validate_references() == expected_result


def test_save_as_xml(oval_document):
    oval_doc_path = os.path.join(TEST_BUILD_DIR, "oval.xml")
    def_id = "oval:ssg-sshd_not_required_or_unset:def:1"

    with open(oval_doc_path, "wb") as fd:
        refs = oval_document.get_all_references_of_definition(def_id)
        oval_document.save_as_xml(fd, refs)

    filtered_oval_document = _load_oval_document(oval_doc_path)
    _assert_filtered_oval_document(filtered_oval_document, def_id)
