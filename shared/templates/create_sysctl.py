#!/usr/bin/python2

import sys
import re

from template_common import *

# Define input template filename to resulting output filename mapping
files = { 'template_sysctl_static' : 'sysctl_static_',
          'template_sysctl_runtime' : 'sysctl_runtime_',
          'template_sysctl' : 'sysctl_' }

files_var = { 'template_sysctl_static_var' : 'sysctl_static_',
	  'template_sysctl_runtime_var' : 'sysctl_runtime_',
          'template_sysctl' : 'sysctl_' }

def output_checkfile(target, serviceinfo):
    # get the items out of the list
    sysctl_var, sysctl_val = serviceinfo
    # convert variable name to a format suitable for 'id' tags
    sysctl_var_id = re.sub('[-\.]', '_', sysctl_var)

    if target == "bash":
        # if the sysctl value is not present, use the variable template
        if not sysctl_val.strip():
            # open the template and perform the conversions
            file_from_template(
                "template_BASH_sysctl_var",
                {
                    "SYSCTLID":  sysctl_var_id,
                    "SYSCTLVAR": sysctl_var
                },
                "./output/bash/sysctl_{0}.sh", sysctl_var_id
            )
        else:
            file_from_template(
                "./template_BASH_sysctl",
                {
                    "SYSCTLID":  sysctl_var_id,
                    "SYSCTLVAR": sysctl_var,
                    "SYSCTLVAL": sysctl_val
                },
                "./output/bash/sysctl_{0}.sh", sysctl_var_id
        )

    elif target == "oval":
        # if the sysctl value is not present, use the variable template
        if not sysctl_val.strip():

            # open the template files and perform the conversions
            for sysctlfile in files_var.keys():
                file_from_template(
                    sysctlfile,
                    {
                        "SYSCTLID":  sysctl_var_id,
                        "SYSCTLVAR": sysctl_var,
                    },
                    "./output/oval/{0}.xml", files_var[sysctlfile] + sysctl_var_id
                )
        else:

            # open the template files and perform the conversions
            for sysctlfile in files.keys():
                file_from_template(
                    sysctlfile,
                    {
                        "SYSCTLID":  sysctl_var_id,
                        "SYSCTLVAR": sysctl_var,
                        "SYSCTLVAL": sysctl_val
                    },
                    "./output/oval/{0}.xml", files[sysctlfile] + sysctl_var_id
                )
    else:

        raise ValueError("Unknown target " + target)

def help():
    print("Usage:\n\t" + __file__ + " <bash/oval> <csv file>")
    print("CSV should contains lines of the format: " +
               "sysctlvariable,sysctlvalue")

if __name__ == "__main__":
    main(sys.argv, help, output_checkfile)
