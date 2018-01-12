import sys
import os
import re
import argparse
import tempfile
import subprocess
import ssgcommon
import lxml.etree as ET
from ConfigParser import SafeConfigParser

import idtranslate_module as idtranslate

SHARED_OVAL = re.sub('shared.*', 'shared', __file__) + '/checks/oval/'
timestamp = ssgcommon.timestamp


footer = ssgcommon.oval_footer
ovalns = ssgcommon.oval_namespace

try:
    from openscap import oscap_get_version
    if oscap_get_version() < 1.2:
        oval_version = 5.10
    else:
        oval_version = 5.11
except ImportError:
    oval_version = 5.10

# globals, to make recursion easier in case we encounter extend_definition
definitions = ET.Element("definitions")
tests = ET.Element("tests")
objects = ET.Element("objects")
states = ET.Element("states")
variables = ET.Element("variables")


# append new child ONLY if it's not a duplicate
def append(element, newchild):
    newid = newchild.get("id")
    existing = element.find(".//*[@id='" + newid + "']")
    if existing is not None:
        if not silent_mode:
            sys.stderr.write("Notification: this ID is used more than once " +
                             "and should represent equivalent elements: " +
                             newid + "\n")
    else:
        element.append(newchild)


def add_oval_elements(body, header):
    """Add oval elements to the global Elements defined above"""

    tree = ET.fromstring(header + body + footer)
    tree = replace_external_vars(tree)
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
            for defchild in childnode.findall(".//{%s}extend_definition" % ovalns):
                defid = defchild.get("definition_ref")
                extend_ref = find_testfile(defid+".xml")
                includedbody = read_ovaldefgroup_file(extend_ref)
                # recursively add the elements in the other file
                add_oval_elements(includedbody, header)
        if childnode.tag.endswith("_test"):
            append(tests, childnode)
        if childnode.tag.endswith("_object"):
            append(objects, childnode)
        if childnode.tag.endswith("_state"):
            append(states, childnode)
        if childnode.tag.endswith("_variable"):
            append(variables, childnode)
    return defname


def replace_external_vars(tree):
    """Replace external_variables with local_variables, so the definition can be
       tested independently of an XCCDF file"""

    # external_variable is a special case: we turn it into a local_variable so
    # we can test
    for node in tree.findall(".//{%s}external_variable" % ovalns):
        print ("External_variable with id : " + node.get("id"))
        extvar_id = node.get("id")
        # for envkey, envval in os.environ.iteritems():
        #     print envkey + " = " + envval
        # sys.exit()
        if extvar_id not in os.environ.keys():
            print ("External_variable specified, but no value provided via " \
                   "environment variable")
            sys.exit(2)
        # replace tag name: external -> local
        node.tag = "{%s}local_variable" % ovalns
        literal = ET.Element("literal_component")
        literal.text = os.environ[extvar_id]
        node.append(literal)
        # TODO: assignment of external_variable via environment vars, for
        # testing
    return tree


def find_testfile(testfile):
    """Find OVAL files in CWD or shared/oval"""
    for path in ['.', SHARED_OVAL]:
        for root, folder, files in os.walk(path):
            searchfile = root + '/' + testfile
            if not os.path.isfile(searchfile):
                searchfile = ""
            else:
                testfile = searchfile.strip()
                # Most likely found file, exit this loop
                break

    if not os.path.isfile(testfile):
        print ("ERROR: %s does not exist! Please specify a valid OVAL file.") % testfile
        sys.exit(1)

    return testfile


def read_ovaldefgroup_file(testfile):
    """Read oval files"""
    with open(testfile, 'r') as test_file:
        body = test_file.read()
    return body


def parse_options():
    usage = "usage: %(prog)s [options] definition_file.xml"
    parser = argparse.ArgumentParser(usage=usage, version="%(prog)s ")
    # only some options are on by default

    parser.add_argument("--oval_version", default=oval_version,
                        dest="oval_version", action="store",
                        help="OVAL version to use. Example: 5.11, 5.10, ... \
                        [Default: %(default)s]")
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
    header = ssgcommon.oval_generated_header("testoval.py", oval_version, "0.0.1")
    testfile = find_testfile(testfile)
    body = read_ovaldefgroup_file(testfile)
    defname = add_oval_elements(body, header)
    ovaltree = ET.fromstring(header + footer)

    # append each major element type, if it has subelements
    for element in [definitions, tests, objects, states, variables]:
        if element.getchildren():
            ovaltree.append(element)
    # re-map all the element ids from meaningful names to meaningless
    # numbers
    testtranslator = idtranslate.IDTranslator("scap-security-guide.testing")
    ovaltree = testtranslator.translate(ovaltree)
    (ovalfile, fname) = tempfile.mkstemp(prefix=defname, suffix=".xml")
    os.write(ovalfile, ET.tostring(ovaltree))
    os.close(ovalfile)
    if not silent_mode:
        print ("Evaluating with OVAL tempfile: " + fname)
        print ("OVAL Schema Version: %s" % oval_version)
        print ("Writing results to: " + fname + "-results")
    cmd = "oscap oval eval --results " + fname + "-results " + fname
    oscap_child = subprocess.Popen(cmd, stdout=subprocess.PIPE, shell=True)
    cmd_out = oscap_child.communicate()[0]
    if not silent_mode:
        print cmd_out
    if oscap_child.returncode != 0:
        if not silent_mode:
            print ("Error launching 'oscap' command: \n\t" + cmd)
        sys.exit(2)
    if 'false' in cmd_out:
        # at least one from the evaluated OVAL definitions evaluated to
        # 'false' result, exit with '1' to indicate OVAL scan FAIL result
        sys.exit(1)
    # perhaps delete tempfile?
    definitions = ET.Element("definitions")
    tests = ET.Element("tests")
    objects = ET.Element("objects")
    states = ET.Element("states")
    variables = ET.Element("variables")

    # 'false' keyword wasn't found in oscap's command output
    # exit with '0' to indicate OVAL scan TRUE result
    sys.exit(0)
