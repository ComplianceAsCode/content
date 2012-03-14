#!/usr/bin/python

#
# verify-references.py
#   perform general verification of references within the source tree
#

# the python modules that we need
import os, re

# print a blank line to keep things pretty
print

#
##################################################################################
#
# The directory src/input/checks contains all of the OVAL checks that are implemented within scap-security-guide.
# In order to build the XCCDF and OVAL properly, several helper scripts expect that the ID assigned to each OVAL
# matches its file name.
#
# Assume we have an OVAL check called "mount_option_var_tmp_bind.xml" in the src/input/checks directory. The ID
# of this check *must* be "mount_option_var_tmp_bind" like so:
#
# <def-group>
#   <definition class="compliance" id="mount_option_var_tmp_bind" version="1">
#     <metadata>
#
# This piece of Python will step through each OVAL check in src/input/checks and verify that the ID matches the
# name of the file. Because each OVAL check is not technically valid XML (it is turned into valid XML by various
# helper scripts) we will have to use some regex-fu to find the ID of each check. Future iterations of this script
# could behave a lot like testcheck.py and form valid XML before verification.
#
##################################################################################
#

# generate a list of all the OVAL checks
oval_checks = []
for root, dirs, files in os.walk("../input"):
    if (root == "../input/checks"):
        for name in files:
            if (name.find(".xml") > -1):
                oval_checks.append(root + "/" + name)

# step through the OVAL checks
for oval_check in oval_checks:
    with open(oval_check, 'r') as infile:
        for line in infile.readlines():
            # the id of the oval check should be the first id that we encounter
            match = re.search(" id=\"(.+?)\"", line)
            if (match != None):
                # compare the id to the file name - they should match
                if (oval_check.find(match.group(1)) < 0):
                    print "  WARNING: the check " + oval_check + " has id \"" + match.group(1) + "\""
                    print "           the id should match the file name (without the .xml at the end)\n"
                # break out of this for loop and move on to next check
                break

#
##################################################################################
#
# This section of Python looks through all of the XCCDF files for references to OVAL checks. If a reference is found we
# want to make sure that a corresponding OVAL check exists in the src/input/checks directory. We print a relatively polite
# warning if a XCCDF Rule references an OVAL check that does not exist.
#
# Again, lots of regex-fu here. In their raw state the XCCDF files are not valid XML. The next iteration of this file may
# add all of the XML complexity so that we can perform these validations by parsing XML.  That would form a more complete
# solution.
#
##################################################################################
#

# generate a list of all the XML files that are used to generate the XCCDF
xccdf_xml_files = []
for root, dirs, files in os.walk("../input"):
    if ((root != "../input") and (root != "../input/checks")):
        for name in files:
            if (name.find(".xml") > -1):
                xccdf_xml_files.append(root + "/" + name)

# step through each XML file
for xml_file in xccdf_xml_files:
    with open(xml_file, 'r') as infile:
        # start with an empty list of references
        references_oval_checks = []
        # boolean flag that helps us keep track of comment blocks
        in_comment = False
        # look for references to OVAL checks
        for line in infile.readlines():
            # examine the line for end of comment
            if (re.search("-->", line)):
                in_comment = False
                continue
            # continue if we are in a comment block
            if (in_comment):
                continue
            # see if we start a comment block
            if (re.search("^\s*<!--", line)):
                in_comment = True
                continue
            # we are not in a comment block so find references to OVAL checks
            match = re.search("^\s*<oval id=\"(.+?)\"", line)
            if (match):
                references_oval_checks.append(match.group(1))
        # at this point references_oval_checks should contain all of the referenced OVAL checks
        # loop through the references and make sure they point to an actual file in src/input/checks
        for reference in references_oval_checks:
            # build the file name
            file_name = "../input/checks/" + reference + ".xml"
            if (not os.access(file_name, os.F_OK)):
                print "  WARNING: file " + xml_file + " references OVAL check \"" + reference + "\" which does not exist"
                print "           expects existence of " + file_name + "\n"

# we are done
exit()
