#!/usr/bin/python

import sys
import csv
import re

# Define input template filename to resulting output filename mapping
files = { 'template_sysctl_static' : 'sysctl_static_',
          'template_sysctl_runtime' : 'sysctl_runtime_',
          'template_sysctl' : 'sysctl_' }

def output_checkfile(serviceinfo):
    # get the items out of the list
    sysctl_var, sysctl_val = serviceinfo
    # convert variable name to a format suitable for 'id' tags
    sysctl_var_id = re.sub('[-\.]', '_', sysctl_var)
    # open the template files and perform the conversions
    for sysctlfile in files.keys():
        with open(sysctlfile, 'r') as templatefile:
            filestring = templatefile.read()
            filestring = filestring.replace("SYSCTLID", sysctl_var_id)
            filestring = filestring.replace("SYSCTLVAR", sysctl_var)
            filestring = filestring.replace("SYSCTLVAL", sysctl_val)
            # write the check
            with open("./output/" + files[sysctlfile] + sysctl_var_id +
                      ".xml", 'w+') as outputfile:
                outputfile.write(filestring)
                outputfile.close()


def main():
    if len(sys.argv) < 2:
        print ("Provide a CSV file containing lines of the format: " +
               "sysctlvariable,sysctlvalue")
        sys.exit(1)
    with open(sys.argv[1], 'r') as csv_file:
        # put the CSV line's items into a list
        sysctl_lines = csv.reader(csv_file)
        for line in sysctl_lines:
            output_checkfile(line)

    sys.exit(0)

if __name__ == "__main__":
    main()
