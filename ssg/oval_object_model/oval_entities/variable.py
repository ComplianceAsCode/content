from ...constants import STR_TO_BOOL
from ..general import (
    OVALEntity,
    load_property_and_notes_of_oval_entity,
    required_attribute,
)


def load_variable(oval_variable_xml_el):
    variable_property, notes = load_property_and_notes_of_oval_entity(
        oval_variable_xml_el
    )

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
    variable.notes = notes
    variable.version = required_attribute(oval_variable_xml_el, "version")
    return variable


class Variable(OVALEntity):
    def __init__(self, tag, id_, data_type, properties):
        super(Variable, self).__init__(tag, id_, properties)
        self.data_type = data_type

    def get_xml_element(self):
        return super(Variable, self).get_xml_element(datatype=self.data_type)
