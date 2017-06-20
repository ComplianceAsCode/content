#!/usr/bin/python2

#
# create_mount_options.py
#        generate template-based checks for partition mount rights


import re

from template_common import FilesGenerator, UnknownTargetError

class MountOptionsGenerator(FilesGenerator):

    def generate(self, target, path_info):
        mount_point, option = path_info
        point_id = re.sub('[-\./]', '_', mount_point)
        if mount_point:
            if target == "ansible":
                self.file_from_template(
                    "./template_ANSIBLE_mount_options",
                    {
                        "MOUNTPOINT":       mount_point,
                        "MOUNTOPTION":       re.sub(' ', ',', option),
                    },
                    "./ansible/mount_option{0}.yml", point_id + '_' + option
                )

            elif target == "anaconda":
                self.file_from_template(
                    "./template_ANACONDA_mount_options",
                    {
                        "MOUNTPOINT":       mount_point,
                        "MOUNTOPTION":       re.sub(' ', ',', option),
                    },
                    "./anaconda/mount_option{0}.anaconda", point_id + '_' + option
                )

            elif target == "oval":
                state_str = "    <linux:state state_ref=\"state" + point_id + "_" +  option + "\" />\n"
                option_str = "  <linux:partition_state id=\"state" + point_id + "_" + option + "\" version=\"1\">\n\
    <linux:mount_options datatype=\"string\" entity_check=\"at least one\" operation=\"equals\">" + option + "</linux:mount_options>\n\
  </linux:partition_state>\n"

                self.file_from_template(
                    "./template_OVAL_mount_options",
                    {
                        "MOUNTPOINT":       mount_point,
                        "MOUNTOPTIONS":        option_str,
                        "OPTIONLIST":       option,
                        "MOUNTSTATES":	state_str,
                        "POINTID":     point_id,
                        "OPTIONID":      option,
                    },
                    "./oval/mount_option{0}.xml", point_id + "_" + option
                )
            else:
                raise UnknownTargetError(target)


    def csv_format(self):
        return("CSV should contains lines of the format: "
              "mount_point,mount_option,[mount_option]+")

if __name__ == "__main__":
    MountOptionsGenerator().main()
