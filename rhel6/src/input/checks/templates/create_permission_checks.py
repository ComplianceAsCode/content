#!/usr/bin/python

####################################################################################################
####################################################################################################
####################################################################################################
#
# NAME
#     create_permission_checks.py
#
# SYNOPSIS
#     create_permission_checks.py [CSV_FILE]
#
# DESCRIPTION
#     Generate valid OVAL checks for the files and directories specified within the CSV file.
#
# CSV FILE FORMAT
#     The structure of the CSV file is as follows.
#
#     directory path,file name,owner uid (numeric),group owner gid (numeric),mode,CCE
#     |              |         |                   |                         |    |
#     |              |         |                   |                         |     the CCE reference
#     |              |         |                   |                         |     associated with
#     |              |         |                   |                         |     this OVAL check
#     |              |         |                   |                          the required mode for
#     |              |         |                   |                          the file or directory
#     |              |         |                   |                          full specification of
#     |              |         |                   |                          the mode is preferred
#     |              |         |                   |                          (0755 instead of 755)
#     |              |         |                    the required group owner of the file or directory;
#     |              |         |                    the numeric value is required (0 instead of root)
#     |              |          the required owner of the file or directory; the numeric value is
#     |              |          required (0 instead of root)
#     |               the name of the file to be checked; this field can be set to "[NULL]" which
#     |               will generate a check of the directory
#      the directory that contains the file to be checked; if the file name is set to "[NULL]" then
#      then the directory itself will be checked
#
#     For example, a check of /etc/resolv.conf file and the /etc directory would look like:
#
#         /etc,resolv.conf,0,0,0644,1234-6
#         /etc,[NULL],0,0,0755,1234-6
#
# OUTPUT
#     This script is designed to be executed within the 'templates' directory. This directory
#     should contain the CSV file, the OVAL templates, as well as a directory called 'output'.
#     All generated checks will be placed in the 'output' directory. This allows a developer
#     to verify the OVAL check and then move it to the official OVAL content once verified.
#
####################################################################################################
####################################################################################################
####################################################################################################

import sys, csv, re

def output_check(path_info):
    # the csv file contains lines that match the following layout:
    #   directory,file_name,uid,gid,mode,cce
    dir_path, file_name, uid, gid, mode, cce = path_info

    # build a string out of the path that is suitable for use in id tags
    # example:  /etc/resolv.conf --> _etc_resolv_conf
    # path_id maps to FILEID in the template
    if (file_name == '[NULL]'):
        path_id = re.sub('[-\./]', '_', dir_path)
    else:
        path_id = re.sub('[-\./]', '_', dir_path) + '_' + re.sub('[-\./]', '_', file_name)

    # build a string that contains the full path to the file
    # full_path maps to FILEPATH in the template
    if (file_name == '[NULL]'):
        full_path = dir_path
    else:
        full_path = dir_path + '/' + file_name

    # build the state that describes our mode
    # mode_str maps to STATEMODE in the template
    fields = ['oexec', 'owrite', 'oread', 'gexec', 'gwrite', 'gread', 'uexec', 'uwrite', 'uread', 'sticky', 'sgid', 'suid']
    mode_int = int(mode, 8)
    mode_str = "  </unix:file_state>"
    for field in fields:
      if (mode_int & 0x01 == 1):
        mode_str = "    <unix:" + field + " datatype=\"boolean\">true</unix:" + field + ">\n" + mode_str
      else:
        mode_str = "    <unix:" + field + " datatype=\"boolean\">false</unix:" + field + ">\n" + mode_str
      mode_int = mode_int >> 1

    # we are ready to create the check
    # open the template and perform the conversions
    with open("./template_permissions", 'r') as templatefile:
        # replace the placeholders within the template with the actual values
        filestring = templatefile.read()
        filestring = filestring.replace("FILEID", path_id)
        filestring = filestring.replace("FILEPATH", full_path)
        filestring = filestring.replace("FILEDIR", dir_path)
        filestring = filestring.replace("CCEID", cce if cce else "TODO")
        filestring = filestring.replace("FILEUID", uid)
        filestring = filestring.replace("FILEGID", gid)
        filestring = filestring.replace("FILEMODE", mode)
        if (file_name == '[NULL]'):
          filestring = filestring.replace("UNIX_FILENAME", "<unix:filename xsi:nil=\"true\" />")
        else:
          filestring = filestring.replace("UNIX_FILENAME", "<unix:filename>" + file_name + "</unix:filename>")
        filestring = filestring.replace("STATEMODE", mode_str)

        # we can now write the check
        with open("./output/file_permissions" + path_id + ".xml", 'wb+') as outputfile:
            outputfile.write(filestring)
            outputfile.close()

    ##### END OF FUNCTION output_check

def main():
    if len(sys.argv) < 2:
        print "\nERROR: you must provide the path to a CSV file that contains lines like so:"
        print "   directory path,file name,owner uid (numeric),group owner gid (numeric),mode,CCE"
        print "a check for /etc/resolv.conf would look like the following:"
        print "   /etc,resolv.conf,0,0,0644,1234-6\n"
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
