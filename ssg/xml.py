from __future__ import absolute_import
from __future__ import print_function

import platform

from .constants import xml_version, oval_header, timestamp, PREFIX_TO_NS


try:
    from xml.etree import cElementTree as ElementTree
except ImportError:
    from xml.etree import ElementTree as ElementTree


def oval_generated_header(product_name, schema_version, ssg_version):
    return xml_version + oval_header + \
        """
    <generator>
        <oval:product_name>%s from SCAP Security Guide</oval:product_name>
        <oval:product_version>ssg: %s, python: %s</oval:product_version>
        <oval:schema_version>%s</oval:schema_version>
        <oval:timestamp>%s</oval:timestamp>
    </generator>""" % (product_name, ssg_version, platform.python_version(),
                       schema_version, timestamp)


def open_xml(filename):
    """
    Given a filename, register all possible namespaces, and return the XML tree.
    """
    try:
        for prefix, uri in PREFIX_TO_NS.items():
            ElementTree.register_namespace(prefix, uri)
    except Exception:
        # Probably an old version of Python
        # Doesn't matter, as this is non-essential.
        pass
    return ElementTree.parse(filename)


def parse_file(filename):
    """
    Given a filename, return the root of the ElementTree
    """
    tree = open_xml(filename)
    return tree.getroot()


def map_elements_to_their_ids(tree, xpath_expr):
    """
    Given an ElementTree and an XPath expression,
    iterate through matching elements and create 1:1 id->element mapping.

    Raises AssertionError if a matching element doesn't have the ``id``
    attribute.

    Returns mapping as a dictionary
    """
    aggregated = {}
    for element in tree.findall(xpath_expr):
        element_id = element.get("id")
        assert element_id is not None
        aggregated[element_id] = element
    return aggregated
