#!/usr/bin/python3

from __future__ import print_function

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
        "cpeoutdir",
        help="Artifact output directory"
    )
    p.add_argument(
        "xccdfFile",
        help="XCCDF file to generate the CPE dictionary from"
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


def process_cpe_oval(oval_file_path, used_cpe_oval_def_ids):
    oval_document = ssg.oval_object_model.load_oval_document(ssg.xml.parse_file(oval_file_path))
    oval_document.product_name = os.path.basename(__file__)

    references_to_keep = ssg.oval_object_model.OVALDefinitionReference()
    for oval_def in oval_document.definitions.values():
        if oval_def.class_ != "inventory":
            continue
        references_to_keep += oval_document.get_all_references_of_definition(oval_def.id_)

    oval_document.keep_referenced_components(references_to_keep)

    translator = ssg.id_translate.IDTranslator("ssg")
    oval_document = translator.translate_oval_document(oval_document, store_defname=True)

    return oval_document


def get_benchmark_cpe_names(xccdf_el_root_xml):
    benchmark_cpe_names = set()

    for platform in xccdf_el_root_xml.findall(".//{%s}platform" % XCCDF12_NS):
        cpe_name = platform.get("idref")
        # skip CPE AL platforms (they are handled later)
        # this is temporary solution until we get rid of old type of platforms in the benchmark
        if cpe_name.startswith("#"):
            continue
        benchmark_cpe_names.add(cpe_name)

    for fact_ref in xccdf_el_root_xml.findall(
        ".//{%s}fact-ref" % ssg.constants.PREFIX_TO_NS["cpe-lang"]
    ):
        cpe_fact_ref_name = fact_ref.get("name")
        benchmark_cpe_names.add(cpe_fact_ref_name)
    return benchmark_cpe_names


def load_cpe_dictionary(benchmark_cpe_names, product_yaml, cpe_items_dir):
    product_cpes = ssg.build_cpe.ProductCPEs()
    product_cpes.load_cpes_from_directory_tree(cpe_items_dir, product_yaml)
    cpe_list = ssg.build_cpe.CPEList()
    for cpe_name in benchmark_cpe_names:
        cpe_item = product_cpes.get_cpe(cpe_name)
        cpe_list.add(cpe_item)
    return cpe_list


def get_all_cpe_oval_def_ids(xccdf_el_root_xml, cpe_dict):
    out = set()

    for cpe_item in cpe_dict.cpe_items:
        out.add(cpe_item.check_id)

    for check_fact_ref in xccdf_el_root_xml.findall(
        ".//{%s}check-fact-ref" % ssg.constants.PREFIX_TO_NS["cpe-lang"]
    ):
        out.add(check_fact_ref.get("id-ref"))
    return out


def main():
    args = parse_args()

    product_yaml = ssg.products.load_product_yaml(args.product_yaml)
    product = product_yaml["product"]

    oval_filename = "ssg-{}-{}".format(product, os.path.basename(args.ovalfile))
    oval_filename = oval_filename.replace("cpe-oval-unlinked", "cpe-oval")
    oval_file_path = os.path.join(args.cpeoutdir, oval_filename)

    cpe_dict_filename = "ssg-{}-cpe-dictionary.xml".format(product)
    cpe_dict_path = os.path.join(args.cpeoutdir, cpe_dict_filename)

    xccdf_el_root_xml = ssg.xml.parse_file(args.xccdfFile)

    benchmark_cpe_names = get_benchmark_cpe_names(xccdf_el_root_xml)
    cpe_dict = load_cpe_dictionary(benchmark_cpe_names, product_yaml, args.cpe_items_dir)
    cpe_dict.translate_cpe_oval_def_ids()
    cpe_dict.to_file(cpe_dict_path, oval_filename)

    used_cpe_oval_def_ids = get_all_cpe_oval_def_ids(xccdf_el_root_xml, cpe_dict)
    oval_document = process_cpe_oval(args.ovalfile, used_cpe_oval_def_ids)
    oval_document.save_as_xml(oval_file_path)

    sys.exit(0)


if __name__ == "__main__":
    main()
