#!/usr/bin/python

import sys
import os
import re
import lxml.etree as etree
from ConfigParser import SafeConfigParser

conf_file = 'oval.config'

# SSG Makefile to official product name mapping
CHROMIUM = 'Google Chromium Browser'
FEDORA = 'Fedora'
FIREFOX = 'Mozilla Firefox'
JRE = 'Java Runtime Environment'
RHEL = 'Red Hat Enterprise Linux'
WEBMIN = 'Webmin'

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

    return product_name

def fix_is_applicable_for_product(platform, product):
    """Based on the platform dict specifier of the remediation script to determine if this
    remediation script is applicable for this product. Return 'True' if so, 'False'
    otherwise"""
    product_name = ''
    product_version = None
    match = re.search(r'\d+$', product)
    if match is not None:
        product_version = product[-1:]
        product = product[:-1]

    # Define general platforms
    multi_platforms = ['multi_platform_all',
                       'multi_platform_' + product ]

    # First test if platform isn't for 'multi_platform_all' or
    # 'multi_platform_' + product
    for mp in multi_platforms:
        if mp in platform and product in ['rhel', 'fedora']:
            return True

    # Get official name for product 
    if product_version is not None:
        product_name = map_product(product) + ' ' + product_version
    else:
        product_name = map_product(product)

    # Test if this is for the concrete product version
    for pf in platform.split(','):
        if product_name == pf.strip():
            return True

    # Remediation script isn't neither a multi platform one, nor isn't applicable
    # for this product => return False to indicate that
    return False

def substitute_vars(fix):
    # brittle and troubling code to assign environment vars to XCCDF values
    env_var = re.match("(\s*source\s+\S+)\n+(\s*declare\s+\S+)\n+(\s*populate\s+)(\S+)\n(.*)",
                       fix.text, re.DOTALL)
    if not env_var:
        # no need to alter fix.text
        return
    # otherwise, create node to populate environment variable
    varname = env_var.group(4)
    mainscript = env_var.group(5)
    fix.text = varname + "=" + '"'
    # new <sub> element to reference XCCDF variable
    xccdf_sub = etree.SubElement(fix, "sub", idref=varname)
    xccdf_sub.tail = '"' + mainscript
    fix.append(xccdf_sub)


def main():
    if len(sys.argv) < 2:
        print "Provide a directory name, which contains the fixes."
        sys.exit(1)

    oval_config = sys.argv[1] + "/" + conf_file
    product = sys.argv[2]
    fixdir = sys.argv[3]
    output = sys.argv[4]

    if os.path.isfile(oval_config):
        (header, multi_platform) = parse_conf_file(oval_config, product)
    else:
        print 'The directory specified does not contain the %s file!' % conf_file
        sys.exit(1)

    fixcontent = etree.Element("fix-content", system="urn:xccdf:fix:script:sh",
                               xmlns="http://checklists.nist.gov/xccdf/1.1")
    fixgroup = etree.SubElement(fixcontent, "fix-group", id="bash",
                                system="urn:xccdf:fix:script:sh",
                                xmlns="http://checklists.nist.gov/xccdf/1.1")

    platform = {}
    included_fixes_count = 0
    for filename in os.listdir(fixdir):
        if filename.endswith(".sh"):
            # create and populate new fix element based on shell file
            fixname = os.path.splitext(filename)[0]

            with open(fixdir + "/" + filename, 'r') as fix_file:
                # assignment automatically escapes shell characters for XML
                script_platform = fix_file.readline().strip('#').strip().split('=')
                if len(script_platform) > 1:
                    platform[script_platform[0].strip()] = script_platform[1].strip()
                if script_platform[0].strip() == 'platform':
                    if fix_is_applicable_for_product(platform['platform'], product):
                        fix = etree.SubElement(fixgroup, "fix", rule=fixname)
                        fix.text = fix_file.read()
                        included_fixes_count += 1

                        # replace instance of bash function "populate" with XCCDF
                        # variable substitution
                        substitute_vars(fix)

    sys.stderr.write("\nNotification: Merged %d remediation scripts into XML document.\n" % included_fixes_count)
    tree = etree.ElementTree(fixcontent)
    tree.write(output, pretty_print=True)

    sys.exit(0)

if __name__ == "__main__":
    main()
