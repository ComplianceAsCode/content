from ...constants import OVAL_NAMESPACES, STR_TO_BOOL
from ..general import (
    OVALEntity,
    load_oval_entity_property,
    load_notes,
    required_attribute,
)


def load_variable(oval_variable_xml_el):
    notes_el = oval_variable_xml_el.find("./{%s}notes" % OVAL_NAMESPACES.definition)

    variable_property = []
    for child_node_el in oval_variable_xml_el:
        if notes_el == child_node_el:
            continue
        variable_property.append(load_oval_entity_property(child_node_el))

    variable = Variable(
        oval_variable_xml_el.tag,
        required_attribute(oval_variable_xml_el, "id"),
        required_attribute(oval_variable_xml_el, "datatype"),
        variable_property,
    )
    variable.comment = oval_variable_xml_el.get("comment", "")
    variable.deprecated = STR_TO_BOOL.get(
        oval_variable_xml_el.get("deprecated", ""), False
    )
    variable.notes = load_notes(notes_el)
    variable.version = required_attribute(oval_variable_xml_el, "version")
    return variable


class Variable(OVALEntity):
    def __init__(self, tag, id_, data_type, properties):
        super(Variable, self).__init__(tag, id_, properties)
        self.data_type = data_type

    def get_xml_element(self):
        return super(Variable, self).get_xml_element(datatype=self.data_type)
