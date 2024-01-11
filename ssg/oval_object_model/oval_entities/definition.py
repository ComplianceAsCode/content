import logging

from ... import utils
from ...constants import BOOL_TO_STR, MULTI_PLATFORM_LIST, OVAL_NAMESPACES, STR_TO_BOOL
from ...xml import ElementTree
from ..general import (
    OVALBaseObject,
    OVALComponent,
    load_notes,
    required_attribute,
    is_product_name_in,
    get_product_name,
)


class GeneralCriteriaNode(OVALBaseObject):
    negate = False
    comment = ""
    applicability_check = False

    def get_xml_element(self):
        el = ElementTree.Element(self.tag_name)
        if self.applicability_check:
            el.set("applicability_check", BOOL_TO_STR[self.applicability_check])
        if self.negate:
            el.set("negate", BOOL_TO_STR[self.negate])
        if self.comment != "":
            el.set("comment", self.comment)

        return el


def load_terminate_criteria(xml_el, class_, ref_prefix):
    terminate_criteria = class_(
        xml_el.tag,
        required_attribute(xml_el, "{}_ref".format(ref_prefix)),
    )
    terminate_criteria.negate = STR_TO_BOOL.get(xml_el.get("negate"), False)
    terminate_criteria.comment = xml_el.get("comment", "")
    terminate_criteria.applicability_check = STR_TO_BOOL.get(
        xml_el.get("applicability_check"), False
    )
    return terminate_criteria


class TerminateCriteriaNode(GeneralCriteriaNode):
    prefix_ref = ""

    def __init__(self, tag, ref):
        super(TerminateCriteriaNode, self).__init__(tag)
        self.ref = ref

    def get_xml_element(self):
        el = super(TerminateCriteriaNode, self).get_xml_element()
        el.set("{}_ref".format(self.prefix_ref), self.ref)
        return el

    def translate_id(self, translator, store_defname=False):
        self.ref = translator.generate_id(
            "{}{}".format(self.namespace, self.prefix_ref), self.ref
        )


# -----


class Criterion(TerminateCriteriaNode):
    prefix_ref = "test"


# -----


class ExtendDefinition(TerminateCriteriaNode):
    prefix_ref = "definition"


# -----


def load_criteria(oval_criteria_xml_el):
    criteria = Criteria(oval_criteria_xml_el.tag)
    criteria.operator = oval_criteria_xml_el.get("operator", "AND")
    criteria.negate = STR_TO_BOOL.get(oval_criteria_xml_el.get("negate"), False)
    criteria.comment = oval_criteria_xml_el.get("comment", "")
    criteria.applicability_check = STR_TO_BOOL.get(
        oval_criteria_xml_el.get("applicability_check"), False
    )
    for child_node_el in oval_criteria_xml_el:
        if child_node_el.tag.endswith("criteria"):
            criteria.add_child_criteria_node(load_criteria(child_node_el))
        elif child_node_el.tag.endswith("criterion"):
            criteria.add_child_criteria_node(
                load_terminate_criteria(child_node_el, Criterion, "test")
            )
        elif child_node_el.tag.endswith("extend_definition"):
            criteria.add_child_criteria_node(
                load_terminate_criteria(child_node_el, ExtendDefinition, "definition")
            )
        else:
            logging.warning("Unknown element '{}'\n".format(child_node_el.tag))
    return criteria


class Criteria(GeneralCriteriaNode):
    operator = "AND"

    def __init__(self, tag):
        super(Criteria, self).__init__(tag)

        self.child_criteria_nodes = []

    def add_child_criteria_node(self, child):
        if not isinstance(child, (Criteria, Criterion, ExtendDefinition)):
            raise TypeError("Unexpected child type of Criteria!")
        self.child_criteria_nodes.append(child)

    def get_xml_element(self):
        criteria_el = super(Criteria, self).get_xml_element()

        criteria_el.set("operator", self.operator)

        for child_criteria_node in self.child_criteria_nodes:
            criteria_el.append(child_criteria_node.get_xml_element())

        return criteria_el

    def _get_reference(self, ref_type):
        out = []
        for child_criteria_node in self.child_criteria_nodes:
            if isinstance(child_criteria_node, ref_type):
                out.append(child_criteria_node.ref)
            elif isinstance(child_criteria_node, Criteria):
                out.extend(child_criteria_node._get_reference(ref_type))
        return out

    def get_test_references(self):
        return self._get_reference(Criterion)

    def get_extend_definition_references(self):
        return self._get_reference(ExtendDefinition)

    def translate_id(self, translator, store_defname=False):
        for child_criteria_node in self.child_criteria_nodes:
            child_criteria_node.translate_id(translator)


# -----


