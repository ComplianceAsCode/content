#!/usr/bin/python

#
# create_services_enabled.py
#   automatically generate checks for enabled services
#
# NOTE: This script relies upon two templates: 'template_service_enabled' and 'template_package_installed'. These
# templates should exist in the same directory as this script. The templates contain the following tags that *must*
# be replaced successfully in order for the checks to work.
#
# SERVICE_NAME - the name of the service as it appears in "/sbin/chkconfig --list"
# SERVICE_CCE - the specific CCE that corresponds with the service check
# PACKAGE_NAME - the name of the package that installs the given service
# PACKAGE_CCE - the specific CCE that corresponds with the package check
#

import sys, csv, re

def output_check(serviceinfo):
    service_name, service_cce, package_name, package_cce = serviceinfo
    # verify the input
    if (service_name and package_name):
        with open("./template_service_enabled", 'r') as templatefile:
            filestring = templatefile.read()
            filestring = filestring.replace("SERVICE_NAME", service_name)
            filestring = filestring.replace("SERVICE_CCE", service_cce if service_cce else "TODO")
            filestring = filestring.replace("PACKAGE_NAME", package_name)
            with open("./output/service_" + service_name + "_enabled.xml", 'wb+') as outputfile:
                outputfile.write(filestring)
                outputfile.close()
        with open("./template_package_installed", 'r') as templatefile:
            filestring = templatefile.read()
            filestring = filestring.replace("PACKAGE_NAME", package_name)
            filestring = filestring.replace("PACKAGE_CCE", package_cce if package_cce else "TODO")
            with open("./output/package_" + package_name + "_installed.xml", 'wb+') as outputfile:
                outputfile.write(filestring)
                outputfile.close()
    else:
        print("ERROR: input violation: both service name and package name must be defined")
        print("   service_name --> \"%s\" service_cce --> \"%s\" package_name --> \"%s\" package_cce --> \"%s\"" % (service_name, service_cce, package_name, package_cce))

def main():
    if len(sys.argv) < 2:
        print("usage: %s <CSV_FILE_PATH>" % sys.argv[0])
        print("   the csv file should contain lines of the format:")
        print("   SERVICE_NAME,SERVICE_CCE,PACKAGE_NAME,PACKAGE_CCE")
        sys.exit(1)
    with open(sys.argv[1], 'r') as f:
        # read the csv from the file
        servicelines = csv.reader(f)
        for line in servicelines:
            output_check(line)

    sys.exit(0)

if __name__ == "__main__":
    main()

