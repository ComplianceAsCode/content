#!/usr/bin/python2

#
# verify-input-sanity.py
#   perform sanity checks on the individual OVAL checks that exist within
#   the src/input/oval directory
#

# the python modules that we need
import os
import datetime
import lxml.etree as ET

timestamp = datetime.datetime.utcnow().strftime("%Y-%m-%dT%H:%M:%S")

# the "oval_header" variable must be prepended to the body of the check to form
# valid XML
oval_header = '''<?xml version="1.0" encoding="UTF-8"?>
<oval_definitions
    xmlns="http://oval.mitre.org/XMLSchema/oval-definitions-5"
    xmlns:unix="http://oval.mitre.org/XMLSchema/oval-definitions-5#unix"
    xmlns:ind="http://oval.mitre.org/XMLSchema/oval-definitions-5#independent"
    xmlns:linux="http://oval.mitre.org/XMLSchema/oval-definitions-5#linux"
    xmlns:oval="http://oval.mitre.org/XMLSchema/oval-common-5"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://oval.mitre.org/XMLSchema/oval-definitions-5#unix unix-definitions-schema.xsd
        http://oval.mitre.org/XMLSchema/oval-definitions-5#independent independent-definitions-schema.xsd
        http://oval.mitre.org/XMLSchema/oval-definitions-5#linux linux-definitions-schema.xsd
        http://oval.mitre.org/XMLSchema/oval-definitions-5 oval-definitions-schema.xsd
        http://oval.mitre.org/XMLSchema/oval-common-5 oval-common-schema.xsd">
       <generator>
        <oval:product_name>testoval.py</oval:product_name>
        <oval:product_version>0.0.1</oval:product_version>
        <oval:schema_version>5.10</oval:schema_version>
        <oval:timestamp>%s</oval:timestamp>
    </generator>''' % (timestamp)

# the "oval_footer" variable must be appended to the body of the check to form
# valid XML
oval_footer = '</oval_definitions>'

# the namespace we are working in
oval_namespace = "{http://oval.mitre.org/XMLSchema/oval-definitions-5}"
xccdf_header = '<?xml version="1.0" encoding="UTF-8"?><xccdf>'
xccdf_footer = '</xccdf>'

# print a blank line to keep things pretty
print

#
################################################################################
##
#
# The directory src/input/oval contains all of the OVAL checks that are
# implemented within scap-security-guide. In order to build the XCCDF and OVAL
# properly, several helper scripts expect that the ID assigned to each OVAL
# check matches its file name.
#
# Assume we have an OVAL check called "mount_option_var_tmp_bind.xml" in the
# src/input/oval directory. The ID of this check *must* be
# "mount_option_var_tmp_bind" like so:
#
# <def-group>
#   <definition class="compliance" id="mount_option_var_tmp_bind" version="1">
#     <metadata>
#
# This piece of Python will step through each OVAL check in src/input/oval
# and verify that the ID assigned to the check matches the name of the file.
# If a mismatch is found, then a warning is printed to stdout.
#
################################################################################
##
#

# make the oval directory our working directory
os.chdir("../input/oval")

# generate a list of all the OVAL checks
oval_file_list = []
for root, dirs, files in os.walk("."):
    if root == ".":
        for name in files:
            if name.find(".xml") > -1:
                oval_file_list.append(root + "/" + name)

# step through each file and open it for reading
for oval_check in oval_file_list:
    with open(oval_check, 'r') as infile:
        # form valid XML so that we can parse it
        oval_xml_contents = oval_header + infile.read() + oval_footer
        # parse the XML at this point
        tree = ET.fromstring(oval_xml_contents)
        # extract the ID of the check
        definition_node = tree.findall("./" + oval_namespace + "def-group/*")
        oval_id = "Error"
        for node in definition_node:
            if node.tag == (oval_namespace + "definition"):
                oval_id = node.get("id")
        # at this point the variable oval_id should contain the id of the oval
        # check now we make sure that the name of the file matches the oval id
        if oval_check.find(oval_id + ".xml") < 0:
            print ("  WARNING: OVAL check " +
                   oval_check.replace("./", "src/input/oval/") +
                   " has ID \"" + oval_id + "\"")
            print ("           the ID should match the file name" +
                   " without the .xml\n")

#
################################################################################
##
#
# This section of Python looks through all of the XCCDF files for references to
# OVAL checks. If a reference is found we want to make sure that a
# corresponding OVAL check exists in the src/input/oval directory. We print
# a relatively polite warning if a XCCDF Rule references an OVAL check that
# does not exist.
#
# Again, lots of regex-fu here. In their raw state the XCCDF files are not
# valid XML. The next iteration of this file may add all of the XML complexity
# so that we can perform these validations by parsing XML. That would form a
# more complete
# solution.
#
################################################################################
##
#

# make the input directory our working directory
# remember that we are currently at "../input/oval"
os.chdir("..")

# exclude these directories in the search for XCCDF files
exclude_subdirs = ['.', './oval', './oval/templates',
                   './oval/templates/output']

# generate a list of all the XML files that are used to generate the XCCDF
xccdf_xml_files = []
for root, dirs, files in os.walk("."):
    if not root in exclude_subdirs:
        for name in files:
            if name.find(".xml") > -1:
                xccdf_xml_files.append(root + "/" + name)

# step through each file and open it for reading
for xccdf_file in xccdf_xml_files:
    with open(xccdf_file, 'r') as infile:
        # form valid XML so that we can parse it
        xccdf_xml_contents = xccdf_header + infile.read() + xccdf_footer
        # parse the XML at this point
        try:
            tree = ET.fromstring(xccdf_xml_contents)
        except ET.XMLSyntaxError as e:
            print ("  XML syntax error in file %s:"
                   % xccdf_file.replace("./", "src/input/"))
            print " ", e.msg, "\n"
        # extract all of the rules that are defined within the XCCDF
        xccdf_rules = tree.findall(".//Rule")
        for xccdf_rule in xccdf_rules:
            # extract any reference to an OVAL check
            oval_check_refs = xccdf_rule.findall(".//oval")
            # make sure the OVAL references point to an actual check
            for oval_ref in oval_check_refs:
                # build a path to look for
                if oval_ref.get("id"):
                    file_name = "./oval/" + oval_ref.get("id") + ".xml"
                    if not os.access(file_name, os.F_OK):
                        print ("  WARNING: XCCDF Rule \"" + xccdf_rule.get("id")
                               + "\" references OVAL check \"" +
                               oval_ref.get("id") + "\" which does not exist")
                        print ("           problem occurs in file: " +
                               xccdf_file.replace("./", "src/input/") + "\n")
                else:
                    print ("  WARNING: XCCDF Rule \"" + xccdf_rule.get("id")
                           + "\" in file " + xccdf_file.replace("./",
                           "src/input/") + " contains a null OVAL check\n")

# we are done
exit()
