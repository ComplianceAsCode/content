#
# create_mount_options.py
#        generate template-based checks for partition mount rights

import re

from template_common import FilesGenerator, UnknownTargetError


class MountOptionsGenerator(FilesGenerator):
    def generate(self, target, path_info):
        mount_point, mount_option = path_info
        point_id = re.sub('[-\./]', '_', mount_point)
        if mount_point:
            if target == "ansible":
                self.file_from_template(
                    "./template_ANSIBLE_mount_options",
                    {
                        "%MOUNTPOINT%":  mount_point,
                        "%MOUNTOPTION%": re.sub(' ', ',', mount_option),
                    },
                    "./ansible/mount_option{0}.yml", point_id + '_' + mount_option
                )

            elif target == "anaconda":
                self.file_from_template(
                    "./template_ANACONDA_mount_options",
                    {
                        "%MOUNTPOINT%":  mount_point,
                        "%MOUNTOPTION%": re.sub(' ', ',', mount_option),
                    },
                    "./anaconda/mount_option{0}.anaconda", point_id + '_' + mount_option
                )

            elif target == "oval":
                self.file_from_template(
                    "./template_OVAL_mount_options",
                    {
                        "%MOUNTPOINT%":  mount_point,
                        "%MOUNTOPTION%": mount_option,
                        "%POINTID%":     point_id,
                    },
                    "./oval/mount_option{0}.xml", point_id + "_" + mount_option
                )
            else:
                raise UnknownTargetError(target)

    def csv_format(self):
        return("CSV should contains lines of the format: "
               "mount_point,mount_option,[mount_option]+")
