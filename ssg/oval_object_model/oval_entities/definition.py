import sys

from ...xml import ElementTree
from ..general import (
    BOOL_TO_STR,
    OVAL_NAMESPACES,
    STR_TO_BOOL,
    OVALBaseObject,
    OVALComponent,
    load_notes,
    required_attribute,
)


class GeneralCriteriaNode(OVALBaseObject):
    def __init__(self, tag, negate=False, comment="", applicability_check=False):
        super().__init__(tag)
        self.negate: bool = negate
        self.comment: str = comment
        self.applicability_check: bool = applicability_check

    def get_xml_element(self):
        el = ElementTree.Element(self.tag)
        if self.applicability_check:
            el.set("applicability_check", BOOL_TO_STR[self.applicability_check])
        if self.negate:
            el.set("negate", BOOL_TO_STR[self.negate])
        if self.comment != "":
            el.set("comment", self.comment)

        return el


# -----


def load_criterion(oval_criterion_xml_el):
    return Criterion(
        oval_criterion_xml_el.tag,
        required_attribute(oval_criterion_xml_el, "test_ref"),
        STR_TO_BOOL.get(oval_criterion_xml_el.get("negate"), False),
        oval_criterion_xml_el.get("comment", ""),
        STR_TO_BOOL.get(oval_criterion_xml_el.get("applicability_check"), False),
    )


class Criterion(GeneralCriteriaNode):
    def __init__(
        self, tag, test_ref, negate=False, comment="", applicability_check=False
    ):
        super().__init__(tag, negate, comment, applicability_check)
        self.test_ref: str = test_ref

    def get_xml_element(self):
        criterion_el = super().get_xml_element()
        criterion_el.set("test_ref", self.test_ref)
        return criterion_el


# -----


def load_extend_definition(oval_extend_definition_xml_el):
    return ExtendDefinition(
        oval_extend_definition_xml_el.tag,
        required_attribute(oval_extend_definition_xml_el, "definition_ref"),
        STR_TO_BOOL.get(oval_extend_definition_xml_el.get("negate"), False),
        oval_extend_definition_xml_el.get("comment", ""),
        STR_TO_BOOL.get(
            oval_extend_definition_xml_el.get("applicability_check"), False
        ),
    )


class ExtendDefinition(GeneralCriteriaNode):
    def __init__(
        self, tag, definition_ref, negate=False, comment="", applicability_check=False
    ):
        super().__init__(tag, negate, comment, applicability_check)
        self.definition_ref: str = definition_ref

    def get_xml_element(self):
        extend_definition_el = super().get_xml_element()
        extend_definition_el.set("definition_ref", self.definition_ref)
        return extend_definition_el


# -----


def load_criteria(oval_criteria_xml_el):
    criteria = Criteria(
        oval_criteria_xml_el.tag,
        oval_criteria_xml_el.get("operator", "AND"),
        STR_TO_BOOL.get(oval_criteria_xml_el.get("negate"), False),
        oval_criteria_xml_el.get("comment", ""),
        STR_TO_BOOL.get(oval_criteria_xml_el.get("applicability_check"), False),
    )
    for child_node_el in oval_criteria_xml_el:
        if child_node_el.tag.endswith("criteria"):
            criteria.add_child_criteria_node(load_criteria(child_node_el))
        elif child_node_el.tag.endswith("criterion"):
            criteria.add_child_criteria_node(load_criterion(child_node_el))
        elif child_node_el.tag.endswith("extend_definition"):
            criteria.add_child_criteria_node(load_extend_definition(child_node_el))
        else:
            sys.stderr.write(
                "Warning: Unknown element '{}'\n".format(child_node_el.tag)
            )
    return criteria


class Criteria(GeneralCriteriaNode):
    def __init__(
        self, tag, operator="AND", negate=False, comment="", applicability_check=False
    ):
        super().__init__(tag, negate, comment, applicability_check)
        self.operator: str = operator

        self.child_criteria_nodes: list[Criteria, ExtendDefinition, Criterion] = []

    def add_child_criteria_node(self, child):
        if not isinstance(child, (Criteria, Criterion, ExtendDefinition)):
            raise TypeError("Unexpected child type of Criteria!")
        self.child_criteria_nodes.append(child)

    def get_xml_element(self):
        criteria_el = super().get_xml_element()

        criteria_el.set("operator", self.operator)

        for child_criteria_node in self.child_criteria_nodes:
            criteria_el.append(child_criteria_node.get_xml_element())

        return criteria_el


# -----


def load_references(all_reference_elements):
    out = []
    for ref_el in all_reference_elements:
        out.append(
            Reference(
                ref_el.tag,
                required_attribute(ref_el, "source"),
                required_attribute(ref_el, "ref_id"),
                ref_el.get("ref_url", ""),
            )
        )
    return out if out else None


class Reference(OVALBaseObject):
    def __init__(self, tag, source, ref_id, ref_url=""):
        super().__init__(tag)
        self.source: str = source
        self.ref_id: str = ref_id
        self.ref_url: str = ref_url

    def get_xml_element(self):
        reference_el = ElementTree.Element(self.tag)
        reference_el.set("ref_id", self.ref_id)
        reference_el.set("source", self.source)
        if self.ref_url != "":
            reference_el.set("ref_url", self.ref_url)
        return reference_el


