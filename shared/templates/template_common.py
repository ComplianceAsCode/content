"""
Common methods for generating files from templates
"""

import csv
import sys
import os
import re

def get_template_file(filename):
    try:

        if 'TEMPLATE_DIR' in os.environ:
            template_filename = os.path.join(os.environ['TEMPLATE_DIR'], filename)
        else:
            template_filename = filename

        return open(template_filename, 'r')

    except IOError:
        # guess shared template
        if 'SHARED_DIR' in os.environ:
            shared_template = os.environ['SHARED_DIR'] + filename
            return open(shared_template, "r")
        else:
            sys.stderr.write(
                "No specialized or shared template found for {}\n".format(filename)
            )
            

def load_modified(filename, constants_dict, regex_dict = None):
    """
    Load file and replace constants accoring to constants_dict and regex_dict

    constants_dict: dict of constants - replace ( key -> value)
    regex_dict: dict of regex substitutions - sub ( key -> value)
    """

    with get_template_file(filename) as template_file:
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
    dir = os.environ.get('PREFIX_DIR', '')
    filename = os.path.join(dir, filename)
    with open(filename, 'w+') as outputfile:
        outputfile.write(string)


def file_from_template(template_filename, constants,
                       filename_format, filename_value, regex_replace = None):
    """
    Load template, fill constant and create new file
    """

    filled_template = load_modified(template_filename, constants, regex_replace)

    save_modified(filename_format, filename_value, filled_template)


def csv_map(filename, method, skip_comments = False):
    """
    Call specified function on every line of file
    """
    with open(filename, 'r') as csv_file:
        # put the CSV line's items into a list
        lines = csv.reader(csv_file)
        for line in lines:
            if not line:
                continue
            if skip_comments and line[0].startswith('#'):
                continue
            method(line)

