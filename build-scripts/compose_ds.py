#!/usr/bin/python3

import argparse
import os
import time
import xml.etree.ElementTree as ET

from ssg.constants import cat_namespace, datastream_namespace, xlink_namespace
import ssg.xml

ID_NS = "org.open-scap"


def parse_args():
    parser = argparse.ArgumentParser(description="Compose an SCAP source data \
        stream from individual SCAP components")
    parser.add_argument("--xccdf", help="XCCDF 1.2 checklist file name")
    parser.add_argument("--oval", help="OVAL file name")
    parser.add_argument("--ocil", help="OCIL file name")
    parser.add_argument("--cpe-dict", help="CPE dictionary file name")
    parser.add_argument("--cpe-oval", help="CPE OVAL file name")
    parser.add_argument(
        "--output", help="Output SCAP source data stream file name")
    return parser.parse_args()


def get_timestamp(file_name):
    source_date_epoch = os.getenv("SOURCE_DATE_EPOCH")
    if source_date_epoch:
        time_sec = float(source_date_epoch)
    else:
        time_sec = os.path.getmtime(file_name)
    timestamp = time.strftime("%Y-%m-%dT%H:%M:%S", time.localtime(time_sec))
    return timestamp


def add_component(
        ds_collection, component_ref_parent, component_file_name,
        dependencies=None):
    component_id = "scap_%s_comp_%s" % (
        ID_NS, os.path.basename(component_file_name))
    component = ET.SubElement(
        ds_collection, "{%s}component" % datastream_namespace)
    component.set("id", component_id)
    component.set("timestamp", get_timestamp(component_file_name))
    component_ref = ET.SubElement(
        component_ref_parent, "{%s}component-ref" % datastream_namespace)
    component_ref_id = "scap_%s_cref_%s" % (
        ID_NS, os.path.basename(component_file_name))
    component_ref.set("id", component_ref_id)
    component_ref.set("{%s}href" % xlink_namespace, "#" + component_id)
    component_root = ET.parse(component_file_name).getroot()
    component.append(component_root)
    if dependencies:
        create_catalog(component_ref, dependencies)


def create_catalog(component_ref, dependencies):
    catalog = ET.SubElement(component_ref, "{%s}catalog" % cat_namespace)
    for dep in dependencies:
        uri = ET.SubElement(catalog, "{%s}uri" % cat_namespace)
        dep_base_name = os.path.basename(dep)
        uri.set("name", dep_base_name)
        uri.set("uri", "#scap_%s_cref_%s" % (ID_NS, dep_base_name))


def compose_ds(
        xccdf_file_name, oval_file_name, ocil_file_name,
        cpe_dict_file_name, cpe_oval_file_name):
    ds_collection = ET.Element(
        "{%s}data-stream-collection" % datastream_namespace)
    name = "from_xccdf_" + os.path.basename(xccdf_file_name)
    ds_collection.set("id", "scap_%s_collection_%s" % (ID_NS, name))
    ds_collection.set("schematron-version", "1.2")
    ds = ET.SubElement(ds_collection, "{%s}data-stream" % datastream_namespace)
    ds.set("id", "scap_%s_datastream_%s" % (ID_NS, name))
    ds.set("scap-version", "1.2")
    ds.set("use-case", "OTHER")
    dictionaries = ET.SubElement(ds, "{%s}dictionaries" % datastream_namespace)
    checklists = ET.SubElement(ds, "{%s}checklists" % datastream_namespace)
    checks = ET.SubElement(ds, "{%s}checks" % datastream_namespace)
    cpe_dict_dependencies = [cpe_oval_file_name]
    add_component(
        ds_collection, dictionaries, cpe_dict_file_name, cpe_dict_dependencies)
    xccdf_dependencies = [oval_file_name, ocil_file_name]
    add_component(
        ds_collection, checklists, xccdf_file_name, xccdf_dependencies)
    add_component(ds_collection, checks, oval_file_name)
    add_component(ds_collection, checks, ocil_file_name)
    add_component(ds_collection, checks, cpe_oval_file_name)
    return ET.ElementTree(ds_collection)


if __name__ == "__main__":
    args = parse_args()
    ssg.xml.register_namespaces()
    ds = compose_ds(
        args.xccdf, args.oval, args.ocil, args.cpe_dict, args.cpe_oval)
    ds.write(args.output)
