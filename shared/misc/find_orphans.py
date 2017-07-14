#!/usr/bin/env python2

"""
This script lists all oval files made for all platforms (set as
multi_platform_all) , and check orphan oval files by parsing the XCCDF content.
This allows newly added distributions to support shared oval and multi-platform
oval without having a complete XCCDF checklist written, avoiding errors in
validate target.

This script is only a helper script, and should be used only while the XCCDF
files are being written, giving some time to the authors.
This is not for indefinite usage.

Author: Jean-Baptiste Donnette <donnet_j@epita.fr>
updated by: Philippe Thierry <phil@reseau-libre.net>
"""

import sys
import os
from lxml import etree


def find_xccdf_files(folder_name, xccdf_list):
    '''
    This fonction find every xccdf file that are in the input/xccdf/
    '''
    for element in os.listdir(folder_name):
        if element.endswith('.xml'):
            find_oval_def(folder_name + '/' +  element, xccdf_list)
        else:
            find_xccdf_files(folder_name + '/' + element, xccdf_list)



def find_oval_def(file_xccdf, xccdf_list):
    '''
    This fonction find every oval definition countainin the file_xccdf and add
    it into the xccdf_list
    '''
    tree = etree.parse(file_xccdf)
    for element in tree.iter():
        if element.tag == "oval":
            xccdf_list.append(element.get("id"))


def find_build_oval(folder_name, oval_list):
    '''
    This fonction find every oval files that are in the build directory and add
    it into the xccdf_list
    '''
    for element in os.listdir(folder_name):
        if element.endswith('.xml'):
            file_open = open(folder_name + '/' + element)
            for line in file_open:
                if "multi_platform_all" in line:
                    oval_list.append(element)
            file_open.close()

def main():
    '''
    main fonction
    '''
    if len(sys.argv) < 2:
        print "Usage : ./find_orphans name_of distribution target"
        sys.exit(1)
    oval_list = []
    xccdf_list = []
    build_dir = "build/" + sys.argv[1] + '_oval/'
    xccdf_directory = "input/xccdf/"

    find_build_oval(build_dir, oval_list)
    find_xccdf_files(xccdf_directory, xccdf_list)
    for element_build in oval_list:
        find = False
        for element_xccdf in xccdf_list:
            if element_build == element_xccdf + ".xml":
                find = True
        if not find:
            print build_dir + element_build


if __name__ == "__main__":
    main()

