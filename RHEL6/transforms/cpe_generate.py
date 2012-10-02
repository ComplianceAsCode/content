#!/usr/bin/python

import sys, os, idtranslate
import lxml.etree as ET

# This script requires two arguments: an OVAL file and a CPE dictionary file.
# It is designed to extract any inventory definitions and the tests, states,
# objects and variables it references and then write them into a standalone
# OVAL CPE file, along with a synchronized CPE dictionary file.

oval_ns = "http://oval.mitre.org/XMLSchema/oval-definitions-5"
xccdf_ns = "http://checklists.nist.gov/xccdf/1.1" 
cpe_ns = "http://cpe.mitre.org/dictionary/2.0"

def parse_xml_file(xmlfile):
    with open( xmlfile, 'r') as f:
        filestring = f.read()
        tree = ET.fromstring(filestring)
        #print filestring
    return tree


def extract_referred_nodes(tree_with_refs, tree_with_ids, attrname):
	reflist = []
	elementlist = []
	iter = tree_with_refs.getiterator()
	for element in iter:
		value = element.get(attrname)
		if value is not None:
			reflist.append(value)

	iter = tree_with_ids.getiterator()
	for element in iter:
		if element.get("id") in reflist:
			elementlist.append(element)
	return elementlist


def collect_nodes(tree, reflist):
	elementlist = []
	iter = tree.getiterator()
	for element in iter:
		if element.get("id") in reflist:
			elementlist.append(element)
	return elementlist

def main():
	if len(sys.argv) < 2:
		print "Provide an OVAL file that contains inventory definitions."
		print "This script extracts these definitions and writes them to STDOUT."
		sys.exit(1)

	ovalfile = sys.argv[1]
	cpedictfile = sys.argv[2]
	idname = sys.argv[3]

    # parse oval file
	ovaltree = parse_xml_file(ovalfile)

	# extract inventory definitions
	# making (dubious) assumption that all inventory defs are CPE
	defs = ovaltree.find("./{%s}definitions" % oval_ns)
	inventory_defs = defs.findall(".//{%s}definition[@class='inventory']" % oval_ns)
	defs.clear()
	[defs.append(inventory_def) for inventory_def in inventory_defs]

	tests = ovaltree.find("./{%s}tests" % oval_ns)
	cpe_tests = extract_referred_nodes(defs, tests, "test_ref")
	tests.clear()
	[tests.append(cpe_test) for cpe_test in cpe_tests]

	states = ovaltree.find("./{%s}states" % oval_ns)
	cpe_states = extract_referred_nodes(tests, states, "state_ref")
	states.clear()
	[states.append(cpe_state) for cpe_state in cpe_states]

	objects = ovaltree.find("./{%s}objects" % oval_ns)
	cpe_objects = extract_referred_nodes(tests, objects, "object_ref")
	objects.clear()
	[objects.append(cpe_object) for cpe_object in cpe_objects]

	variables = ovaltree.find("./{%s}variables" % oval_ns)
	cpe_variables = extract_referred_nodes(ovaltree, variables, "var_ref")
	if cpe_variables:
		variables.clear()
		[variables.append(cpe_variable) for cpe_variable in cpe_variables]
	else:
		ovaltree.remove(variables)

	# turn IDs into meaningless numbers
	translator = idtranslate.idtranslator("./output/"+idname+".ini", idname)
	ovaltree = translator.translate(ovaltree)

	newovalfile = ovalfile.replace("oval", "cpe-oval")
	newovalfile = newovalfile.replace("unlinked", idname)
	ET.ElementTree(ovaltree).write(newovalfile)

	# replace and sync IDs, href filenames in input cpe dictionary file
	cpedicttree = parse_xml_file(cpedictfile)
	newcpedictfile = idname + "-" + os.path.basename(cpedictfile)
	for check in cpedicttree.findall(".//{%s}check" % cpe_ns):
		check.set("href",os.path.basename(newovalfile))
		check.text = translator.assign_id("{" + oval_ns + "}definition", check.text)	
	ET.ElementTree(cpedicttree).write("./output/"+newcpedictfile)

	sys.exit(0)

if __name__ == "__main__":
	main()

