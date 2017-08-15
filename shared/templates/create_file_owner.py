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
        if len(args) > 2:
            name = '_' + args[2]

        if not path:
            raise RuntimeError(
                "ERROR: input violation: the path must be defined")
        if not user:
            raise RuntimeError(
                "ERROR: input violation: the user must be defined")

#        if target == "oval":
#            self.file_from_template(
#                "./template_OVAL_file_owner",
#                {
#                    "%PATH%": path,
#                    "%NAME%": name
#                },
#                "./oval/file_owner{0}.xml", name
#            )

        if target == "bash":
            self.file_from_template(
                "./template_BASH_file_owner",
                {
                    "%PATH%": path,
                    "%USER%": user,
                },
                "./bash/file_owner{0}.sh", name
            )

        elif target == "ansible":
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
               "PATH, USER [,ALT_NAME]")
