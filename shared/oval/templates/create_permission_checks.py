#!/usr/bin/python

#
# create_permission_checks.py
#        generate template-based checks for file permissions/ownership
#
# NOTE: The file 'template_permissions' should be located in the same working
# directory as this script. The template contains tags that *must* be replaced
# successfully in order for the checks to work.
#
#   directory path,file name,owner uid (numeric),group owner gid (numeric),mode

import sys
import csv
import re


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

    # build the state that describes our mode
    # mode_str maps to STATEMODE in the template
    fields = ['oexec', 'owrite', 'oread', 'gexec', 'gwrite', 'gread', 'uexec',
              'uwrite', 'uread', 'sticky', 'sgid', 'suid']
    mode_int = int(mode, 8)
    mode_str = "  </unix:file_state>"
    for field in fields:
        if mode_int & 0x01 == 1:
            mode_str = "	<unix:" + field + " datatype=\"boolean\">true</unix:" + field + ">\n" + mode_str
        else:
            mode_str = "	<unix:" + field + " datatype=\"boolean\">false</unix:" + field + ">\n" + mode_str
        mode_int = mode_int >> 1

    # we are ready to create the check
    # open the template and perform the conversions
    with open("./template_permissions", 'r') as templatefile:
        # replace the placeholders within the template with the actual values
        filestring = templatefile.read()
        filestring = filestring.replace("FILEID", path_id)
        filestring = filestring.replace("FILEPATH", full_path)
        filestring = filestring.replace("FILEDIR", dir_path)
        filestring = filestring.replace("FILEUID", uid)
        filestring = filestring.replace("FILEGID", gid)
        filestring = filestring.replace("FILEMODE", mode)
        if file_name == '[NULL]':
            filestring = filestring.replace("UNIX_FILENAME",
                                            "<unix:filename xsi:nil=\"true\" />")
        else:
            filestring = filestring.replace("UNIX_FILENAME", "<unix:filename>"
                                            + file_name + "</unix:filename>")
        filestring = filestring.replace("STATEMODE", mode_str)

        # we can now write the check
        with open("./output/file_permissions" + path_id +
                  ".xml", 'w+') as outputfile:
            outputfile.write(filestring)
            outputfile.close()


def main():
    if len(sys.argv) < 2:
        print ("\nERROR: you must provide the path to a CSV file that " +
               "contains lines like so:")
        print ("   directory path,file name,owner uid (numeric),group " +
               "owner gid (numeric),mode")
        sys.exit(1)

    # open and read the csv file
    with open(sys.argv[1], 'r') as csv_file:
        file_lines = csv.reader(csv_file)
        for line in file_lines:
            output_check(line)

    # done
    sys.exit(0)

if __name__ == "__main__":
    main()
