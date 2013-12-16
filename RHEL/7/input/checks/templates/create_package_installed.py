#!/usr/bin/python

#
# create_package_installed.py
#   automatically generate checks for installed packages
#
# NOTE: The file 'template_package_installed' should be located in the same working directory as this script. The
# template contains the following tags that *must* be replaced successfully in order for the checks to work.
#
# PKGNAME - the name of the package that should be installed
#

import sys, csv, re

def output_check(package_info):
    pkgname = package_info[0]
    if pkgname:
        with open("./template_OVAL_package_installed", 'r') as OVALtemplatefile:
            filestring = OVALtemplatefile.read()
            filestring = filestring.replace("PKGNAME", pkgname)
            with open("./output/package_" + pkgname + "_installed.xml", 'wb+') as OVALoutputfile:
                OVALoutputfile.write(filestring)
                OVALoutputfile.close()
	with open("./template_BASH_package_installed", 'r') as BASHtemplatefile:
		filestring = BASHtemplatefile.read()
		filestring = filestring.replace("PKGNAME", pkgname)
		with open("./output/package_" + pkgname + "_installed.sh", 'wb+') as BASHoutputfile:
			BASHoutputfile.write(filestring)
			BASHoutputfile.close()
    else:
        print "ERROR: input violation: the package name must be defined"

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
