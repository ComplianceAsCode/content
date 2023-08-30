from ..general import (
    OVAL_NAMESPACES,
    STR_TO_BOOL,
    OVALEndPoint,
    load_end_point_property,
    load_notes,
    required_attribute,
)


def load_state(oval_state_xml_el):
    notes_el = oval_state_xml_el.find("./{%s}notes" % OVAL_NAMESPACES.definition)

    state_property = []
    for child_node_el in oval_state_xml_el:
        if notes_el == child_node_el:
            continue
        state_property.append(load_end_point_property(child_node_el))

    return State(
        oval_state_xml_el.tag,
        required_attribute(oval_state_xml_el, "id"),
        required_attribute(oval_state_xml_el, "version"),
        state_property,
        oval_state_xml_el.get("operator", "AND"),
        load_notes(notes_el),
        oval_state_xml_el.get("comment", ""),
        STR_TO_BOOL.get(oval_state_xml_el.get("deprecated", ""), False),
    )


class State(OVALEndPoint):
    def __init__(
        self,
        tag,
        id_,
        version,
        properties,
        operator="AND",
        notes=None,
        comment="",
        deprecated=False,
    ):
        super().__init__(tag, id_, version, properties, comment, deprecated, notes)
        self.operator: str = operator

    def get_xml_element(self):
        state_el = super().get_xml_element()
        state_el.set("operator", self.operator)
        return state_el
