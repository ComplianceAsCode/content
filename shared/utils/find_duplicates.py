#!/usr/bin/python3

import sys
from os import path
import glob
import re


class BashDuplicitiesFinder:
    def __init__(self, root_dir):
        self._root_dir = root_dir
        self._shared_static = path.join(root_dir, "shared", "templates", "static", "bash")
        self._normalized = {}

    def _static_dirs(self):
        mask = path.join(self._root_dir, "**", "static", "bash")
        for static_path in glob.glob(mask, recursive=True):
            if not static_path.startswith(self._shared_static):
                yield static_path

    def _normalize_script(self, content):
        # remove comments
        # naive implementation (todo)
        content = re.sub(r"^\s*#.*", "", content)

        # remove empty lines
        content = "\n" + content + "\n"
        content = "\n".join([s for s in content.split("\n") if s])

        return content

    def _get_normalized(self, file_path):
        if file_path in self._normalized:
            return self._normalized[file_path]

        with open(file_path, 'r') as content_file:
            content = content_file.read()
            normalized = self._normalize_script(content)
            self._normalized[file_path] = normalized
            return normalized

    def search(self):
        self.search_static()

    def search_static(self):
        self._normalized = {}

        static_dirs = list(self._static_dirs())

        # Walk all static scripts
        static_scripts = path.join(self._shared_static, "*.sh")
        for shared_static_filename in glob.glob(static_scripts):

            basename = path.basename(shared_static_filename)

            # Walk all specific dirs
            for specific_static_dir in static_dirs:

                # Get file to compare
                specific_filename = path.join(specific_static_dir, basename)

                # Compare
                if self._compare_files(shared_static_filename, specific_filename):
                    print("Duplicity found! {}\t=>\t{}".format(shared_static_filename, specific_filename))


    def _compare_files(self, shared_filename, specific_filename):
        if not path.isfile(specific_filename):
            return False

        shared_normalized = self._get_normalized(shared_filename)
        specific_normalized = self._get_normalized(specific_filename)

        return shared_normalized == specific_normalized


def main():
    '''
    main function
    '''
    if len(sys.argv) < 2:
        print("Usage : ./find_duplicities root_ssg_directory")
        sys.exit(1)

    root_dir = sys.argv[1]
    finder = BashDuplicitiesFinder(root_dir)

    print()
    finder.search()



if __name__ == "__main__":
    main()
