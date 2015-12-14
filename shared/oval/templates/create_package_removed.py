#!/usr/bin/python2

#
# create_package_removed.py
#   automatically generate checks for removed packages
#
# NOTE: The file 'template_package_removed' should be located in the same
# working directory as this script. The template contains the following tags
# that *must* be replaced successfully in order for the checks to work.
#
# PKGNAME - the name of the package that should be removed
#

import sys
import csv


def output_check(package_info):
	pkgname = package_info[0]
	if pkgname:
		with open("./template_package_removed", 'r') as templatefile:
			filestring = templatefile.read()
			filestring = filestring.replace("PKGNAME", pkgname)
		with open("./output/package_" + pkgname + "_removed.xml", 'w+') as outputfile:
			outputfile.write(filestring)
			outputfile.close()

		with open("./template_BASH_package_removed", 'r') as bash_template_file:
			filestring = bash_template_file.read()
			filestring = filestring.replace("PKGNAME", pkgname)
		with open("./output/package_" + pkgname + "_removed.sh", 'w+') as bash_output_file:
			bash_output_file.write(filestring)
			bash_output_file.close()
	else:
		print "ERROR: input violation: the package name must be defined"


def main():
    if len(sys.argv) < 2:
        print "usage: %s <CSV_FILE_PATH>" % sys.argv[0]
        print "   the csv file should contain lines of the format:"
        print "   PACKAGE_NAME"
        sys.exit(1)

    with open(sys.argv[1], 'r') as csv_file:
        csv_lines = csv.reader(csv_file)
        for line in csv_lines:

            # Skip lines of input file starting with comment '#' character
            if line[0].startswith('#'):
                continue

            output_check(line)

    sys.exit(0)

if __name__ == "__main__":
    main()
