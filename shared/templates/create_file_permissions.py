#
# create_file_permissions.py
#   generate checks for file permissions
#

from template_common import FilesGenerator, UnknownTargetError
import re


class FilePermissionsGenerator(FilesGenerator):
    def generate(self, target, args):
        path = args[0]
        name = re.sub('[-\./]', '_', path)
        mode = args[1]

        # Third column is the optional alternative name, it overwrites the convention
        if len(args) > 2 and args[2]:
            name = '_' + args[2]

        if not path:
            raise RuntimeError(
                "ERROR: input violation: the path must be defined")
        if not mode:
            raise RuntimeError(
                "ERROR: input violation: the mode must be defined")

        # The fourth column is optional. It is used to indicate if the given path is a
        # directory or a file. The default value is file.
        if len(args) > 3 and args[3] == "directory":
            dftype = "directory"
        else:
            dftype = "file"

        # The fifth column is optional. It is used to describe the path name in regular
        # expression as defined in http://oval.mitre.org/language/about/re_support_5.6.html.
        # If it does not exist, use the exact full string of path as regex.
        # Remediation files will only be generated from template if this column does not
        # exist or is empty.
        if len(args) > 4 and args[4]:
            pathregex = args[4]
            rem_from_template = False
        else:
            pathregex = '^' + path + '$'
            rem_from_template = True

        # decode the permissions of octal format: nnn or nnnn 
        if len(mode) == 4:                         # calculate the suid, sgid and sticky bit
            perm = int(mode[0])                    # from the first digit
            suid = str(perm / 2 / 2 % 2)
            sgid = str(perm / 2 % 2)
            sticky = str(perm % 2)
            mode = mode[1:]                        # remove the first digit from mode
        else:
            suid = str(0)
            sgid = str(0)
            sticky = str(0)

        if len(mode) != 3:
            raise RuntimeError(
                "ERROR: input violation: the mode must be in format nnn or nnnn")
            
        if target == "oval":
            #raise RuntimeError(
            #    "INFO: sbits are", suid, sgid, sticky )

            self.file_from_template(
                "./template_OVAL_file_permissions",
                {
                    "%PATH%": path,
                    "%PERMISSIONS%": args[1],      # mode might has been modified
                    "%PATHID%": name,
                    "%DFTYPE%": dftype,
                    "%PATHREGEX%": pathregex,
                    "%SUID%": suid,
                    "%SGID%": sgid,
                    "%STICKY%": sticky,
                    "%UREAD%": str(int(mode[0]) / 2 / 2 % 2),
                    "%UWRITE%": str(int(mode[0]) / 2 % 2),
                    "%UEXEC%": str(int(mode[0]) % 2),
                    "%GREAD%": str(int(mode[1]) / 2 / 2 % 2),
                    "%GWRITE%": str(int(mode[1]) / 2 % 2),
                    "%GEXEC%": str(int(mode[1]) % 2),
                    "%OREAD%": str(int(mode[2]) / 2 / 2 % 2),
                    "%OWRITE%": str(int(mode[2]) / 2 % 2),
                    "%OEXEC%": str(int(mode[2]) % 2)
                },
                "./oval/file_permissions{0}.xml", name
            )

        elif target == "bash" and rem_from_template:
            self.file_from_template(
                "./template_BASH_file_permissions",
                {
                    "%PATH%": path,
                    "%MODE%": mode,
                },
                "./bash/file_permissions{0}.sh", name
            )

        elif target == "ansible" and rem_from_template:
            self.file_from_template(
                "./template_ANSIBLE_file_permissions",
                {
                    "%PATH%": path,
                    "%MODE%": mode,
                },
                "./ansible/file_permissions{0}.yml", name
            )

        else:
            raise UnknownTargetError(target)

    def csv_format(self):
        return("CSV should contains lines of the format: " +
               "PATH,MODE[,[ALT_NAME],[directory|file],[PATHREGEX]]")
