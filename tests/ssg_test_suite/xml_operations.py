#!/usr/bin/python3
import xml.etree.cElementTree as ET

import logging
import contextlib
import re
import subprocess

from ssg.constants import OSCAP_RULE
from ssg.constants import PREFIX_TO_NS
from ssg.constants import bash_system as bash_rem_system
from ssg.constants import ansible_system as ansible_rem_system
from ssg.constants import puppet_system as puppet_rem_system
from ssg.constants import anaconda_system as anaconda_rem_system
from ssg.constants import ignition_system as ignition_rem_system

SYSTEM_ATTRIBUTE = {
    'bash': bash_rem_system,
    'ansible': ansible_rem_system,
    'puppet': puppet_rem_system,
    'anaconda': anaconda_rem_system,
    'ignition': ignition_rem_system,
}


BENCHMARK_QUERY = ".//ds:component/xccdf-1.2:Benchmark"
OVAL_DEF_QUERY = ".//ds:component/oval-def:oval_definitions/oval-def:definitions"

logging.getLogger(__name__).addHandler(logging.NullHandler())


def get_all_xccdf_ids_in_datastream(datastream):
    root = ET.parse(datastream).getroot()

    checklists_node = root.find(".//ds:checklists", PREFIX_TO_NS)
    if checklists_node is None:
        logging.error(
            "Checklists not found within DataStream")

    all_checklist_components = checklists_node.findall('ds:component-ref',
                                                       PREFIX_TO_NS)
    xccdf_ids = [component.get("id") for component in all_checklist_components]
    return xccdf_ids


def infer_benchmark_id_from_component_ref_id(datastream, ref_id):
    root = ET.parse(datastream).getroot()
    component_ref_node = root.find("*//ds:component-ref[@id='{0}']"
                                   .format(ref_id), PREFIX_TO_NS)
    if component_ref_node is None:
        msg = (
            'Component reference of Ref-Id {} not found within datastream'
            .format(ref_id))
        raise RuntimeError(msg)

    comp_id = component_ref_node.get('{%s}href' % PREFIX_TO_NS['xlink'])
    comp_id = comp_id.lstrip('#')

    query = ".//ds:component[@id='{}']/xccdf-1.2:Benchmark".format(comp_id)
    benchmark_node = root.find(query, PREFIX_TO_NS)
    if benchmark_node is None:
        msg = (
            'Benchmark not found within component of Id {}'
            .format(comp_id)
        )
        raise RuntimeError(msg)

    return benchmark_node.get('id')


@contextlib.contextmanager
def datastream_root(ds_location, save_location=None):
    try:
        tree = ET.parse(ds_location)
        for prefix, uri in PREFIX_TO_NS.items():
            ET.register_namespace(prefix, uri)
        root = tree.getroot()
        yield root
    finally:
        if save_location:
            tree.write(save_location)


def find_elements(root, element_spec=None):
    query = BENCHMARK_QUERY
    if element_spec is not None:
        query = query + "//{0}".format(element_spec)
    return root.findall(query, PREFIX_TO_NS)


def remove_platforms_from_element(root, element_spec=None, platforms=None):
    elements = find_elements(root, element_spec)
    for el in elements:
        platforms_xml = el.findall("./xccdf-1.2:platform", PREFIX_TO_NS)
        for p in platforms_xml:
            if platforms is None or instance_in_platforms(p, platforms):
                el.remove(p)


def instance_in_platforms(inst, platforms):
    return (isinstance(platforms, str) and inst.get("idref") == platforms) or \
        (hasattr(platforms, "__iter__") and inst.get("idref") in platforms)


def remove_machine_platform(root):
    remove_platforms_from_element(root, "xccdf-1.2:Rule", "cpe:/a:machine")
    remove_platforms_from_element(root, "xccdf-1.2:Group", "cpe:/a:machine")
    remove_platforms_from_element(root, "xccdf-1.2:Rule", "#machine")
    remove_platforms_from_element(root, "xccdf-1.2:Group", "#machine")


def remove_platforms(root):
    remove_platforms_from_element(root)
    remove_platforms_from_element(root, "xccdf-1.2:Profile")


def remove_ocp4_platforms(root):
    remove_platforms_from_element(
        root, "xccdf-1.2:Rule",
        ["cpe:/o:redhat:openshift_container_platform:4",
         "cpe:/o:redhat:openshift_container_platform_node:4",
         "cpe:/a:ocp4-master-node"])
    remove_platforms_from_element(
        root, "xccdf-1.2:Group",
        ["cpe:/o:redhat:openshift_container_platform:4",
         "cpe:/o:redhat:openshift_container_platform_node:4",
         "cpe:/a:ocp4-master-node"])


def remove_machine_remediation_condition(root):
    remove_bash_machine_remediation_condition(root)
    remove_ansible_machine_remediation_condition(root)


def remove_bash_machine_remediation_condition(root):
    system = "urn:xccdf:fix:script:sh"
    considered_machine_platform_checks = [
        r"\[\s+!\s+-f\s+/\.dockerenv\s+\]\s+&&\s+\[\s+!\s+-f\s+/run/\.containerenv\s+\]",
    ]
    repl = "true"
    _replace_in_fix(root, system, considered_machine_platform_checks, repl)


def remove_ansible_machine_remediation_condition(root):
    system = "urn:xccdf:fix:script:ansible"
    considered_machine_platform_checks = [
        r"\bansible_virtualization_type\s+not\s+in.*docker.*",
    ]
    repl = "True"
    _replace_in_fix(root, system, considered_machine_platform_checks, repl)


