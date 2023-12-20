from ...constants import STR_TO_BOOL
from ..general import (
    OVALEntity,
    load_property_and_notes_of_oval_entity,
    required_attribute,
)


def load_object(oval_object_xml_el):
    object_property, notes = load_property_and_notes_of_oval_entity(oval_object_xml_el)

    oval_object = ObjectOVAL(
        oval_object_xml_el.tag,
        required_attribute(oval_object_xml_el, "id"),
        object_property,
    )
    oval_object.version = required_attribute(oval_object_xml_el, "version")
    oval_object.comment = oval_object_xml_el.get("comment", "")
    oval_object.notes = notes
    oval_object.deprecated = STR_TO_BOOL.get(
        oval_object_xml_el.get("deprecated", ""), False
    )
    return oval_object


class ObjectOVAL(OVALEntity):

    def get_xml_element(self):
        return super(ObjectOVAL, self).get_xml_element()

    def get_variable_references(self):
        return self._get_references("var_ref")

    def get_state_references(self):
        return self._get_references("filter")

    def get_object_references(self):
        return self._get_references("object_reference")
