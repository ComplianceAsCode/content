#!/usr/bin/python2

#
# create_kernel_modules_disabled.py
#   automatically generate checks for disabled kernel modules

import sys
from template_common import *

def output_checkfile(target, kerninfo):
    # get the items out of the list
    kernmod = kerninfo[0]

    if target == "bash":
        file_from_template(
            "./template_BASH_kernel_module_disabled",
            {
               "KERNMODULE": kernmod
            },
            "./output/bash/kernel_module_{0}_disabled.sh", kernmod
        )

    elif target == "oval":
        file_from_template(
            "./template_kernel_module_disabled",
            {
                "KERNMODULE": kernmod
            },
            "./output/oval/kernel_module_{0}_disabled.xml", kernmod
        )

    else:
        print("Unknown target: " + target)
        sys.exit(1)

def help():
    print("Usage:\n\t" + __file__ + " <bash/oval> <csv file>")
    print (
        "CSV file should contains lines of the format: kernmod"
    )

if __name__ == "__main__":
    main(sys.argv, help, output_checkfile)
