#!/usr/bin/python3

from __future__ import print_function

import fnmatch
import sys
import os
import ssg
import argparse

import ssg.build_cpe
import ssg.id_translate
import ssg.products
import ssg.xml
import ssg.yaml
import ssg.oval_object_model
from ssg.constants import XCCDF12_NS

# This script requires two arguments: an OVAL file and a CPE dictionary file.
# It is designed to extract any inventory definitions and the tests, states,
# objects and variables it references and then write them into a standalone
# OVAL CPE file, along with a synchronized CPE dictionary file.

oval_ns = "http://oval.mitre.org/XMLSchema/oval-definitions-5"
cpe_ns = "http://cpe.mitre.org/dictionary/2.0"


def parse_args():
    p = argparse.ArgumentParser(
        description="This script takes as input an OVAL file and a CPE dictionary file "
        "and extracts any inventory definitions and the tests, states objects and variables it "
        "references, and then write them into a standalone OVAL CPE file, along with "
        "a synchronized CPE dictionary file."
    )
    p.add_argument(
        "--product-yaml",
        help="YAML file with information about the product we are building. "
        "e.g.: ~/scap-security-guide/rhel7/product.yml "
        "needed for autodetection of profile root"
    )
    p.add_argument(
        "idname",
        help="Identifier prefix"
    )
    p.add_argument(
        "cpeoutdir",
        help="Artifact output directory"
    )
    p.add_argument(
        "shorthandfile",
        help="shorthand xml to generate the CPE dictionary from"
    )
    p.add_argument(
        "ovalfile",
        help="OVAL file to process"
    )
    p.add_argument(
        "--cpe-items-dir",
        help="the directory where compiled CPE items are stored"
    )
    return p.parse_args()


def main():
    args = parse_args()

    # Keep the list of 'id' attributes from untranslated inventory def elements
    inventory_defs_id_attrs = []

    # parse oval file
    oval_document = ssg.oval_object_model.load_oval_document(ssg.xml.parse_file(args.ovalfile))
    oval_document.product_name = __file__

    # extract inventory definitions
    # making (dubious) assumption that all inventory defs are CPE
    references_to_keep = ssg.oval_object_model.OVALDefinitionReference()
    for oval_def in oval_document.definitions.values():
        if oval_def.class_ != "inventory":
            continue
        references_to_keep += oval_document.get_all_references_of_definition(oval_def.id_)
        inventory_defs_id_attrs.append(oval_def.id_)

    oval_document.keep_referenced_components(references_to_keep)

    # turn IDs into meaningless numbers
    translator = ssg.id_translate.IDTranslator(args.idname)
    oval_document = translator.translate_oval_document(oval_document, store_defname=True)

    product_yaml = ssg.products.load_product_yaml(args.product_yaml)
    product = product_yaml["product"]
    newovalfile = args.idname + "-" + product + "-" + os.path.basename(args.ovalfile)
    newovalfile = newovalfile.replace("cpe-oval-unlinked", "cpe-oval")

    oval_document.save_as_xml(os.path.join(args.cpeoutdir, newovalfile))

    # Lets scrape the shorthand for the list of platforms referenced
    benchmark_cpe_names = set()
    shorthandtree = ssg.xml.parse_file(args.shorthandfile)
    for platform in shorthandtree.findall(".//{%s}platform" % XCCDF12_NS):
        cpe_name = platform.get("idref")
        # skip CPE AL platforms (they are handled later)
        # this is temporary solution until we get rid of old type of platforms in the benchmark
        if cpe_name.startswith("#"):
            continue
        benchmark_cpe_names.add(cpe_name)
    # add CPE names used by factref elements in CPEAL platforms
    for factref in shorthandtree.findall(
            ".//ns1:fact-ref", {"ns1":ssg.constants.PREFIX_TO_NS["cpe-lang"]}):
        cpe_factref_name = factref.get("name")
        benchmark_cpe_names.add(cpe_factref_name)

    product_cpes = ssg.build_cpe.ProductCPEs()
    product_cpes.load_cpes_from_directory_tree(args.cpe_items_dir, product_yaml)
    cpe_list = ssg.build_cpe.CPEList()
    for cpe_name in benchmark_cpe_names:
        cpe_list.add(product_cpes.get_cpe(cpe_name))

    cpedict_filename = "ssg-" + product + "-cpe-dictionary.xml"
    cpedict_path = os.path.join(args.cpeoutdir, cpedict_filename)
    cpe_list.to_file(cpedict_path, newovalfile)

    # replace and sync IDs, href filenames in input cpe dictionary file
    cpedicttree = ssg.xml.parse_file(cpedict_path)
    for check in cpedicttree.findall(".//{%s}check" % cpe_ns):
        checkhref = check.get("href")
        # If CPE OVAL references another OVAL file
        if checkhref == 'filename':
            # Sanity check -- Verify the referenced OVAL is truly defined
            # somewhere in the (sub)directory tree below CWD. In correct
            # scenario is should be located:
            # * either in input/oval/*.xml
            # * or copied by former run of "combine_ovals.py" script from
            #   shared/ directory into build/ subdirectory
            refovalfilename = check.text
            refovalfilefound = False
            for dirpath, dirnames, filenames in os.walk(os.curdir, topdown=True):
                dirnames.sort()
                filenames.sort()
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
                    dirnames.sort()
                    filenames.sort()
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
            \n\tExiting..\n" % (check.text, args.ovalfile, check.text)
            sys.stderr.write(error_msg)
            sys.exit(1)

        # Referenced OVAL checks passed both of the above sanity tests
        check.text = translator.generate_id("{" + oval_ns + "}definition", check.text)

    ssg.xml.ElementTree.ElementTree(cpedicttree).write(cpedict_path)

    sys.exit(0)


if __name__ == "__main__":
    main()
