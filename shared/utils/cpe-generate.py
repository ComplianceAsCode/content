#!/usr/bin/python2

import fnmatch
import sys
import os
import lxml.etree as ET

# Put shared python modules in path
sys.path.insert(0, os.path.join(
        os.path.dirname(os.path.dirname(os.path.realpath(__file__))),
        "modules"))
import idtranslate_module as idtranslate

# This script requires two arguments: an OVAL file and a CPE dictionary file.
# It is designed to extract any inventory definitions and the tests, states,
# objects and variables it references and then write them into a standalone
# OVAL CPE file, along with a synchronized CPE dictionary file.

oval_ns = "http://oval.mitre.org/XMLSchema/oval-definitions-5"
xccdf_ns = "http://checklists.nist.gov/xccdf/1.1"
cpe_ns = "http://cpe.mitre.org/dictionary/2.0"


def parse_xml_file(xmlfile):
    with open(xmlfile, 'r') as xml_file:
        filestring = xml_file.read()
        tree = ET.fromstring(filestring)
    return tree


def extract_subelement(objects, sub_elem_type):
    for obj in objects:
        for subelement in obj.getiterator():
            if subelement.get(sub_elem_type):
                sub_element = subelement.get(sub_elem_type)
                return sub_element


def extract_env_obj(objects, local_var):
    for obj in objects:
        env_id = extract_subelement(local_var, 'object_ref')
        if env_id == obj.get('id'):
            return obj


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
        print ("This script extracts these definitions and writes them" +
               " to STDOUT.")
        sys.exit(1)

    product = sys.argv[1]
    idname = sys.argv[2]
    cpeoutdir = sys.argv[3]
    ovalfile = sys.argv[4]
    cpedictfile = sys.argv[5]

    # parse oval file
    ovaltree = parse_xml_file(ovalfile)

    # extract inventory definitions
    # making (dubious) assumption that all inventory defs are CPE
    defs = ovaltree.find("./{%s}definitions" % oval_ns)
    inventory_defs = defs.findall(".//{%s}definition[@class='inventory']"
                                  % oval_ns)
    # Keep the list of 'id' attributes from untranslated inventory def elements
    inventory_defs_id_attrs = []

    defs.clear()
    [defs.append(inventory_def) for inventory_def in inventory_defs]
    # Fill in that list
    inventory_defs_id_attrs = \
        [inventory_def.get("id") for inventory_def in inventory_defs]

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
    env_objects = extract_referred_nodes(objects, objects, "id")
    objects.clear()
    [objects.append(cpe_object) for cpe_object in cpe_objects]

    # if any subelements in an object contain var_ref, return it here
    local_var_ref = extract_subelement(objects, 'var_ref')

    variables = ovaltree.find("./{%s}variables" % oval_ns)
    if variables is not None:
        cpe_variables = extract_referred_nodes(tests, variables, "var_ref")
        local_variables = extract_referred_nodes(variables, variables, "id")
        if cpe_variables:
            variables.clear()
            [variables.append(cpe_variable) for cpe_variable in cpe_variables]
        elif local_var_ref:
            for local_var in local_variables:
                if local_var.get('id') == local_var_ref:
                    variables.clear()
                    variables.append(local_var)
                    env_obj = extract_env_obj(env_objects, local_var)
                    objects.append(env_obj)
        else:
            ovaltree.remove(variables)

    # turn IDs into meaningless numbers
    translator = idtranslate.idtranslator(idname)
    ovaltree = translator.translate(ovaltree)

    newovalfile = idname + "-" + product + "-" + os.path.basename(ovalfile)
    newovalfile = newovalfile.replace("oval-unlinked", "cpe-oval")
    ET.ElementTree(ovaltree).write(cpeoutdir + "/" + newovalfile)

    # replace and sync IDs, href filenames in input cpe dictionary file
    cpedicttree = parse_xml_file(cpedictfile)
    newcpedictfile = idname + "-" + os.path.basename(cpedictfile)
    for check in cpedicttree.findall(".//{%s}check" % cpe_ns):
        checkhref = check.get("href")
        # If CPE OVAL references another OVAL file
        if checkhref == 'filename':
            # Sanity check -- Verify the referenced OVAL is truly defined
            # somewhere in the (sub)directory tree below CWD. In correct
            # scenario is should be located:
            # * either in input/oval/*.xml
            # * or copied by former run of "combine-ovals.py" script from
            #   shared/ directory into build/ subdirectory
            refovalfilename = check.text
            refovalfilefound = False
            for dirpath, dirnames, filenames in os.walk(os.curdir, topdown=True):
                # Case when referenced OVAL file exists
                for location in fnmatch.filter(filenames, refovalfilename + '.xml'):
                    refovalfilefound = True
                    break                     # break from the inner for loop

                if refovalfilefound:
                    break                     # break from the outer for loop

            shared_dir = \
                os.path.dirname(os.path.dirname(os.path.realpath(__file__)))
            if shared_dir is not None:
                for dirpath, dirnames, filenames in os.walk(shared_dir, topdown=True):
                    # Case when referenced OVAL file exists
                    for location in fnmatch.filter(filenames, refovalfilename + '.xml'):
                        refovalfilefound = True
                        break                     # break from the inner for loop

                    if refovalfilefound:
                        break                     # break from the outer for loop

            # Referenced OVAL doesn't exist in the subdirtree below CWD:
            # * there's either typo in the refenced OVAL filename, or
            # * is has been forgotten to be placed into input/oval, or
            # * the <platform> tag of particular shared/ OVAL wasn't modified
            #   to include the necessary referenced file.
            # Therefore display an error and exit with failure in such cases
            if not refovalfilefound:
                error_msg = "\n\tError: Can't locate \"%s\" OVAL file in the \
                \n\tlist of OVAL checks for this product! Exiting..\n" % refovalfilename
                sys.stderr.write(error_msg)
                # sys.exit(1)
        check.set("href", os.path.basename(newovalfile))

        # Sanity check to verify if inventory check OVAL id is present in the
        # list of known "id" attributes of inventory definitions. If not it
        # means provided ovalfile (sys.argv[1]) doesn't contain this OVAL
        # definition (it wasn't included due to <platform> tag restrictions)
        # Therefore display an error and exit with failure, since otherwise
        # we might end up creating invalid $(ID)-$(PROD)-cpe-oval.xml file
        if check.text not in inventory_defs_id_attrs:
            error_msg = "\n\tError: Can't locate \"%s\" definition in \"%s\". \
            \n\tEnsure <platform> element is configured properly for \"%s\".  \
            \n\tExiting..\n" % (check.text, ovalfile, check.text)
            sys.stderr.write(error_msg)
            # sys.exit(1)

        # Referenced OVAL checks passed both of the above sanity tests
        check.text = translator.generate_id("{" + oval_ns + "}definition", check.text)

    ET.ElementTree(cpedicttree).write(cpeoutdir + '/' + newcpedictfile)

    sys.exit(0)

if __name__ == "__main__":
    main()
