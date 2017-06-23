#!/usr/bin/python2

#
# create_audit_rules_dac_modification.py
#        generate template-based checks for audit rules dac modifications


import re

from template_common import FilesGenerator, UnknownTargetError


class AuditRulesDacModificationGenerator(FilesGenerator):
    def __init__(self):
        super(AuditRulesDacModificationGenerator, self).__init__()
        self.delimiter = '&'

    def generate(self, target, audit_info):
        # the csv file contains lines that match the following layout:
        #    attr,pattern_32,pattern_64

        if target == "oval":
            # we are ready to create the check
            # open the template and perform the conversions
            attr = audit_info[0]
            pattern_32 = audit_info[1]
            pattern_64 = audit_info[2]

            self.file_from_template(
                "./template_OVAL_audit_rules_dac_modification",
                {
                    "%ATTR%":           attr,
                    "%PATTERN_32%":     pattern_32,
                    "%PATTERN_64%":     pattern_64,
                },
                "./oval/audit_rules_dac_modification_{0}.xml", attr
            )
        else:
            raise UnknownTargetError(target)

    def csv_format(self):
        return("CSV should contains lines of the format: "
               "attr,pattern_32,pattern_64")

if __name__ == "__main__":
    AuditRulesDacModificationGenerator().main()
