import sys
import os
import re
import tempfile
import subprocess
import datetime
import lxml.etree as ET
from ConfigParser import SafeConfigParser

import idtranslate_module as idtranslate

SHARED_OVAL = re.sub('shared.*', 'shared', __file__) + '/oval/'
timestamp = datetime.datetime.utcnow().strftime("%Y-%m-%dT%H:%M:%S")


conf_file = re.sub('shared.*', '', __file__) + '/build/oval.config'
footer = '</oval_definitions>'
ovalns = "{http://oval.mitre.org/XMLSchema/oval-definitions-5}"

# globals, to make recursion easier in case we encounter extend_definition
definitions = ET.Element("definitions")
tests = ET.Element("tests")
objects = ET.Element("objects")
states = ET.Element("states")
variables = ET.Element("variables")

def _header(schema_version):
    header = '''<?xml version="1.0" encoding="UTF-8"?>
<oval_definitions
    xmlns="http://oval.mitre.org/XMLSchema/oval-definitions-5"
    xmlns:unix="http://oval.mitre.org/XMLSchema/oval-definitions-5#unix"
    xmlns:ind="http://oval.mitre.org/XMLSchema/oval-definitions-5#independent"
    xmlns:linux="http://oval.mitre.org/XMLSchema/oval-definitions-5#linux"
    xmlns:oval="http://oval.mitre.org/XMLSchema/oval-common-5"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://oval.mitre.org/XMLSchema/oval-definitions-5#unix unix-definitions-schema.xsd
        http://oval.mitre.org/XMLSchema/oval-definitions-5#independent independent-definitions-schema.xsd
        http://oval.mitre.org/XMLSchema/oval-definitions-5#linux linux-definitions-schema.xsd
        http://oval.mitre.org/XMLSchema/oval-definitions-5 oval-definitions-schema.xsd
        http://oval.mitre.org/XMLSchema/oval-common-5 oval-common-schema.xsd">
       <generator>
        <oval:product_name>testoval.py</oval:product_name>
        <oval:product_version>0.0.1</oval:product_version>
        <oval:schema_version>%s</oval:schema_version>
        <oval:timestamp>%s</oval:timestamp>
    </generator>''' % (schema_version, timestamp)

    return header


def parse_conf_file(conf_file):
    parser = SafeConfigParser()
    parser.read(conf_file)
    oval_version = None

    for section in parser.sections():
        for name, setting in parser.items(section):
            setting = re.sub('.;:', ',', re.sub(' ', '', setting))
            if not oval_version and name == 'oval_version':
                oval_version = setting

    if oval_version is None:
        print 'ERROR! The setting returned a value of \'%s\'!' % oval_version
        sys.exit(1)

    return oval_version


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
    for childnode in tree.findall("./" + ovalns + "def-group/*"):
        # print "childnode.tag is " + childnode.tag
        if childnode.tag is ET.Comment:
            continue
        if childnode.tag == (ovalns + "definition"):
            append(definitions, childnode)
            defname = childnode.get("id")
            # extend_definition is a special case:  must include a whole other
            # definition
            for defchild in childnode.findall(".//" + ovalns +
                                              "extend_definition"):
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
    for node in tree.findall(".//"+ovalns+"external_variable"):
        print ("External_variable with id : " + node.get("id"))
        extvar_id = node.get("id")
        # for envkey, envval in os.environ.iteritems():
        #     print envkey + " = " + envval
        # sys.exit()
        if extvar_id not in os.environ.keys():
            print ("External_variable specified, but no value provided via "
                  + "environment variable")
            sys.exit(2)
        # replace tag name: external -> local
        node.tag = ovalns + "local_variable"
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


def usage():
    """Display script usage and exit"""
    print ("Usage: " + sys.argv[0] + " [-q | --quiet | --silent] definition_file.xml")
    sys.exit(2)


def main():
    global definitions
    global tests
    global objects
    global states
    global variables
    global silent_mode

    silent_mode = False
    silent_mode_options = ['-q', '--quiet', '--silent']

    if len(sys.argv) < 2 or len(sys.argv) > 3:
        print ("Provide the name of an XML file, which contains" +
               " the definition to test.")
        usage()

    if len(sys.argv) == 3 and sys.argv[1] in silent_mode_options:
        if sys.argv[2].rfind('.xml') != -1:
            silent_mode = True
            sys.argv.pop(1)
        else:
            usage()

    if len(sys.argv) != 2 or sys.argv[1].rfind('.xml') == -1:
        usage()

    if not len(sys.argv) == 4:
        try:
            from openscap import oscap_get_version
            if oscap_get_version() < 1.2:
                schema = 5.10
            else:
                schema = 5.11
        except ImportError:
            schema = parse_conf_file(conf_file)
    else:
        # FUTURE: replace with sys arg
        schema = '5.10'

    testfile = sys.argv[1]
    header = _header(schema)
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
    testtranslator = idtranslate.idtranslator("scap-security-guide.testing")
    ovaltree = testtranslator.translate(ovaltree)
    (ovalfile, fname) = tempfile.mkstemp(prefix=defname, suffix=".xml")
    os.write(ovalfile, ET.tostring(ovaltree))
    os.close(ovalfile)
    if not silent_mode:
        print ("Evaluating with OVAL tempfile : " + fname)
        print ("Writing results to : " + fname + "-results")
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
