#!/usr/bin/python

#
# create_package_removed.py
#   automatically generate checks for removed packages
#
# NOTE: The file 'template_package_removed' should be located in the same working directory as this script. The
# template contains the following tags that *must* be replaced successfully in order for the checks to work.
#
# PKGNAME - the name of the package that should be removed
#

import sys, csv, re

def output_check(package_info):
    pkgname = package_info[0]
    if (pkgname):
        with open("./template_package_removed", 'r') as templatefile:
            filestring = templatefile.read()
            filestring = filestring.replace("PKGNAME", pkgname)
            with open("./output/package_" + pkgname + "_removed.xml", 'wb+') as outputfile:
                outputfile.write(filestring)
                outputfile.close()

def main():
    if len(sys.argv) < 2:
        print("usage: %s <CSV_FILE_PATH>" % sys.argv[0])
        print("   the csv file should contain lines of the format:")
        print("   PACKAGE_NAME")
        sys.exit(1)

    with open(sys.argv[1], 'r') as csv_file:
        csv_lines = csv.reader(csv_file)
        for line in csv_lines:
            output_check(line)
    sys.exit(0)

if __name__ == "__main__":
    main()
