#!/usr/bin/python2

#
# create_audit_rules_privileged_commands.py
#        generate template-based checks for privileged commands rules


from template_common import FilesGenerator, UnknownTargetError

import os
import re


class AuditRulesPrivilegedCommandsGenerator(FilesGenerator):
    def generate(self, target, args):
        path = args[0]
        name = re.sub('[-\./]', '_', os.path.basename(path))
        if target == "oval":
            self.file_from_template(
                "./template_OVAL_audit_rules_privileged_commands",
                {
                    "ID": "audit_rules_privileged_commands_" + name,
                    "TITLE": "Ensure auditd Collects Information on the Use of Privileged Commands - " + name,
                    "NAME":	name,
                    "PATH":	path.replace("/", "\\/")
                },
                "./oval/audit_rules_privileged_commands_{0}.xml", name
            )

        elif target == "bash":
            self.file_from_template(
                "./template_BASH_audit_rules_privileged_commands",
                {
                    "PATH":	path
                },
                "./bash/audit_rules_privileged_commands_{0}.sh", name
            )

        elif target == "ansible":
            self.file_from_template(
                "./template_ANSIBLE_audit_rules_privileged_commands",
                {
                    "NAME":	name,
                    "PATH":	path
                },
                "./ansible/audit_rules_privileged_commands_{0}.yml", name
            )

        else:
            raise UnknownTargetError(target)

    def csv_format(self):
        return("CSV should contains lines of the format: " +
               "PATH")
