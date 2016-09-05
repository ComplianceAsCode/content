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
import re

from template_common import *

def output_checkfile(target, serviceinfo):
    # get the items out of the list
    servicename, packagename = serviceinfo

    if target == "oval":
        if packagename:
            file_from_template(
                "./template_service_enabled",
                {
                    "SERVICENAME": servicename,
                    "PACKAGENAME": packagename
                },
                "./output/oval/service_{0}_enabled.xml", servicename
            )
        else:
            file_from_template(
                "./template_service_enabled",
                { "SERVICENAME": servicename },
                regex_replace = {
                    "\n\s*<criteria.*>\n\s*<extend_definition.*/>": "",
                    "\s*</criteria>\n\s*</criteria>": "\n    </criteria>"
                },
                filename_format = "./output/oval/service_{0}_enabled.xml",
                filename_value = servicename
            )

    elif target == "bash":

        file_from_template(
            "./template_BASH_service_enabled",
            { "SERVICENAME": servicename },
            "./output/bash/service_{0}_enabled.sh", servicename
        )

    elif target == "ansible":

        file_from_template(
            "./template_ANSIBLE_service_enabled",
            {
                "SERVICENAME": servicename
            },
            "./output/ansible/service_{0}_enabled.yml", servicename
        )

    else:

        raise ValueError("Unknown target " + target)


def help():
    print("Usage:\n\t" + __file__ + " <bash/oval> <csv file>")
    print("CSV should contains lines of the format: " +
               "servicename,packagename")

if __name__ == "__main__":
    main(sys.argv, help, output_checkfile)
