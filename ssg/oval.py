from __future__ import absolute_import
from __future__ import print_function

import sys
import os
import re
import argparse
import tempfile
import subprocess

from .constants import oval_footer as footer
from .constants import oval_namespace as ovalns
from .rules import get_rule_dir_id, get_rule_dir_ovals, find_rule_dirs
from .xml import ElementTree as ET
from .xml import oval_generated_header
from .jinja import process_file_with_macros, add_python_functions
from .yaml import open_environment
from .id_translate import IDTranslator

SHARED_OVAL = re.sub(r'ssg/.*', 'shared', __file__) + '/checks/oval/'
LINUX_OS_GUIDE = re.sub(r'ssg/.*', 'linux_os', __file__) + '/guide/'


ASSUMED_OVAL_VERSION_STRING = "5.11"


# globals, to make recursion easier in case we encounter extend_definition
try:
    ET.register_namespace("oval", ovalns)
except AttributeError:
    # Legacy Python 2.6 fix, see e.g.
    # https://www.programcreek.com/python/example/57552/xml.etree.ElementTree._namespace_map
    from xml.etree import ElementTree as ET
    ET._namespace_map[ovalns] = "oval"

definitions = ET.Element("oval:definitions")
tests = ET.Element("oval:tests")
objects = ET.Element("oval:objects")
states = ET.Element("oval:states")
variables = ET.Element("oval:variables")
silent_mode = False


# append new child ONLY if it's not a duplicate
def append(element, newchild):
    global silent_mode
    newid = newchild.get("id")
    existing = element.find(".//*[@id='" + newid + "']")
    if existing is not None:
        if not silent_mode:
            sys.stderr.write("Notification: this ID is used more than once " +
                             "and should represent equivalent elements: " +
                             newid + "\n")
    else:
        element.append(newchild)


def _add_elements(body, header, yaml_env):
    """Add oval elements to the global Elements defined above"""
    global definitions
    global tests
    global objects
    global states
    global variables

    tree = ET.fromstring(header + body + footer)
    tree = replace_external_vars(tree)
    defname = None
    # parse new file(string) as an etree, so we can arrange elements
    # appropriately
    for childnode in tree.findall("./{%s}def-group/*" % ovalns):
        # print "childnode.tag is " + childnode.tag
        if childnode.tag is ET.Comment:
            continue
        if childnode.tag == ("{%s}definition" % ovalns):
            append(definitions, childnode)
            defname = childnode.get("id")
            # extend_definition is a special case:  must include a whole other
            # definition
            for defchild in childnode.findall(".//{%s}extend_definition"
                                              % ovalns):
                defid = defchild.get("definition_ref")
                extend_ref = find_testfile_or_exit(defid)
                includedbody = read_ovaldefgroup_file(extend_ref, yaml_env)
                # recursively add the elements in the other file
                _add_elements(includedbody, header, yaml_env)
        if childnode.tag.endswith("_test"):
            append(tests, childnode)
        if childnode.tag.endswith("_object"):
            append(objects, childnode)
        if childnode.tag.endswith("_state"):
            append(states, childnode)
        if childnode.tag.endswith("_variable"):
            append(variables, childnode)
    return defname


def applicable_platforms(oval_file, oval_version_string=None):
    """
    Returns the applicable platforms for a given oval file
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

    body = process_file_with_macros(oval_file, subst_dict)

    oval_tree = ET.fromstring(header + body + footer)

    element_path = "./{%s}def-group/{%s}definition/{%s}metadata/{%s}affected/{%s}platform"
    element_ns_path = element_path % (ovalns, ovalns, ovalns, ovalns, ovalns)
    for node in oval_tree.findall(element_ns_path):
        platforms.append(node.text)

    return platforms


def parse_affected(oval_contents):
    """
    Returns the tuple (start_affected, end_affected, platform_indents) for
    the passed oval file contents. start_affected is the line number of
    starting tag of the <affected> element, end_affected is the line number of
    the closing tag of the </affected> element, and platform_indents is a
    string containing the indenting characters before the contents of the
    <affected> element.
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


def replace_external_vars(tree):
    """Replace external_variables with local_variables, so the definition can be
       tested independently of an XCCDF file"""

    # external_variable is a special case: we turn it into a local_variable so
    # we can test
    for node in tree.findall(".//{%s}external_variable" % ovalns):
        print("External_variable with id : " + node.get("id"))
        extvar_id = node.get("id")
        # for envkey, envval in os.environ.iteritems():
        #     print envkey + " = " + envval
        # sys.exit()
        if extvar_id not in os.environ.keys():
            print("External_variable specified, but no value provided via "
                  "environment variable", file=sys.stderr)
            sys.exit(2)
        # replace tag name: external -> local
        node.tag = "{%s}local_variable" % ovalns
        literal = ET.Element("oval:literal_component")
        literal.text = os.environ[extvar_id]
        node.append(literal)
        # TODO: assignment of external_variable via environment vars, for
        # testing
    return tree


def find_testfile_or_exit(testfile):
    """Find OVAL files in CWD or shared/oval and calls sys.exit if the file is not found"""
    _testfile = find_testfile(testfile)
    if _testfile is None:
        print("ERROR: %s does not exist! Please specify a valid OVAL file." % testfile,
              file=sys.stderr)
        sys.exit(1)
    else:
        return _testfile


