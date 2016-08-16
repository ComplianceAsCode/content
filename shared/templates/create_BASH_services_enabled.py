#!/usr/bin/python2

#
# create_services_enabled.py
#   automatically generate remediations for enabled services
#
# NOTE: The file 'template_BASH_service_enabled' should be located in the same
# working directory as this script. The template contains the following tags
# that *must* be replaced successfully in order for the remediations to work.
#
# SERVICENAME - the name of the service that should be enabled
# PACKAGENAME - the name of the package that installs the service
#

import sys

from template_common import *

def output_checkfile(serviceinfo):
    # get the items out of the list
    servicename, packagename = serviceinfo

    file_from_template(
        "./template_BASH_service_enabled",
        { "SERVICENAME": servicename },
        "./output/bash/service_{0}_enabled.sh", servicename
    )

def main():
    if len(sys.argv) < 2:
        print ("Provide a CSV file containing lines of the format: " +
               "servicename,packagename")
        sys.exit(1)

    filename = sys.argv[1]
    csv_map(filename, output_checkfile, skip_comments = True)

    sys.exit(0)

if __name__ == "__main__":
    main()
