"""
Common functions for processing OVAL in SSG
"""

from __future__ import absolute_import
from __future__ import print_function

import sys
import os

from .constants import oval_footer as footer
from .constants import oval_namespace as ovalns
from .xml import ElementTree as ET
from .xml import oval_generated_header

from .jinja import process_file_with_macros
from .products import _get_implied_properties


ASSUMED_OVAL_VERSION_STRING = "5.11"
# globals, to make recursion easier in case we encounter extend_definition
try:
    ET.register_namespace("oval", ovalns)
except AttributeError:
    # Legacy Python 2.6 fix, see e.g.
    # https://www.programcreek.com/python/example/57552/xml.etree.ElementTree._namespace_map
    from xml.etree import ElementTree as ET
    ET._namespace_map[ovalns] = "oval"


def applicable_platforms(oval_file, oval_version_string=None):
    """
    Returns the applicable platforms for a given OVAL file.

    This function processes an OVAL file to extract the platforms it applies to. It uses a
    specified OVAL version string or a default version if none is provided. The function
    constructs an XML tree from the OVAL file and extracts platform information from it.

    Args:
        oval_file (str): The path to the OVAL file to be processed.
        oval_version_string (str, optional): The OVAL version string to be used.
                                             If not provided, a default version is used.

    Returns:
        list: A list of platforms that the OVAL file applies to.

    Raises:
        Exception: If there is an error while parsing the OVAL file.
    """
    platforms = []

    if not oval_version_string:
        oval_version_string = ASSUMED_OVAL_VERSION_STRING
    header = oval_generated_header("applicable_platforms", oval_version_string, "0.0.1")

    oval_version_list = [int(num) for num in oval_version_string.split(".")]
    subst_dict = dict(target_oval_version=oval_version_list)

    oval_filename_components = oval_file.split(os.path.sep)
    if len(oval_filename_components) > 3:
        subst_dict["rule_id"] = oval_filename_components[-3]
    else:
        msg = "Unable to get rule ID from OVAL path '{path}'".format(path=oval_file)
        print(msg, file=sys.stderr)

    subst_dict = _get_implied_properties(subst_dict)
    subst_dict['target_oval_version'] = [999, 999.999]

    body = process_file_with_macros(oval_file, subst_dict)

    try:
        oval_tree = ET.fromstring(header + body + footer)
    except Exception as e:
        msg = "Error while loading " + oval_file
        print(msg, file=sys.stderr)
        raise e

    element_path = "./{%s}def-group/{%s}definition/{%s}metadata/{%s}affected/{%s}platform"
    element_ns_path = element_path % (ovalns, ovalns, ovalns, ovalns, ovalns)
    for node in oval_tree.findall(element_ns_path):
        platforms.append(node.text)

    return platforms


def parse_affected(oval_contents):
    """
    Returns the tuple (start_affected, end_affected, platform_indents) for the passed OVAL file contents.

    Args:
    oval_contents (list of str): The contents of the OVAL file, where each element is a line from
                                 the file.

    Returns:
        tuple: A tuple containing:
            - start_affected (int): The line number of the starting <affected> tag.
            - end_affected (int): The line number of the closing </affected> tag.
            - platform_indents (str): The indenting characters before the contents of the
              <affected> element.

    Raises:
        ValueError: If the OVAL file does not contain a single <affected> element, if the start
                    tag is after the end tag, or if the tags contain other elements.
    """
    start_affected = list(filter(lambda x: "<affected" in oval_contents[x],
                                 range(0, len(oval_contents))))
    if len(start_affected) != 1:
        raise ValueError("OVAL file does not contain a single <affected> "
                         "element; counted %d in:\n%s\n\n" %
                         (len(start_affected), "\n".join(oval_contents)))

    start_affected = start_affected[0]

    end_affected = list(filter(lambda x: "</affected" in oval_contents[x],
                               range(0, len(oval_contents))))
    if len(end_affected) != 1:
        raise ValueError("Malformed OVAL file does not contain a single "
                         "closing </affected>; counted %d in:\n%s\n\n" %
                         (len(start_affected), "\n".join(oval_contents)))
    end_affected = end_affected[0]

    if start_affected >= end_affected:
        raise ValueError("Malformed OVAL file: start affected tag begins "
                         "on the same line or after ending affected tag: "
                         "start:%d vs end:%d:\n%s\n\n" %
                         (start_affected, end_affected, oval_contents))

    # Validate that start_affected contains only a starting <affected> tag;
    # otherwise, using this information to update the <platform> subelements
    # would fail.
    start_line = oval_contents[start_affected]
    start_line = start_line.strip()

    if not start_line.startswith('<affected'):
        raise ValueError("Malformed OVAL file: line with starting affected "
                         "tag contains other elements: line:%s\n%s\n\n" %
                         (start_line, oval_contents))
    if '<' in start_line[1:]:
        raise ValueError("Malformed OVAL file: line with starting affected "
                         "tag contains other elements: line:%s\n%s\n\n" %
                         (start_line, oval_contents))

    # Validate that end_affected contains only an ending </affected> tag;
    # otherwise, using this information to update the <platform> subelements
    # would fail.
    end_line = oval_contents[end_affected]
    end_line = end_line.strip()

    if not end_line.startswith('</affected>'):
        raise ValueError("Malformed OVAL file: line with ending affected "
                         "tag contains other elements: line:%s\n%s\n\n" %
                         (end_line, oval_contents))
    if '<' in end_line[1:]:
        raise ValueError("Malformed OVAL file: line with ending affected "
                         "tag contains other elements: line:%s\n%s\n\n" %
                         (end_line, oval_contents))

    indents = ""
    if start_affected+1 == end_affected:
        # Since the affected element is present but empty, the indents should
        # be two more spaces than that of the starting <affected> element.
        start_index = oval_contents[start_affected].index('<')
        indents = oval_contents[start_affected][0:start_index]
        indents += "  "
    else:
        # Otherwise, grab the indents off the next line unmodified, as this is
        # likely a platform element tag. We don't validate here that this is
        # indeed the case, as other parts of the build infrastructure will
        # validate this for us.
        start_index = oval_contents[start_affected+1].index('<')
        indents = oval_contents[start_affected+1][0:start_index]

    return start_affected, end_affected, indents
