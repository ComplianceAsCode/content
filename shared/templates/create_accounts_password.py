#!/usr/bin/python2

#
# create_accounts_password.py
#        generate template-based remediation for account passwords

import sys
import re

from template_common import FilesGenerator, UnknownTargetError

class AccountsPasswordGenerator(FilesGenerator):

    def generate(self, target, pam_info):
        VARIABLE, = pam_info

        if target == "bash":

            self.file_from_template(
                "./template_BASH_accounts_password",
                {
                    "VARIABLE":   VARIABLE
                },
                "./bash/accounts_password_pam_{0}.sh", VARIABLE
            )

        else:
            raise UnknownTargetError(target)

    def csv_format(self):
        return("CSV should contains lines of the format: " +
                   "VARIABLE")

if __name__ == "__main__":
    AccountsPasswordGenerator().main()
