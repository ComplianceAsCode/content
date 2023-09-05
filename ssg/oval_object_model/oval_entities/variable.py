from ..general import (
    OVAL_NAMESPACES,
    STR_TO_BOOL,
    OVALEntity,
    load_OVAL_entity_property,
    load_notes,
    required_attribute,
)


def load_variable(oval_variable_xml_el):
    notes_el = oval_variable_xml_el.find("./{%s}notes" % OVAL_NAMESPACES.definition)

    variable_property = []
    for child_node_el in oval_variable_xml_el:
        if notes_el == child_node_el:
            continue
        variable_property.append(load_OVAL_entity_property(child_node_el))

    return Variable(
        oval_variable_xml_el.tag,
        required_attribute(oval_variable_xml_el, "id"),
        required_attribute(oval_variable_xml_el, "version"),
        required_attribute(oval_variable_xml_el, "datatype"),
        variable_property,
        load_notes(notes_el),
        oval_variable_xml_el.get("comment", ""),
        STR_TO_BOOL.get(oval_variable_xml_el.get("deprecated", ""), False),
    )


class Variable(OVALEntity):
    def __init__(
        self,
        tag,
        id_,
        version,
        data_type,
        properties,
        notes=None,
        comment="",
        deprecated=False,
    ):
        super().__init__(tag, id_, version, properties, comment, deprecated, notes)
        self.data_type: str = data_type

    def get_xml_element(self):
        variable_el = super().get_xml_element()
        variable_el.set("datatype", self.data_type)
        return variable_el
