from __future__ import absolute_import
from __future__ import print_function

import os
import os.path
import sys
import re
from copy import deepcopy
import collections

from .build_yaml import Rule, DocumentationNotComplete
from .constants import oval_namespace as oval_ns
from .constants import oval_footer
from .constants import oval_header
from .constants import MULTI_PLATFORM_LIST
from .jinja import process_file_with_macros
from .rule_yaml import parse_prodtype
from .rules import get_rule_dir_id, get_rule_dir_ovals, find_rule_dirs_in_paths
from . import utils
from .xml import ElementTree


def _check_is_applicable_for_product(oval_check_def, product):
    """Based on the <platform> specifier of the OVAL check determine if this
    OVAL check is applicable for this product. Return 'True' if so, 'False'
    otherwise"""

    product, product_version = utils.parse_name(product)

    # Define general platforms
    multi_platforms = ['<platform>multi_platform_all',
                       '<platform>multi_platform_' + product]

    # First test if OVAL check isn't for 'multi_platform_all' or
    # 'multi_platform_' + product
    for multi_prod in multi_platforms:
        if multi_prod in oval_check_def and product in MULTI_PLATFORM_LIST:
            return True

    # Current SSG checks aren't unified which element of '<platform>'
    # and '<product>' to use as OVAL AffectedType metadata element,
    # e.g. Chromium content uses both of them across the various checks
    # Thus for now check both of them when checking concrete platform / product
    affected_type_elements = ['<platform>', '<product>']

    for afftype in affected_type_elements:
        # Get official name for product (prefixed with content of afftype)
        product_name = afftype + utils.map_name(product)
        # Append the product version to the official name
        if product_version is not None:
            # Some product versions have a dot in between the numbers
            # While the prodtype doesn't have the dot, the full product name does
            if product == "ubuntu" or product == "macos":
                product_version = product_version[:2] + "." + product_version[2:]
            product_name += ' ' + product_version

        # Test if this OVAL check is for the concrete product version
        if product_name in oval_check_def:
            return True

    # OVAL check isn't neither a multi platform one, nor isn't applicable
    # for this product => return False to indicate that

    return False


def finalize_affected_platforms(xml_tree, env_yaml):
    """Depending on your use-case of OVAL you may not need the <affected>
    element. Such use-cases including using OVAL as a check engine for XCCDF
    benchmarks. Since the XCCDF Benchmarks use cpe:platform with CPE IDs,
    the affected element in OVAL definitions is redundant and just bloats the
    files. This function removes all *irrelevant* affected platform elements
    from given OVAL tree. It then adds one platform of the product we are
    building.
    """

    for affected in xml_tree.findall(".//{%s}affected" % (oval_ns)):
        for platform in affected.findall("./{%s}platform" % (oval_ns)):
            affected.remove(platform)
        for product in affected.findall("./{%s}product" % (oval_ns)):
            affected.remove(product)

        final = ElementTree.SubElement(
            affected, "{%s}%s" % (oval_ns, utils.required_key(env_yaml, "type")))
        final.text = utils.required_key(env_yaml, "full_name")

    return xml_tree


def oval_entities_are_identical(firstelem, secondelem):
    """Check if OVAL entities represented by XML elements are identical
       Return: True if identical, False otherwise
       Based on: http://stackoverflow.com/a/24349916"""

    # Per https://github.com/OpenSCAP/scap-security-guide/pull/1343#issuecomment-234541909
    # and https://github.com/OpenSCAP/scap-security-guide/pull/1343#issuecomment-234545296
    # ignore the differences in 'comment', 'version', 'state_operator', and
    # 'deprecated' attributes. Also ignore different nsmap, since all these
    # don't affect the semantics of the OVAL entities

    # Operate on copies of the elements (since we will modify
    # some attributes). Deepcopy will also reset the namespace map
    # on copied elements for us
    firstcopy = deepcopy(firstelem)
    secondcopy = deepcopy(secondelem)

    # Ignore 'comment', 'version', 'state_operator', and 'deprecated'
    # attributes since they don't change the semantics of an element
    for copy in [firstcopy, secondcopy]:
        for key in copy.keys():
            if key in ["comment", "version", "state_operator",
                       "deprecated"]:
                del copy.attrib[key]

    # Compare the equality of the copies
    if firstcopy.tag != secondcopy.tag:
        return False
    if firstcopy.text != secondcopy.text:
        return False
    if firstcopy.tail != secondcopy.tail:
        return False
    if firstcopy.attrib != secondcopy.attrib:
        return False
    if len(firstcopy) != len(secondcopy):
        return False

    return all(oval_entities_are_identical(
        fchild, schild) for fchild, schild in zip(firstcopy, secondcopy))


