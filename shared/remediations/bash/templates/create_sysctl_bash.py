#!/usr/bin/python

import sys
import csv
import re


def output_checkfile(serviceinfo):
    # get the items out of the list
    sysctl_var, sysctl_val = serviceinfo
    # convert variable name to a format suitable for 'id' tags
    sysctl_var_id = re.sub('[-\.]', '_', sysctl_var)

    # if the sysctl value is not present, use the variable template
    if not sysctl_val.strip():
        # open the template and perform the conversions 
        with open("template_sysctl_var", 'r') as templatefile:
            filestring = templatefile.read()
            filestring = filestring.replace("SYSCTLID", sysctl_var_id)
            filestring = filestring.replace("SYSCTLVAR", sysctl_var)
	    # write the check
            with open("./output/sysctl_"  + sysctl_var_id +
                      ".sh", 'w+') as outputfile:
                outputfile.write(filestring)
                outputfile.close()

    else:
        # open the template and perform the conversions
        with open("template_sysctl", 'r') as templatefile:
            filestring = templatefile.read()
            filestring = filestring.replace("SYSCTLID", sysctl_var_id)
            filestring = filestring.replace("SYSCTLVAR", sysctl_var)
            filestring = filestring.replace("SYSCTLVAL", sysctl_val)
            # write the check
            with open("./output/sysctl_" + sysctl_var_id +
                      ".sh", 'w+') as outputfile:
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

            # Skip lines of input file starting with comment '#' character
            if line[0].startswith('#'):
                continue

            output_checkfile(line)

    sys.exit(0)

if __name__ == "__main__":
    main()
