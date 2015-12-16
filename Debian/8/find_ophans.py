#!/usr/bin/python2

import sys
import os
import re
import glob


# The goal of this script is to find orphans rules that are in xccdf files
# and remove it/them

def find_xccdf_files (folder_name, xccdf_list):
    for element in os.listdir(folder_name):
        if element.endswith('.xml'):
            find_oval_def(folder_name + '/' +  element, xccdf_list)
        else:
            find_xccdf_files(folder_name + '/' + element, xccdf_list)

def find_oval_def (file_xccdf, xccdf_list):
    file_open = open (file_xccdf)
    for line in file_open:
        if "<oval id=" in line:
            #remove balises
            xccdf_list.append(line[10:-5])
    file_open.close()




def main():
    if len(sys.argv) < 2:
        print "Usage : ./find_orphans name_of distribution target"
        sys.exit(1)

    build_dir = "build/" + sys.argv[1] + '_oval/'
    xccdf_directory = "input/xccdf/"

    #create a liste from all oval def
    oval_list = glob.glob(build_dir + '*.xml')
    xccdf_list = []
    find_xccdf_files (xccdf_directory, xccdf_list)
    print(xccdf_list)


if __name__ == "__main__":
    main()
