#!/usr/bin/env python2
import xml.etree.cElementTree as ET

import logging

NAMESPACES = {
    'xccdf': "http://checklists.nist.gov/xccdf/1.2",
    'ds': "http://scap.nist.gov/schema/scap/source/1.2",
    'xlink': "http://www.w3.org/1999/xlink",
}


logging.getLogger(__name__).addHandler(logging.NullHandler())


def get_all_xccdf_ids_in_datastream(datastream):
    root = ET.parse(datastream).getroot()

    checklists_node = root.find(".//ds:checklists", NAMESPACES)
    if checklists_node is None:
        logging.error(
            "Checklists not found within DataStream")

    all_checklist_components = checklists_node.findall('ds:component-ref',
                                                       NAMESPACES)
    xccdf_ids = [component.get("id") for component in all_checklist_components]
    return xccdf_ids


def infer_benchmark_id_from_component_ref_id(datastream, ref_id):
    root = ET.parse(datastream).getroot()
    component_ref_node = root.find("*//ds:component-ref[@id='{0}']"
                                   .format(ref_id), NAMESPACES)
    if component_ref_node is None:
        msg = (
            'Component reference of Ref-Id {} not found within datastream'
            .format(ref_id))
        raise RuntimeError(msg)

    comp_id = component_ref_node.get('{%s}href' % NAMESPACES['xlink'])
    comp_id = comp_id.lstrip('#')

    query = ".//ds:component[@id='{}']/xccdf:Benchmark".format(comp_id)
    benchmark_node = root.find(query, NAMESPACES)
    if benchmark_node is None:
        msg = (
            'Benchmark not found within component of Id {}'
            .format(comp_id)
        )
        raise RuntimeError(msg)

    return benchmark_node.get('id')


def _get_benchmark_node(datastream, benchmark_id, logging):
    root = ET.parse(datastream).getroot()
    benchmark_node = root.find(
        "*//xccdf:Benchmark[@id='{0}']".format(benchmark_id), NAMESPACES)
    if benchmark_node is None:
        if logging is not None:
            logging.error(
                "Benchmark ID '{}' not found within DataStream"
                .format(benchmark_id))
    return benchmark_node


def get_all_profiles_in_benchmark(datastream, benchmark_id, logging=None):
    benchmark_node = _get_benchmark_node(datastream, benchmark_id, logging)
    all_profiles = benchmark_node.findall('xccdf:Profile', NAMESPACES)
    return all_profiles


def benchmark_get_applicable_platforms(datastream, benchmark_id, logging=None):
    """
    Returns a set of CPEs the given benchmark is applicable to.
    """
    benchmark_node = _get_benchmark_node(datastream, benchmark_id, logging)
    platform_elements = benchmark_node.findall('xccdf:platform', NAMESPACES)
    cpes = {platform_el.get("idref") for platform_el in platform_elements}
    return cpes
