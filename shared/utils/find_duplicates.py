#!/usr/bin/python3

import sys
from os import path
import glob
import re


class DuplicitiesFinder(object):
    def __init__(self, root_dir, specific_dirs_mask, shared_dir, shared_files_mask):
        self._root_dir = root_dir
        self._specific_dirs_mask = path.join(root_dir, specific_dirs_mask)
        self._shared_dir = path.join(root_dir, shared_dir)
        self._clear_normalized()
        self._shared_files_mask = shared_files_mask

    def _clear_normalized(self):
        self._normalized = {}

    def _get_normalized(self, file_path):
        """
        Return cached normalized content of file
        :param file_path:
        :return:
        """
        if file_path in self._normalized:
            return self._normalized[file_path]

        with open(file_path, 'r') as content_file:
            content = content_file.read()
            normalized = self._normalize_content(content)
            self._normalized[file_path] = normalized
            return normalized

    def _compare_files(self, shared_filename, specific_filename):
        """
        :param shared_filename:
        :param specific_filename:
        :return:
        """
        if not path.isfile(specific_filename):
            return False

        shared_normalized = self._get_normalized(shared_filename)
        specific_normalized = self._get_normalized(specific_filename)

        return shared_normalized == specific_normalized

    def _print_match(self, first_filename, second_filename):
        print("Duplicity found! {}\t=>\t{}".format(first_filename, second_filename))

    def search(self):
        """

        :return: True if duplicity found
        """
        found = False
        self._clear_normalized()

        specific_dirs = list(self._specific_dirs())

        # Walk all shared files
        shared_files_mask = path.join(self._shared_dir, self._shared_files_mask)
        for shared_filename in glob.glob(shared_files_mask):

            basename = path.basename(shared_filename)

            # Walk all specific dirs
            for specific_dir in specific_dirs:

                # Get file to compare
                specific_filename = path.join(specific_dir, basename)

                # Compare
                if self._compare_files(shared_filename, specific_filename):
                    found = True
                    self._print_match(shared_filename, specific_filename)

        return found

    def _specific_dirs(self):
        for static_path in glob.glob(self._specific_dirs_mask, recursive=True):
            if not static_path.startswith(self._shared_dir):
                yield static_path

    def _normalize_content(self, content):
        return content


class BashDuplicitiesFinder(DuplicitiesFinder):
    def __init__(self, root_dir, specific_dirs_mask, shared_dir, shared_files_mask="*.sh"):
        DuplicitiesFinder.__init__(self, root_dir, specific_dirs_mask, shared_dir, shared_files_mask)

    def _normalize_content(self, content):
        # remove comments
        # naive implementation (todo)
        content = re.sub(r"^\s*#.*", "", content)

        # remove empty lines
        content = "\n" + content + "\n"
        content = "\n".join([s for s in content.split("\n") if s])

        return content


def main():
    '''
    main function
    '''
    if len(sys.argv) < 2:
        print("Usage : ./find_duplicities root_ssg_directory")
        sys.exit(1)

    root_dir = sys.argv[1]
    without_duplicities = True


    # Static bash scripts
    print("Static bash files:")
    static_bash_finder = BashDuplicitiesFinder(
        root_dir,
        path.join("**", "static", "bash"),
        path.join("shared", "templates", "static", "bash")
    )
    if static_bash_finder.search():
        without_duplicities = False


    # Templates bash scripts
    print("Bash templates:")
    template_bash_finder = BashDuplicitiesFinder(
        root_dir,
        path.join("**", "templates"),
        path.join("shared", "templates"),
        "template_BASH_*"
    )
    if template_bash_finder.search():
        without_duplicities = False


    # Scan result
    if without_duplicities:
        print("No duplicities found")
        sys.exit(0)
    else:
        print("Duplicities found!")
        sys.exit(1)


if __name__ == "__main__":
    main()
