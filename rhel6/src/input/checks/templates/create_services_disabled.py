#!/usr/bin/python

#
# create_services_disabled.py
#   automatically generate checks for disabled services
#
# NOTE: The file 'template_service_disabled' should be located in the same working directory as this script. The
# template contains the following tags that *must* be replaced successfully in order for the checks to work.
#
# SERVICENAME - the name of the service that should be disabled
# CCE_ID - the corresponding CCE reference (optional)
#
# NOTE: I have removed the code that deals with the "extends_definition" package check because testing revealed
# that it didn't really add anything to the overall check. Checks for disabled services whose corresponding packages
# are not installed still return the correct value of "TRUE". For instance, the "service_squid_disabled.xml" check still
# returns "TRUE" even if the "squid" package is not installed. Removing this code makes for a more concise check.
#
# Just in case we want to eventually add this back here is exactly what was removed:
#
# This goes in the template file 'template_service_disabled':
#
#   <criteria comment="PACKAGENAME is not installed or service is not running" operator="OR">
#       <extend_definition comment="PACKAGENAME is not installed" definition_ref="package_PACKAGENAME_removed" />
#       <SERVICE CHECK CRITERIA BLOCK>
#   </criteria>
#
# Here is the python code that removes the "extend_definition" if no package name was given
#
#   # remove extend_definition if no package name is given
#   if packagename:
#       filestring = filestring.replace("PACKAGENAME", packagename)
#   else:
#       filestring = re.sub("<criteria.*\n.*<extend_definition.*/>","",filestring)
#       filestring = filestring.replace("</criteria>", "",1)
#

import sys, csv, re

def output_checkfile(serviceinfo):
    #get the items out of the list
    servicename, packagename, cce = serviceinfo
    with open("./template_service_disabled", 'r') as templatefile:
        filestring = templatefile.read()
        filestring = filestring.replace("SERVICENAME", servicename)
        filestring = filestring.replace("CCE_ID", cce if cce else "TODO")
        with open("./output/service_" + servicename + "_disabled.xml", 'wb+') as outputfile:
            outputfile.write(filestring)
            outputfile.close()

def main():
    if len(sys.argv) < 2:
        print "Provide a CSV file containing lines of the format: servicename,packagename,CCE"
        sys.exit(1)
    with open(sys.argv[1], 'r') as f:
        # put the CSV line's items into a list
        servicelines = csv.reader(f)
        for line in servicelines:
            output_checkfile(line)

    sys.exit(0)

if __name__ == "__main__":
    main()