def load_references(all_reference_elements):
    out = []
    for ref_el in all_reference_elements:
        ref = Reference(
            ref_el.tag,
            required_attribute(ref_el, "source"),
            required_attribute(ref_el, "ref_id"),
        )
        ref.ref_url = ref_el.get("ref_url", "")
        out.append(ref)
    return out if out else None


class Reference(OVALBaseObject):
    ref_url = ""

    def __init__(self, tag, source, ref_id):
        super(Reference, self).__init__(tag)
        self.source = source
        self.ref_id = ref_id

    def get_xml_element(self):
        reference_el = ElementTree.Element(self.tag_name)
        reference_el.set("ref_id", self.ref_id)
        reference_el.set("source", self.source)
        if self.ref_url != "":
            reference_el.set("ref_url", self.ref_url)
        return reference_el


# -----


def _get_tag(el):
    if el is None:
        return None
    return el.tag


def _get_list_of_affected(affected_el, element_name):
    elements = affected_el.findall(
        "./{%s}%s" % (OVAL_NAMESPACES.definition, element_name)
    )
    if len(elements) == 0:
        return None
    return [el.text for el in elements]


def load_affected(all_affected_elements):
    out = []
    for affected_el in all_affected_elements:
        affected = Affected(
            affected_el.tag,
            required_attribute(affected_el, "family"),
        )
        affected.platform_tag = _get_tag(
            affected_el.find("./{%s}platform" % OVAL_NAMESPACES.definition)
        )
        affected.product_tag = _get_tag(
            affected_el.find("./{%s}product" % OVAL_NAMESPACES.definition)
        )
        affected.platforms = _get_list_of_affected(affected_el, "platform")
        affected.products = _get_list_of_affected(affected_el, "product")
        out.append(affected)
    return out if out else None


class Affected(OVALBaseObject):
    platform_tag = "platform"
    product_tag = "product"
    platforms = None
    products = None

    def __init__(self, tag, family):
        super(Affected, self).__init__(tag)
        self.family = family

    def finalize_affected_platforms(self, type_, full_name):
        """
        Depending on your use-case of OVAL you may not need the <affected>
        element. Such use-cases including using OVAL as a check engine for XCCDF
        benchmarks. Since the XCCDF Benchmarks use cpe:platform with CPE IDs,
        the affected element in OVAL definitions is redundant and just bloats the
        files. This function removes all *irrelevant* affected platform elements
        from given OVAL tree. It then adds one platform of the product we are
        building.
        """
        setattr(self, "{}s".format(type_), [full_name])
        setattr(
            self, "{}_tag".format(type_), "{%s}%s" % (OVAL_NAMESPACES.definition, type_)
        )

    def _is_in_platforms(self, multi_prod, product):
        for platform in self.platforms if self.platforms is not None else []:
            if multi_prod in platform and product in MULTI_PLATFORM_LIST:
                return True
        return False

    def is_applicable_for_product(self, product_):
        """
        Based on the <platform> specifier of the OVAL check determine if this
        OVAL check is applicable for this product. Return 'True' if so, 'False'
        otherwise
        """

        product, product_version = utils.parse_name(product_)

        # Define general platforms
        multi_platforms = ["multi_platform_all", "multi_platform_" + product]

        # First test if OVAL check isn't for 'multi_platform_all' or
        # 'multi_platform_' + product
        for multi_prod in multi_platforms:
            if self._is_in_platforms(multi_prod, product):
                return True

        product_name = get_product_name(product, product_version)

        # Test if this OVAL check is for the concrete product version

        if is_product_name_in(self.platforms, product_name):
            return True

        if is_product_name_in(self.products, product_name):
            return True

        # OVAL check isn't neither a multi platform one, nor isn't applicable
        # for this product => return False to indicate that
        return False

    def _add_to_affected_element(self, affected_el, elements, tag):
        for platform in elements if elements is not None else []:
            platform_el = ElementTree.Element(tag)
            platform_el.text = platform
            affected_el.append(platform_el)

    def get_xml_element(self):
        affected_el = ElementTree.Element(self.tag_name)
        affected_el.set("family", self.family)

        self._add_to_affected_element(affected_el, self.platforms, self.platform_tag)
        self._add_to_affected_element(affected_el, self.products, self.product_tag)
        return affected_el


# -----


def _get_string_of(element, definition_id, type_):
    out = ""
    if element.text is not None:
        out = element.text
    else:
        logging.info(
            "OVAL definition '{0}' have empty a {1}, which is mandatory".format(
                definition_id, type_
            )
        )
    return out