def _replace_in_fix(root, system, considered_machine_platform_checks, repl):
    query = BENCHMARK_QUERY + '//xccdf-1.2:fix[@system="' + system + '"]'
    fix_elements = root.findall(query, PREFIX_TO_NS)
    for el in fix_elements:
        for check in considered_machine_platform_checks:
            sub_els = el.findall(".//xccdf-1.2:sub", PREFIX_TO_NS)
            for sub_el in sub_els:
                sub_el.tail = re.sub(check, repl, sub_el.tail)
            el.text = re.sub(check, repl, el.text)


def get_oscap_supported_cpes():
    """
    Obtain a list of CPEs that the scanner supports
    """
    result = []
    proc = subprocess.Popen(
            ("oscap", "--version"),
            stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    try:
        outs, errs = proc.communicate(timeout=3)
    except subprocess.TimeoutExpired:
        logging.warn("Scanner timeouted when asked about supported CPEs")
        proc.kill()
        return []

    if proc.returncode != 0:
        first_error_line = errs.split("\n")[0]
        logging.warn("Error getting CPEs from the scanner: {msg}".format(msg=first_error_line))

    cpe_regex = re.compile(r'\bcpe:\S+$')
    for line in outs.decode().split("\n"):
        match = cpe_regex.search(line)
        if match:
            result.append(match.group(0))
    return result


def add_platform_to_benchmark(root, cpe_regex):
    benchmark_query = ".//ds:component/xccdf-1.2:Benchmark"
    benchmarks = root.findall(benchmark_query, PREFIX_TO_NS)
    if not benchmarks:
        msg = (
            "No benchmarks found in the datastream"
        )
        raise RuntimeError(msg)

    all_cpes = get_oscap_supported_cpes()
    regex = re.compile(cpe_regex)

    cpes_to_add = []
    for cpe_str in all_cpes:
        if regex.search(cpe_str):
            cpes_to_add.append(cpe_str)

    if not cpes_to_add:
        cpes_to_add = [cpe_regex]

    for benchmark in benchmarks:
        existing_platform_element = benchmark.find("xccdf-1.2:platform", PREFIX_TO_NS)
        if existing_platform_element is None:
            logging.warn(
                "Couldn't find platform element in a benchmark, "
                "not adding any additional platforms as a result.")
            continue
        platform_index = list(benchmark).index(existing_platform_element)
        for cpe_str in cpes_to_add:
            e = ET.Element("xccdf-1.2:platform", idref=cpe_str)
            benchmark.insert(platform_index, e)


def add_product_to_fips_certified(root, product="fedora"):
    query = OVAL_DEF_QUERY + "/{0}".format(
        "oval-def:definition[@id='oval:ssg-installed_OS_is_FIPS_certified:def:1']/"
        "oval-def:criteria")
    criteria = root.find(query, PREFIX_TO_NS)
    if criteria:
        e = ET.Element("oval-def:extend_definition",
                       comment="Installed OS is {0}".format(product),
                       definition_ref="oval:ssg-installed_OS_is_{0}:def:1".format(product))
        criteria.append(e)


def _get_benchmark_node(datastream, benchmark_id, logging):
    root = ET.parse(datastream).getroot()
    benchmark_node = root.find(
        "*//xccdf-1.2:Benchmark[@id='{0}']".format(benchmark_id), PREFIX_TO_NS)
    if benchmark_node is None:
        if logging is not None:
            logging.error(
                "Benchmark ID '{}' not found within DataStream"
                .format(benchmark_id))
    return benchmark_node


def get_all_profiles_in_benchmark(datastream, benchmark_id, logging=None):
    benchmark_node = _get_benchmark_node(datastream, benchmark_id, logging)
    all_profiles = benchmark_node.findall('xccdf-1.2:Profile', PREFIX_TO_NS)
    return all_profiles


def get_all_rule_selections_in_profile(datastream, benchmark_id, profile_id, logging=None):
    benchmark_node = _get_benchmark_node(datastream, benchmark_id, logging)
    profile = benchmark_node.find("xccdf-1.2:Profile[@id='{0}']".format(profile_id), PREFIX_TO_NS)
    rule_selections = profile.findall("xccdf-1.2:select[@selected='true']", PREFIX_TO_NS)
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
    platform_elements = benchmark_node.findall('xccdf-1.2:platform', PREFIX_TO_NS)
    cpes = {platform_el.get("idref") for platform_el in platform_elements}
    return cpes


def find_rule_in_benchmark(datastream, benchmark_id, rule_id, logging=None):
    """
    Returns rule node from the given benchmark.
    """
    benchmark_node = _get_benchmark_node(datastream, benchmark_id, logging)
    rule = benchmark_node.find(".//xccdf-1.2:Rule[@id='{0}']".format(rule_id), PREFIX_TO_NS)
    return rule


def get_all_rules_in_benchmark(datastream, benchmark_id, logging=None):
    """
    Returns all rule IDs in the given benchmark.
    """
    rules = []
    benchmark_node = _get_benchmark_node(datastream, benchmark_id, logging)
    for rule in benchmark_node.findall(".//xccdf-1.2:Rule", PREFIX_TO_NS):
        rules.append(rule.get("id"))
    return rules


def find_fix_in_benchmark(datastream, benchmark_id, rule_id, fix_type='bash', logging=None):
    """
    Return fix from benchmark. None if not found.
    """
    rule = find_rule_in_benchmark(datastream, benchmark_id, rule_id, logging)
    if rule is None:
        return None

    system_attribute = SYSTEM_ATTRIBUTE.get(fix_type, bash_rem_system)

    fix = rule.find("xccdf-1.2:fix[@system='{0}']".format(system_attribute), PREFIX_TO_NS)
    return fix
