from ..general import (
    OVAL_NAMESPACES,
    STR_TO_BOOL,
    OVALEntity,
    load_oval_entity_property,
    load_notes,
    required_attribute,
)


def load_state(oval_state_xml_el):
    notes_el = oval_state_xml_el.find("./{%s}notes" % OVAL_NAMESPACES.definition)

    state_property = []
    for child_node_el in oval_state_xml_el:
        if notes_el == child_node_el:
            continue
        state_property.append(load_oval_entity_property(child_node_el))

    state = State(
        oval_state_xml_el.tag,
        required_attribute(oval_state_xml_el, "id"),
        state_property,
    )
    state.version = required_attribute(oval_state_xml_el, "version")
    state.comment = oval_state_xml_el.get("comment", "")
    state.deprecated = STR_TO_BOOL.get(oval_state_xml_el.get("deprecated", ""), False)
    state.notes = load_notes(notes_el)
    state.operator = oval_state_xml_el.get("operator", "AND")
    return state


class State(OVALEntity):
    operator = "AND"

    def __init__(self, tag, id_, properties):
        super(State, self).__init__(tag, id_, properties)

    def get_xml_element(self):
        return super(State, self).get_xml_element(operator=self.operator)
