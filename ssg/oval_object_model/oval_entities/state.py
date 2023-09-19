from ...constants import STR_TO_BOOL
from ..general import (
    OVALEntity,
    load_property_and_notes_of_oval_entity,
    required_attribute,
)


def load_state(oval_state_xml_el):
    state_property, notes = load_property_and_notes_of_oval_entity(oval_state_xml_el)

    state = State(
        oval_state_xml_el.tag,
        required_attribute(oval_state_xml_el, "id"),
        state_property,
    )
    state.version = required_attribute(oval_state_xml_el, "version")
    state.comment = oval_state_xml_el.get("comment", "")
    state.deprecated = STR_TO_BOOL.get(oval_state_xml_el.get("deprecated", ""), False)
    state.notes = notes
    state.operator = oval_state_xml_el.get("operator", "AND")
    return state


class State(OVALEntity):
    operator = "AND"

    def __init__(self, tag, id_, properties):
        super(State, self).__init__(tag, id_, properties)

    def get_xml_element(self):
        return super(State, self).get_xml_element(operator=self.operator)
