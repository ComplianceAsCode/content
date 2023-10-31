from __future__ import absolute_import

import platform
import logging

from ..constants import OVAL_NAMESPACES, timestamp, xsi_namespace
from ..utils import required_key
from ..xml import ElementTree
from .oval_container import OVALContainer
from .oval_shorthand import OVALShorthand
from .oval_definition_references import OVALDefinitionReference


def _get_xml_el(tag_name, xml_el):
    el = xml_el.find("./{%s}%s" % (OVAL_NAMESPACES.definition, tag_name))
    return el if el else ElementTree.Element("empty-element")


def _load_definitions(oval_document, oval_document_xml_el):
    for definition_el in _get_xml_el("definitions", oval_document_xml_el):
        oval_document.load_definition(definition_el)


def _load_tests(oval_document, oval_document_xml_el):
    for test_el in _get_xml_el("tests", oval_document_xml_el):
        oval_document.load_test(test_el)


def _load_objects(oval_document, oval_document_xml_el):
    for object_el in _get_xml_el("objects", oval_document_xml_el):
        oval_document.load_object(object_el)


def _load_states(oval_document, oval_document_xml_el):
    for state_el in _get_xml_el("states", oval_document_xml_el):
        oval_document.load_state(state_el)


def _load_variables(oval_document, oval_document_xml_el):
    for variable_el in _get_xml_el("variables", oval_document_xml_el):
        oval_document.load_variable(variable_el)


def load_oval_document(oval_document_xml_el):
    generator_el = oval_document_xml_el.find(
        "./{%s}generator" % OVAL_NAMESPACES.definition
    )
    product_name = generator_el.find("./{%s}product_name" % OVAL_NAMESPACES.oval)
    schema_version = generator_el.find("./{%s}schema_version" % OVAL_NAMESPACES.oval)
    product_version = generator_el.find("./{%s}product_version" % OVAL_NAMESPACES.oval)
    oval_document = OVALDocument()
    oval_document.product_version = product_version.text
    oval_document.schema_version = schema_version.text
    oval_document.product_name = product_name.text

    _load_definitions(oval_document, oval_document_xml_el)
    _load_tests(oval_document, oval_document_xml_el)
    _load_objects(oval_document, oval_document_xml_el)
    _load_states(oval_document, oval_document_xml_el)
    _load_variables(oval_document, oval_document_xml_el)

    return oval_document


class MissingOVALComponent(Exception):
    pass


class OVALDocument(OVALContainer):
    schema_version = "5.11"
    __product_name = "OVAL Object Model from SCAP Security Guide"
    product_version = ""
    __ssg_version = ""

    def __init__(self):
        super(OVALDocument, self).__init__()

    @property
    def ssg_version(self):
        return self.__ssg_version

    @ssg_version.setter
    def ssg_version(self, __value):
        self.__ssg_version = __value
        self.product_version = "ssg: {}, python: {}".format(
            self.__ssg_version, platform.python_version()
        )

    @property
    def product_name(self):
        return self.__product_name

    @product_name.setter
    def product_name(self, __value):
        if "from SCAP Security Guide" in __value:
            self.__product_name = __value
            return
        self.__product_name = "{} from SCAP Security Guide".format(__value)

    @staticmethod
    def _skip_if_is_none(value, component_id):
        if value is None:
            raise MissingOVALComponent(component_id)
        return False

    def load_shorthand(self, xml_string, product, rule_id=None):
        shorthand = OVALShorthand()
        shorthand.load_shorthand(xml_string)

        is_valid = shorthand.validate(product, rule_id)
        if is_valid:
            self.add_content_of_container(shorthand)
        return is_valid

    def finalize_affected_platforms(self, env_yaml):
        """
        Depending on your use-case of OVAL you may not need the <affected>
        element. Such use-cases including using OVAL as a check engine for XCCDF
        benchmarks. Since the XCCDF Benchmarks use cpe:platform with CPE IDs,
        the affected element in OVAL definitions is redundant and just bloats the
        files. This function removes all *irrelevant* affected platform elements
        from given OVAL tree. It then adds one platform of the product we are
        building.
        """
        type_ = required_key(env_yaml, "type")
        full_name = required_key(env_yaml, "full_name")
        for definition in self.definitions.values():
            definition.metadata.finalize_affected_platforms(type_, full_name)

    def validate_references(self):
        ref = OVALDefinitionReference()
        ref.save_definitions(self.definitions)
        try:
            self._process_definition_references(ref)
            self._process_test_references(ref)
            self._process_objects_states_variables_references(ref)
        except MissingOVALComponent as error:
            logging.warning("Missing OVAL component: {}".format(error))
            return False
        return True

    def get_xml_element(self):
        root = self._get_oval_definition_el()
        root.append(self._get_generator_el())
        root.append(self._get_component_el("definitions", self.definitions.values()))
        root.append(self._get_component_el("tests", self.tests.values()))
        root.append(self._get_component_el("objects", self.objects.values()))
        if self.states:
            root.append(self._get_component_el("states", self.states.values()))
        if self.variables:
            root.append(self._get_component_el("variables", self.variables.values()))
        return root

    def save_as_xml(self, fd):
        root = self.get_xml_element()
        if hasattr(ElementTree, "indent"):
            ElementTree.indent(root, space=" ", level=0)
        ElementTree.ElementTree(root).write(fd, xml_declaration=True, encoding="utf-8")

    def _get_component_el(self, tag, values):
        xml_el = ElementTree.Element("{%s}%s" % (OVAL_NAMESPACES.definition, tag))
        for val in values:
            xml_el.append(val.get_xml_element())
        return xml_el

    def _get_generator_el(self):
        generator_el = ElementTree.Element("{%s}generator" % OVAL_NAMESPACES.definition)

        product_name_el = ElementTree.Element("{%s}product_name" % OVAL_NAMESPACES.oval)
        product_name_el.text = self.product_name

        generator_el.append(product_name_el)

        product_version_el = ElementTree.Element(
            "{%s}product_version" % OVAL_NAMESPACES.oval
        )
        product_version_el.text = self.product_version

        generator_el.append(product_version_el)

        schema_version_el = ElementTree.Element(
            "{%s}schema_version" % OVAL_NAMESPACES.oval
        )
        schema_version_el.text = self.schema_version
        generator_el.append(schema_version_el)

        timestamp_el = ElementTree.Element("{%s}timestamp" % OVAL_NAMESPACES.oval)
        timestamp_el.text = str(timestamp)
        generator_el.append(timestamp_el)

        return generator_el

    def _get_oval_definition_el(self):
        oval_definition_el = ElementTree.Element(
            "{%s}oval_definitions" % OVAL_NAMESPACES.definition
        )

        oval_definition_el.set(
            ElementTree.QName(xsi_namespace, "schemaLocation"),
            (
                "{0} oval-common-schema.xsd  {1} oval-definitions-schema.xsd"
                "  {1}#independent independent-definitions-schema.xsd"
                "  {1}#unix unix-definitions-schema.xsd"
                "  {1}#linux linux-definitions-schema.xsd"
            ).format(
                OVAL_NAMESPACES.oval,
                OVAL_NAMESPACES.definition,
            ),
        )
        return oval_definition_el
