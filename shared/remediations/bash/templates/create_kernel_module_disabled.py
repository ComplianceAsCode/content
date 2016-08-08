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
from template_common import *


def output_checkfile(kerninfo):
    # get the items out of the list
    kernmod = kerninfo[0]

    file_from_template(
        "./template_kernel_module_disabled",
        {
           "KERNMODULE": kernmod
        },
        "./output/kernel_module_{0}_disabled.sh", kernmod
    )

def main():
    if len(sys.argv) < 2:
        print "Provide a CSV file containing lines of the format: kernmod"
        sys.exit(1)

    filename = sys.argv[1]
    csv_map(filename, output_checkfile)

    sys.exit(0)

if __name__ == "__main__":
    main()