def load_metadata(oval_metadata_xml_el, definition_id):
    title_el = oval_metadata_xml_el.find("./{%s}title" % OVAL_NAMESPACES.definition)
    title_str = _get_string_of(title_el, definition_id, "title")
    description_el = oval_metadata_xml_el.find(
        "./{%s}description" % OVAL_NAMESPACES.definition
    )
    description_str = _get_string_of(description_el, definition_id, "description")
    all_affected_elements = oval_metadata_xml_el.findall(
        "./{%s}affected" % OVAL_NAMESPACES.definition
    )
    all_reference_elements = oval_metadata_xml_el.findall(
        "./{%s}reference" % OVAL_NAMESPACES.definition
    )
    metadata = Metadata(oval_metadata_xml_el.tag)
    metadata.title = title_str
    metadata.description = description_str
    metadata.array_of_affected = load_affected(all_affected_elements)
    metadata.array_of_references = load_references(all_reference_elements)
    return metadata


class Metadata(OVALBaseObject):
    array_of_affected = None
    array_of_references = None
    title = ""
    description = ""
    title_tag = "title"
    description_tag = "description"

    def finalize_affected_platforms(self, type_, full_name):
        """
        Depending on your use-case of OVAL you may not need the <affected>
        element. Such use-cases including using OVAL as a check engine for XCCDF
        benchmarks. Since the XCCDF Benchmarks use cpe:platform with CPE IDs,
        the affected element in OVAL definitions is redundant and just bloats the
        files. This function removes all *irrelevant* affected platform elements
        from given OVAL tree. It then adds one platform of the product we are
        building.
        """
        for affected in self.array_of_affected:
            affected.finalize_affected_platforms(type_, full_name)

    def is_applicable_for_product(self, product):
        """
        Based on the <platform> specifier of the OVAL check determine if this
        OVAL check is applicable for this product. Return 'True' if so, 'False'
        otherwise
        """
        for affected in self.array_of_affected:
            if affected.is_applicable_for_product(product):
                return True
        return False

    def add_reference(self, ref_id, source):
        if self.array_of_references is None:
            self.array_of_references = []
        self.array_of_references.append(
            Reference(
                "{%s}reference" % OVAL_NAMESPACES.definition,
                source,
                ref_id,
            )
        )

    @staticmethod
    def _add_sub_elements_from_arrays(el, array):
        for item in array if array is not None else []:
            el.append(item.get_xml_element())

    def get_xml_element(self):
        metadata_el = ElementTree.Element(self.tag_name)

        title_el = ElementTree.Element("{}{}".format(self.namespace, self.title_tag))
        title_el.text = self.title
        metadata_el.append(title_el)

        self._add_sub_elements_from_arrays(metadata_el, self.array_of_affected)
        self._add_sub_elements_from_arrays(metadata_el, self.array_of_references)

        description_el = ElementTree.Element(
            "{}{}".format(self.namespace, self.description_tag)
        )
        description_el.text = self.description
        metadata_el.append(description_el)

        return metadata_el


# -----


def load_definition(oval_definition_xml_el):
    metadata_el = oval_definition_xml_el.find(
        "./{%s}metadata" % OVAL_NAMESPACES.definition
    )
    notes_el = oval_definition_xml_el.find("./{%s}notes" % OVAL_NAMESPACES.definition)
    criteria_el = oval_definition_xml_el.find(
        "./{%s}criteria" % OVAL_NAMESPACES.definition
    )
    definition_id = required_attribute(oval_definition_xml_el, "id")
    definition = Definition(
        oval_definition_xml_el.tag,
        definition_id,
        required_attribute(oval_definition_xml_el, "class"),
        load_metadata(metadata_el, definition_id),
    )
    definition.deprecated = STR_TO_BOOL.get(
        oval_definition_xml_el.get("deprecated", ""), False
    )
    definition.notes = load_notes(notes_el)
    definition.version = required_attribute(oval_definition_xml_el, "version")
    definition.criteria = load_criteria(criteria_el)
    return definition


class Definition(OVALComponent):
    criteria = None

    def __init__(self, tag, id_, class_, metadata):
        super(Definition, self).__init__(tag, id_)
        self.class_ = class_
        self.metadata = metadata

    def check_affected(self):
        if (
            self.metadata.array_of_affected is None
            or not self.metadata.array_of_affected
        ):
            raise ValueError(
                "Definition '{}' doesn't contain OVAL 'affected' element".format(
                    self.id_
                )
            )

    def is_applicable_for_product(self, product):
        return self.metadata.is_applicable_for_product(product)

    def get_xml_element(self):
        definition_el = super(Definition, self).get_xml_element()
        definition_el.set("class", self.class_)
        definition_el.append(self.metadata.get_xml_element())
        if self.criteria:
            definition_el.append(self.criteria.get_xml_element())
        return definition_el

    def translate_id(self, translator, store_defname=False):
        super(Definition, self).translate_id(translator, store_defname)
        self.criteria.translate_id(translator)
        if store_defname:
            self.metadata.add_reference(self.name, translator.content_id)
