#!/usr/bin/python

import sys, os 
import lxml.etree as ET

header = '''<?xml version="1.0" encoding="UTF-8"?>
<oval_definitions
	xmlns="http://oval.mitre.org/XMLSchema/oval-definitions-5"
	xmlns:oval="http://oval.mitre.org/XMLSchema/oval-common-5"
	xmlns:ind="http://oval.mitre.org/XMLSchema/oval-definitions-5#independent"
	xmlns:unix="http://oval.mitre.org/XMLSchema/oval-definitions-5#unix"
	xmlns:linux="http://oval.mitre.org/XMLSchema/oval-definitions-5#linux"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xsi:schemaLocation="http://oval.mitre.org/XMLSchema/oval-common-5 oval-common-schema.xsd
		http://oval.mitre.org/XMLSchema/oval-definitions-5 oval-definitions-schema.xsd
		http://oval.mitre.org/XMLSchema/oval-definitions-5#independent independent-definitions-schema.xsd
		http://oval.mitre.org/XMLSchema/oval-definitions-5#unix unix-definitions-schema.xsd
		http://oval.mitre.org/XMLSchema/oval-definitions-5#linux linux-definitions-schema.xsd">
	<generator>
		<oval:product_name>python</oval:product_name>
		<oval:product_version>2.6.6</oval:product_version>
		<oval:schema_version>5.10</oval:schema_version>
		<oval:timestamp>2011-09-21T13:44:00</oval:timestamp>
	</generator>'''

footer = '</oval_definitions>'

# append new child ONLY if it's not a duplicate 
def append(element, newchild):
    newid = newchild.get("id")
    existing = element.find(".//*[@id='" + newid + "']")
    if existing is not None:
        sys.stderr.write( "Notification: this ID is used more than once and should represent equivalent elements: " + newid + "\n")
    else:
        element.append(newchild)

def main():
	if len(sys.argv) < 2:
		print "Provide a directory name, which contains the checks."
		sys.exit(1)

        # concatenate all XML files in the checks directory, to create the document body
	body = ""
	for filename in os.listdir(sys.argv[1]):
		if filename.endswith(".xml"):
			with open( sys.argv[1] + "/" + filename, 'r') as f:
				body = body + f.read()
   
	# parse new file(string) as an ElementTree, so we can reorder elements appropriately 
	tree = ET.fromstring(header + body + footer)
	definitions = ET.Element("definitions")
	tests = ET.Element("tests")
	objects = ET.Element("objects")
	states = ET.Element("states")
	variables = ET.Element("variables")

	for childnode in tree.findall("./{http://oval.mitre.org/XMLSchema/oval-definitions-5}def-group/*"):
                if childnode.tag is ET.Comment: continue
		if childnode.tag.endswith("definition"): append(definitions, childnode) 
		if childnode.tag.endswith("_test"): append(tests, childnode)
		if childnode.tag.endswith("_object"): append(objects, childnode) 
		if childnode.tag.endswith("_state"): append(states, childnode) 
		if childnode.tag.endswith("_variable"): append(variables, childnode) 

	tree = ET.fromstring(header + footer)
	tree.append(definitions)
	tree.append(tests)
	tree.append(objects)
	tree.append(states)
	tree.append(variables)

	ET.dump(tree) 
	sys.exit(0)

if __name__ == "__main__":
    main()

