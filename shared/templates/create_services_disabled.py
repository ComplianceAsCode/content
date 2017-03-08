#!/usr/bin/python2

#
# create_services_disabled.py
#   automatically generate checks for disabled services
#
# NOTE: The file 'template_service_disabled' should be located in the same
# working directory as this script. The template contains the following tags
# that *must* be replaced successfully in order for the checks to work.
#
# SERVICENAME - the name of the service that should be disabled
# PACKAGENAME - the name of the package that installs the service
#

import sys
import re

from template_common import FilesGenerator, UnknownTargetError

class ServiceDisabledGenerator(FilesGenerator):

    def generate(self, target, serviceinfo):
        try:
            # get the items out of the list
            servicename, packagename, daemonname = serviceinfo
        except ValueError as e:
            print "\tEntry: %s\n" % serviceinfo
            print "\tError unpacking servicename, packagename, and daemonname: ", str(e)
            sys.exit(1)

        if not daemonname:
            daemonname = servicename

        if target == "bash":
            self.file_from_template(
                "./template_BASH_service_disabled",
                {
                    "SERVICENAME": servicename
                },
                "./bash/service_{0}_disabled.sh", servicename
            )

        elif target == "ansible":
            self.file_from_template(
                "./template_ANSIBLE_service_disabled",
                {
                    "SERVICENAME": servicename
                },
                "./ansible/service_{0}_disabled.yml", servicename
            )

        elif target == "puppet":
            self.file_from_template(
                "./template_PUPPET_service_disabled",
                {
                    "SERVICENAME": servicename
                },
                "./puppet/service_{0}_disabled.yml", servicename
            )

        elif target == "oval":
            if packagename:
                self.file_from_template(
                    "./template_service_disabled",
                    {
                        "SERVICENAME": servicename,
                        "DAEMONNAME":  daemonname,
                        "PACKAGENAME": packagename
                    },
                    "./oval/service_{0}_disabled.xml", servicename
                )
            else:
                self.file_from_template(
                    "./template_service_disabled",
                    {
                        "SERVICENAME": servicename,
                        "DAEMONNAME":  daemonname
                    },
                    regex_replace = [
                        ("\n\s*<criteria.*>\n\s*<extend_definition.*/>", ""),
                        ("\s*</criteria>\n\s*</criteria>", "\n    </criteria>")
                    ],
                    filename_format = "./oval/service_{0}_disabled.xml",
                    filename_value = servicename
                )

        else:
            raise UnknownTargetError(target)

    def csv_format(self):
        return("CSV should contains lines of the format: " +
                   "servicename,packagename")

if __name__ == "__main__":
    ServiceDisabledGenerator().main()
