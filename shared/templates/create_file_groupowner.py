#
# create_file_groupowner.py
#   generate checks for file group owner
#

from template_common import FilesGenerator, UnknownTargetError
import re


class FileGroupOwnerGenerator(FilesGenerator):
    def generate(self, target, args):
        path = args[0]
        name = re.sub('[-\./]', '_', path)
        group = args[1]

       # Third column is the optional alternative name, it overwrites the convention
        if len(args) > 2 and args[2]:
            name = '_' + args[2]

        if not path:
            raise RuntimeError(
                "ERROR: input violation: the path must be defined")
        if not group:
            raise RuntimeError(
                "ERROR: input violation: the group must be defined")

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
                "./template_OVAL_file_groupowner",
                {
                    "%PATH%": path,
                    "%GROUP%": group,
                    "%PATHID%": name,
                    "%PATHREGEX%": pathregex,
                    "%DFTYPE%": dftype
                },
                "./oval/file_groupowner{0}.xml", name
            )

        if target == "bash" and rem_from_template:
            self.file_from_template(
                "./template_BASH_file_groupowner",
                {
                    "%PATH%": path,
                    "%GROUP%": group,
                },
                "./bash/file_groupowner{0}.sh", name
            )

        elif target == "ansible" and rem_from_template:
            self.file_from_template(
                "./template_ANSIBLE_file_groupowner",
                {
                    "%PATH%": path,
                    "%GROUP%": group,
                },
                "./ansible/file_groupowner{0}.yml", name
            )

        else:
            raise UnknownTargetError(target)

    def csv_format(self):
        return("CSV should contains lines of the format: " +
               "PATH,GROUP[,[ALT_NAME],[directory|file],[PATHREGEX]]")
