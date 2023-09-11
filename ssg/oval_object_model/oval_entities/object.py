from ..general import (
    OVAL_NAMESPACES,
    STR_TO_BOOL,
    OVALEntity,
    load_oval_entity_property,
    load_notes,
    required_attribute,
)


def load_object(oval_object_xml_el):
    notes_el = oval_object_xml_el.find("./{%s}notes" % OVAL_NAMESPACES.definition)

    object_property = []
    for child_node_el in oval_object_xml_el:
        if notes_el == child_node_el:
            continue
        object_property.append(load_oval_entity_property(child_node_el))

    oval_object = ObjectOVAL(
        oval_object_xml_el.tag,
        required_attribute(oval_object_xml_el, "id"),
        object_property,
    )
    oval_object.version = required_attribute(oval_object_xml_el, "version")
    oval_object.comment = oval_object_xml_el.get("comment", "")
    oval_object.notes = load_notes(notes_el)
    oval_object.deprecated = STR_TO_BOOL.get(
        oval_object_xml_el.get("deprecated", ""), False
    )
    return oval_object


class ObjectOVAL(OVALEntity):
    def __init__(self, tag, id_, properties):
        super(ObjectOVAL, self).__init__(tag, id_, properties)

    def get_xml_element(self):
        return super(ObjectOVAL, self).get_xml_element()
