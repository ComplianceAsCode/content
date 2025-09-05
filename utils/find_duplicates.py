#!/usr/bin/env python2
"""
    This script should find duplicates e.g. specific template is same as shared one
"""
import sys
import os
import re
import glob
import argparse


def recursive_globi(mask):
    """
    Simple replacement of glob.globi(mask, recursive=true)
    Reason: Older Python versions support
    """

    parts = mask.split("**/")

    if not len(parts) == 2:
        raise NotImplementedError

    search_root = parts[0]

    # instead of '*' use regex '.*'
    path_mask = parts[1].replace("*", ".*")
    re_path_mask = re.compile(path_mask + "$")

    for root, dirnames, filenames in os.walk(search_root):
        paths = filenames + dirnames
        for path in paths:
            full_path = os.path.join(root, path)
            if re_path_mask.search(full_path):
                yield full_path


class DuplicatesFinder(object):
    def __init__(self, root_dir, specific_dirs_mask, shared_dir, shared_files_mask):
        self._root_dir = root_dir
        self._specific_dirs_mask = os.path.join(root_dir, specific_dirs_mask)
        self._shared_dir = os.path.join(root_dir, shared_dir)
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
        if not os.path.isfile(specific_filename):
            return False

        shared_normalized = self._get_normalized(shared_filename)
        specific_normalized = self._get_normalized(specific_filename)

        return shared_normalized == specific_normalized

    def _print_match(self, first_filename, second_filename):
        print("Duplicate found! {}\t=>\t{}".format(first_filename, second_filename))

    def search(self):
        """
        :return: True if any duplicate found
        """
        found = False
        self._clear_normalized()

        specific_dirs = list(self._specific_dirs())

        # Walk all shared files
        shared_files_mask = os.path.join(self._shared_dir, self._shared_files_mask)
        for shared_filename in glob.glob(shared_files_mask):

            basename = os.path.basename(shared_filename)

            # Walk all specific dirs
            for specific_dir in specific_dirs:

                # Get file to compare
                specific_filename = os.path.join(specific_dir, basename)

                # Compare
                if self._compare_files(shared_filename, specific_filename):
                    found = True
                    self._print_match(shared_filename, specific_filename)

        return found

    def _specific_dirs(self):
        for static_path in recursive_globi(self._specific_dirs_mask):
            if not static_path.startswith(self._shared_dir):
                yield static_path

    def _normalize_content(self, content):
        return content


class BashDuplicatesFinder(DuplicatesFinder):
    def __init__(self, root_dir, specific_dirs_mask, shared_dir, shared_files_mask="*.sh"):
        DuplicatesFinder.__init__(self, root_dir, specific_dirs_mask, shared_dir, shared_files_mask)

    def _normalize_content(self, content):
        # remove comments
        # naive implementation (todo)
        content = re.sub(r"^\s*#.*", "", content)

        # remove empty lines
        content = "\n".join([s for s in content.split("\n") if s])

        return content


class OvalDuplicatesFinder(DuplicatesFinder):
    def __init__(self, root_dir, specific_dirs_mask, shared_dir, shared_files_mask="*.xml"):
        DuplicatesFinder.__init__(self, root_dir, specific_dirs_mask, shared_dir, shared_files_mask)

    def _normalize_content(self, content):
        # remove comments
        # naive implementation (todo)
        content = re.sub(r"^\s*#.*", "", content)  # bash style comments - due to #platform
        content = re.sub('<!--.*?-->', "", content, flags=re.DOTALL)  # xml comments

        # remove empty lines
        content = "\n".join([s for s in content.split("\n") if s])

        return content


def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("root_ssg_directory", help="Path to root of ssg git repository")
    return parser.parse_args()


def main():
    """
    main function
    """
    args = parse_args()
    root_dir = args.root_ssg_directory
    without_duplicates = True

    # Static bash scripts
    print("Static bash files:")
    static_bash_finder = BashDuplicatesFinder(
        root_dir,
        os.path.join("**", "fixes", "bash"),
        os.path.join("shared", "fixes", "bash")
    )
    if static_bash_finder.search():
        without_duplicates = False

    # Templates bash scripts
    print("Bash templates:")
    template_bash_finder = BashDuplicatesFinder(
        root_dir,
        os.path.join("**", "templates"),
        os.path.join("shared", "templates"),
        "template_BASH_*"
    )
    if template_bash_finder.search():
        without_duplicates = False

    # Static oval files
    print("Static oval files:")
    static_oval_finder = OvalDuplicatesFinder(
        root_dir,
        os.path.join("**", "checks", "oval"),
        os.path.join("shared", "checks", "oval")
    )
    if static_oval_finder.search():
        without_duplicates = False

    # Templates oval files
    print("Templates oval files:")
    templates_oval_finder = OvalDuplicatesFinder(
        root_dir,
        os.path.join("**", "templates"),
        os.path.join("shared", "templates"),
        "template_OVAL_*"
    )

    if templates_oval_finder.search():
        without_duplicates = False

    # Scan results
    if without_duplicates:
        print("No duplicates found")
        sys.exit(0)
    else:
        print("Duplicates found!")
        sys.exit(1)


if __name__ == "__main__":
    main()
