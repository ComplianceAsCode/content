#!/usr/bin/env python2

import datetime
import os
import os.path
import errno
import platform
import re
import sys
from copy import deepcopy
import argparse


try:
    from xml.etree import cElementTree as ElementTree
except ImportError:
    import cElementTree as ElementTree

try:
    from configparser import SafeConfigParser
except ImportError:
    # for python2
    from ConfigParser import SafeConfigParser

# Put shared python modules in path
sys.path.insert(0, os.path.join(
        os.path.dirname(os.path.dirname(os.path.realpath(__file__))),
        "modules"))
from map_product_module import map_product, parse_product_name, multi_product_list

oval_ns = "http://oval.mitre.org/XMLSchema/oval-definitions-5"
footer = "</oval_definitions>"


def _header(schema_version, ssg_version):
    timestamp = datetime.datetime.utcnow().strftime("%Y-%m-%dT%H:%M:%S")
    return """<?xml version="1.0" encoding="UTF-8"?>
<oval_definitions
    xmlns="http://oval.mitre.org/XMLSchema/oval-definitions-5"
    xmlns:oval="http://oval.mitre.org/XMLSchema/oval-common-5"
    xmlns:ind="http://oval.mitre.org/XMLSchema/oval-definitions-5#independent"
    xmlns:unix="http://oval.mitre.org/XMLSchema/oval-definitions-5#unix"
    xmlns:linux="http://oval.mitre.org/XMLSchema/oval-definitions-5#linux"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://oval.mitre.org/XMLSchema/oval-common-5 oval-common-schema.xsd
        http://oval.mitre.org/XMLSchema/oval-definitions-5 oval-definitions-schema.xsd
        http://oval.mitre.org/XMLSchema/oval-definitions-5#independent independent-definitions-schema.xsd
        http://oval.mitre.org/XMLSchema/oval-definitions-5#unix unix-definitions-schema.xsd
        http://oval.mitre.org/XMLSchema/oval-definitions-5#linux linux-definitions-schema.xsd">
    <generator>
        <oval:product_name>combine-ovals.py from SCAP Security Guide</oval:product_name>
        <oval:product_version>ssg: %s, python: %s</oval:product_version>
        <oval:schema_version>%s</oval:schema_version>
        <oval:timestamp>%s</oval:timestamp>
    </generator>""" % (ssg_version, platform.python_version(),
                       schema_version, timestamp)


def parse_conf_file(conf_file, product):
    parser = SafeConfigParser()
    parser.read(conf_file)
    multi_platform = {}

    for section in parser.sections():
        for name, setting in parser.items(section):
            setting = re.sub('.;:', ',', re.sub(' ', '', setting))
            multi_platform[name] = [item for item in setting.split(",")]

    return multi_platform


def check_is_applicable_for_product(oval_check_def, product):
    """Based on the <platform> specifier of the OVAL check determine if this
    OVAL check is applicable for this product. Return 'True' if so, 'False'
    otherwise"""

    product, product_version = parse_product_name(product)

    # Define general platforms
    multi_platforms = ['<platform>multi_platform_all',
                       '<platform>multi_platform_' + product ]

    # First test if OVAL check isn't for 'multi_platform_all' or
    # 'multi_platform_' + product
    for mp in multi_platforms:
        if mp in oval_check_def and product in multi_product_list:
            return True

    # Current SSG checks aren't unified which element of '<platform>'
    # and '<product>' to use as OVAL AffectedType metadata element,
    # e.g. Chromium content uses both of them across the various checks
    # Thus for now check both of them when checking concrete platform / product
    affected_type_elements = ['<platform>', '<product>']

    for afftype in affected_type_elements:
        # Get official name for product (prefixed with content of afftype)
        product_name = afftype + map_product(product)
        # Append the product version to the official name
        if product_version is not None:
            product_name += ' ' + product_version

        # Test if this OVAL check is for the concrete product version
        if product_name in oval_check_def:
            return True

    # OVAL check isn't neither a multi platform one, nor isn't applicable
    # for this product => return False to indicate that

    return False


def add_platforms(xml_tree, multi_platform):
    for affected in xml_tree.findall(".//{%s}affected" % oval_ns):
        if affected.get("family") != "unix":
            continue

        for plat_elem in affected:
            try:
                if plat_elem.text == 'multi_platform_oval':
                    for platforms in multi_platform[plat_elem.text]:
                        for plat in multi_platform[platforms]:
                            platform = ElementTree.Element(
                                "{%s}platform" % oval_ns)
                            platform.text = map_product(platforms) + ' ' + plat
                            affected.insert(1, platform)
                else:
                    for platforms in multi_platform[plat_elem.text]:
                        platform = ElementTree.Element("{%s}platform" % oval_ns)
                        platform.text = map_product(plat_elem.text) + ' ' + platforms
                        affected.insert(0, platform)
            except KeyError:
                pass

            # Remove multi_platform element
            if re.findall('multi_platform', plat_elem.text):
                affected.remove(plat_elem)

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
            if key in ["comment", "version", "state_operator", \
                       "deprecated"]:
                del copy.attrib[key]

    # Compare the equality of the copies
    if firstcopy.tag != secondcopy.tag: return False
    if firstcopy.text != secondcopy.text: return False
    if firstcopy.tail != secondcopy.tail: return False
    if firstcopy.attrib != secondcopy.attrib: return False
    if len(firstcopy) != len(secondcopy): return False
    return all(oval_entities_are_identical( \
        fchild, schild) for fchild,schild in zip(firstcopy,secondcopy))


