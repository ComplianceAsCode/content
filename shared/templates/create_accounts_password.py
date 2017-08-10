#
# create_accounts_password.py
#        generate template-based remediation for account passwords


from template_common import FilesGenerator, UnknownTargetError


class AccountsPasswordGenerator(FilesGenerator):
    def generate(self, target, pam_info):
        VARIABLE, = pam_info

        if target == "bash":
            self.file_from_template(
                "./template_BASH_accounts_password",
                {
                    "%VARIABLE%": VARIABLE
                },
                "./bash/accounts_password_pam_{0}.sh", VARIABLE
            )

        elif target == "ansible":
            self.file_from_template(
                "./template_ANSIBLE_accounts_password",
                {
                    "%VARIABLE%": VARIABLE
                },
                "./ansible/accounts_password_pam_{0}.yml", VARIABLE
            )

        else:
            raise UnknownTargetError(target)

    def csv_format(self):
        return("CSV should contains lines of the format: " +
               "VARIABLE")
