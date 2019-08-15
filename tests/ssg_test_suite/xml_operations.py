#!/usr/bin/env python2
import xml.etree.cElementTree as ET

import logging

from ssg.constants import OSCAP_RULE
from ssg.constants import XCCDF12_NS as xccdf_ns
from ssg.constants import datastream_namespace
from ssg.constants import xlink_namespace
from ssg.constants import oval_namespace as oval_ns
from ssg.constants import bash_system as bash_rem_system
from ssg.constants import ansible_system as ansible_rem_system
from ssg.constants import puppet_system as puppet_rem_system
from ssg.constants import anaconda_system as anaconda_rem_system

SYSTEM_ATTRIBUTE = {
    'bash': bash_rem_system,
    'ansible': ansible_rem_system,
    'puppet': puppet_rem_system,
    'anaconda': anaconda_rem_system,
}

NAMESPACES = {
    'xccdf': xccdf_ns,
    'ds': datastream_namespace,
    'xlink': xlink_namespace,
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


def get_all_rule_selections_in_profile(datastream, benchmark_id, profile_id, logging=None):
    benchmark_node = _get_benchmark_node(datastream, benchmark_id, logging)
    profile = benchmark_node.find("xccdf:Profile[@id='{0}']".format(profile_id), NAMESPACES)
    rule_selections = profile.findall("xccdf:select[@selected='true']", NAMESPACES)
    return rule_selections


def get_all_rule_ids_in_profile(datastream, benchmark_id, profile_id, logging=None):
    rule_selections = get_all_rule_selections_in_profile(datastream, benchmark_id,
                                                         profile_id, logging=None)
    rule_ids = [select.get("idref") for select in rule_selections]

    # Strip xccdf 1.2 prefixes from rule ids
    # Necessary to search for the rules within test scenarios tree
    prefix_len = len(OSCAP_RULE)
    return [rule[prefix_len:] for rule in rule_ids]


def benchmark_get_applicable_platforms(datastream, benchmark_id, logging=None):
    """
    Returns a set of CPEs the given benchmark is applicable to.
    """
    benchmark_node = _get_benchmark_node(datastream, benchmark_id, logging)
    platform_elements = benchmark_node.findall('xccdf:platform', NAMESPACES)
    cpes = {platform_el.get("idref") for platform_el in platform_elements}
    return cpes


def find_rule_in_benchmark(datastream, benchmark_id, rule_id, logging=None):
    """
    Returns rule node from the given benchmark.
    """
    benchmark_node = _get_benchmark_node(datastream, benchmark_id, logging)
    rule = benchmark_node.find(".//xccdf:Rule[@id='{0}']".format(rule_id), NAMESPACES)
    return rule

def find_fix_in_benchmark(datastream, benchmark_id, rule_id, fix_type='bash', logging=None):
    """
    Return fix from benchmark. None if not found.
    """
    rule = find_rule_in_benchmark(datastream, benchmark_id, rule_id, logging)
    if rule is None:
        return None

    system_attribute = SYSTEM_ATTRIBUTE.get(fix_type, bash_rem_system)

    fix = rule.find("xccdf:fix[@system='{0}']".format(system_attribute), NAMESPACES)
    return fix
