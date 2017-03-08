#!/usr/bin/python2

#
# create_mount_options.py
#        generate template-based checks for partition mount rights


import sys
import re

from template_common import FilesGenerator, UnknownTargetError

class MountOptionsGenerator(FilesGenerator):

    def generate(self, target, path_info):
        # the csv file contains lines that match the following layout:
        #    mount_point,option,[option]+
        # first col is the mount point, others are options, at least one
        mount_infos = list()
        mount_infos = path_info
        mount_point = mount_infos[0]

        # build a string out of the path that is suitable for use in id tags
        # example:	/var/log --> _var_log
        point_id = re.sub('[-\./]', '_', mount_point)
        for option in mount_infos[1:]:
            option_id = re.sub('[-\./ ]', '_', option)

            if target == "ansible":
                self.file_from_template(
                    "./template_ANSIBLE_mount_options",
                    {
                        "MOUNTPOINT":       mount_point,
                        "MOUNTOPTION":       re.sub(' ', ',', option),
                    },
                    "./ansible/mount_options{0}.yml", point_id + '_' + option_id
                )

            elif target == "oval":
                # we are ready to create the check
                # open the template and perform the conversions
                option_str = ""
                state_str = ""
                #for option in mount_options.split():
                state_str = "    <linux:state state_ref=\"object" + point_id + "_" +  option_id + "\" />\n"
                option_str = "  <linux:partition_state id=\"object" + point_id + "_" + option_id + "\" version=\"1\">\n\
        <linux:mount_options datatype=\"string\" entity_check=\"at least one\" operation=\"equals\">" + option + "</linux:mount_options>\n\
      </linux:partition_state>\n"

                self.file_from_template(
                    "./template_mount_options",
                    {
                        "MOUNTPOINT":       mount_point,
                        "MOUNTOPTIONS":        option_str,
                        "OPTIONLIST":       option,
                        "MOUNTSTATES":	state_str,
                        "POINTID":     point_id,
                        "OPTIONID":      option_id,
                    },
                    "./oval/mount_options{0}.xml", point_id + "_" + option_id
                )
            else:
                raise UnknownTargetError(target)


    def csv_format(self):
        return("CSV should contains lines of the format: "
              "mount_point,mount_option,[mount_option]+")

if __name__ == "__main__":
    MountOptionsGenerator().main()
