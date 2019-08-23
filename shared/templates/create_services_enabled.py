#!/usr/bin/env python2

#
# create_services_enabled.py
#   automatically generate checks for enabled services

import sys

from template_common import FilesGenerator, UnknownTargetError


class ServiceEnabledGenerator(FilesGenerator):
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

        if target == "oval":
            self.file_from_template(
                "./template_OVAL_service_enabled",
                {
                    "SERVICENAME": servicename,
                    "PACKAGENAME": packagename,
                    "DAEMONNAME": daemonname
                },
                "./oval/service_{0}_enabled.xml", servicename
            )
        elif target == "bash":
            self.file_from_template(
                "./template_BASH_service_enabled",
                {
                    "SERVICENAME": servicename,
                    "DAEMONNAME": daemonname
                },
                "./bash/service_{0}_enabled.sh", servicename
            )

        elif target == "ansible":
            self.file_from_template(
                "./template_ANSIBLE_service_enabled",
                {
                    "SERVICENAME": servicename,
                    "PACKAGENAME": packagename,
                    "DAEMONNAME": daemonname
                },
                "./ansible/service_{0}_enabled.yml", servicename
            )

        elif target == "puppet":
            self.file_from_template(
                "./template_PUPPET_service_enabled",
                {
                    "SERVICENAME": servicename,
                    "DAEMONNAME": daemonname
                },
                "./puppet/service_{0}_enabled.yml", servicename
            )

        else:
            raise UnknownTargetError(target)

    def csv_format(self):
        return("CSV should contains lines of the format: " +
               "servicename,packagename")
