#!/usr/bin/python

#
# create_package_checks.py
#   automatically generate checks for installed/removed packages
#
# NOTE: The file 'template_package' should be located in the same working directory as this script. The
# template contains the following tags that *must* be replaced successfully in order for the checks to work.
#
# PKGNAME - the name of the package that should be installed/removed
# PKGSTATUS - must be either the string "removed" or the string "installed"
# PKGCCE - the corresponding CCE reference (optional)
# PKGEXISTANCE - will either be "all_exist" (installed) or "none_exist" (removed)
#
# The CSV file must contain lines that look like this:
#
#   aide,installed,4209-3
#   vlock,removed,3910-7
#
# The first field is the name of the RPM package.  The second field specifies if the package should
# be installed for removed.  The third and final field contains a CCE reference if applicable.
#

import sys, csv, re

def output_check(package_info):
    pkgname, pkgstatus, pkgcce = package_info
    if (pkgname and pkgstatus):
        with open("./template_package", 'r') as templatefile:
            filestring = templatefile.read()
            filestring = filestring.replace("PKGNAME", pkgname)
            filestring = filestring.replace("PKGSTATUS", pkgstatus)
            filestring = filestring.replace("PKGCCE", pkgcce if pkgcce else "TODO")
            filestring = filestring.replace("PKGEXISTANCE", "all_exist" if (pkgstatus == "installed") else "none_exist")
            with open("./output/package_" + pkgname + "_" + pkgstatus + ".xml", 'wb+') as outputfile:
                outputfile.write(filestring)
                outputfile.close()
    else:
        print("ERROR: input violation: both package name and package status must be defined")
        print("   pkgname --> \"%s\" pkgstatus --> \"%s\" pkgcce --> \"%s\"" % (pkgname, pkgstatus, pkgcce))

def main():
    if len(sys.argv) < 2:
        print("usage: %s <CSV_FILE_PATH>" % sys.argv[0])
        print("   the csv file should contain lines of the format:")
        print("   PACKAGE_NAME,(removed|installed),PACKAGE_CCE")
        sys.exit(1)
    with open(sys.argv[1], 'r') as csv_file:
        csv_lines = csv.reader(csv_file)
        for line in csv_lines:
            output_check(line)
    sys.exit(0)

if __name__ == "__main__":
    main()
