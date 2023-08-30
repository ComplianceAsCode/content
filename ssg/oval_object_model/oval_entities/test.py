import sys

from ...xml import ElementTree
from ..general import (
    OVAL_NAMESPACES,
    STR_TO_BOOL,
    OVALComponent,
    load_notes,
    required_attribute,
)


def load_test(oval_test_xml_el):
    notes_el = oval_test_xml_el.find("./{%s}notes" % OVAL_NAMESPACES.definition)
    test = Test(
        oval_test_xml_el.tag,
        required_attribute(oval_test_xml_el, "id"),
        required_attribute(oval_test_xml_el, "version"),
        required_attribute(oval_test_xml_el, "check"),
        required_attribute(oval_test_xml_el, "comment"),
        STR_TO_BOOL.get(oval_test_xml_el.get("deprecated", ""), False),
        load_notes(notes_el),
        oval_test_xml_el.get("check_existence", "at_least_one_exists"),
        oval_test_xml_el.get("state_operator", "AND"),
    )
    for child_node_el in oval_test_xml_el:
        if child_node_el.tag.endswith("object"):
            test.set_object_ref(child_node_el.get("object_ref"))
            test.object_ref_tag = child_node_el.tag
        elif child_node_el.tag.endswith("state"):
            test.add_state_ref(child_node_el.get("state_ref"))
            test.state_ref_tag = child_node_el.tag
        else:
            sys.stderr.write(
                "Warning: Unknown element '{}'\n".format(child_node_el.tag)
            )
    return test


class ExceptionDuplicateObjectReferenceInTest(Exception):
    pass


class ExceptionMissingObjectReferenceInTest(Exception):
    pass


class Test(OVALComponent):
    def __init__(
        self,
        tag,
        id_,
        version,
        check,
        comment,
        deprecated=False,
        notes=None,
        check_existence="at_least_one_exists",
        state_operator="AND",
    ):
        super().__init__(tag, id_, version, deprecated, notes)
        self.check: str = check
        self.check_existence: str = check_existence
        self.state_operator: str = state_operator
        self.comment: str = comment

        self.object_ref_tag: str = ""
        self.object_ref: str = ""
        self.state_ref_tag: str = ""
        self.state_refs: list[str] = []

    def set_object_ref(self, object_ref):
        if self.object_ref != "":
            raise ExceptionDuplicateObjectReferenceInTest(
                "Problematic OVAL test: {}".format(self.id_)
            )
        self.object_ref = object_ref

    def add_state_ref(self, state_ref):
        self.state_refs.append(state_ref)

    def get_xml_element(self):
        test_el = super().get_xml_element()
        test_el.set("check", self.check)
        test_el.set("comment", self.comment)
        if self.check_existence != "at_least_one_exists":
            test_el.set("check_existence", self.check_existence)

        test_el.set("state_operator", self.state_operator)

        if self.object_ref == "":
            raise ExceptionMissingObjectReferenceInTest(
                "Problematic OVAL test: {}".format(self.id_)
            )
        object_ref_el = ElementTree.Element(self.object_ref_tag)
        object_ref_el.set("object_ref", self.object_ref)
        test_el.append(object_ref_el)

        for state_ref in self.state_refs:
            state_ref_el = ElementTree.Element(self.state_ref_tag)
            state_ref_el.set("state_ref", state_ref)
            test_el.append(state_ref_el)

        return test_el
