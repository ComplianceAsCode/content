#!/usr/bin/python2

import sys
import csv
import re
import os


# Define input template filename to resulting output filename mapping
files = { 'template_sebool' : 'sebool_' }

PENDING = '>SEBOOL_BOOL</linux:pending_status'
CURRENT = '>SEBOOL_BOOL</linux:current_status'
EXTERN_VAR = '''</linux:selinuxboolean_state>

  <external_variable comment="external variable for %s"
  datatype="boolean" id="var_%s" version="1" />
''' 


def bool_state(sebool_state):
    sebool = ""
    sebool_state = re.sub(' ', '', sebool_state)

    if sebool_state == "on" or sebool_state == "enable":
        sebool_state = "enabled"
    elif sebool_state == "off" or sebool_state == "disable":
        sebool_state = "disabled"
    elif sebool_state == "use_var" or sebool_state == "":
        pass
    else:
        print("Error: Invalid SELinux state value: %s" % sebool_state)
        sys.exit()

    if sebool_state == "enabled":
        sebool = "true"
    if sebool_state == "disabled":
        sebool = "false"

    return sebool_state, sebool


def output_checkfile(serviceinfo):
    # get the items out of the list
    sebool_name, sebool_state = serviceinfo
    # convert variable name to a format suitable for 'id' tags
    sebool_id = re.sub('[-\.]', '_', sebool_name)

    # open the template files and perform the conversions
    (sebool_state, sebool_bool) = bool_state(sebool_state)
    (dirname, script) = os.path.split(__file__)

    if not sebool_state:
        pass
    else:
        for seboolfile in files.keys():
            with open(dirname + '/' + seboolfile, 'r') as templatefile:
                filestring = templatefile.read()
                filestring = filestring.replace("SEBOOLID", sebool_id)
                if sebool_state != "use_var":
                    filestring = filestring.replace("SEBOOL_BOOL", sebool_bool)
                else:
                    filestring = filestring.replace(CURRENT, ' var_ref="var_%s" /' % sebool_id)
                    filestring = filestring.replace(PENDING, ' var_ref="var_%s" /' % sebool_id)
                    filestring = filestring.replace("</linux:selinuxboolean_state>", EXTERN_VAR % (sebool_id, sebool_id))
                # write the check
                with open("./oval/" + files[seboolfile] + sebool_id +
                          ".xml", 'w+') as outputfile:
                    outputfile.write(filestring)
                    outputfile.close()


def main():
    if len(sys.argv) < 2:
        print ("Provide a CSV file containing lines of the format: " +
               "seboolvariable,seboolstate")
        sys.exit(1)
    with open(sys.argv[1], 'r') as csv_file:
        # put the CSV line's items into a list
        sebool_lines = csv.reader(csv_file)
        for line in sebool_lines:

            # Skip lines of input file starting with comment '#' character
            if line[0].startswith('#'):
                continue

            output_checkfile(line)

    sys.exit(0)

if __name__ == "__main__":
    main()
