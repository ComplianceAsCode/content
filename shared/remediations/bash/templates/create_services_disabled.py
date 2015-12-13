#!/usr/bin/python2

#
# create_services_disabled.py
#   automatically generate remediations for disabled services
#
# NOTE: The file 'template_service_disabled' should be located in the same
# working directory as this script. The template contains the following tags
# that *must* be replaced successfully in order for the remediations to work.
#
# SERVICENAME - the name of the service that should be disabled
# PACKAGENAME - the name of the package that installs the service
#

import sys
import csv


def output_checkfile(serviceinfo):
    # get the items out of the list
    servicename, packagename = serviceinfo
    with open("./template_service_disabled", 'r') as templatefile:
        filestring = templatefile.read()
        filestring = filestring.replace("SERVICENAME", servicename)
        with open("./output/service_" + servicename +
                  "_disabled.sh", 'w+') as outputfile:
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
            output_checkfile(line)

    sys.exit(0)

if __name__ == "__main__":
    main()
