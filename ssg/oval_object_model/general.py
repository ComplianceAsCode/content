import re

from ..constants import BOOL_TO_STR, xsi_namespace
from ..xml import ElementTree
from .. import utils

# ----- General functions


def required_attribute(_xml_el, _key):
    if _key in _xml_el.attrib:
        return _xml_el.get(_key)
    raise ValueError(
        "%s is required but was not found in:\n%s" % (_key, repr(_xml_el.attrib))
    )


def get_product_name(product, product_version=None):
    # Current SSG checks aren't unified which element of '<platform>'
    # and '<product>' to use as OVAL AffectedType metadata element,
    # e.g. Chromium content uses both of them across the various checks
    # Thus for now check both of them when checking concrete platform / product

    # Get official name for product (prefixed with content of afftype)
    product_name = utils.map_name(product)

    # Append the product version to the official name
    if product_version is not None:
        product_name += " " + utils.get_fixed_product_version(product, product_version)
    return product_name


def is_product_name_in(list_, product_name):
    for item in list_ if list_ is not None else []:
        if product_name in item:
            return True
    return False


# ----- General Objects


class OVALBaseObject(object):
    __namespace = ""
    tag = ""

    def __init__(self, tag):
        match_ns = re.match(r"\{.*\}", tag)
        self.namespace = match_ns.group(0) if match_ns else ""
        self.tag = tag.replace(self.namespace, "")

    @property
    def namespace(self):
        return self.__namespace

    @namespace.setter
    def namespace(self, __value):
        if isinstance(__value, str):
            if not __value.startswith("{"):
                __value = "{" + __value
            if not __value.endswith("}"):
                __value = __value + "}"
        self.__namespace = __value

    def __ne__(self, __value):
        return self.__dict__ != __value.__dict__

    def __eq__(self, __value):
        return self.__dict__ == __value.__dict__

    def __repr__(self):
        return str(self.__dict__)

    def __str__(self):
        return str(self.__dict__)

    def get_xml_element(self):
        raise NotImplementedError


class OVALComponent(OVALBaseObject):
    deprecated = False
    notes = None
    version = "0"

    def __init__(self, tag, id_):
        super(OVALComponent, self).__init__(tag)
        self.id_ = id_

    def get_xml_element(self):
        el = ElementTree.Element("{}{}".format(self.namespace, self.tag))
        el.set("id", self.id_)
        el.set("version", self.version)
        if self.deprecated:
            el.set("deprecated", BOOL_TO_STR[self.deprecated])
        if self.notes:
            el.append(self.notes.get_xml_element())
        return el


class OVALEntity(OVALComponent):
    comment = ""

    def __init__(self, tag, id_, properties):
        super(OVALEntity, self).__init__(tag, id_)
        self.properties = properties

    def _get_references(self, key):
        out = []
        for property_ in self.properties:
            out.extend(property_.get_values_by_key(key))
        return out

    def get_xml_element(self, **attributes):
        el = super(OVALEntity, self).get_xml_element()

        for key, value in attributes.items():
            if "xsi" in key:
                key = ElementTree.QName(xsi_namespace, key.split(":")[-1])
            el.set(key, value)

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
        super(Notes, self).__init__(tag)
        self.note_tag = note_tag
        if len(notes) == 0:
            raise ExceptionEmptyNote(
                "Element notes should contain at least one element note."
            )
        self.notes = notes

    def get_xml_element(self):
        notes_el = ElementTree.Element("{}{}".format(self.namespace, self.tag))
        for note in self.notes:
            note_el = ElementTree.Element(self.note_tag)
            note_el.text = note
            notes_el.append(note_el)
        return notes_el


# -----


def load_property_and_notes_of_oval_entity(oval_entity_el):
    notes = None
    object_property = []
    for child_node_el in oval_entity_el:
        if "notes" in child_node_el.tag:
            notes = load_notes(child_node_el)
        else:
            object_property.append(load_oval_entity_property(child_node_el))
    return object_property, notes


def load_oval_entity_property(end_point_property_el):
    data = OVALEntityProperty(end_point_property_el.tag)
    data.attributes = (
        end_point_property_el.attrib if end_point_property_el.attrib else None
    )
    data.text = end_point_property_el.text
    for child_end_point_property_el in end_point_property_el:
        data.add_child_property(load_oval_entity_property(child_end_point_property_el))
    return data


class OVALEntityProperty(OVALBaseObject):
    attributes = None
    text = None

    def __init__(self, tag):
        super(OVALEntityProperty, self).__init__(tag)
        self.properties = []

    def add_child_property(self, property_):
        self.properties.append(property_)

    def get_xml_element(self):
        property_el = ElementTree.Element("{}{}".format(self.namespace, self.tag))
        for key, val in self.attributes.items() if self.attributes is not None else {}:
            property_el.set(key, val)

        if self.text is not None:
            property_el.text = self.text

        for child in self.properties:
            property_el.append(child.get_xml_element())

        return property_el

    def get_values_by_key(self, key):
        out = []
        if self.attributes and key in self.attributes:
            out.append(self.attributes.get(key))
        if key in self.tag:
            out.append(self.text)
        for property_ in self.properties:
            out.extend(property_.get_values_by_key(key))
        return out
