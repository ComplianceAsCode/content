#!/usr/bin/python

import sys, csv, re

def output_checkfile(serviceinfo):
    #get the items out of the list
    servicename, packagename, cce = serviceinfo
    with open("service_disabled_template", 'r') as templatefile:
        filestring = templatefile.read()
        filestring = filestring.replace("SERVICENAME", servicename)
        filestring = filestring.replace("CCE_ID", cce if cce else "TODO")
        # if there's no packagename, use regexes to remove the criteria
        if packagename:
            filestring = filestring.replace("PACKAGENAME", packagename)
        else:
            filestring = re.sub("<criteria.*\n.*<extend_definition.*/>","",filestring)
            filestring = filestring.replace("</criteria>", "",1)
        with open("output/service_" + servicename + "_disabled.xml", 'wb+') as outputfile:
            outputfile.write(filestring)
            outputfile.close()

def main():
    if len(sys.argv) < 2:
        print "Provide a CSV file containing lines of the format: servicename,packagename,CCE"
        sys.exit(1)
    with open(sys.argv[1], 'r') as f:
        # put the CSV line's items into a list
        servicelines = csv.reader(f)
        for line in servicelines:
            output_checkfile(line)

    sys.exit(0)

if __name__ == "__main__":
    main()

