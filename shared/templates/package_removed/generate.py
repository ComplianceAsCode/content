#!/usr/bin/python2

#
# create_package_removed.py
#   automatically generate checks for removed packages

import sys
import os

modules_path = os.path.join(os.path.dirname(__file__),"..","..","modules")
sys.path.append(modules_path)
from templates_common import FilesGenerator, UnknownTargetError

class PackageRemovedGenerator(FilesGenerator):
    def generate(self, target, package_info):
        pkgname = package_info[0]
        if pkgname:
            if target == "oval":

                self.file_from_template(
                    "oval",
                    { "PKGNAME" : pkgname},
                    "package_{0}_removed.xml", pkgname
                )

            elif target == "bash":
                self.file_from_template(
                    "oval",
                    { "PKGNAME" : pkgname },
                    "package_{0}_removed.sh", pkgname
                )

            elif target == "ansible":
                self.file_from_template(
                    "ansible",
                    { "PKGNAME" : pkgname },
                    "package_{0}_removed.yml", pkgname
                )

            elif target == "anaconda":
                self.file_from_template(
                    "anaconda",
                    { "PKGNAME" : pkgname },
                    "package_{0}_removed.anaconda", pkgname
                )

            elif target == "puppet":
                self.file_from_template(
                    "puppet",
                    { "PKGNAME" : pkgname },
                    "package_{0}_removed.pp", pkgname
                )

            else:
                raise UnknownTargetError(target)
        else:
            print "ERROR: input violation: the package name must be defined"

    def supported_targets(self):
        return ["bash","oval","ansible","anaconda","puppet"]

    def extra_help(self):
        return ("CSV should contains lines of the format: " +
              "PACKAGE_NAME")

if __name__ == "__main__":
    PackageRemovedGenerator().run("package_removed", sys.argv)

