#!/usr/bin/env python2

#
# create_auditd_lineinfile.py
#   automatically generate checks for auditd line in file configuration

import sys

from template_common import FilesGenerator, UnknownTargetError, CSVLineError


class AuditdLineinfileGenerator(FilesGenerator):
    def generate(self, target, lineinfileinfo):
        try:            
            # missing parameter pass is false by default
            missing_parameter_pass = False

            # get the items out of the list
            # items can be in format
            # <rule_id, parameter, value> or
            # <rule_id, parameter, value, missing_parameter_pass>
            if len(lineinfileinfo) == 3:
                rule_id, parameter, value = lineinfileinfo
            elif len(lineinfileinfo) == 4:
                rule_id, parameter, value, missing_parameter_pass = lineinfileinfo
                # use boolean instead of any string that came from csv file
                if missing_parameter_pass == "true":
                    missing_parameter_pass = True
                elif missing_parameter_pass == "false":
                    missing_parameter_pass = False
                else:
                    raise ValueError("Unrecognized option for missing_parameter_pass parameter ({}). ".format(missing_parameter_pass) +
                                     "Possible values are: true or false.")
        except ValueError as e:
            print("\tEntry: %s\n" % lineinfileinfo)
            print("\tError unpacking rule_id, parameter, value and missing_parameter_pass: " + str(e))
            raise CSVLineError()

        if target == "oval":
            self.file_from_template(
                "./template_OVAL_auditd_lineinfile",
                {
                    "products": "all",
                    "rule_title" : "Rule title of {}".format(rule_id),
                    "rule_id": rule_id,
                    "PARAMETER": parameter,
                    "VALUE": value,
                    "MISSING_PARAMETER_PASS": missing_parameter_pass,
                },
                "./oval/{0}.xml", rule_id
            )
        elif target == "bash":
            self.file_from_template(
                "./template_BASH_auditd_lineinfile",
                {
                    "PARAMETER": parameter,
                    "VALUE": value
                },
                "./bash/{0}.sh", rule_id
            )

        elif target == "ansible":
            self.file_from_template(
                "./template_ANSIBLE_auditd_lineinfile",
                {
                    "rule_title" : "Rule title of {}".format(rule_id),
                    "PARAMETER": parameter,
                    "VALUE": value
                },
                "./ansible/{0}.yml", rule_id
            )

        else:
            raise UnknownTargetError(target)

    def csv_format(self):
        return("CSV should contains lines of the format: " +
               "rule_id,parameter,value<, missing_parameter_pass>")
