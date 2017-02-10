#!/usr/bin/python2

#
# create_mount_options.py
#        generate template-based checks for partition mount rights


import sys
import re

from template_common import *


def output_checkfile(target, path_info):
    # the csv file contains lines that match the following layout:
    #    mount_point,flag [flag]+
    mount_point, mount_flags = path_info

    # build a string out of the path that is suitable for use in id tags
    # example:	/var/log --> _var_log
    # path_id maps to MOUNTPOINTID in the template
    point_id = re.sub('[-\./]', '_', mount_point)
    flag_id = re.sub('[-\./ ]', '_', mount_flags)

    if target == "ansible":
        file_from_template(
            "./template_ANSIBLE_mount_options",
            {
                "MOUNTPOINT":       mount_point,
                "MOUNTFLAGS":       re.sub(' ', ',', mount_flags),
            },
            "./ansible/mount_options{0}.yml", point_id
        )

    elif target == "oval":
        # we are ready to create the check
        # open the template and perform the conversions
        flag_str = ""
        state_str = ""
        for flag in mount_flags.split():
            state_str = "    <linux:state state_ref=\"object" + point_id + "_" +  flag + "\" />\n" + state_str
            flag_str = "  <linux:partition_state id=\"object" + point_id + "_" + flag + "\" version=\"1\">\n\
    <linux:mount_options datatype=\"string\" entity_check=\"at least one\" operation=\"equals\">" + flag + "</linux:mount_options>\n\
  </linux:partition_state>\n" + flag_str

        file_from_template(
            "./template_mount_options",
            {
                "MOUNTPOINT":       mount_point,
                "MOUNTFLAGS":        flag_str,
                "FLAGLIST":       mount_flags,
                "MOUNTSTATES":	state_str,
                "POINTID":     point_id,
                "FLAGID":      flag_id,
            },
            "./oval/mount_options{0}.xml", point_id
        )
    else:
        raise UnknownTargetError(target)


def help():
    print "Usage:\n\t" + __file__ + " <bash/oval/ansible> <csv file>"
    print("CSV should contains lines of the format: "
          "mount_point,mount_flag [mount_flag]+")

if __name__ == "__main__":
    main(sys.argv, help, output_checkfile)
