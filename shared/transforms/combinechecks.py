#!/usr/bin/python

import sys
import os
import re
import datetime
import lxml.etree as ET
from ConfigParser import SafeConfigParser

timestamp = datetime.datetime.utcnow().strftime("%Y-%m-%dT%H:%M:%S")

conf_file = 'oval.config'
footer = '</oval_definitions>'

RHEL = 'Red Hat Enterpise Linux'
FEDORA = 'Fedora'


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
        <oval:product_version>2.6.6</oval:product_version>
        <oval:schema_version>%s</oval:schema_version>
        <oval:timestamp>%s</oval:timestamp>
    </generator>''' % (schema_version, timestamp)

    return header


def parse_conf_file(conf_file):
    parser = SafeConfigParser()
    parser.read(conf_file)
    multi_platform = {}
    oval_version = None

    for section in parser.sections():
        for name, setting in parser.items(section):
            setting = re.sub('.;:', ',', re.sub(' ', '', setting))
            if name == 'oval_version':
                oval_version = setting
            else:
                multi_platform[name] = [item for item in setting.split(",")]

    if oval_version is None:
        print 'ERROR! The setting returned a value of \'%s\'!' % oval_version
        sys.exit(1)

    return oval_version, multi_platform


def multi_os(version):
    if re.findall('rhel', version):
        multi_os = RHEL
    if re.findall('fedora', version):
        multi_os = FEDORA

    return multi_os


def add_platforms(xml_tree, multi_platform):
    for affected in xml_tree.findall('.//*[@family="unix"]'):
        for plat_elem in affected:
            try:
                if plat_elem.text == 'multi_platform_oval':
                    for platforms in multi_platform[plat_elem.text]:
                        for plat in multi_platform[platforms]:
                            platform = ET.Element('platform')
                            platform.text = multi_os(platforms) + ' ' + plat
                            affected.insert(1, platform)
                else:
                    for platforms in multi_platform[plat_elem.text]:
                        platform = ET.Element('platform')
                        platform.text = multi_os(plat_elem.text) + ' ' + platforms
                        affected.insert(0, platform)
            except KeyError:
                pass

            # Remove multi_platform element
            if re.findall('multi_platform', plat_elem.text):
                affected.remove(plat_elem)

    return xml_tree


# append new child ONLY if it's not a duplicate
def append(element, newchild):
    newid = newchild.get("id")
    existing = element.find(".//*[@id='" + newid + "']")
    if existing is not None:
        sys.stderr.write("Notification: this ID is used more than once " +
                         "and should represent equivalent elements: " +
                         newid + "\n")
    else:
        element.append(newchild)


def main():
    if len(sys.argv) < 2:
        print "Provide a directory name, which contains the checks."
        sys.exit(1)

    # Get header with schema version
    oval_config = sys.argv[1] + "/" + conf_file

    if os.path.isfile(oval_config):
        (header, multi_platform) = parse_conf_file(oval_config)
        header = _header(header)
    else:
        print 'The directory specified does not contain the %s file!' % conf_file
        sys.exit(1)

    # concatenate all XML files in the checks directory, to create the
    # document body
    body = ""
    for filename in os.listdir(sys.argv[2]):
        if filename.endswith(".xml"):
            with open(sys.argv[2] + "/" + filename, 'r') as xml_file:
                body = body + xml_file.read()

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
    tree.append(variables)

    ET.dump(tree)
    sys.exit(0)

if __name__ == "__main__":
    main()
