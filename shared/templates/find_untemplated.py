#!/usr/bin/env python2

import sys
import os
import glob

# locate files in the parent directory that match a certain filename pattern
# and thus should be templated, and compare to currently templated files.


def main():
    prefixsearchlist = ['package_', 'service_', 'sysctl_',
                        'kernel_module_']
    # the directory/file permission situation still needs to be sorted out,
    # then we should add file_permissions etc

    templatable_files = []
    for prefix in prefixsearchlist:
        foundfiles = glob.glob("../"+prefix+"*.xml")
        templatable_files.extend(foundfiles)

    templatable = set([os.path.basename(file) for file in templatable_files])
    templated = set([os.path.basename(file) for file in glob.glob("./output/*.xml")])
    untemplated = templatable.difference(templated)

    print ("\nThe following files' names suggest they could be " +
           "templated, though they might be intentionally edited:")
    for file in untemplated:
        print file
    print ("\nA typical reason for hand-editing a file is to " +
           "gracefully handle situations where the test should pass.")

    sys.exit(0)

if __name__ == "__main__":
    main()