def oval_entity_is_extvar(elem):
    """Check if OVAL entity represented by XML element is OVAL
       <external_variable> element
       Return: True if <external_variable>, False otherwise"""

    return elem.tag == '{%s}external_variable' % oval_ns


element_child_cache = collections.defaultdict(dict)


def append(element, newchild):
    """Append new child ONLY if it's not a duplicate"""

    global element_child_cache

    newid = newchild.get("id")
    existing = element_child_cache[element].get(newid, None)

    if existing is not None:
        # ID is identical and OVAL entities are identical
        if oval_entities_are_identical(existing, newchild):
            # Moreover the entity is OVAL <external_variable>
            if oval_entity_is_extvar(newchild):
                # If OVAL entity is identical to some already included
                # in the benchmark and represents an OVAL <external_variable>
                # it's safe to ignore this ID (since external variables are
                # in multiple checks just to notify 'testoval.py' helper to
                # substitute the ID with <local_variable> entity when testing
                # the OVAL for the rule)
                pass
            # Some other OVAL entity
            else:
                # If OVAL entity is identical, but not external_variable, the
                # implementation should be rewritten each entity to be present
                # just once
                sys.stderr.write("ERROR: OVAL ID '%s' is used multiple times "
                                 "and should represent the same elements.\n"
                                 % (newid))
                sys.stderr.write("Rewrite the OVAL checks. Place the identical "
                                 "IDs into their own definition and extend "
                                 "this definition by it.\n")
                sys.exit(1)
        # ID is identical, but OVAL entities are semantically difference =>
        # report and error and exit with failure
        # Fixes: https://github.com/OpenSCAP/scap-security-guide/issues/1275
        else:
            if not oval_entity_is_extvar(existing) and \
              not oval_entity_is_extvar(newchild):
                # This is an error scenario - since by skipping second
                # implementation and using the first one for both references,
                # we might evaluate wrong requirement for the second entity
                # => report an error and exit with failure in that case
                # See
                #   https://github.com/OpenSCAP/scap-security-guide/issues/1275
                # for a reproducer and what could happen in this case
                sys.stderr.write("ERROR: it's not possible to use the " +
                                 "same ID: %s " % newid + "for two " +
                                 "semantically different OVAL entities:\n")
                sys.stderr.write("First entity  %s\n" % ElementTree.tostring(existing))
                sys.stderr.write("Second entity %s\n" % ElementTree.tostring(newchild))
                sys.stderr.write("Use different ID for the second entity!!!\n")
                sys.exit(1)
    else:
        element.append(newchild)
        element_child_cache[element][newid] = newchild


def check_oval_version(oval_version):
    """Not necessary, but should help with typos"""

    supported_versions = ["5.10", "5.11"]
    if oval_version not in supported_versions:
        supported_versions_str = ", ".join(supported_versions)
        sys.stderr.write(
            "Suspicious oval version \"%s\", one of {%s} is "
            "expected.\n" % (oval_version, supported_versions_str))
        sys.exit(1)


def _check_is_loaded(loaded_dict, filename, version):
    if filename in loaded_dict:
        if loaded_dict[filename] >= version:
            return True

        # Should rather fail, than override something unwanted
        sys.stderr.write(
            "You cannot override generic OVAL file in version '%s' "
            "by more specific one in older version '%s'" %
            (version, loaded_dict[filename])
        )
        sys.exit(1)

    return False