def find_testfile(oval_id):
    """
    Find OVAL file by id in CWD, SHARED_OVAL, or LINUX_OS_GUIDE. Understands rule
    directories and defaults to returning shared.xml over {{{ product }}}.xml.

    Returns path to OVAL file or None if not found.
    """
    if os.path.isfile(os.path.abspath(oval_id)):
        return os.path.abspath(oval_id)

    if oval_id.endswith(".xml"):
        oval_id, _ = os.path.splitext(oval_id)
        oval_id = os.path.basename(oval_id)

    candidates = [oval_id, "%s.xml" % oval_id]

    found_file = None
    for path in ['.', SHARED_OVAL, LINUX_OS_GUIDE]:
        for root, _, _ in os.walk(path):
            for candidate in candidates:
                search_file = os.path.join(root, candidate).strip()
                if os.path.isfile(search_file):
                    found_file = search_file
                    break

        for rule_dir in find_rule_dirs(path):
            rule_id = get_rule_dir_id(rule_dir)
            if rule_id == oval_id:
                ovals = get_rule_dir_ovals(rule_dir, product="shared")
                if ovals:
                    found_file = ovals[0]
                    break

    return found_file


def read_ovaldefgroup_file(testfile, yaml_env):
    """Read oval files"""
    body = process_file_with_macros(testfile, yaml_env)
    return body


def get_openscap_supported_oval_version():
    try:
        from openscap import oscap_get_version
        if [int(x) for x in str(oscap_get_version()).split(".")] >= [1, 2, 0]:
            return "5.11"
    except ImportError:
        pass

    return "5.10"


def parse_options():
    usage = "usage: %(prog)s [options] definition_file.xml"
    parser = argparse.ArgumentParser(usage=usage)
    # only some options are on by default

    oscap_oval_version = get_openscap_supported_oval_version()

    parser.add_argument("--oval_version",
                        default=oscap_oval_version,
                        dest="oval_version", action="store",
                        help="OVAL version to use. Example: 5.11, 5.10, ... "
                             "If not supplied the highest version supported by "
                             "openscap will be used: %s" % (oscap_oval_version))
    parser.add_argument("-q", "--quiet", "--silent", default=False,
                        action="store_true", dest="silent_mode",
                        help="Don't show any output when testing OVAL files")
    parser.add_argument("xmlfile", metavar="XMLFILE", help="OVAL XML file")
    args = parser.parse_args()

    return args


def main():
    global definitions
    global tests
    global objects
    global states
    global variables
    global silent_mode

    args = parse_options()
    silent_mode = args.silent_mode
    oval_version = args.oval_version

    testfile = args.xmlfile
    header = oval_generated_header("testoval.py", oval_version, "0.0.1")
    testfile = find_testfile_or_exit(testfile)
    yaml_env = dict()
    body = read_ovaldefgroup_file(testfile, yaml_env)

    defname = _add_elements(body, header, yaml_env)
    if defname is None:
        print("Error while evaluating oval: defname not set; missing "
              "definitions section?")
        sys.exit(1)

    ovaltree = ET.fromstring(header + footer)

    # append each major element type, if it has subelements
    for element in [definitions, tests, objects, states, variables]:
        if list(element):
            ovaltree.append(element)

    # re-map all the element ids from meaningful names to meaningless
    # numbers
    testtranslator = IDTranslator("scap-security-guide.testing")
    ovaltree = testtranslator.translate(ovaltree)
    (ovalfile, fname) = tempfile.mkstemp(prefix=defname, suffix=".xml")
    os.write(ovalfile, ET.tostring(ovaltree))
    os.close(ovalfile)

    cmd = ['oscap', 'oval', 'eval', '--results', fname + '-results', fname]
    if not silent_mode:
        print("Evaluating with OVAL tempfile: " + fname)
        print("OVAL Schema Version: %s" % oval_version)
        print("Writing results to: " + fname + "-results")
        print("Running command: %s\n" % " ".join(cmd))

    oscap_child = subprocess.Popen(cmd, stdout=subprocess.PIPE)
    cmd_out = oscap_child.communicate()[0]

    if isinstance(cmd_out, bytes):
        cmd_out = cmd_out.decode('utf-8')

    if not silent_mode:
        print(cmd_out, file=sys.stderr)

    if oscap_child.returncode != 0:
        if not silent_mode:
            print("Error launching 'oscap' command: return code %d" % oscap_child.returncode)
        sys.exit(2)

    if 'false' in cmd_out or 'error' in cmd_out:
        # at least one from the evaluated OVAL definitions evaluated to
        # 'false' result, exit with '1' to indicate OVAL scan FAIL result
        sys.exit(1)

    # perhaps delete tempfile?
    definitions = ET.Element("oval:definitions")
    tests = ET.Element("oval:tests")
    objects = ET.Element("oval:objects")
    states = ET.Element("oval:states")
    variables = ET.Element("oval:variables")

    # 'false' keyword wasn't found in oscap's command output
    # exit with '0' to indicate OVAL scan TRUE result
    sys.exit(0)
