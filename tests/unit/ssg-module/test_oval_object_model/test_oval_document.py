import pytest
import os

from test_load_and_store import _load_oval_document


DATA_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "data"))
OVAL_DOCUMENT_PATH = os.path.join(
    DATA_DIR, "minimal_oval_of_oval_ssg-sshd_rekey_limit_def.xml"
)


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


def test_keep_referenced_components(oval_document):
    def_id = "oval:ssg-sshd_not_required_or_unset:def:1"
    ref = oval_document.get_all_references_of_definition(def_id)
    oval_document.keep_referenced_components(ref)

    assert def_id in oval_document.definitions
    assert "oval:ssg-sshd_rekey_limit:def:1" not in oval_document.definitions
    assert "oval:ssg-test_sshd_not_required:tst:1" in oval_document.tests
    assert "oval:ssg-test_sshd_rekey_limit:tst:1" not in oval_document.tests
    assert "oval:ssg-object_sshd_requirement_unknown:obj:1" in oval_document.objects
    assert "oval:ssg-obj_sshd_rekey_limit:obj:1" not in oval_document.objects
    assert "oval:ssg-state_sshd_requirement_unset:ste:1" in oval_document.states
    assert "oval:ssg-state_sshd_rekey_limit:ste:1" not in oval_document.states
    assert "oval:ssg-sshd_required:var:1" in oval_document.variables
    assert "oval:ssg-var_rekey_limit_size:var:1" not in oval_document.variables
