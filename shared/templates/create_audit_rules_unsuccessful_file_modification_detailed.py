#!/usr/bin/python2

#
# create_audit_rules_unsuccessful_file_modification_detailed.py
#        generate template-based checks for unsuccessful file modifications detailed
#            - audit_rules_unsuccessful_file_modification_syscall_o_creat
#            - audit_rules_unsuccessful_file_modification_syscall_o_trunc_write
#            - audit_rules_unsuccessful_file_modification_syscall_rule_order


from template_common import FilesGenerator, UnknownTargetError

import re

class ARUFMDetailedGenerator(FilesGenerator):
    def generate(self, target, args):
        syscall = re.sub('[-\./]', '_', args[0])
        if target == "oval":
            self.file_from_template(
                "./template_OVAL_audit_rules_unsuccessful_file_modification_o_creat",
                {
                    "SYSCALL":	syscall
                },
                "./oval/audit_rules_unsuccessful_file_modification_{0}_o_creat.xml", syscall
            )
            self.file_from_template(
                "./template_OVAL_audit_rules_unsuccessful_file_modification_o_trunc_write",
                {
                    "SYSCALL":	syscall
                },
                "./oval/audit_rules_unsuccessful_file_modification_{0}_o_trunc_write.xml", syscall
            )
            self.file_from_template(
                "./template_OVAL_audit_rules_unsuccessful_file_modification_rule_order",
                {
                    "SYSCALL":	syscall
                },
                "./oval/audit_rules_unsuccessful_file_modification_{0}_rule_order.xml", syscall
            )
        else:
            raise UnknownTargetError(target)

    def csv_format(self):
        return("CSV should contains lines of the format: " +
               "SYSCALL")
