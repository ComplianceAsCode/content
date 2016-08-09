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

def output_check(package_info):
    pkgname = package_info[0]
    if pkgname:

        file_from_template(
            "./template_OVAL_package_installed",
            { "PKGNAME" : pkgname },
            "./output/package_{0}_installed.xml", pkgname
        )

        file_from_template(
            "./template_BASH_package_installed",
            { "PKGNAME" : pkgname },
            "./output/package_{0}_installed.sh", pkgname
        )

    else:
        print "ERROR: input violation: the package name must be defined"


def main():
    if len(sys.argv) < 2:
        print("usage: %s <CSV_FILE_PATH>" % sys.argv[0])
        print("   the csv file should contain lines of the format:")
        print("   PACKAGE_NAME")
        sys.exit(1)

    filename = sys.argv[1]
    csv_map(filename, output_check, skip_comments = True)

    sys.exit(0)

if __name__ == "__main__":
    main()
