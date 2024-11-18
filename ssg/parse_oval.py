"""
Common functions for OVAL parsing in SSG
"""

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
    """
    A class to find specific elements within an XML structure based on given criteria.

    Attributes:
        oval_groups (dict): A dictionary containing groups of OVAL definitions.
        target (str): The name of the target element to find.
        attrib (str): The attribute of the target element to retrieve.
        result (set): A set to store the results of the found elements' attributes.
    """
    def __init__(self, oval_groups):
        self.oval_groups = oval_groups
        self.target = None
        self.attrib = None
        self.result = set()

    def find_element(self, start_element, target_element_name, sought_attrib):
        """
        Find elements in an XML tree that match the target element name and sought attribute.

        Args:
            start_element (Element): The starting element to begin the search from.
            target_element_name (str): The name of the target element to find.
            sought_attrib (str): The attribute to look for in the target elements.

        Returns:
            None: This method does not return a value. The results are stored in the instance
                  variable `self.result`.
        """
        self.target = target_element_name
        self.attrib = sought_attrib
        self.result = set()
        self._recurse(start_element)

    def _recurse(self, element):
        """
        Recursively traverses an XML element tree to find elements with a specific tag and attribute.

        Args:
            element (xml.etree.ElementTree.Element): The current XML element to examine.

        Returns:
            None
        """
        if element.tag.endswith(self.target):
            self.result.add(element.attrib[self.attrib])
            return

        self._examine_element(element)
        for child in element:
            self._recurse(child)

    def _examine_element(self, element):
        """
        Examines an XML element and processes it based on its tag name or reference attributes.

        This method first strips the namespace from the element's tag name and checks if it is in
        the REFERENCE_TO_GROUP dictionary. If it is, it retrieves the corresponding group from the
        oval_groups dictionary using the element's text as the key. If the tag name is not in
        REFERENCE_TO_GROUP, it searches for reference attributes within the element. If reference
        attributes are found, it retrieves the corresponding group from the oval_groups dictionary
        using the reference attribute name and entity ID.

        If a new root element is found, the method recursively processes the new root element.

        Args:
            element (xml.etree.ElementTree.Element): The XML element to examine and process.

        Raises:
            AssertionError: If the entity ID is not found in the corresponding group in oval_groups.
        """
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
                assert entity_id in self.oval_groups[reference_target], \
                    ('Missing definition: "%s" in "%s" "%s"' %
                     (entity_id, reference_target, element))
                new_root = self.oval_groups[reference_target][entity_id]

        if new_root is not None:
            self._recurse(new_root)


def _sort_by_id(elements):
    """
    Process a list of XML elements by their 'id' attribute and returns a dictionary.

    Args:
        elements (list): A list of XML elements, each having an 'id' attribute.

    Returns:
        dict: A dictionary where the keys are the 'id' attributes of the elements and the values
              are the corresponding XML elements.
    """
    ret = dict()
    for element in elements:
        ret[element.attrib["id"]] = element
    return ret


def _search_dict_for_items_that_end_with(dic, what_to_look_for):
    """
    Searches a dictionary for keys that end with a specified substring and returns the
    corresponding value.

    Args:
        dic (dict): The dictionary to search through.
        what_to_look_for (str): The substring to look for at the end of the dictionary keys.

    Returns:
        The value corresponding to the first key that ends with the specified substring,
        or None if no such key is found.
    """
    for item in dic:
        if item.endswith(what_to_look_for):
            return dic[item]
    return None


def _search_element_for_reference_attributes(element):
    """
    Searches an XML element for attributes that match reference names defined in REFERENCE_TO_GROUP.

    Args:
        element (xml.etree.ElementTree.Element): The XML element to search within.

    Returns:
        tuple: A tuple containing the reference attribute name and its occurrence if found. Or
        None, if no matching reference attribute is found.
    """
    for ref_attribute_name in REFERENCE_TO_GROUP:
        occurence = _search_dict_for_items_that_end_with(
            element.attrib, ref_attribute_name)
        if occurence is not None:
            return ref_attribute_name, occurence
    return None


