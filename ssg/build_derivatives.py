"""
Common functions for enabling derivative products
"""

from __future__ import absolute_import
from __future__ import print_function

import re
from .xml import ElementTree
from .constants import standard_profiles, OSCAP_VENDOR, PREFIX_TO_NS, oval_namespace
from .build_cpe import ProductCPEs
from .id_translate import IDTranslator


def add_cpes(elem, namespace, mapping):
    """
    Adds derivative CPEs next to RHEL ones, checks XCCDF elements of given
    namespace.
    """

    affected = False

    for child in list(elem):
        affected = affected or add_cpes(child, namespace, mapping)

    # precompute this so that we can affect the tree while iterating
    children = list(elem.findall(".//{%s}platform" % (namespace)))

    for child in children:
        idref = child.get("idref")
        if idref in mapping:
            new_platform = ElementTree.Element("{%s}platform" % (namespace))
            new_platform.set("idref", mapping[idref])
            # this is done for the newline and indentation
            new_platform.tail = child.tail

            index = list(elem).index(child)
            # insert it right after the respective RHEL CPE
            elem.insert(index + 1, new_platform)

            affected = True

    return affected


def add_cpe_item_to_dictionary(tree_root, product, cpe_ref, cpe_oval_filename, id_name):
    cpe_list = tree_root.find(".//{%s}cpe-list" % (PREFIX_TO_NS["cpe-dict"]))
    if cpe_list:
        product_cpes = ProductCPEs(product)
        cpe_item = product_cpes.get_cpe(cpe_ref)
        translator = IDTranslator(id_name)
        cpe_item.check_id = translator.generate_id("{" + oval_namespace + "}definition", cpe_item.check_id)
        cpe_list.append(cpe_item.to_xml_element(cpe_oval_filename))


def add_notice(benchmark, namespace, notice, warning):
    """
    Adds derivative notice as the first notice to given benchmark.
    """

    index = -1
    prev_element = None
    existing_notices = list(benchmark.findall("./{%s}notice" % (namespace)))
    if existing_notices:
        prev_element = existing_notices[0]
        # insert before the first notice
        index = list(benchmark).index(prev_element)
    else:
        existing_descriptions = list(
            benchmark.findall("./{%s}description" % (namespace))
        )
        prev_element = existing_descriptions[-1]
        # insert after the last description
        index = list(benchmark).index(prev_element) + 1

    if index == -1:
        raise RuntimeError(
            "Can't find existing notices or description in benchmark '%s'." %
            (benchmark)
        )

    elem = ElementTree.Element("{%s}notice" % (namespace))
    elem.set("id", warning)
    elem.append(notice)
    # this is done for the newline and indentation
    elem.tail = prev_element.tail
    benchmark.insert(index, elem)

    return True


def remove_idents(tree_root, namespace, prod="RHEL"):
    """
    Remove product identifiers from rules in XML tree
    """

    ident_exp = '.*' + prod + '-*'
    ref_exp = prod + '-*'
    for rule in tree_root.findall(".//{%s}Rule" % (namespace)):
        for ident in rule.findall(".//{%s}ident" % (namespace)):
            if ident is not None:
                if (re.search(r'CCE-*', ident.text) or
                        re.search(ident_exp, ident.text)):
                    rule.remove(ident)

        for ref in rule.findall(".//{%s}reference" % (namespace)):
            if ref.text is not None:
                if re.search(ref_exp, ref.text):
                    rule.remove(ref)

        for fix in rule.findall(".//{%s}fix" % (namespace)):
            if "fips" in fix.get("id"):
                rule.remove(fix)
            sub_elems = fix.findall(".//{%s}sub" % (namespace))
            for sub_elem in sub_elems:
                sub_elem.tail = re.sub(r"[\s]+- CCE-.*", "", sub_elem.tail)
                sub_elem.tail = re.sub(r"CCE-[0-9]*-[0-9]*", "", sub_elem.tail)
            if fix.text is not None:
                fix.text = re.sub(r"[\s]+- CCE-.*", "", fix.text)
                fix.text = re.sub(r"CCE-[0-9]*-[0-9]*", "", fix.text)


def remove_cce_reference(tree_root, namespace):
    """
    Remove CCE identifiers from OVAL checks in XML tree
    """
    for definition in tree_root.findall(".//{%s}definition" % (namespace)):
        for metadata in definition.findall(".//{%s}metadata" % (namespace)):
            for ref in metadata.findall(".//{%s}reference" % (namespace)):
                if (re.search(r'CCE-*', ref.get("ref_id"))):
                    metadata.remove(ref)


def profile_handling(tree_root, namespace):
    ns_profiles = []
    for i in standard_profiles:
        ns_profiles.append("xccdf_%s.content_profile_%s" % (OSCAP_VENDOR, i))
    all_profiles = standard_profiles + ns_profiles
    for profile in tree_root.findall(".//{%s}Profile" % (namespace)):
        if profile.get("id") not in all_profiles:
            tree_root.remove(profile)


def replace_platform(tree_root, namespace, product):
    for oval in tree_root.findall(".//{%s}oval_definitions" % (namespace)):
        for platform in oval.findall(".//{%s}platform" % (namespace)):
            platform.text = (platform.text).replace("Red Hat Enterprise Linux", product)
