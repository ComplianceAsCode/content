"""
Common methods for generating files from templates
"""

import csv
import sys
import os
import re
import argparse

class ExitCodes:
    OK = 0
    ERROR = 1
    NO_TEMPLATE = 128 + 1
    UNKNOWN_TARGET = 128 + 2

class ActionType:
    INPUT = 1
    OUTPUT = 2
    BUILD = 3

product_input_dir = None
output_dir = None
action = None

class UnknownTargetError(ValueError):
    def __init__(self, msg):
        ValueError.__init__(self, "Unknown target language: \"{0}\"".format(msg))

def get_template_filename(filename):

    template_filename = os.path.join(product_input_dir, filename)

    if os.path.isfile(template_filename):
        return template_filename

    shared_dir = os.path.dirname(os.path.realpath(__file__))

    shared_template = os.path.join(shared_dir, filename)
    if os.path.isfile(shared_template):
        return shared_template

    sys.stderr.write(
        "No specialized or shared template found for {0}\n".format(filename)
    )
    sys.exit(ExitCodes.NO_TEMPLATE)


def load_modified(filename, constants_dict, regex_replace=[]):
    """
    Load file and replace constants according to constants_dict and regex_replace

    constants_dict: dict of constants - replace ( key -> value)
    regex_dict: dict of regex substitutions - sub ( key -> value)
    """

    template_filename = get_template_filename(filename)

    if action == ActionType.OUTPUT:
        return ""

    if action == ActionType.INPUT:
        print(template_filename)
        return ""

    with open(template_filename, "r") as template_file:
        filestring = template_file.read()

    for key, value in constants_dict.iteritems():
        filestring = filestring.replace(key, value)

    for pattern, replacement in regex_replace:
        filestring = re.sub(pattern, replacement, filestring)

    return filestring

def save_modified(filename_format, filename_value, string):
    """
    Save string to file
    """
    filename = filename_format.format(filename_value)

    filename = os.path.join(output_dir, filename)

    if action == ActionType.INPUT:
        return

    if action == ActionType.OUTPUT:
        print(filename)
        return

    with open(filename, 'w+') as outputfile:
        outputfile.write(string)

def file_from_template(template_filename, constants,
                       filename_format, filename_value, regex_replace=[]):
    """
    Load template, fill constant and create new file
    @param regex_replace: array of tuples (pattern, replacement)
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
            supported_targets = [x.strip() for x in match.group(1).split(",")]
            if target not in supported_targets:
                return None

    # get part before comment
    return (line.split("#")[0]).strip()


def filter_out_csv_lines(csv_file, language):
    """
    Filter out not applicable lines
    """

    for line in csv_file:
        processed_line = process_line(line, language)

        if not processed_line:
             continue

        yield processed_line


def csv_map(filename, method, language):
    """
    Call specified function on every line of file
    CSV lines can look like:
        col1, col2 # comment
        col3, col4 # only-for: bash, oval

    todo: remove skip_comments parameter - should be always True
    """

    with open(filename, 'r') as csv_file:
        filtered_file = filter_out_csv_lines(csv_file, language)

        csv_lines_content = csv.reader(filtered_file)

        try:
            for csv_line in csv_lines_content:
                method(language, csv_line)
        except UnknownTargetError as e:
            sys.stderr.write(str(e) + "\n")
            sys.exit(ExitCodes.UNKNOWN_TARGET)

def parse_args(csv_format):
    p = argparse.ArgumentParser()

    sp = p.add_subparsers(help="actions")

    make_sp = sp.add_parser('build', help="Build scripts")
    make_sp.set_defaults(action=ActionType.BUILD)

    input_sp = sp.add_parser('list-inputs', help="Generate input list")
    input_sp.set_defaults(action=ActionType.INPUT)

    output_sp = sp.add_parser('list-outputs', help="Generate output list")
    output_sp.set_defaults(action=ActionType.OUTPUT)

    p.add_argument('-s','--shared_dir', action="store", help="Shared directory")
    p.add_argument('--language', action="store", default=None, required=True,
                   help="Scripts of which language should we generate?")
    p.add_argument('-c',"--csv", action="store", required=True,
                   help="csv filename.\n" + csv_format)
    p.add_argument('-o','--output_dir', action="store", required=True,
                   help="output dir")
    p.add_argument('-i','--input_dir', action="store", required=True,
                   help="templates dir")

    args, unknown = p.parse_known_args()

    return (args,unknown)



def main(argv, csv_format, process_line_callback):

    parsed, unknown = parse_args(csv_format)

    if unknown:
        sys.stderr.write(
            "Unknown positional arguments " + ",".join(unknown) + ".\n"
        )
        sys.exit(ExitCodes.ERROR)

    global output_dir
    global action
    global product_input_dir

    output_dir = parsed.output_dir
    action = parsed.action
    product_input_dir = parsed.input_dir

    csv_map(parsed.csv, process_line_callback, language=parsed.language)
    sys.exit(ExitCodes.OK)