def _find_attr(oval_groups, defn, elem, attr):
    """
    Finds and returns the attribute value of a specified element within a given definition.

    Args:
        oval_groups (list): A list of OVAL groups to search within.
        defn (str): The definition identifier to search for.
        elem (str): The element name to find within the definition.
        attr (str): The attribute name whose value is to be retrieved.

    Returns:
        str: The value of the specified attribute if found, otherwise None.
    """
    finder = ElementFinder(oval_groups)
    finder.find_element(defn, elem, attr)
    return finder.result


def resolve_definition(oval_groups, defn):
    """
    Resolves a definition by finding the attribute 'external_variable' with the specified 'id'
    in the given OVAL groups.

    Args:
        oval_groups (dict): A dictionary containing OVAL groups.
        defn (str): The definition to resolve.

    Returns:
        The value of the 'external_variable' attribute with the specified 'id' if found,
        otherwise None.
    """
    return _find_attr(oval_groups, defn, "external_variable", "id")


def find_extending_defs(oval_groups, defn):
    """
    Find and return the definitions that extend a given definition.

    Args:
        oval_groups (dict): A dictionary containing OVAL groups.
        defn (str): The definition to find extensions for.

    Returns:
        list: A list of definitions that extend the given definition.
    """
    return _find_attr(oval_groups, defn, "extend_definition", "definition_ref")


def get_container_groups(fname):
    """
    Parses an OVAL file and retrieves container groups.

    Args:
        fname (str): The path to the OVAL file to be parsed.

    Returns:
        list: A list of container groups extracted from the OVAL file.
    """
    return _get_container_oval_groups_from_tree(ET.parse(fname))


def _strip_ns_from_tag(tag_name):
    """
    Remove the namespace from an XML tag.

    Args:
        tag_name (str): The XML tag with namespace.

    Returns:
        str: The XML tag without the namespace.
    """
    return tag_name.split("}", 1)[1]


def _get_container_oval_groups_from_tree(element_tree):
    """
    Extracts and sorts OVAL groups from an XML element tree.

    This function takes an XML element tree, retrieves its root, and iterates through its
    children. For each child, it strips the namespace from the tag and checks if the resulting
    group name is in the predefined list of container groups (CONTAINER_GROUPS). If it is, the
    child is sorted by ID and added to the oval_groups dictionary under the corresponding group
    name.

    Args:
        element_tree (ElementTree): The XML element tree to parse.

    Returns:
        dict: A dictionary where the keys are group names and the values are the sorted elements
              of those groups.
    """
    root = element_tree.getroot()

    oval_groups = {}
    for child in root:
        group_name = _strip_ns_from_tag(child.tag)
        if group_name in CONTAINER_GROUPS:
            oval_groups[group_name] = _sort_by_id(child)

    return oval_groups


def _get_resolved_definitions(oval_groups):
    """
    Resolves definitions within the given OVAL groups and maps each definition ID to its
    corresponding variable IDs.

    Args:
        oval_groups (dict): A dictionary containing OVAL groups, where "definitions" is a key that
                            maps to another dictionary of definition IDs and their corresponding
                            elements.

    Returns:
        dict: A dictionary mapping each definition ID to a list of variable IDs resolved from the
              definitions.
    """
    def_id_to_vars_ids = {}
    for def_id, def_el in oval_groups["definitions"].items():
        def_id_to_vars_ids[def_id] = resolve_definition(oval_groups, def_el)
    return def_id_to_vars_ids


def _check_sanity(oval_groups, resolved_defns):
    """
    Checks the sanity of OVAL variable definitions by ensuring that all external variables are
    accounted for and no unexpected variables are caught.

    Args:
        oval_groups (dict): A dictionary containing OVAL variable groups. The key "variables"
                            should map to another dictionary where keys are variable IDs and
                            values are variable elements.
        resolved_defns (dict): A dictionary where keys are variable IDs and values are sets of
                               resolved variable definitions.
    Returns:
        None

    Raises:
        AssertionError: If there are unexpected caught variables.
    """
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
    """
    Perform sanity checks on the given file.

    This function reads the file specified by `fname`, extracts OVAL groups,
    resolves definitions, and then checks the sanity of these groups and definitions.

    Args:
        fname (str): The path to the file to be checked.

    Returns:
        None

    Raises:
        ValueError: If any sanity check fails.
    """
    oval_groups = get_container_groups(fname)
    resolved_defns = _get_resolved_definitions(oval_groups)
    _check_sanity(oval_groups, resolved_defns)
