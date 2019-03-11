#!/usr/bin/python2

#
# create_audit_rules_path_syscall_detailed.py
#        generate template-based checks for changes to a path via syscalls 


from template_common import FilesGenerator, UnknownTargetError

import re

class AuditRulesPathSyscallGenerator(FilesGenerator):
    def generate(self, target, args):
        path,syscall,pos = args[0:3]
        pathid = re.sub('[-\./]', '_', path)
        # remove root slash made into '_'
        pathid = pathid[1:]
        if target == "oval":
            self.file_from_template(
                "./template_OVAL_audit_rules_path_syscall",
                {
                    "PATH":	path,
                    "PATHID":	pathid,
                    "SYSCALL":	syscall,
                    "POS":	pos
                },
                "./oval/audit_rules_{0}_{1}.xml", pathid, syscall
            )
        else:
            raise UnknownTargetError(target)

    def csv_format(self):
        return("CSV should contains lines of the format: " +
               "PATH,SYSCALL,POS")
