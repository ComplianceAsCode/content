#
# create_mounts.py
#        generate template-based checks for partitions and partition
#        mount rights


import re

from template_common import FilesGenerator, UnknownTargetError


class MountsGenerator(FilesGenerator):
    def generate(self, target, path_info):
        mount_point, = path_info
        point_id = re.sub('[-\./]', '_', mount_point)
        if mount_point:
            if target == "anaconda":
                self.file_from_template(
                    "./template_ANACONDA_mount",
                    {
                        "%MOUNTPOINT%":  mount_point,
                    },
                    "./anaconda/partition_for{0}.anaconda", point_id
                )

            elif target == "oval":
                self.file_from_template(
                    "./template_OVAL_mount",
                    {
                        "%MOUNTPOINT%":  mount_point,
                        "%POINTID%":     point_id,
                    },
                    "./oval/partition_for{0}.xml", point_id
                )
        else:
            raise UnknownTargetError(target)

    def csv_format(self):
        return("CSV should contains lines of the format: "
               "mount_point")
