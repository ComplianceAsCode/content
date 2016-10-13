#!/usr/bin/python2

#
# create_package_removed.py
#   automatically generate checks for removed packages

import sys

from template_common import *

def output_checkfile(target, package_info):
    pkgname = package_info[0]
    if pkgname:
        if target == "oval":

            file_from_template(
                "./template_package_removed",
                { "PKGNAME" : pkgname},
                "./output/oval/package_{0}_removed.xml", pkgname
            )

        elif target == "bash":
            file_from_template(
                "./template_BASH_package_removed",
                { "PKGNAME" : pkgname },
                "./output/bash/package_{0}_removed.sh", pkgname
            )

        elif target == "ansible":
            file_from_template(
                "./template_ANSIBLE_package_removed",
                { "PKGNAME" : pkgname },
                "./output/ansible/package_{0}_removed.yml", pkgname
            )

        else:
            raise UnknownTargetError(target)
    else:
        print "ERROR: input violation: the package name must be defined"

def help():
    print("Usage:\n\t" + __file__ + " <bash/oval/ansible> <csv file>")
    print("CSV should contains lines of the format: " +
               "PACKAGE_NAME")

if __name__ == "__main__":
    main(sys.argv, help, output_checkfile)
