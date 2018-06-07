#
# create_file_owner.py
#   generate checks for file owner
#

from template_common import FilesGenerator, UnknownTargetError
import re


class FileOwnerGenerator(FilesGenerator):
    def generate(self, target, args):
        path = args[0]
        name = re.sub('[-\./]', '_', path)
        user = args[1]

        # Third column is the alternative name, it overwrites the convention
        if len(args) > 2 and args[2]:
            name = '_' + args[2]

        if not path:
            raise RuntimeError(
                "ERROR: input violation: the path must be defined")
        if not user:
            raise RuntimeError(
                "ERROR: input violation: the user must be defined")

        # The fourth column is optional. It is used to indicate if the given path is a
        # directory or a file. The default value is file.
        if len(args) > 3 and args[3] == "directory":
            dftype = "directory"
        else:
            dftype = "file"

        # The fifth column is optional. It is used to describe the path name in regular
        # expression as defined in http://oval.mitre.org/language/about/re_support_5.6.html.
        # If it does not exist, use the exact full string of path as regex.
        # Remediation files will only be generated from template if this column does not exist
        # or is empty.
        if len(args) > 4 and args[4]:
            pathregex = args[4]
            rem_from_template = False
        else:
            pathregex = '^' + path + '$'
            rem_from_template = True

        if target == "oval":
            self.file_from_template(
                "./template_OVAL_file_owner",
                {
                    "%PATH%": path,
                    "%USER%": user,
                    "%PATHID%": name,
                    "%PATHREGEX%": pathregex,
                    "%DFTYPE%": dftype
                },
                "./oval/file_owner{0}.xml", name
            )

        elif target == "bash" and rem_from_template:
            self.file_from_template(
                "./template_BASH_file_owner",
                {
                    "%PATH%": path,
                    "%USER%": user,
                },
                "./bash/file_owner{0}.sh", name
            )

        elif target == "ansible" and rem_from_template:
            self.file_from_template(
                "./template_ANSIBLE_file_owner",
                {
                    "%PATH%": path,
                    "%USER%": user,
                },
                "./ansible/file_owner{0}.yml", name
            )

        else:
            raise UnknownTargetError(target)

    def csv_format(self):
        return("CSV should contains lines of the format: " +
               "PATH,USER[,[ALT_NAME],[directory|file],[PATHREGEX]]")
