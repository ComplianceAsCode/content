#!/usr/bin/python2

#
# create_package_installed.py
#   automatically generate checks for installed packages
#
# NOTE: The file 'template_package_installed' should be located in the same
# working directory as this script. The template contains the following tags
# that *must* be replaced successfully in order for the checks to work.
#
# PKGNAME - the name of the package that should be installed
#

import sys

from template_common import *

def output_checkfile(target, package_info):
    pkgname = package_info[0]
    if pkgname:
        if target == "oval":
            file_from_template(
                "./template_OVAL_package_installed",
                { "PKGNAME" : pkgname },
                "./output/oval/package_{0}_installed.xml", pkgname
            )

        elif target == "bash":
            file_from_template(
                "./template_BASH_package_installed",
                { "PKGNAME" : pkgname },
                "./output/bash/package_{0}_installed.sh", pkgname
            )

        elif target == "ansible":
            file_from_template(
                "./template_ANSIBLE_package_installed",
                { "PKGNAME" : pkgname },
                "./output/ansible/package_{0}_installed.yml", pkgname
            )

        else:
            raise ValueError("Unknown target " + target)


    else:
        print "ERROR: input violation: the package name must be defined"

def help():
    print("Usage:\n\t" + __file__ + " <bash/oval/ansible> <csv file>")
    print("CSV should contains lines of the format: " +
               "PACKAGE_NAME")

if __name__ == "__main__":
    main(sys.argv, help, output_checkfile)