def oval_entity_is_extvar(elem):
    """Check if OVAL entity represented by XML element is OVAL
       <external_variable> element
       Return: True if <external_variable>, False otherwise"""

    return elem.tag == '{%s}external_variable' % oval_ns


element_child_cache = {}


def append(element, newchild):
    """Append new child ONLY if it's not a duplicate"""

    if element not in element_child_cache:
        element_child_cache[element] = dict()

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

    supported_versions = ["oval_5.10", "oval_5.11"]
    if oval_version not in supported_versions:
        supported_versions_str = ", ".join(supported_versions)
        sys.stderr.write(
            "Suspicious oval version \"%s\", one of {%s} is "
            "expected.\n" % (oval_version, supported_versions_str))
        sys.exit(1)


def check_is_loaded(loaded_dict, filename, version):
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


def check_oval_version_from_oval(xml_content, oval_version):
    oval_file_tree = ElementTree.fromstring(_header("", "") + xml_content + footer)
    for defgroup in oval_file_tree.findall("./{%s}def-group" % oval_ns):
        file_oval_version = defgroup.get("oval_version")
  
    if file_oval_version is None:
        # oval_version does not exist in <def-group/>
        # which means the OVAL is supported for any version.
        # By default, that version is 5.10
        file_oval_version = "5.10"
 
    if tuple(oval_version.split(".")) >= tuple(file_oval_version.split(".")):
        return True


def checks(product, oval_version, oval_dirs):
    """Concatenate all XML files in the oval directory, to create the document
       body
       oval_dirs: list of directory with oval files (later has higher priority)
       Return: The document body"""

    body = []
    included_checks_count = 0
    reversed_dirs = oval_dirs[::-1]  # earlier directory has higher priority
    already_loaded = dict()  # filename -> oval_version

    for oval_dir in reversed_dirs:
        try:
            # sort the files to make output deterministic
            for filename in sorted(os.listdir(oval_dir)):
                if filename.endswith(".xml"):
                    with open(os.path.join(oval_dir, filename), 'r') as xml_file:
                        xml_content = xml_file.read()
                        if not check_is_applicable_for_product(xml_content, product):
                            continue
                        if check_is_loaded(already_loaded, filename, oval_version):
                            continue
                        if not check_oval_version_from_oval(xml_content, oval_version):
                            continue
                        body.append(xml_content)
                        included_checks_count += 1
                        already_loaded[filename] = oval_version
        except OSError as e:
            if e.errno != errno.ENOENT:
                raise
            else:
                sys.stderr.write("Not merging OVAL content from the "
                                 "'%s' directory as the directory does not "
                                 "exist\n" % (oval_dir))
    sys.stderr.write("Merged %d OVAL checks.\n" % (included_checks_count))

    return "".join(body)


def main():
    p = argparse.ArgumentParser()
    p.add_argument("--ssg_version", default="unknown",
                   help="SSG version for reporting purposes. example: 0.1.34")
    p.add_argument("--product", required=True,
                   help="which product are we building for? example: rhel7")
    p.add_argument("--oval_config", required=True,
                   help="Location of the oval.config file.")
    p.add_argument("--oval_version", required=True,
                   help="OVAL version to use. Example: 5.11, 5.10, ...")
    p.add_argument("--output", type=argparse.FileType('w'), required=True)
    p.add_argument("ovaldirs", metavar="OVAL_DIR", nargs="+",
                   help="Directory(ies) from which we will collect "
                   "OVAL definitions to combine. Order matters, latter "
                   "directories override former.")

    args, unknown = p.parse_known_args()
    if unknown:
        sys.stderr.write(
            "Unknown positional arguments " + ",".join(unknown) + ".\n"
        )
        sys.exit(1)

    if os.path.isfile(args.oval_config):
        multi_platform = \
            parse_conf_file(args.oval_config, args.product)
        header = _header(args.oval_version, args.ssg_version)
    else:
        sys.stderr.write("The directory specified does not contain the %s "
                         "file!\n" % (args.oval_config))
        sys.exit(1)

    body = checks(args.product, args.oval_version, args.ovaldirs)

    # parse new file(string) as an ElementTree, so we can reorder elements
    # appropriately
    corrected_tree = ElementTree.fromstring(
        ("%s%s%s" % (header, body, footer)).encode("utf-8"))
    tree = add_platforms(corrected_tree, multi_platform)
    definitions = ElementTree.Element("{%s}definitions" % oval_ns)
    tests = ElementTree.Element("{%s}tests" % oval_ns)
    objects = ElementTree.Element("{%s}objects" % oval_ns)
    states = ElementTree.Element("{%s}states" % oval_ns)
    variables = ElementTree.Element("{%s}variables" % oval_ns)

    for childnode in tree.findall("./{%s}def-group/*" % oval_ns):
        if childnode.tag is ElementTree.Comment:
            continue
        elif childnode.tag.endswith("definition"):
            append(definitions, childnode)
        elif childnode.tag.endswith("_test"):
            append(tests, childnode)
        elif childnode.tag.endswith("_object"):
            append(objects, childnode)
        elif childnode.tag.endswith("_state"):
            append(states, childnode)
        elif childnode.tag.endswith("_variable"):
            append(variables, childnode)
        else:
            sys.stderr.write("Warning: Unknown element '%s'\n"
                             % (childnode.tag))

    root = ElementTree.fromstring(("%s%s" % (header, footer)).encode("utf-8"))
    root.append(definitions)
    root.append(tests)
    root.append(objects)
    root.append(states)
    if list(variables):
        root.append(variables)

    ElementTree.ElementTree(root).write(args.output)

    sys.exit(0)

if __name__ == "__main__":
    main()
