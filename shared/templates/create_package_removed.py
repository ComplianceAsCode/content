#!/usr/bin/python2

#
# create_package_removed.py
#   automatically generate checks for removed packages

import sys

from template_common import FilesGenerator, UnknownTargetError

class PackageRemovedGenerator(FilesGenerator):

    def generate(self, target, package_info):
        pkgname = package_info[0]
        if pkgname:
            if target == "oval":

                self.file_from_template(
                    "./template_package_removed",
                    { "PKGNAME" : pkgname},
                    "./oval/package_{0}_removed.xml", pkgname
                )

            elif target == "bash":
                self.file_from_template(
                    "./template_BASH_package_removed",
                    { "PKGNAME" : pkgname },
                    "./bash/package_{0}_removed.sh", pkgname
                )

            elif target == "ansible":
                self.file_from_template(
                    "./template_ANSIBLE_package_removed",
                    { "PKGNAME" : pkgname },
                    "./ansible/package_{0}_removed.yml", pkgname
                )

            elif target == "anaconda":
                self.file_from_template(
                    "./template_ANACONDA_package_removed",
                    { "PKGNAME" : pkgname },
                    "./anaconda/package_{0}_removed.anaconda", pkgname
                )

            elif target == "puppet":
                self.file_from_template(
                    "./template_PUPPET_package_removed",
                    { "PKGNAME" : pkgname },
                    "./puppet/package_{0}_removed.pp", pkgname
                )

            else:
                raise UnknownTargetError(target)
        else:
            print "ERROR: input violation: the package name must be defined"

    def csv_format(self):
        return("CSV should contains lines of the format: " +
                   "PACKAGE_NAME")

if __name__ == "__main__":
    PackageRemovedGenerator().main()
