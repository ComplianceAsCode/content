#!/usr/bin/python2

import datetime
import lxml.etree as ET
import os
import os.path
import platform
import re
import sys

from copy import deepcopy

from ConfigParser import SafeConfigParser

oval_ns = "http://oval.mitre.org/XMLSchema/oval-definitions-5"
timestamp = datetime.datetime.utcnow().strftime("%Y-%m-%dT%H:%M:%S")
conf_file = 'oval.config'
footer = '</oval_definitions>'

# SSG Makefile to official product name mapping
CHROMIUM = 'Google Chromium Browser'
DEBIAN = 'Debian'
FEDORA = 'Fedora'
FIREFOX = 'Mozilla Firefox'
JRE = 'Java Runtime Environment'
RHEL = 'Red Hat Enterprise Linux'
WEBMIN = 'Webmin'
FUSE = 'JBoss Fuse'
OPENSUSE = 'OpenSUSE'
SUSE = 'SUSE Linux Enterprise'


def _header(schema_version):
    header = '''<?xml version="1.0" encoding="UTF-8"?>
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
        <oval:product_name>python</oval:product_name>
        <oval:product_version>%s</oval:product_version>
        <oval:schema_version>%s</oval:schema_version>
        <oval:timestamp>%s</oval:timestamp>
    </generator>''' % (platform.python_version(), schema_version, timestamp)

    return header


def parse_conf_file(conf_file, product):
    parser = SafeConfigParser()
    parser.read(conf_file)
    multi_platform = {}
    oval_version = None

    for section in parser.sections():
        for name, setting in parser.items(section):
            setting = re.sub('.;:', ',', re.sub(' ', '', setting))
            if name == product + '_oval_version':
                oval_version = setting
            elif not oval_version and name == 'oval_version':
                oval_version = setting
            else:
                multi_platform[name] = [item for item in setting.split(",")]

    if oval_version is None:
        print 'ERROR! The setting returned a value of \'%s\'!' % oval_version
        sys.exit(1)

    return oval_version, multi_platform


def map_product(version):
    """Maps SSG Makefile internal product name to official product name"""

    product_name = None

    if re.findall('chromium', version):
        product_name = CHROMIUM
    if re.findall('fedora', version):
        product_name = FEDORA
    if re.findall('firefox', version):
        product_name = FIREFOX
    if re.findall('jre', version):
        product_name = JRE
    if re.findall('rhel', version):
        product_name = RHEL
    if re.findall('webmin', version):
        product_name = WEBMIN
    if re.findall('debian', version):
        product_name = DEBIAN
    if re.findall('fuse', version):
        product_name = FUSE
    if re.findall('opensuse', version):
        product_name = OPENSUSE
    if re.findall('suse', version):
        product_name = SUSE

    return product_name

def check_is_applicable_for_product(oval_check_def, product):
    """Based on the <platform> specifier of the OVAL check determine if this
    OVAL check is applicable for this product. Return 'True' if so, 'False'
    otherwise"""

    product_version = None
    match = re.search(r'\d+$', product)
    if match is not None:
        product_version = product[-1:]
        product = product[:-1]

    # Define general platforms
    multi_platforms = ['<platform>multi_platform_all',
                       '<platform>multi_platform_' + product ]

    # First test if OVAL check isn't for 'multi_platform_all' or
    # 'multi_platform_' + product
    for mp in multi_platforms:
        if mp in oval_check_def and product in ['rhel', 'fedora', 'rhel-osp', 'debian']:
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
    for affected in xml_tree.findall('.//*[@family="unix"]'):
        for plat_elem in affected:
            try:
                if plat_elem.text == 'multi_platform_oval':
                    for platforms in multi_platform[plat_elem.text]:
                        for plat in multi_platform[platforms]:
                            platform = ET.Element('platform')
                            platform.text = map_product(platforms) + ' ' + plat
                            affected.insert(1, platform)
                else:
                    for platforms in multi_platform[plat_elem.text]:
                        platform = ET.Element('platform')
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

    if elem.tag == '{%s}external_variable' % oval_ns: return True
    return False


