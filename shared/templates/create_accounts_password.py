#!/usr/bin/python2

#
# create_accounts_password.py
#        generate template-based remediation for account passwords

import sys
import re

from template_common import *

def output_checkfile(target, pam_info):
    VARIABLE, = pam_info

    if target == "bash":

        file_from_template(
            "./template_BASH_accounts_password",
            {
                "VARIABLE":   VARIABLE
            },
            "./bash/accounts_password_pam_{0}.sh", VARIABLE
        )

    else:
        raise UnknownTargetError(target)


def help():
    print("Usage:\n\t" + __file__ + " <bash> <csv file>")
    print("CSV should contains lines of the format: " +
               "VARIABLE")

if __name__ == "__main__":
    main(sys.argv, help, output_checkfile)
