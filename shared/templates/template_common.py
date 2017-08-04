"""
Common methods for generating files from templates
"""

import csv
import sys
import os
import re
from abc import abstractmethod


class ActionType:
    INPUT = 1
    OUTPUT = 2
    BUILD = 3


class UnknownTargetError(ValueError):
    def __init__(self, msg):
        super(UnknownTargetError, self).__init__(
            "Unknown target language: \"{0}\"".format(msg)
        )


class TemplateNotFoundError(RuntimeError):
    def __init__(self, template, paths):
        super(TemplateNotFoundError, self).__init__(
            "Template not found: '%s'. Looked in %s."
            % (template, ", ".join(paths))
        )

TARGET_REGEX = re.compile(r"#\s*only-for:([\s\w,]*)")


class FilesGenerator(object):
    def __init__(self):
        self.delimiter = ','
        self.reset()

    def reset(self):
        self.files = []

    def get_template_filename(self, filename):
        template_filename = os.path.join(self.product_input_dir, filename)

        if os.path.isfile(template_filename):
            return template_filename

        paths = [self.product_input_dir]

        if self.product_input_dir.endswith("oval_5.11_templates"):
            template_filename = os.path.join(
                os.path.dirname(self.product_input_dir), filename
            )
            if os.path.isfile(template_filename):
                return template_filename
            paths.append(os.path.dirname(template_filename))

        shared_template = os.path.join(self.shared_dir, "templates", filename)
        if os.path.isfile(shared_template):
            return shared_template
        paths.append(os.path.dirname(shared_template))

        raise TemplateNotFoundError(filename, paths)

    def load_modified(self, filename, constants_dict, regex_replace=[]):
        """
        Load file and replace constants according to constants_dict and
        regex_replace

        constants_dict: dict of constants - replace ( key -> value)
        regex_dict: dict of regex substitutions - sub ( key -> value)
        """

        template_filename = self.get_template_filename(filename)

        if self.action == ActionType.OUTPUT:
            return ""

        if self.action == ActionType.INPUT:
            self.files.append(template_filename)
            return ""

        with open(template_filename, "r") as template_file:
            filestring = template_file.read()

        for key, value in constants_dict.iteritems():
            if not key.startswith("%") or not key.endswith("%"):
                raise RuntimeError(
                    "Refuse to replace '%s' because it doesn't start and end "
                    "with the %% character. Please follow conventions! "
                    "Class name: %s" % (key, self.__class__))

            filestring = filestring.replace(key, value)

            trimmed_key = key[1:-1]  # the key without the % padding chars
            if trimmed_key in filestring:
                highlighted_filestring = filestring.replace(
                    trimmed_key, "--->%s<---" % (trimmed_key)
                )
                raise RuntimeError(
                    "Trimmed key '%s' was found in the filestring after the "
                    "substitution was performed. This is usually a typo or a "
                    "mistake in the template, the python generator or both. "
                    "In the rare case where this is expected please rename the "
                    "key to something unambiguous. Class name: %s. Filestring "
                    "with the trimmed key highlighted:\n%s"
                    % (trimmed_key, self.__class__, highlighted_filestring))

        for pattern, replacement in regex_replace:
            filestring = re.sub(pattern, replacement, filestring)

        return filestring

    def save_modified(self, filename_format, filename_value, string):
        """
        Save string to file
        """

        if self.action == ActionType.INPUT:
            return

        filename = os.path.join(
            self.output_dir, filename_format.format(filename_value)
        )

        if self.action == ActionType.OUTPUT:
            self.files.append(filename)
            return

        with open(filename, "w") as f:
            f.write(string)

    def file_from_template(self, template_filename, constants,
                           filename_format, filename_value, regex_replace=[]):
        """
        Load template, fill constant and create new file
        @param regex_replace: array of tuples (pattern, replacement)
        """

        try:
            filled_template = \
                self.load_modified(template_filename, constants, regex_replace)

            self.save_modified(filename_format, filename_value, filled_template)

        except TemplateNotFoundError as e:
            if self.action == ActionType.BUILD:
                sys.stderr.write(str(e) + "\n")

    def process_csv_line(self, line, target):
        """
        Remove comments
        Remove line if target is unsupported
        """

        if target is not None:
            match = TARGET_REGEX.search(line)

            if match:
                # if line contains restriction to target, check it
                supported_targets = \
                    [x.strip() for x in match.group(1).split(",")]
                if target not in supported_targets:
                    return None

        # get part before comment
        return (line.split("#")[0]).strip()

    def filter_out_csv_lines(self, csv_file, language):
        """Filter out not applicable lines
        """

        for line in csv_file:
            processed_line = self.process_csv_line(line, language)

            if not processed_line:
                continue

            yield processed_line

    def csv_map(self, filename, language):
        """Call specified function on every line of file

        CSV lines can look like:
            col1, col2 # comment
            col3, col4 # only-for: bash, oval
        """

        with open(filename, "r") as csv_file:
            filtered_file = self.filter_out_csv_lines(
                csv_file.readlines(), language)
            csv_lines_content = csv.reader(filtered_file,
                                           delimiter=self.delimiter)

            try:
                for csv_line in csv_lines_content:
                    self.generate(language, csv_line)

            except UnknownTargetError as e:
                if self.action == ActionType.BUILD:
                    sys.stderr.write(str(e) + "\n")

    @abstractmethod
    def csv_format(self):
        raise NotImplementedError("Please Implement this method")
