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
            "./bash/kernel_module_{0}_disabled.sh", kernmod
        )

    elif target == "oval":
        file_from_template(
            "./template_kernel_module_disabled",
            {
                "KERNMODULE": kernmod
            },
            "./oval/kernel_module_{0}_disabled.xml", kernmod
        )

    elif target == "ansible":
        file_from_template(
            "./template_ANSIBLE_kernel_module_disabled",
            {
               "KERNMODULE": kernmod
            },
            "./ansible/kernel_module_{0}_disabled.yml", kernmod
        )

    else:
        raise UnknownTargetError(target)


def help():
    print("Usage:\n\t" + __file__ + " <bash/ansible/oval> <csv file>")
    print (
        "CSV file should contains lines of the format: kernmod"
    )

if __name__ == "__main__":
    main(sys.argv, help, output_checkfile)
