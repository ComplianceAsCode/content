#
# create_file_groupowner.py
#   generate checks for file group owner
#

from template_common import FilesGenerator, UnknownTargetError
import re


class FileGroupOwnerGenerator(FilesGenerator):
    def generate(self, target, args):
        path = args[0]
        pathid = re.sub('[-\./]', '_', path)
        group = args[1]

        if not path:
            raise RuntimeError(
                "ERROR: input violation: the path must be defined")
        if not group:
            raise RuntimeError(
                "ERROR: input violation: the group must be defined")

        # The third column is optional. It is used to describe the path name in regular
        # expression as defined in http://oval.mitre.org/language/about/re_support_5.6.html.
        # If it does not exist, use the exact full string of path as regex.
        if len(args) > 2 and args[2]:
            pathregex = args[2]
        else:
            pathregex = '^' + path + '$'

        # The fourth column is optional. It is used to indicate if the given path is a
        # directory or a file. The default value is file.
        if len(args) > 3 and args[3] == "directory":
            dftype = "directory"
        else:
            dftype = "file"

        if target == "oval":
            self.file_from_template(
                "./template_OVAL_file_groupowner",
                {
                    "%PATH%": path,
                    "%PATHID%": pathid,
                    "%PATHREGEX%": pathregex,
                    "%GROUP%": group,
                    "%DFTYPE%": dftype
                },
                "./oval/file_groupowner{0}.xml", pathid
            )

        if target == "bash":
            self.file_from_template(
                "./template_BASH_file_groupowner",
                {
                    "%PATH%": path,
                    "%GROUP%": group,
                },
                "./bash/file_groupowner{0}.sh", pathid
            )

        elif target == "ansible":
            self.file_from_template(
                "./template_ANSIBLE_file_groupowner",
                {
                    "%PATH%": path,
                    "%GROUP%": group,
                },
                "./ansible/file_groupowner{0}.yml", pathid
            )

        else:
            raise UnknownTargetError(target)

    def csv_format(self):
        return("CSV should contains lines of the format: " +
               "PATH,GROUP[,[PATHREGEX],[directory|file]]")
