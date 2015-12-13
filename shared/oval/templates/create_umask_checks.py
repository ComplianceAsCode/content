#!/usr/bin/python2

#
# create_umask_checks.py
#       generate template-based checks for umask
#
# NOTE: The file 'template_umask' should be located in the same working
# directory as this script.
# The template contains tags that *must* be replaced successfully in order
# for the checks to work.
#
# directory path, file name, external OVAL umask variable name, title,
# description, custom oval check id
#

import sys
import csv
import re


def output_check(path_info):
    # the csv file contains lines that match the following layout
    # (see file_umask_checks.csv for more details):
    #
    #   directory path, file name, external OVAL umask variable name, title,
    # description, custom oval check id
    #
    dir_path, file_name, ext_oval_var, title, description, oval_check_id = path_info

    # build a string out of the path that is suitable for use in id tags
    # example:      /etc/resolv.conf --> _etc_resolv_conf
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

    # custom oval check id wasn't requested => build one as concatenation of:
    #
    #   'accounts_umask' + value of path_id variable
    #
    # oval_check_id maps to OVALCHECKID in the template
    if oval_check_id == '[NULL]':
        oval_check_id = 'accounts_umask' + path_id

    # we are ready to create the check
    # open the template and perform the conversions
    with open("./template_umask", 'r') as templatefile:
        # replace the placeholders within the template with the actual values
        filestring = templatefile.read()
        filestring = filestring.replace("OVALCHECKID", oval_check_id)
        filestring = filestring.replace("TITLE", title)
        filestring = filestring.replace("DESCRIPTION", description)
        filestring = filestring.replace("FILEID", path_id)
        filestring = filestring.replace("FILEPATH", full_path)
        filestring = filestring.replace("USERUMASKVARIABLE", ext_oval_var)

        # we can now write the check
        with open("./output/" + oval_check_id + ".xml", 'w+') as outputfile:
            outputfile.write(filestring)
            outputfile.close()


def main():
    if len(sys.argv) < 2:
        print ("\nERROR: you must provide the path to a CSV file " +
               "that contains lines like so:")
        print ("   directory path, file name, external OVAL umask " +
               "variable name for comparison")
        sys.exit(1)

        # open and read the csv file
        with open(sys.argv[1], 'r') as csv_file:
            file_lines = csv.reader(csv_file)
            for line in file_lines:

                # Skip lines of input file starting with comment '#' character
                if line[0].startswith('#'):
                    continue

                output_check(line)

        # done
        sys.exit(0)

if __name__ == "__main__":
    main()
