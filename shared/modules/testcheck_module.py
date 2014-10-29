import sys
import os
import tempfile
import subprocess
import lxml.etree as ET

# always use /shared/transforms' version of idtranslate.py
from transforms import idtranslate

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
        <oval:product_name>testcheck.py</oval:product_name>
        <oval:product_version>0.0.1</oval:product_version>
        <oval:schema_version>5.10</oval:schema_version>
        <oval:timestamp>2011-09-23T13:44:00</oval:timestamp>
    </generator>'''
footer = '</oval_definitions>'

ovalns = "{http://oval.mitre.org/XMLSchema/oval-definitions-5}"

# globals, to make recursion easier in case we encounter extend_definition
definitions = ET.Element("definitions")
tests = ET.Element("tests")
objects = ET.Element("objects")
states = ET.Element("states")
variables = ET.Element("variables")


def add_oval_elements(body):
    """add oval elements to the global Elements defined above"""

    tree = ET.fromstring(header + body + footer)
    tree = replace_external_vars(tree)
    # parse new file(string) as an etree, so we can arrange elements
    # appropriately
    for childnode in tree.findall("./" + ovalns + "def-group/*"):
        # print "childnode.tag is " + childnode.tag
        if childnode.tag is ET.Comment:
            continue
        if childnode.tag == (ovalns + "definition"):
            definitions.append(childnode)
            defname = childnode.get("id")
            # extend_definition is a special case:  must include a whole other
            # definition
            for defchild in childnode.findall(".//" + ovalns +
                                              "extend_definition"):
                defid = defchild.get("definition_ref")
                includedbody = read_ovaldefgroup_file(defid+".xml")
                # recursively add the elements in the other file
                add_oval_elements(includedbody)
        if childnode.tag.endswith("_test"):
            tests.append(childnode)
        if childnode.tag.endswith("_object"):
            objects.append(childnode)
        if childnode.tag.endswith("_state"):
            states.append(childnode)
        if childnode.tag.endswith("_variable"):
            variables.append(childnode)
    return defname


def replace_external_vars(tree):
    """replace external_variables with local_variables, so the definition can be
       tested independently of an XCCDF file"""

    # external_variable is a special case: we turn it into a local_variable so
    # we can test
    for node in tree.findall(".//"+ovalns+"external_variable"):
        print "external_variable with id : " + node.get("id")
        extvar_id = node.get("id")
        # for envkey, envval in os.environ.iteritems():
        #     print envkey + " = " + envval
        # sys.exit()
        if extvar_id not in os.environ.keys():
            sys.exit("external_variable specified, but no value provided via "
                     + "environment variable")
        # replace tag name: external -> local
        node.tag = ovalns + "local_variable"
        literal = ET.Element("literal_component")
        literal.text = os.environ[extvar_id]
        node.append(literal)
        # TODO: assignment of external_variable via environment vars, for
        # testing
    return tree


def read_ovaldefgroup_file(testfile):
    """read oval files"""
    with open(testfile, 'r') as test_file:
        body = test_file.read()
    return body


def main():
    global definitions
    global tests
    global objects
    global states
    global variables

    if len(sys.argv) < 2:
        print ("Provide the name of an XML file, which contains" +
               " the definition to test.")
        sys.exit(1)

    for testfile in sys.argv[1:]:
        body = read_ovaldefgroup_file(testfile)
        defname = add_oval_elements(body)
        ovaltree = ET.fromstring(header + footer)
        # append each major element type, if it has subelements
        for element in [definitions, tests, objects, states, variables]:
            if element.getchildren():
                ovaltree.append(element)
        # re-map all the element ids from meaningful names to meaningless
        # numbers
        testtranslator = idtranslate.idtranslator("testids.ini",
                                                  "scap-security-guide.testing")
        ovaltree = testtranslator.translate(ovaltree)
        (ovalfile, fname) = tempfile.mkstemp(prefix=defname, suffix=".xml")
        os.write(ovalfile, ET.tostring(ovaltree))
        os.close(ovalfile)
        print "Evaluating with OVAL tempfile : " + fname
        print "Writing results to : " + fname + "-results"
        subprocess.call("oscap oval eval --results " + fname
                        + "-results " + fname, shell=True)
        # perhaps delete tempfile?
        definitions = ET.Element("definitions")
        tests = ET.Element("tests")
        objects = ET.Element("objects")
        states = ET.Element("states")
        variables = ET.Element("variables")

    sys.exit(0)
