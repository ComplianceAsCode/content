#!/usr/bin/python2

import sys
import os
import re
import glob


# The goal of this script is to find orphans rules that are in xccdf files
# and remove it/them

def find_xccdf_files(folder_name, xccdf_list):
    for element in os.listdir(folder_name):
        if os.path.isdir(element):
            find_xccdf_files(element, xccdf_list)
        else:
            #vérifier qu'il soit un fichier oval et ajouter les régles à la liste
            xccdf_list.append(element)





def main():
    if len(sys.argv) < 2:
        print "Usage : ./find_orphans name_of distribution target"
        sys.exit(1)

    build_dir = "build/" + sys.argv[1] + '_oval/'
    xccdf_directory = "input/xccdf/"

    #create a liste from all oval def
    oval_list = glob.glob(build_dir + '*.xml')
    xccdf_list = []
    print xccdf_list

    #oval id="name"


if __name__ == "__main__":
    main()
