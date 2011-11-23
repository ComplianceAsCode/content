#!/usr/bin/python

import sys, csv, re

def output_checkfile(serviceinfo):
    # get the items out of the list
    sysctl_var, sysctl_val, cce = serviceinfo
    # convert variable name to a format suitable for 'id' tags (get rid of periods and dashes)
    sysctl_var_id = sysctl_var.replace('.', '_')
    sysctl_var_id = sysctl_var_id.replace('-', '_')
    # build the regular expression that will find the variable
    sysctl_var_regex = sysctl_var.replace('.', '\.')
    # open the template and perform the conversions
    with open("template_sysctl", 'r') as templatefile:
        filestring = templatefile.read()
        filestring = filestring.replace("SYSCTLVAR", sysctl_var)
        filestring = filestring.replace("SYSCTLID", sysctl_var_id)
        filestring = filestring.replace("SYSCTLREGEX", sysctl_var_regex)
        filestring = filestring.replace("CCE_ID", cce if cce else "TODO")
        filestring = filestring.replace("SYSCTLVAL", sysctl_val)
        # write the check
        with open("./output/sysctl_" + sysctl_var_id + ".xml", 'wb+') as outputfile:
            outputfile.write(filestring)
            outputfile.close()

def main():
    if len(sys.argv) < 2:
        print "Provide a CSV file containing lines of the format: sysctlvariable,sysctlvalue,CCE"
        sys.exit(1)
    with open(sys.argv[1], 'r') as f:
        # put the CSV line's items into a list
        sysctl_lines = csv.reader(f)
        for line in sysctl_lines:
            output_checkfile(line)

    sys.exit(0)

if __name__ == "__main__":
    main()

