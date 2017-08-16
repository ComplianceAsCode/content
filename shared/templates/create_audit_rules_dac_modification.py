#
# create_audit_rules_dac_modification.py
#        generate template-based checks for audit rules dac modifications


from template_common import FilesGenerator, UnknownTargetError


class AuditRulesDacModificationGenerator(FilesGenerator):
    def generate(self, target, audit_info):
        # the csv file contains lines that match the following layout:
        #    attr

        if target == "oval":
            # we are ready to create the check
            # open the template and perform the conversions
            attr = audit_info[0]

            self.file_from_template(
                "./template_OVAL_audit_rules_dac_modification",
                {
                    "%ATTR%":           attr,
                },
                "./oval/audit_rules_dac_modification_{0}.xml", attr
            )

        elif target == "bash":
            self.file_from_template(
                "./template_BASH_audit_rules_dac_modification",
                {
                    "%PATH%":	path
                },
                "./bash/audit_rules_dac_modification_{0}.sh", name
            )

        elif target == "ansible":
            self.file_from_template(
                "./template_ANSIBLE_audit_rules_dac_modification",
                {
                    "%NAME%":	name,
                    "%PATH%":	path
                },
                "./ansible/audit_rules_dac_modification_{0}.yml", name
            )

        else:
            raise UnknownTargetError(target)

    def csv_format(self):
        return("CSV should contains lines of the format: "
               "attr")