# -----


def _get_tag(el):
    if el is None:
        return ""
    return el.tag


def _get_list_of_affected(affected_el, element_name):
    return [
        el.text
        for el in affected_el.findall(
            "./{%s}%s" % (OVAL_NAMESPACES.definition, element_name)
        )
    ]


def load_affected(all_affected_elements):
    out = []
    for affected_el in all_affected_elements:
        platforms = _get_list_of_affected(affected_el, "platform")

        products = _get_list_of_affected(affected_el, "product")

        platform_tag = _get_tag(
            affected_el.find("./{%s}platform" % OVAL_NAMESPACES.definition)
        )
        product_tag = _get_tag(
            affected_el.find("./{%s}product" % OVAL_NAMESPACES.definition)
        )
        if not platforms:
            platforms = None
        if not products:
            products = None
        out.append(
            Affected(
                affected_el.tag,
                required_attribute(affected_el, "family"),
                platform_tag,
                product_tag,
                platforms,
                products,
            )
        )
    return out if out else None


class Affected(OVALBaseObject):
    def __init__(
        self,
        tag,
        family,
        platform_tag="",
        product_tag="",
        platforms=None,
        products=None,
    ):
        super().__init__(tag)
        self.family: str = family

        self.platforms: list[str] = platforms
        self.products: list[str] = products
        self.platform_tag: str = platform_tag
        self.product_tag: str = product_tag

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
        if type_ == "platform":
            self.platforms = [full_name]

        if type_ == "product":
            self.products = [full_name]

    def _add_to_affected_element(self, affected_el, elements):
        for platform in elements if elements is not None else []:
            platform_el = ElementTree.Element(self.platform_tag)
            platform_el.text = platform
            affected_el.append(platform_el)

    def get_xml_element(self):
        affected_el = ElementTree.Element(self.tag)
        affected_el.set("family", self.family)

        self._add_to_affected_element(affected_el, self.platforms)
        self._add_to_affected_element(affected_el, self.products)

        return affected_el


# -----


def load_metadata(oval_metadata_xml_el):
    title_el = oval_metadata_xml_el.find("./{%s}title" % OVAL_NAMESPACES.definition)
    title_str = title_el.text
    title_tag = title_el.tag
    description_el = oval_metadata_xml_el.find(
        "./{%s}description" % OVAL_NAMESPACES.definition
    )
    description_str = description_el.text
    description_tag = description_el.tag
    all_affected_elements = oval_metadata_xml_el.findall(
        "./{%s}affected" % OVAL_NAMESPACES.definition
    )
    all_reference_elements = oval_metadata_xml_el.findall(
        "./{%s}reference" % OVAL_NAMESPACES.definition
    )
    return Metadata(
        oval_metadata_xml_el.tag,
        title_str,
        title_tag,
        description_str,
        description_tag,
        load_affected(all_affected_elements),
        load_references(all_reference_elements),
    )


class Metadata(OVALBaseObject):
    def __init__(
        self,
        tag,
        title,
        title_tag,
        description,
        description_tag,
        array_of_affected=None,
        array_of_references=None,
    ):
        super().__init__(tag)
        self.title: str = title
        self.description: str = description

        self.array_of_affected: list[Affected] = array_of_affected
        self.array_of_references: list[Reference] = array_of_references

        self.title_tag: str = title_tag
        self.description_tag: str = description_tag

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

    @staticmethod
    def _add_sub_elements_from_arrays(el, array):
        for item in array if array is not None else []:
            el.append(item.get_xml_element())

    def get_xml_element(self):
        metadata_el = ElementTree.Element(self.tag)

        title_el = ElementTree.Element(self.title_tag)
        title_el.text = self.title
        metadata_el.append(title_el)

        self._add_sub_elements_from_arrays(metadata_el, self.array_of_affected)
        self._add_sub_elements_from_arrays(metadata_el, self.array_of_references)

        description_el = ElementTree.Element(self.description_tag)
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
    return Definition(
        oval_definition_xml_el.tag,
        required_attribute(oval_definition_xml_el, "id"),
        required_attribute(oval_definition_xml_el, "class"),
        required_attribute(oval_definition_xml_el, "version"),
        load_metadata(metadata_el),
        STR_TO_BOOL.get(oval_definition_xml_el.get("deprecated", ""), False),
        load_notes(notes_el),
        load_criteria(criteria_el),
    )


class Definition(OVALComponent):
    def __init__(
        self,
        tag,
        id_,
        class_,
        version,
        metadata,
        deprecated=False,
        notes=None,
        criteria=None,
    ):
        super().__init__(tag, id_, version, deprecated, notes)
        self.class_: str = class_
        self.metadata: Metadata = metadata
        self.criteria: Criteria = criteria

    def get_xml_element(self):
        definition_el = super().get_xml_element()
        definition_el.set("class", self.class_)
        definition_el.append(self.metadata.get_xml_element())
        if self.criteria:
            definition_el.append(self.criteria.get_xml_element())
        return definition_el
