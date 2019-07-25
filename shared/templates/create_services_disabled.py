#
# create_services_disabled.py
#   automatically generate checks for disabled services

import sys

from template_common import FilesGenerator, UnknownTargetError, CSVLineError


class ServiceDisabledGenerator(FilesGenerator):
    def generate(self, target, serviceinfo):
        try:
            # mask service by default
            mask_service = True

            # get the items out of the list
            # items can be in format
            # <service_name, package_name, daemon_name> or
            # <service_name, package_name, daemon_name, mask_service>
            if len(serviceinfo) == 3:
                servicename, packagename, daemonname = serviceinfo
            elif len(serviceinfo) == 4:
                servicename, packagename, daemonname, mask_service = serviceinfo
                # use boolean instead of any string that came from csv file
                if mask_service == "true":
                    mask_service = True
                elif mask_service == "false":
                    mask_service = False
                else:
                    raise ValueError("Unrecognized option for mask_service parameter ({}). ".format(mask_service) +
                                     "Possible values are: true or false.")
            else:
                raise CSVLineError()
            if not packagename:
                packagename = servicename
        except ValueError as e:
            print("\tError unpacking servicename, packagename, daemonname " +
                  "and mask_service: " + str(e))
            print("\tEntry: %s\n" % serviceinfo)
            raise CSVLineError()

        if not daemonname:
            daemonname = servicename

        if target == "bash":
            self.file_from_template(
                "./template_BASH_service_disabled",
                {
                    "SERVICENAME": servicename,
                    "DAEMONNAME": daemonname,
                    "MASK_SERVICE": mask_service
                },
                "./bash/service_{0}_disabled.sh", servicename
            )

        elif target == "ansible":
            self.file_from_template(
                "./template_ANSIBLE_service_disabled",
                {
                    "SERVICENAME": servicename,
                    "DAEMONNAME": daemonname,
                    "MASK_SERVICE": mask_service
                },
                "./ansible/service_{0}_disabled.yml", servicename
            )

        elif target == "puppet":
            self.file_from_template(
                "./template_PUPPET_service_disabled",
                {
                    "SERVICENAME": servicename,
                    "DAEMONNAME": daemonname,
                    "MASK_SERVICE": mask_service
                },
                "./puppet/service_{0}_disabled.yml", servicename
            )

        elif target == "oval":
            self.file_from_template(
                "./template_OVAL_service_disabled",
                {
                    "SERVICENAME": servicename,
                    "DAEMONNAME":  daemonname,
                    "PACKAGENAME": packagename,
                    "MASK_SERVICE": mask_service
                },
                "./oval/service_{0}_disabled.xml", servicename
            )
        else:
            raise UnknownTargetError(target)

    def csv_format(self):
        return("CSV should contains lines of the format: " +
               "servicename,packagename,daemonname[,mask_service]")
