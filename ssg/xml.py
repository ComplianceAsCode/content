from __future__ import absolute_import
from __future__ import print_function

import platform
import re

from .constants import (
    xml_version, oval_header, timestamp, PREFIX_TO_NS, XCCDF11_NS, XCCDF12_NS)


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


def register_namespaces():
    """
    Register all possible namespaces
    """
    try:
        for prefix, uri in PREFIX_TO_NS.items():
            ElementTree.register_namespace(prefix, uri)
    except Exception:
        # Probably an old version of Python
        # Doesn't matter, as this is non-essential.
        pass


def open_xml(filename):
    """
    Given a filename, register all possible namespaces, and return the XML tree.
    """
    register_namespaces()
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


SSG_XHTML_TAGS = [
    'table', 'tr', 'th', 'td', 'ul', 'li', 'ol',
    'p', 'code', 'strong', 'b', 'em', 'i', 'pre', 'br', 'hr', 'small',
]


def add_xhtml_namespace(data):
    """
    Given a xml blob, adds the xhtml namespace to all relevant tags.
    """
    # The use of lambda in the lines below is a workaround for https://bugs.python.org/issue1519638
    # I decided for this approach to avoid adding workarounds in the matching regex, this way only
    # the substituted part contains the workaround.
    # Transform <tt> in <code>
    data = re.sub(r'<(\/)?tt(\/)?>',
                  lambda m: r'<' + (m.group(1) or '') + 'code' + (m.group(2) or '') + '>', data)
    # Adds xhtml prefix to elements: <tag>, </tag>, <tag/>
    return re.sub(r'<(\/)?((?:%s).*?)(\/)?>' % "|".join(SSG_XHTML_TAGS),
                  lambda m: r'<' + (m.group(1) or '') + 'xhtml:' +
                  (m.group(2) or '') + (m.group(3) or '') + '>',
                  data)


def determine_xccdf_tree_namespace(tree):
    root = tree.getroot()
    if root.tag == "{%s}Benchmark" % XCCDF11_NS:
        xccdf_ns = XCCDF11_NS
    elif root.tag == "{%s}Benchmark" % XCCDF12_NS:
        xccdf_ns = XCCDF12_NS
    else:
        raise ValueError("Unknown root element '%s'" % root.tag)
    return xccdf_ns
