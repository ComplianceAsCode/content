#!/usr/bin/python2

#
# create_kernel_modules_disabled.py
#   automatically generate checks for disabled kernel modules
#
# NOTE: The file 'template_kernel_module_disabled' should be located in the
# same working directory as this script. The template contains the following
# tags that *must* be replaced successfully in order for the checks to work.
#
# KERNMODULE - the name of the kernel module that should be disabled
#

import sys
import csv


def output_checkfile(kerninfo):
    # get the items out of the list
    kernmod = kerninfo[0]
    with open("./template_kernel_module_disabled", 'r') as templatefile:
        filestring = templatefile.read()
        filestring = filestring.replace("KERNMODULE", kernmod)
        with open("./output/kernel_module_" + kernmod +
                  "_disabled.xml", 'w+') as outputfile:
            outputfile.write(filestring)
            outputfile.close()


def main():
    if len(sys.argv) < 2:
        print "Provide a CSV file containing lines of the format: kernmod"
        sys.exit(1)
    with open(sys.argv[1], 'r') as csv_file:
        # put the CSV line's items into a list
        lines = csv.reader(csv_file)
        for line in lines:

            # Skip lines of input file starting with comment '#' character
            if line[0].startswith('#'):
                continue

            output_checkfile(line)

    sys.exit(0)

if __name__ == "__main__":
    main()
