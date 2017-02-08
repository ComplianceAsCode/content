#!/usr/bin/python2

#
# create_permission.py
#        generate template-based checks for partition mount rights


import sys
import re

from template_common import *


def output_checkfile(target, path_info):
    # the csv file contains lines that match the following layout:
    #    directory,file_name,uid,gid,mode
    #dir_path, file_name, uid, gid, mode = path_info
	mount_point, mount_flag = path_info

    # build a string out of the path that is suitable for use in id tags
    # example:	/var/log --> _var_log
    # path_id maps to MOUNTPOINTID in the template
	point_id = re.sub('[-\./]', '_', mount_point)
	flag_id = re.sub('[-\./]', '_', mount_flag)

	if target == "oval":
        # we are ready to create the check
        # open the template and perform the conversions
		file_from_template(
            "./template_partitions_rights",
            {
                "MOUNTPOINT":       mount_point,
                "MOUNTFLAG":        mount_flag,
                "POINTID":     point_id,
                "FLAGID":      flag_id,
            },
            "./oval/partitions_rights{0}.xml", point_id + '_' + flag_id
        )
	else:
		raise UnknownTargetError(target)


def help():
    print("Usage:\n\t" + __file__ + " <bash/oval/ansible> <csv file>")
    print("CSV should contains lines of the format: "
          "directory path,file name,owner uid (numeric),group "
          "owner gid (numeric),mode")

if __name__ == "__main__":
    main(sys.argv, help, output_checkfile)
