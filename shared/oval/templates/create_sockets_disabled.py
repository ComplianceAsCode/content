#!/usr/bin/python2

#
# create_sockets_disabled.py
#   automatically generate checks for disabled sockets.
#
# NOTE: The file 'template_socket_disabled' should be located in the same
# working directory as this script. The template contains the following tags
# that *must* be replaced successfully in order for the checks to work.
#
# SOCKETNAME - the name of the socket that should be disabled
# PACKAGENAME - the name of the package that installs the socket
#

import sys
import csv
import re


def output_checkfile(socketinfo):
    # get the items out of the list
    socketname, packagename = socketinfo
    with open("./template_socket_disabled", 'r') as templatefile:
        filestring = templatefile.read()
        filestring = filestring.replace("SOCKETNAME", socketname)
        if packagename:
            filestring = filestring.replace("PACKAGENAME", packagename)
        else:
            filestring = re.sub("\n\s*<criteria.*>\n\s*<extend_definition.*/>",
                                "", filestring)
            filestring = re.sub("\s*</criteria>\n\s*</criteria>",
                                "\n    </criteria>", filestring)
        with open("./output/socket_" + socketname +
                  "_disabled.xml", 'w+') as outputfile:
            outputfile.write(filestring)
            outputfile.close()


def main():
    if len(sys.argv) < 2:
        print ("Provide a CSV file containing lines of the format: " +
               "socketname,packagename")
        sys.exit(1)
    with open(sys.argv[1], 'r') as csv_file:
        # put the CSV line's items into a list
        socketlines = csv.reader(csv_file)
        for line in socketlines:

            # Skip lines of input file starting with comment '#' character
            if line[0].startswith('#'):
                continue

            output_checkfile(line)

    sys.exit(0)


if __name__ == "__main__":
    main()
