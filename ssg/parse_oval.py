from __future__ import absolute_import
from __future__ import print_function

from .xml import ElementTree as ET


REFERENCE_TO_GROUP = dict(
    var_ref="variables",
    test_ref="tests",
    object_ref="objects",
    state_ref="states",
)


CONTAINER_GROUPS = set((
    "definitions",
    "objects",
    "states",
    "tests",
    "variables",
))


class ElementFinder(object):
    def __init__(self, oval_groups):
        self.oval_groups = oval_groups
        self.target = None
        self.attrib = None
        self.result = set()

    def find_element(self, start_element, target_element_name, sought_attrib):
        self.target = target_element_name
        self.attrib = sought_attrib
        self.result = set()
        self._recurse(start_element)

    def _recurse(self, element):
        if element.tag.endswith(self.target):
            self.result.add(element.attrib[self.attrib])
            return

        self._examine_element(element)
        for child in element:
            self._recurse(child)

    def _examine_element(self, element):
        name = _strip_ns_from_tag(element.tag)
        new_root = None

        if name in REFERENCE_TO_GROUP:
            reference_target = REFERENCE_TO_GROUP[name]
            new_root = self.oval_groups[reference_target][element.text]
        else:
            _attr_group = _search_element_for_reference_attributes(element)
            if _attr_group is not None:
                ref_attribute_name, entity_id = _attr_group
                reference_target = REFERENCE_TO_GROUP[ref_attribute_name]
                new_root = self.oval_groups[reference_target][entity_id]

        if new_root is not None:
            self._recurse(new_root)


def _sort_by_id(elements):
    ret = dict()
    for element in elements:
        ret[element.attrib["id"]] = element
    return ret


def _search_dict_for_items_that_end_with(dic, what_to_look_for):
    for item in dic:
        if item.endswith(what_to_look_for):
            return dic[item]
    return None


def _search_element_for_reference_attributes(element):
    for ref_attribute_name in REFERENCE_TO_GROUP:
        occurence = _search_dict_for_items_that_end_with(
            element.attrib, ref_attribute_name)
        if occurence is not None:
            return ref_attribute_name, occurence
    return None


def resolve_definition(oval_groups, defn):
    finder = ElementFinder(oval_groups)
    finder.find_element(defn, "external_variable", "id")
    return finder.result


def find_extending_defs(oval_groups, defn):
    finder = ElementFinder(oval_groups)
    finder.find_element(defn, "extend_definition", "definition_ref")
    return finder.result


def get_container_groups(fname):
    return _get_container_oval_groups_from_tree(ET.parse(fname))


def _strip_ns_from_tag(tag_name):
    return tag_name.split("}", 1)[1]


def _get_container_oval_groups_from_tree(element_tree):
    root = element_tree.getroot()

    oval_groups = {}
    for child in root:
        group_name = _strip_ns_from_tag(child.tag)
        if group_name in CONTAINER_GROUPS:
            oval_groups[group_name] = _sort_by_id(child)

    return oval_groups


def _get_resolved_definitions(oval_groups):
    def_id_to_vars_ids = {}
    for def_id, def_el in oval_groups["definitions"].items():
        def_id_to_vars_ids[def_id] = resolve_definition(oval_groups, def_el)
    return def_id_to_vars_ids


def _check_sanity(oval_groups, resolved_defns):
    all_external_variables = set()
    for var_id, var_el in oval_groups["variables"].items():
        if var_el.tag.endswith("external_variable"):
            all_external_variables.add(var_id)

    all_caught_variables = set()
    for var in resolved_defns.values():
        all_caught_variables.update(var)

    skipped_variables = all_external_variables.difference(all_caught_variables)
    if skipped_variables:
        print("These variables managed to slip past:", skipped_variables)
        strange_variables = all_caught_variables.difference(
            all_external_variables)
        assert not strange_variables, \
            ("There were unexpected caught variables: {}"
             .format(str(strange_variables)))


def _check_sanity_on_file(fname):
    oval_groups = get_container_groups(fname)
    resolved_defns = _get_resolved_definitions(oval_groups)
    _check_sanity(oval_groups, resolved_defns)
