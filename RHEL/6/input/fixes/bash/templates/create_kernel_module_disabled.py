#!/usr/bin/python

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

import sys, csv, re

def output_checkfile(kerninfo):
    # get the items out of the list
    kernmod = kerninfo[0]
    with open("./template_kernel_module_disabled", 'r') as templatefile:
        filestring = templatefile.read()
        filestring = filestring.replace("KERNMODULE", kernmod)
        with open("./output/kernel_module_" + kernmod + "_disabled.sh", 'wb+') as outputfile:
            outputfile.write(filestring)
            outputfile.close()

def main():
    if len(sys.argv) < 2:
        print "Provide a CSV file containing lines of the format: kernmod"
        sys.exit(1)
    with open(sys.argv[1], 'r') as f:
        # put the CSV line's items into a list
        lines = csv.reader(f)
        for line in lines:
            output_checkfile(line)

    sys.exit(0)

if __name__ == "__main__":
    main()

