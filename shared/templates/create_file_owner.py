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
        platforms = args[2].replace(';', ',')

        # Fourth column is the alternative name, it overwrites the convention
        if len(args) > 3:
            name = '_' + args[3]

        if not path:
            raise RuntimeError(
                "ERROR: input violation: the path must be defined")
        if not user:
            raise RuntimeError(
                "ERROR: input violation: the user must be defined")
        if not platforms:
            raise RuntimeError(
                "ERROR: input violation: the platforms must be defined")

#        if target == "oval":
#            self.file_from_template(
#                "./template_OVAL_file_owner",
#                {
#                    "%PATH%": path,
#                    "%PLATFORMS%": platforms,
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
                    "%PLATFORMS%": platforms,
                },
                "./bash/file_owner{0}.sh", name
            )

        elif target == "ansible":
            self.file_from_template(
                "./template_ANSIBLE_file_owner",
                {
                    "%PATH%": path,
                    "%USER%": user,
                    "%PLATFORMS%": platforms,
                },
                "./ansible/file_owner{0}.yml", name
            )

        else:
            raise UnknownTargetError(target)

    def csv_format(self):
        return("CSV should contains lines of the format: " +
               "PATH, USER, PLATFORM_1[;PLATFORM_N][,ALT_NAME]")
