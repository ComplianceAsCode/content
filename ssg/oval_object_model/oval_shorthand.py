import logging

from ..constants import OVAL_NAMESPACES, oval_footer, oval_header
from ..xml import ElementTree
from .oval_container import OVALContainer


def _get_xml_element_from_string_shorthand(shorthand):
    valid_oval_xml_string = "{}{}{}".format(oval_header, shorthand, oval_footer).encode(
        "utf-8"
    )
    xml_element = ElementTree.fromstring(valid_oval_xml_string)
    return xml_element.findall("./{%s}def-group/*" % OVAL_NAMESPACES.definition)


def _is_definition_applicable_for_product(definition, product):
    if product is None or definition.is_applicable_for_product(product):
        return True

    logging.info(
        "Definition '{}' is not applicable for product '{}'.".format(
            definition.id_, product
        )
    )
    return False


def _is_definitions_applicable_for_product(definitions_dict, product):
    is_present_applicable_definition = []
    for definition in definitions_dict.values():
        definition.check_affected()

        is_present_applicable_definition.append(
            _is_definition_applicable_for_product(definition, product)
        )
    return any(is_present_applicable_definition)


class OVALShorthand(OVALContainer):
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
            logging.warning("Unknown element '{}'\n".format(xml_el.tag))

    @staticmethod
    def _skip_if_is_none(value, component_id):
        return value is None

    def validate(self, product, rule_id):
        if not _is_definitions_applicable_for_product(self.definitions, product):
            return False

        if rule_id is not None and rule_id not in self.definitions:
            raise ValueError(
                (
                    "ERROR: OVAL definition that match the rule ID '{}'"
                    " do not appear in the shorthand."
                ).format(rule_id)
            )
        return True

    def load_shorthand(self, xml_string):
        for xml_el in _get_xml_element_from_string_shorthand(xml_string):
            self._load_element(xml_el)
