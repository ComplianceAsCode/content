#!/usr/bin/python2

#
# create_audit_rules_file_deletion_events.py
#        generate template-based checks for file deletion events


from template_common import FilesGenerator, UnknownTargetError

import re

class AuditRulesFileDeletionEventsGenerator(FilesGenerator):
    def generate(self, target, args):
        name = re.sub('[-\./]', '_', args[0])
        if target == "oval":
            self.file_from_template(
                "./template_OVAL_audit_rules_file_deletion_events",
                {
                    "%NAME%":	name
                },
                "./oval/audit_rules_file_deletion_events_{0}.xml", name
            )

        elif target == "bash":
            self.file_from_template(
                "./template_BASH_audit_rules_file_deletion_events",
                {
                    "%NAME%":	name
                },
                "./bash/audit_rules_file_deletion_events_{0}.sh", name
            )

#        elif target == "ansible":
#            self.file_from_template(
#                "./template_ANSIBLE_audit_rules_file_deletion_events",
#                {
#                    "%NAME%":	name
#                },
#                "./ansible/audit_rules_file_deletion_events_{0}.yml", name
#            )

        else:
            raise UnknownTargetError(target)

    def csv_format(self):
        return("CSV should contains lines of the format: " +
               "NAME")
