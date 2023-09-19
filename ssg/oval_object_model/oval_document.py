from __future__ import absolute_import

import sys

from ..constants import oval_footer, oval_header, timestamp
from ..xml import ElementTree, register_namespaces
from ..constants import OVAL_NAMESPACES, xsi_namespace
from .general import OVALBaseObject, required_attribute
from .oval_entities import (
    load_definition,
    load_object,
    load_state,
    load_test,
    load_variable,
)


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
    oval_document = OVALDocument(
        product_name.text, schema_version.text, product_version.text
    )

    _load_definitions(oval_document, oval_document_xml_el)
    _load_tests(oval_document, oval_document_xml_el)
    _load_objects(oval_document, oval_document_xml_el)
    _load_states(oval_document, oval_document_xml_el)
    _load_variables(oval_document, oval_document_xml_el)

    return oval_document


class ExceptionDuplicateOVALEntity(Exception):
    pass


class OVALDocument(OVALBaseObject):
    def __init__(self, product_name, schema_version, product_version):
        self.product_name = product_name
        self.schema_version = schema_version
        self.product_version = product_version

        self.definitions = {}
        self.tests = {}
        self.objects = {}
        self.states = {}
        self.variables = {}

    def _get_xml_element_from_string_shorthand(self, shorthand):
        valid_oval_xml_string = "{}{}{}".format(
            oval_header, shorthand, oval_footer
        ).encode("utf-8")
        xml_element = ElementTree.fromstring(valid_oval_xml_string)
        return xml_element.findall("./{%s}def-group/*" % OVAL_NAMESPACES.definition)

    def _load_element(self, xml_el):
        if xml_el.tag.endswith("definition"):
            self.load_definition(xml_el)
        elif xml_el.tag.endswith("_test"):
            self.load_test(xml_el)
        elif xml_el.tag.endswith("_object"):
            self.load_object(xml_el)
        elif xml_el.tag.endswith("_state"):
            self.load_state(xml_el)
        elif xml_el.tag.endswith("_variable"):
            self.load_variable(xml_el)
        elif xml_el.tag is not ElementTree.Comment:
            sys.stderr.write("Warning: Unknown element '{}'\n".format(xml_el.tag))

    def load_shorthand(self, xml_string):
        for xml_el in self._get_xml_element_from_string_shorthand(xml_string):
            self._load_element(xml_el)

    @staticmethod
    def _is_external_variable(component):
        return "external_variable" in component.tag

    @staticmethod
    def _handle_existing_id(component, component_dict):
        # ID is identical, but OVAL entities are semantically difference =>
        # report and error and exit with failure
        # Fixes: https://github.com/ComplianceAsCode/content/issues/1275
        if (
            component != component_dict[component.id_]
            and not OVALDocument._is_external_variable(component)
            and not OVALDocument._is_external_variable(component_dict[component.id_])
        ):
            # This is an error scenario - since by skipping second
            # implementation and using the first one for both references,
            # we might evaluate wrong requirement for the second entity
            # => report an error and exit with failure in that case
            # See
            #   https://github.com/ComplianceAsCode/content/issues/1275
            # for a reproducer and what could happen in this case
            raise ExceptionDuplicateOVALEntity(
                (
                    "ERROR: it's not possible to use the same ID: {} for two semantically"
                    " different OVAL entities:\nFirst entity:\n{}\nSecond entity:\n{}\n"
                    "Use different ID for the second entity!!!\n"
                ).format(
                    component.id_,
                    str(component),
                    str(component_dict[component.id_]),
                )
            )
        elif not OVALDocument._is_external_variable(component):
            # If OVAL entity is identical, but not external_variable, the
            # implementation should be rewritten each entity to be present
            # just once
            raise ExceptionDuplicateOVALEntity(
                (
                    "ERROR: OVAL ID {} is used multiple times and should represent "
                    "the same elements.\n Rewrite the OVAL checks. Place the identical IDs"
                    " into their own definition and extend this definition by it.\n"
                ).format(component.id_)
            )

    @staticmethod
    def _add_oval_component(component, component_dict):
        if component.id_ not in component_dict:
            component_dict[component.id_] = component
        else:
            OVALDocument._handle_existing_id(component, component_dict)

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
        type_ = required_attribute(env_yaml, "type")
        full_name = required_attribute(env_yaml, "full_name")
        for definition in self.definitions.values():
            definition.metadata.finalize_affected_platforms(type_, full_name)

    def load_definition(self, oval_definition_xml_el):
        definition = load_definition(oval_definition_xml_el)
        self._add_oval_component(definition, self.definitions)

    def load_test(self, oval_test_xml_el):
        test = load_test(oval_test_xml_el)
        self._add_oval_component(test, self.tests)

    def load_object(self, oval_object_xml_el):
        object_ = load_object(oval_object_xml_el)
        self._add_oval_component(object_, self.objects)

    def load_state(self, oval_state_xml_element):
        state = load_state(oval_state_xml_element)
        self._add_oval_component(state, self.states)

    def load_variable(self, oval_variable_xml_element):
        variable = load_variable(oval_variable_xml_element)
        self._add_oval_component(variable, self.variables)

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
        schema_version_el.text = str(self.schema_version)
        generator_el.append(schema_version_el)

        timestamp_el = ElementTree.Element("{%s}timestamp" % OVAL_NAMESPACES.oval)
        timestamp_el.text = str(timestamp)
        generator_el.append(timestamp_el)

        return generator_el

    def _get_oval_definition_el(self):
        oval_definition_el = ElementTree.Element(
            "{%s}oval_definitions" % OVAL_NAMESPACES.definition
        )

        register_namespaces({"xsi": xsi_namespace})

        space = "         "
        oval_definition_el.set(
            "xsi:schemaLocation",
            (
                "{0} oval-common-schema.xsd{1}{2} oval-definitions-schema.xsd"
                "{1}{2}#independent independent-definitions-schema.xsd"
                "{1}{2}#unix unix-definitions-schema.xsd"
                "{1}{2}#linux linux-definitions-schema.xsd"
            ).format(
                OVAL_NAMESPACES.oval,
                space,
                OVAL_NAMESPACES.definition,
            ),
        )
        return oval_definition_el
