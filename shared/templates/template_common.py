"""
Common methods for generating files from templates
"""

import csv
import sys
import os
import re

EXIT_NO_TEMPLATE    = 2
EXIT_UNKNOWN_TARGET = 3

class UnknownTargetError(ValueError):
    def __init__(self, msg):
        ValueError.__init__(self, "Unknown target: \"{0}\"".format(msg))

def get_template_filename(filename):

    if 'TEMPLATE_DIR' in os.environ:
        template_filename = os.path.join(os.environ['TEMPLATE_DIR'], filename)
    else:
        template_filename = filename

    if os.path.isfile(template_filename):
        return template_filename

    # guess shared template
    if 'SHARED_DIR' in os.environ:
        shared_template = os.path.join(os.environ['SHARED_DIR'], filename)
        if os.path.isfile(shared_template):
            return shared_template

    sys.stderr.write(
        "No specialized or shared template found for {}\n".format(filename)
    )
    sys.exit(EXIT_NO_TEMPLATE)


def load_modified(filename, constants_dict, regex_dict = None):
    """
    Load file and replace constants accoring to constants_dict and regex_dict

    constants_dict: dict of constants - replace ( key -> value)
    regex_dict: dict of regex substitutions - sub ( key -> value)
    """

    template_filename = get_template_filename(filename)

    if os.environ.get('GENERATE_OUTPUT_LIST', '') == "true":
        return ""

    if os.environ.get('GENERATE_INPUT_LIST', '') == "true":
        print(template_filename)
        return ""

    with open(template_filename, "r") as template_file:
        filestring = template_file.read()

    for key, value in constants_dict.iteritems():
       filestring = filestring.replace(key, value)

    if regex_dict:
        for pattern, replacement in regex_dict.iteritems():
            filestring = re.sub(pattern, replacement, filestring)

    return filestring

def save_modified(filename_format, filename_value, string):
    """
    Save string to file
    """
    filename = filename_format.format(filename_value)
    dir = os.environ.get('BUILD_DIR', '')
    filename = os.path.join(dir, filename)

    if os.environ.get('GENERATE_INPUT_LIST', '') == "true":
        return

    if os.environ.get('GENERATE_OUTPUT_LIST', '') == "true":
        print(filename)
        return

    with open(filename, 'w+') as outputfile:
        outputfile.write(string)

def file_from_template(template_filename, constants,
                       filename_format, filename_value, regex_replace = None):
    """
    Load template, fill constant and create new file
    """

    filled_template = load_modified(template_filename, constants, regex_replace)

    save_modified(filename_format, filename_value, filled_template)


def process_line(line, target):
    """
    Remove comments
    Remove line if target is unsupported
    """

    if target is not None:
        regex = re.compile(r"#\s*only-for:([\s\w,]*)")

        match = regex.search(line)

        if match:
            # if line contains restriction to target, check it
            supported_targets = [ x.strip() for x in match.group(1).split(",") ]
            if target not in supported_targets:
                return None

    # get part before comment
    return (line.split("#")[0]).strip()


def filter_out_csv_lines(csv_file, target):
    """
    Filter out not applicable lines
    """

    for line in csv_file:
        processed_line = process_line(line, target)

        if not processed_line:
             continue

        yield processed_line


def csv_map(filename, method, skip_comments = True, target = None):
    """
    Call specified function on every line of file
    CSV lines can look like:
        col1, col2 # comment
        col3, col4 # only-for: bash, oval

    todo: remove skip_comments parameter - should be always True
    """

    with open(filename, 'r') as csv_file:
        filtered_file = filter_out_csv_lines(csv_file, target)

        csv_lines_content = csv.reader(filtered_file)

        try:
            map(method, csv_lines_content)
        except UnknownTargetError as e:
            sys.stderr.write(str(e) + "\n")
            sys.exit(EXIT_UNKNOWN_TARGET)

def main(argv, help_callback, process_line_callback):

    argv_len = len(argv)

    if argv_len < 3:
        help_callback()
        sys.exit(1)

    target = sys.argv[1]
    filename = sys.argv[2]

    def process_line(*args):
        # todo: pass target only to csv_map()
        process_line_callback(target, *args)

    csv_map(filename, process_line, target=target)
    sys.exit(0)
