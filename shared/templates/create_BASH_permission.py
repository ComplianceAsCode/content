#!/usr/bin/python2

#
# create_BASH_permission.py
#        generate template-based remediations for file permissions/ownership
#
# NOTE: The file 'template_permissions' should be located in the same working
# directory as this script. The template contains tags that *must* be replaced
# successfully in order for the checks to work.
#
#   directory path,file name,owner uid (numeric),group owner gid (numeric),mode

import sys
import re

from template_common import *

def output_check(path_info):
    # the csv file contains lines that match the following layout:
    #    directory,file_name,uid,gid,mode
    dir_path, file_name, uid, gid, mode = path_info

    # build a string out of the path that is suitable for use in id tags
    # example:	/etc/resolv.conf --> _etc_resolv_conf
    # path_id maps to FILEID in the template
    if file_name == '[NULL]':
        path_id = re.sub('[-\./]', '_', dir_path)
    else:
        path_id = re.sub('[-\./]', '_', dir_path) + '_' + re.sub('[-\./]',
                                                                 '_', file_name)

    # build a string that contains the full path to the file
    # full_path maps to FILEPATH in the template
    if file_name == '[NULL]':
        full_path = dir_path
    else:
        full_path = dir_path + '/' + file_name

    # we are ready to create the check
    # open the template and perform the conversions
    file_from_template(
        "./template_BASH_permissions",
        {
            "FILEPATH":      full_path,
            "FILEMODE":      mode,
        },
        "./output/bash/file_permissions{0}.sh", path_id
    )

def main():
    if len(sys.argv) < 2:
        print ("\nERROR: you must provide the path to a CSV file that " +
               "contains lines like so:")
        print ("   directory path,file name,owner uid (numeric),group " +
               "owner gid (numeric),mode")
        sys.exit(1)

    filename = sys.argv[1]
    csv_map(filename, output_check, skip_comments = True)

    # done
    sys.exit(0)

if __name__ == "__main__":
    main()
