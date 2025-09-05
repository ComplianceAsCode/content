#
# create_package_installed.py
#   automatically generate checks for installed packages
#

import re
from template_common import FilesGenerator, UnknownTargetError


class PackageInstalledGenerator(FilesGenerator):
    def generate(self, target, package_info):
        pkgname = package_info[0]
        if not pkgname:
            raise RuntimeError(
                "ERROR: input violation: the package name must be defined")

        if target == "oval":
            evr = ""
            # If the input is "pkgname,evr", verify if the evr string is in correct format
            if len(package_info) > 1:
                evr = package_info[1]
                if evr and not re.match(r'\d:\d[\d\w+.]*-\d[\d\w+.]*', evr, 0):
                    raise RuntimeError(
                        "ERROR: input violation: evr should be in epoch:version-release format",
                        "current package is", pkgname, "current evr is", evr)

            self.file_from_template(
                "./template_OVAL_package_installed",
                {
                    "PKGNAME": pkgname,
                    "EVR": evr
                },
                "./oval/package_{0}_installed.xml", pkgname
            )

        elif target == "bash":
            self.file_from_template(
                "./template_BASH_package_installed",
                {"PKGNAME": pkgname},
                "./bash/package_{0}_installed.sh", pkgname
            )

        elif target == "ansible":
            self.file_from_template(
                "./template_ANSIBLE_package_installed",
                {"PKGNAME": pkgname},
                "./ansible/package_{0}_installed.yml", pkgname
            )

        elif target == "anaconda":
            self.file_from_template(
                "./template_ANACONDA_package_installed",
                {"PKGNAME": pkgname},
                "./anaconda/package_{0}_installed.anaconda", pkgname
            )

        elif target == "puppet":
            self.file_from_template(
                "./template_PUPPET_package_installed",
                {"PKGNAME": pkgname},
                "./puppet/package_{0}_installed.pp", pkgname
            )

        else:
            raise UnknownTargetError(target)

    def csv_format(self):
        return("CSV should contains lines of the format: " +
               "PACKAGE_NAME[,EVR_STRING]")
