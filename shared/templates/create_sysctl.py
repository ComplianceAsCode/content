#!/usr/bin/python2

import sys
import re

from template_common import *
from load import *

def is_ipv6_id(var_id):
    return var_id.find("ipv6") >= 0

def get_files_var_for_id(var_id):

    if is_ipv6_id(var_id):
          template_name = 'template_sysctl_ipv6'
    else:
          template_name = 'template_sysctl'

    return {
        'template_sysctl_static_var' : 'sysctl_static_',
        'template_sysctl_runtime_var' : 'sysctl_runtime_',
        template_name : 'sysctl_'
    }


def get_files_for_id(var_id):

    if is_ipv6_id(var_id):
          template_name = 'template_sysctl_ipv6'
    else:
          template_name = 'template_sysctl'

    return {
          'template_sysctl_static' : 'sysctl_static_',
          'template_sysctl_runtime' : 'sysctl_runtime_',
          template_name: 'sysctl_'
    }


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
                "./bash/sysctl_{0}.sh", sysctl_var_id
            )
        else:
            file_from_template(
                "./template_BASH_sysctl",
                {
                    "SYSCTLID":  sysctl_var_id,
                    "SYSCTLVAR": sysctl_var,
                    "SYSCTLVAL": sysctl_val
                },
                "./bash/sysctl_{0}.sh", sysctl_var_id
        )

    elif target == "oval":
        # if the sysctl value is not present, use the variable template
        if not sysctl_val.strip():

            # open the template files and perform the conversions
            for sysctlfile, prefix in get_files_var_for_id(sysctl_var_id).items():
                file_from_template(
                    sysctlfile,
                    {
                        "SYSCTLID":  sysctl_var_id,
                        "SYSCTLVAR": sysctl_var,
                    },
                    "./oval/{0}.xml", prefix + sysctl_var_id
                )
        else:

            # open the template files and perform the conversions
            for sysctlfile, prefix in get_files_for_id(sysctl_var_id).items():
                file_from_template(
                    sysctlfile,
                    {
                        "SYSCTLID":  sysctl_var_id,
                        "SYSCTLVAR": sysctl_var,
                        "SYSCTLVAL": sysctl_val
                    },
                    "./oval/{0}.xml", prefix + sysctl_var_id
                )
    else:

        raise UnknownTargetError(target)

def help():
    print("Usage:\n\t" + __file__ + " <bash/oval> <csv file>")
    print("CSV should contains lines of the format: " +
               "sysctlvariable,sysctlvalue")

if __name__ == "__main__":
    main(sys.argv, help, output_checkfile)