def _check_oval_version_from_oval(xml_content, oval_version):
    try:
        argument = oval_header + xml_content + oval_footer
        oval_file_tree = ElementTree.fromstring(argument)
    except ElementTree.ParseError as error:
        line, column = error.position
        lines = argument.splitlines()
        before = '\n'.join(lines[:line])
        column_pointer = ' ' * (column - 1) + '^'
        sys.stderr.write(
            "%s\n%s\nError when parsing OVAL file.\n" %
            (before, column_pointer))
        sys.exit(1)
    for defgroup in oval_file_tree.findall("./{%s}def-group" % oval_ns):
        file_oval_version = defgroup.get("oval_version")

    if file_oval_version is None:
        # oval_version does not exist in <def-group/>
        # which means the OVAL is supported for any version.
        # By default, that version is 5.10
        file_oval_version = "5.10"

    if tuple(oval_version.split(".")) >= tuple(file_oval_version.split(".")):
        return True


def checks(env_yaml, yaml_path, oval_version, oval_dirs):
    """
    Concatenate all XML files in the oval directory, to create the document
    body. Then concatenates this with all XML files in the guide directories,
    preferring {{{ product }}}.xml to shared.xml.

    oval_dirs: list of directory with oval files (later has higher priority)

    Return: The document body
    """

    body = []
    product = utils.required_key(env_yaml, "product")
    included_checks_count = 0
    reversed_dirs = oval_dirs[::-1]  # earlier directory has higher priority
    already_loaded = dict()  # filename -> oval_version
    local_env_yaml = dict()
    local_env_yaml.update(env_yaml)

    product_dir = os.path.dirname(yaml_path)
    relative_guide_dir = utils.required_key(env_yaml, "benchmark_root")
    guide_dir = os.path.abspath(os.path.join(product_dir, relative_guide_dir))
    additional_content_directories = env_yaml.get("additional_content_directories", [])
    add_content_dirs = [os.path.abspath(os.path.join(product_dir, rd)) for rd in additional_content_directories]

    for _dir_path in find_rule_dirs_in_paths([guide_dir] + add_content_dirs):
        rule_id = get_rule_dir_id(_dir_path)

        rule_path = os.path.join(_dir_path, "rule.yml")
        try:
            rule = Rule.from_yaml(rule_path, env_yaml)
        except DocumentationNotComplete:
            # Happens on non-debug build when a rule is "documentation-incomplete"
            continue
        prodtypes = parse_prodtype(rule.prodtype)

        local_env_yaml['rule_id'] = rule.id_
        local_env_yaml['rule_title'] = rule.title
        local_env_yaml['products'] = prodtypes # default is all

        for _path in get_rule_dir_ovals(_dir_path, product):
            # To be compatible with the later checks, use the rule_id
            # (i.e., the value of _dir) to recreate the expected filename if
            # this OVAL was in a rule directory.
            filename = "%s.xml" % rule_id

            xml_content = process_file_with_macros(_path, local_env_yaml)

            if not _check_is_applicable_for_product(xml_content, product):
                continue
            if _check_is_loaded(already_loaded, filename, oval_version):
                continue
            if not _check_oval_version_from_oval(xml_content, oval_version):
                continue

            body.append(xml_content)
            included_checks_count += 1
            already_loaded[filename] = oval_version

    for oval_dir in reversed_dirs:
        if os.path.isdir(oval_dir):
            # sort the files to make output deterministic
            for filename in sorted(os.listdir(oval_dir)):
                if filename.endswith(".xml"):
                    xml_content = process_file_with_macros(
                        os.path.join(oval_dir, filename), env_yaml
                    )

                    if not _check_is_applicable_for_product(xml_content, product):
                        continue
                    if _check_is_loaded(already_loaded, filename, oval_version):
                        continue
                    if not _check_oval_version_from_oval(xml_content, oval_version):
                        continue
                    body.append(xml_content)
                    included_checks_count += 1
                    already_loaded[filename] = oval_version

    return "".join(body)