def append(element, newchild):
    """Append new child ONLY if it's not a duplicate"""

    newid = newchild.get("id")
    existing = element.find(".//*[@id='" + newid + "']")
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
                sys.stderr.write("\nNotification: this ID is used more than " +
                                 "once and should represent equivalent " +
                                 "elements: %s \n" % newid)
                sys.stderr.write("Rewrite the corresponding OVAL checks by " +
                                 "placing the identical IDs into its own " +
                                 "definition, and extend this definition " +
                                 "on necessary places.\n")
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
                sys.stderr.write("\nError: it's not possible to use the " +
                                 "same ID: %s " % newid + "for two " +
                                 "semantically different OVAL entities:\n")
                sys.stderr.write("First entity  %s\n" % ET.tostring(existing))
                sys.stderr.write("Second entity %s\n" % ET.tostring(newchild))
                sys.stderr.write("Use different ID for the second entity!!!\n")
                sys.exit(1)
    else:
        element.append(newchild)


def checks(product):
    """Concatenate all XML files in the oval directory, to create the document
       body
       Return: The document body"""

    body = ""
    included_checks_count = 0
    for filename in os.listdir(sys.argv[3]):
        if filename.endswith(".xml"):
            with open(os.path.join(sys.argv[3], filename), 'r') as xml_file:
                xml_content = xml_file.read()
                if check_is_applicable_for_product(xml_content, product):
                    body = body + xml_content
                    included_checks_count += 1

    if len(sys.argv) == 6:
        for filename in os.listdir(sys.argv[4]):
            if filename.endswith(".xml"):
                with open(os.path.join(sys.argv[4], filename), 'r') as xml_file:
                    filecontent = xml_file.read()
                    if '<platform>multi_platform_all</platform>' in filecontent:
                        body = body + filecontent
                    elif '<platform>' + sys.argv[5] + '</platform>' in filecontent:
                        body = body + filecontent
                    elif '<platform>' + sys.argv[6] + '</platform>' in filecontent:
                        body = body + filecontent

    sys.stderr.write("\nNotification: Merged %d OVAL checks into OVAL document.\n" % included_checks_count)

    return body


def main():
    if len(sys.argv) < 4:
        print "Provide a directory name, which contains the checks."
        sys.exit(1)

    # Get header with schema version
    oval_config = os.path.join(sys.argv[1], conf_file)
    product = sys.argv[2]

    oval_schema_version = None
    runtime_oval_schema_version = os.getenv('RUNTIME_OVAL_VERSION', None)

    if os.path.isfile(oval_config):
        (config_oval_schema_version, multi_platform) = parse_conf_file(oval_config, product)
        if runtime_oval_schema_version is not None and \
           runtime_oval_schema_version != config_oval_schema_version:
            oval_schema_version = runtime_oval_schema_version
        else:
            oval_schema_version = config_oval_schema_version
        header = _header(oval_schema_version)
    else:
        print 'The directory specified does not contain the %s file!' % conf_file
        sys.exit(1)

    body = checks(product)

    # parse new file(string) as an ElementTree, so we can reorder elements
    # appropriately
    corrected_tree = ET.fromstring(header + body + footer)
    tree = add_platforms(corrected_tree, multi_platform)
    definitions = ET.Element("definitions")
    tests = ET.Element("tests")
    objects = ET.Element("objects")
    states = ET.Element("states")
    variables = ET.Element("variables")

    for childnode in tree.findall("./{http://oval.mitre.org/XMLSchema/oval-definitions-5}def-group/*"):
        if childnode.tag is ET.Comment:
            continue
        if childnode.tag.endswith("definition"):
            append(definitions, childnode)
        if childnode.tag.endswith("_test"):
            append(tests, childnode)
        if childnode.tag.endswith("_object"):
            append(objects, childnode)
        if childnode.tag.endswith("_state"):
            append(states, childnode)
        if childnode.tag.endswith("_variable"):
            append(variables, childnode)

    tree = ET.fromstring(header + footer)
    tree.append(definitions)
    tree.append(tests)
    tree.append(objects)
    tree.append(states)
    if list(variables):
        tree.append(variables)

    ET.dump(tree)
    sys.exit(0)

if __name__ == "__main__":
    main()
