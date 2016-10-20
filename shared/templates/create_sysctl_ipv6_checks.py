#!/usr/bin/python2

import sys
import re

from template_common import *

# Define input template filename to resulting output filename mapping
files = { 'template_sysctl_static' : 'sysctl_static_',
          'template_sysctl_runtime' : 'sysctl_runtime_',
          'template_sysctl_ipv6' : 'sysctl_' }

files_var = { 'template_sysctl_static_var' : 'sysctl_static_',
	  'template_sysctl_runtime_var' : 'sysctl_runtime_',
          'template_sysctl_ipv6' : 'sysctl_' }

def output_checkfile(serviceinfo):
    # get the items out of the list
    sysctl_var, sysctl_val = serviceinfo
    # convert variable name to a format suitable for 'id' tags
    sysctl_var_id = re.sub('[-\.]', '_', sysctl_var)

    # if the sysctl value is not present, use the variable template
    if not sysctl_val.strip():
        # open the template files and perform the conversions
        file_from_template(
            sysctlfile,
            {
                "SYSCTLID":  sysctl_var_id,
                "SYSCTLVAR": sysctl_var
            },
            "./oval/{0}.xml", files_var[sysctlfile] + sysctl_var_id
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
                "./oval/{0}.xml", files[sysctlfile] + sysctl_var_id
            )

def main():
    if len(sys.argv) < 2:
        print ("Provide a CSV file containing lines of the format: " +
               "sysctlvariable,sysctlvalue")
        sys.exit(1)

    filename = argv[1]
    csv_map(filename, output_checkfile, skip_comments = True)

    sys.exit(0)

if __name__ == "__main__":
    main()
