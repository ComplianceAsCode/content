import sys
import os
import re
import glob

from ssg._utils import recursive_globi


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
