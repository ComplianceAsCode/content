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

        # Third column is the alternative name, it overwrites the convention
        if len(args) > 2:
            name = '_' + args[2]

        if not path:
            raise RuntimeError(
                "ERROR: input violation: the path must be defined")
        if not mode:
            raise RuntimeError(
                "ERROR: input violation: the mode must be defined")

#        if target == "oval":
#            self.file_from_template(
#                "./template_OVAL_file_permissions",
#                {
#                    "%PATH%": path,
#                    "%MODE%": mode,
#                    "%PLATFORMS%": platforms,
#                    "%NAME%": name
#                },
#                "./oval/file_permissions{0}.xml", name
#            )

        if target == "bash":
            self.file_from_template(
                "./template_BASH_file_permissions",
                {
                    "%PATH%": path,
                    "%MODE%": mode,
                },
                "./bash/file_permissions{0}.sh", name
            )

        elif target == "ansible":
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
               "PATH, MODE, [,ALT_NAME]")
