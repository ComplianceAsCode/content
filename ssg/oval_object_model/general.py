from ..constants import oval_namespace as oval_ns
from ..xml import ElementTree

# ----- Constants


STR_TO_BOOL = {
    "false": False,
    "False": False,
    "true": True,
    "True": True,
}

BOOL_TO_STR = {True: "true", False: "false"}


class OvalNamespaces:
    oval = "http://oval.mitre.org/XMLSchema/oval-common-5"
    definition = oval_ns
    independent = "http://oval.mitre.org/XMLSchema/oval-definitions-5#independent"
    linux = "http://oval.mitre.org/XMLSchema/oval-definitions-5#linux"


OVAL_NAMESPACES = OvalNamespaces()

# ----- General functions


def required_attribute(_xml_el, _key):
    if _key in _xml_el.attrib:
        return _xml_el.get(_key)
    raise ValueError(
        "%s is required but was not found in:\n%s" % (_key, repr(_xml_el.attrib))
    )


# ----- General Objects


class OVALBaseObject:
    def __init__(self, tag):
        self.tag: str = tag

    def __eq__(self, __value):
        return self.__dict__ == __value.__dict__

    def __repr__(self):
        return str(self.__dict__)

    def __str__(self):
        return str(self.__dict__)

    def get_xml_element(self):
        raise NotImplementedError


class OVALComponent(OVALBaseObject):
    def __init__(self, tag, id_, version, deprecated=False, notes=None):
        super().__init__(tag)
        self.id_: str = id_
        self.version: str = version
        self.deprecated: bool = deprecated
        self.notes: Notes = notes

    def get_xml_element(self):
        el = ElementTree.Element(self.tag)
        el.set("id", self.id_)
        el.set("version", self.version)
        if self.deprecated:
            el.set("deprecated", BOOL_TO_STR[self.deprecated])
        if self.notes:
            el.append(self.notes.get_xml_element())
        return el


class OVALEndPoint(OVALComponent):
    def __init__(
        self,
        tag,
        id_,
        version,
        properties,
        comment="",
        deprecated=False,
        notes=None,
    ):
        super().__init__(tag, id_, version, deprecated, notes)
        self.comment: str = comment
        self.properties: list[EndPointProperty] = properties

    def get_xml_element(self):
        el = super().get_xml_element()

        if self.comment:
            el.set("comment", self.comment)

        for property_ in self.properties:
            el.append(property_.get_xml_element())

        return el


# ----- OVAL Objects


def load_notes(oval_notes_xml_el):
    if oval_notes_xml_el is None:
        return None
    notes = []
    for note_el in oval_notes_xml_el:
        notes.append(note_el.text)
    return Notes(oval_notes_xml_el.tag, note_el.tag, notes)


class ExceptionEmptyNote(Exception):
    pass


class Notes(OVALBaseObject):
    def __init__(self, tag, note_tag, notes):
        super().__init__(tag)
        self.note_tag: str = note_tag
        if len(notes) == 0:
            raise ExceptionEmptyNote(
                "Element notes should contain at least one element note."
            )
        self.notes: list[str] = notes

    def get_xml_element(self):
        notes_el = ElementTree.Element(self.tag)
        for note in self.notes:
            note_el = ElementTree.Element(self.note_tag)
            note_el.text = note
            notes_el.append(note_el)
        return notes_el


# -----


def load_end_point_property(end_point_property_el):
    data = EndPointProperty(
        end_point_property_el.tag,
        end_point_property_el.attrib,
        end_point_property_el.text,
    )
    for child_end_point_property_el in end_point_property_el:
        data.add_child_property(load_end_point_property(child_end_point_property_el))
    return data


class EndPointProperty(OVALBaseObject):
    def __init__(self, tag, attributes=None, text=None):
        super().__init__(tag)
        self.attributes: dict = attributes
        self.text: str = text

        self.properties: list[EndPointProperty] = []

    def add_child_property(self, property_):
        self.properties.append(property_)

    def get_xml_element(self):
        property_el = ElementTree.Element(self.tag)
        for key, val in self.attributes.items():
            property_el.set(key, val)

        if self.text is not None:
            property_el.text = self.text

        for child in self.properties:
            property_el.append(child.get_xml_element())

        return property_el
