from ..general import (
    OVAL_NAMESPACES,
    STR_TO_BOOL,
    OVALEntity,
    load_OVAL_entity_property,
    load_notes,
    required_attribute,
)


def load_object(oval_object_xml_el):
    notes_el = oval_object_xml_el.find("./{%s}notes" % OVAL_NAMESPACES.definition)

    object_property = []
    for child_node_el in oval_object_xml_el:
        if notes_el == child_node_el:
            continue
        object_property.append(load_OVAL_entity_property(child_node_el))

    return ObjectOVAL(
        oval_object_xml_el.tag,
        required_attribute(oval_object_xml_el, "id"),
        required_attribute(oval_object_xml_el, "version"),
        object_property,
        load_notes(notes_el),
        oval_object_xml_el.get("comment", ""),
        STR_TO_BOOL.get(oval_object_xml_el.get("deprecated", ""), False),
    )


class ObjectOVAL(OVALEntity):
    def __init__(
        self,
        tag,
        id_,
        version,
        properties,
        notes=None,
        comment="",
        deprecated=False,
    ):
        super().__init__(tag, id_, version, properties, comment, deprecated, notes)

    def get_xml_element(self):
        return super().get_xml_element()
