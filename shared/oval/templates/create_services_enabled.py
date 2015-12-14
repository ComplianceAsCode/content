#!/usr/bin/python2

#
# create_services_enabled.py
#   automatically generate checks for enabled services
#
# NOTE: The file 'template_service_enabled' should be located in the same
# working directory as this script. The template contains the following tags
# that *must* be replaced successfully in order for the checks to work.
#
# SERVICENAME - the name of the service that should be enabled
# PACKAGENAME - the name of the package that installs the service
#

import sys
import csv
import re


def output_checkfile(serviceinfo):
    # get the items out of the list
    servicename, packagename = serviceinfo
    with open("./template_service_enabled", 'r') as templatefile:
        filestring = templatefile.read()
        filestring = filestring.replace("SERVICENAME", servicename)
        if packagename:
            filestring = filestring.replace("PACKAGENAME", packagename)
        else:
            filestring = re.sub("\n\s*<criteria.*>\n\s*<extend_definition.*/>",
                                "", filestring)
            filestring = re.sub("\s*</criteria>\n\s*</criteria>",
                                "\n    </criteria>", filestring)
        with open("./output/service_" + servicename +
                  "_enabled.xml", 'w+') as outputfile:
            outputfile.write(filestring)
            outputfile.close()


def main():
    if len(sys.argv) < 2:
        print ("Provide a CSV file containing lines of the format: " +
               "servicename,packagename")
        sys.exit(1)
    with open(sys.argv[1], 'r') as csv_file:
        # put the CSV line's items into a list
        servicelines = csv.reader(csv_file)
        for line in servicelines:

            # Skip lines of input file starting with comment '#' character
            if line[0].startswith('#'):
                continue

            output_checkfile(line)

    sys.exit(0)

if __name__ == "__main__":
    main()
