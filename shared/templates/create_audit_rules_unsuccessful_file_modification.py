#!/usr/bin/python2

#
# create_audit_rules_unsuccessful_file_modification.py
#        generate template-based checks for unsuccessful file modifications


from template_common import FilesGenerator, UnknownTargetError

import re

class AuditRulesUnsuccessfulFileModificationGenerator(FilesGenerator):
    def generate(self, target, args):
        name = re.sub('[-\./]', '_', args[0])
        if target == "oval":
            self.file_from_template(
                "./template_OVAL_audit_rules_unsuccessful_file_modification",
                {
                    "%NAME%":	name
                },
                "./oval/audit_rules_unsuccessful_file_modification_{0}.xml", name
            )

        elif target == "bash":
            self.file_from_template(
                "./template_BASH_audit_rules_unsuccessful_file_modification",
                {
                    "%NAME%":	name
                },
                "./bash/audit_rules_unsuccessful_file_modification_{0}.sh", name
            )

        elif target == "ansible":
            self.file_from_template(
                "./template_ANSIBLE_audit_rules_privileged_commands",
                {
                    "%NAME%":	name
                },
                "./ansible/audit_rules_unsuccessful_file_modification_{0}.yml", name
            )

        else:
            raise UnknownTargetError(target)

    def csv_format(self):
        return("CSV should contains lines of the format: " +
               "NAME")
