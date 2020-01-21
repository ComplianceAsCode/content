#!/usr/bin/env python2

from __future__ import print_function

import os
import sys


MAX_PATH_LEN = 200


def main():
    ssg_root = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
    max_path = ""
    for dir_, _, files in os.walk(ssg_root):
        # Don't check for path len of log files
        # They are not shipped nor used during build
        current_relative_path = os.path.relpath(dir_, ssg_root)
        if current_relative_path.startswith("tests/logs/"):
            continue
        for file_ in files:
            path = os.path.relpath(os.path.join(dir_, file_), ssg_root)
            if len(path) > len(max_path):
                max_path = path

    print("The longest file path is '%s' at %i characters."
          % (max_path, len(max_path)))

    if len(max_path) > MAX_PATH_LEN:
        print("At least one file path is longer than %i characters. That may "
              "be problematic on some platforms." % (MAX_PATH_LEN),
              file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
