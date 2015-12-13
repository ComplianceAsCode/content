#!/usr/bin/python2

import sys
import os
import errno
import string
import re
from optparse import OptionParser
import lxml.etree as ET

xmlns = {
    "o": "http://oval.mitre.org/XMLSchema/oval-definitions-5",
    "xsi": "http://www.w3.org/2001/XMLSchema-instance",
    "oval": "http://oval.mitre.org/XMLSchema/oval-common-5",
    "unix": "http://oval.mitre.org/XMLSchema/oval-definitions-5#unix",
    "linux": "http://oval.mitre.org/XMLSchema/oval-definitions-5#linux",
    "ind": "http://oval.mitre.org/XMLSchema/oval-definitions-5#independent",
}


def parse_options():
    usage = "usage: %prog [options] input_file [input_file . . .]"
    parser = OptionParser(usage=usage, version="%prog ")
    parser.add_option("-o", dest="out_dname", default="/tmp/checks",
                      help="name of output directory. If unspecified, default is a new directory \"/tmp/checks\"")
    (options, args) = parser.parse_args()
    if len(args) < 1:
        parser.print_help()
        sys.exit(1)
    return (options, args)


# look for any occurrences of these attributes, and then gather the node
# referenced
def gather_refs(element, defn):
    items_with_refs = element.findall(".//*[@test_ref]")
    items_with_refs.extend(element.findall(".//*[@var_ref]"))
    items_with_refs.extend(element.findall(".//*[@state_ref]"))
    items_with_refs.extend(element.findall(".//*[@object_ref]"))
    for item in items_with_refs:
        for attr in item.attrib.keys():
            if attr.endswith("_ref"):
                ident = item.get(attr)
                referenced_item = id_element_map[ident]
                if referenced_item not in def_reflist_map[defn]:
                    def_reflist_map[defn].append(referenced_item)
                gather_refs(referenced_item, defn)


def gather_refs_for_defs(tree):
    defn_elements = tree.getiterator("{" + xmlns["o"] + "}definition")
    # initialize dictionary, which maps definitions to a list of those things
    # it references
    for defn in defn_elements:
        def_reflist_map[defn] = []
    for defn in defn_elements:
        gather_refs(defn, defn)


def output_checks(dname):
    try:
        os.makedirs(dname)
    except OSError, e:
        if e.errno != errno.EEXIST:
            raise
    # use namespace prefix-to-uri defined above, to provide abbreviations
    for prefix, uri in xmlns.iteritems():
        ET.register_namespace(prefix, uri)

    os.chdir(dname)
    for defn, reflist in def_reflist_map.iteritems():
        # create filename from id attribute, get rid of punctuation
        fname = defn.get("id")
        fname = fname.translate(string.maketrans("", ""),
                                string.punctuation) + ".xml"
        # output definition, and then all elements that the definition
        # references
        outstring = ET.tostring(defn)
        for ref in reflist:
            outstring = outstring + ET.tostring(ref)
        with open(fname, 'w+') as xml_file:
            # giant kludge: get rid of per-node namespace attributes
            outstring = re.sub(r"\s+xmlns[^\s]+ ", " ", outstring)
            xml_file.write("<def-group>\n" + outstring + "</def-group>")
    return


def gather_ids_for_elements(tree):
    for element in tree.findall(".//*[@id]"):
        id_element_map[element.get("id")] = element

id_element_map = {}    # map of ids to elements
def_reflist_map = {}   # map of definitions to lists of elements it references


def main():
    (options, args) = parse_options()
    for fname in args:
        tree = ET.parse(fname)
        # ET.dump(tree)
        gather_ids_for_elements(tree)
        gather_refs_for_defs(tree)
        output_checks(options.out_dname)
        sys.exit(0)

if __name__ == "__main__":
    main()
