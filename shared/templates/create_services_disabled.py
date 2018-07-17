#
# create_services_disabled.py
#   automatically generate checks for disabled services

import sys

from template_common import FilesGenerator, UnknownTargetError


class ServiceDisabledGenerator(FilesGenerator):
    def generate(self, target, serviceinfo):
        try:
            # get the items out of the list
            servicename, packagename, daemonname = serviceinfo
            if not packagename:
                packagename = servicename
        except ValueError as e:
            print("\tEntry: %s\n" % serviceinfo)
            print("\tError unpacking servicename, packagename, and daemonname: " + str(e))
            sys.exit(1)

        if not daemonname:
            daemonname = servicename

        if target == "bash":
            self.file_from_template(
                "./template_BASH_service_disabled",
                {
                    "SERVICENAME": servicename,
                    "DAEMONNAME": daemonname
                },
                "./bash/service_{0}_disabled.sh", servicename
            )

        elif target == "ansible":
            self.file_from_template(
                "./template_ANSIBLE_service_disabled",
                {
                    "SERVICENAME": servicename,
                    "DAEMONNAME": daemonname
                },
                "./ansible/service_{0}_disabled.yml", servicename
            )

        elif target == "puppet":
            self.file_from_template(
                "./template_PUPPET_service_disabled",
                {
                    "SERVICENAME": servicename,
                    "DAEMONNAME": daemonname
                },
                "./puppet/service_{0}_disabled.yml", servicename
            )

        elif target == "oval":
            self.file_from_template(
                "./template_OVAL_service_disabled",
                {
                    "SERVICENAME": servicename,
                    "DAEMONNAME":  daemonname,
                    "PACKAGENAME": packagename
                },
                "./oval/service_{0}_disabled.xml", servicename
            )
        else:
            raise UnknownTargetError(target)

    def csv_format(self):
        return("CSV should contains lines of the format: " +
               "servicename,packagename")
