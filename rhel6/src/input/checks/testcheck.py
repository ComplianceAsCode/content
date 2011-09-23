#!/usr/bin/python

import sys, os, tempfile, subprocess
import idtranslate
import lxml.etree as ET

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
        http://oval.mitre.org/XMLSchema/oval-common-5 oval-common-schema.xsd">'''
footer = '</oval_definitions>'

id_keywords = (
    "definition",
    "test",
    "object",
    "state",
    "variable",
)

def strip_namespace(tag):
    return tag.split("}")[-1]

def main():
    if len(sys.argv) < 2:
        print "Provide the name of an XML file, which contains the definition (and dependencies) to test."
        sys.exit(1)

    with open( sys.argv[1], 'r') as f:
        body = f.read()

    # parse new file(string) as an etree, so we can arrange elements appropriately 
    tree = ET.fromstring(header + body + footer)
    definitions = ET.Element("definitions")
    tests = ET.Element("tests")
    objects = ET.Element("objects")
    states = ET.Element("states")
    variables = ET.Element("variables")

    for childnode in tree.findall("./{http://oval.mitre.org/XMLSchema/oval-definitions-5}def-group/*"):
        if childnode.tag == ("{http://oval.mitre.org/XMLSchema/oval-definitions-5}definition"): 
            definitions.append(childnode)
            defname = childnode.get("id")
        if childnode.tag.endswith("_test"): tests.append(childnode)
        if childnode.tag.endswith("_object"): objects.append(childnode)
        if childnode.tag.endswith("_state"): states.append(childnode)
        if childnode.tag.endswith("_variable"): variables.append(childnode)

    tree = ET.fromstring(header + footer)
    tree.append(definitions)
    tree.append(tests)
    tree.append(objects)
    tree.append(states)
    tree.append(variables)

    idmapping = idtranslate.idtranslate("testing.ini", "oval:scap-security-guide.testing")
    # this needs to be refactored to idtranslate 
    for element in tree.getiterator():
        if element.get("id"):
            element.set("id", idmapping.assign_id(element.tag, element.get("id")))
    # needs to handle all _ref attributes, too

    # the ini file is not tracked by git, see .gitignore
    idmapping.save()

    (ovalfile, fname) = tempfile.mkstemp(prefix=defname)
    os.write(ovalfile, ET.tostring(tree))
#    oscap oval eval --id "defname" --results somefile  generatedINPUTfile.xml
# delete tempfile?

    sys.exit(0)

if __name__ == "__main__":
    main()


