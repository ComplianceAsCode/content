from __future__ import print_function

"""
Common methods for generating files from templates
"""

import csv
import sys
import os
import re
import ssg.jinja
import ssg.utils
from abc import abstractmethod


class ActionType:
    INPUT = 1
    OUTPUT = 2
    BUILD = 3


class CSVLineError(Exception):
    pass


class UnknownTargetError(ValueError):
    def __init__(self, lang):
        super(UnknownTargetError, self).__init__(
            "Unknown target language: \"{0}\"".format(lang)
        )
        self.lang = lang


class TemplateNotFoundError(RuntimeError):
    def __init__(self, template, paths):
        super(TemplateNotFoundError, self).__init__(
            "Template not found: '%s'. Looked in %s."
            % (template, ", ".join(paths))
        )


TEMPLATED_LANGUAGES = ["bash", "ansible", "oval", "anaconda", "puppet"]
TARGET_EXCLUDE_REGEX = re.compile(r"#\s*except-for:([\s\w,]*)")


class FilesGenerator(object):
    def __init__(self):
        self.delimiter = ','
        self.reset()
        self.env_yaml = {}

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

            shared_template = os.path.join(self.shared_dir, "templates",
                                           "oval_5.11_templates", filename)
            if os.path.isfile(shared_template):
                return shared_template
            paths.append(os.path.dirname(shared_template))

        shared_template = os.path.join(self.shared_dir, "templates", filename)
        if os.path.isfile(shared_template):
            return shared_template
        paths.append(os.path.dirname(shared_template))

        raise TemplateNotFoundError(filename, paths)

    def file_from_template(self, template_filename, constants,
                           filename_format, filename_value, *extra_filename_args):
        """
        Load template, fill constant and create new file
        """

        template_filepath = self.get_template_filename(template_filename)
        format_args = (filename_value,) + extra_filename_args
        output_filepath = os.path.join(
            self.output_dir, filename_format.format(*format_args)
        )

        if self.action == ActionType.INPUT:
            self.files.append(template_filepath)
            return
        elif self.action == ActionType.OUTPUT:
            self.files.append(output_filepath)
            return

        try:
            jinja_dict = ssg.utils.merge_dicts(self.env_yaml, constants)
            filled_template = ssg.jinja.process_file_with_macros(template_filepath,
                                                                 jinja_dict)

            with open(output_filepath, "w") as f:
                f.write(filled_template)

        except TemplateNotFoundError as e:
            print(e, file=sys.stderr)

    def process_csv_line(self, line, target):
        """
        Remove comments
        Remove line if target is unsupported
        """

        if target is not None:
            exclude_match = TARGET_EXCLUDE_REGEX.search(line)

            if exclude_match:
                # Check if line contains restriction to target
                unsupported_targets = \
                    [x.strip() for x in exclude_match.group(1).split(",")]
                if target in unsupported_targets:
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
            col3, col4 # except-for: bash, oval
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
                    # If lang is one of these it just means that the template
                    # doesn't implement that language. It doesn't mean that the
                    # target is invalid.
                    if e.lang not in TEMPLATED_LANGUAGES:
                        sys.stderr.write(str(e) + "\n")
            except CSVLineError as e:
                sys.stderr.write("Unexpected CSV line format in "
                                 "file {}: \"{}\"\n".format(filename, ",".join(csv_line)))



    @abstractmethod
    def csv_format(self):
        raise NotImplementedError("Please Implement this method")
