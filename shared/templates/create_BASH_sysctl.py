#!/usr/bin/python

import sys
import re
from template_common import *

def output_checkfile(serviceinfo):
    # get the items out of the list
    sysctl_var, sysctl_val = serviceinfo
    # convert variable name to a format suitable for 'id' tags
    sysctl_var_id = re.sub('[-\.]', '_', sysctl_var)

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

def main():
    if len(sys.argv) < 2:
        print ("Provide a CSV file containing lines of the format: " +
               "sysctlvariable,sysctlvalue")
        sys.exit(1)

    filename = sys.argv[1]
    csv_map(filename, output_checkfile, skip_comments = True)

    sys.exit(0)

if __name__ == "__main__":
    main()
