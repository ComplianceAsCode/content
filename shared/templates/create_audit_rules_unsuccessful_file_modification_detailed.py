#!/usr/bin/python2

#
# create_audit_rules_unsuccessful_file_modification_detailed.py
#        generate template-based checks for unsuccessful file modifications detailed
#            - audit_rules


from template_common import FilesGenerator, UnknownTargetError

import re

class AuditRulesUnsuccessfulFileModificationDetailedGenerator(FilesGenerator):
    def generate(self, target, args):
        name = re.sub('[-\./]', '_', args[0])
        if target == "oval":
            self.file_from_template(
                "./template_OVAL_audit_rules_unsuccessful_file_modification_o_creat",
                {
                    "NAME":	name
                },
                "./oval/audit_rules_unsuccessful_file_modification_{0}_o_creat.xml", name
            )
            self.file_from_template(
                "./template_OVAL_audit_rules_unsuccessful_file_modification_o_trunc_write",
                {
                    "NAME":	name
                },
                "./oval/audit_rules_unsuccessful_file_modification_{0}_o_trunc_write.xml", name
            )
            self.file_from_template(
                "./template_OVAL_audit_rules_unsuccessful_file_modification_rule_order",
                {
                    "NAME":	name
                },
                "./oval/audit_rules_unsuccessful_file_modification_{0}_rule_order.xml", name
            )
        else:
            raise UnknownTargetError(target)

    def csv_format(self):
        return("CSV should contains lines of the format: " +
               "NAME")
