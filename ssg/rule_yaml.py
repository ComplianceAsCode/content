"""
The rule_yaml module provides various utility functions for handling YAML files
containing Jinja macros, without having to parse the macros.
"""

from __future__ import absolute_import
from __future__ import print_function

import os
import sys
from collections import namedtuple
import yaml

from .rules import get_rule_dir_yaml
from .utils import read_file_list


def find_section_lines(file_contents, sec):
    """
    Parses the given file_contents as YAML to find the section with the given identifier.
    Note that this does not call into the yaml library and thus correctly handles jinja
    macros at the expense of not being a strictly valid yaml parsing.

    Returns a list of namedtuples (start, end) of the lines where section exists.
    """

    # Hack to find a global key ("section"/sec) in a YAML-like file.
    # All indented lines until the next global key are included in the range.
    # For example:
    #
    # 0: not_it:
    # 1:     - value
    # 2: this_one:
    # 3:      - 2
    # 4:      - 5
    # 5:
    # 6: nor_this:
    #
    # for the section "this_one", the result [(2, 5)] will be returned.
    # Note that multiple sections may exist in a file and each will be
    # identified and returned.
    section = namedtuple('section', ['start', 'end'])

    sec_ranges = []
    sec_id = sec + ":"
    sec_len = len(sec_id)
    end_num = len(file_contents)
    line_num = 0

    while line_num < end_num:
        if len(file_contents[line_num]) >= sec_len:
            if file_contents[line_num][0:sec_len] == sec_id:
                begin = line_num
                line_num += 1
                while line_num < end_num:
                    nonempty_line = file_contents[line_num]
                    if nonempty_line and file_contents[line_num][0] != ' ':
                        break
                    line_num += 1

                end = line_num - 1
                sec_ranges.append(section(begin, end))
        line_num += 1

    return sec_ranges


def add_key_value(contents, key, start_line, new_value):
    """
    Adds a new key to contents with the given value after line start_line, returning
    the result. Also adds a blank line afterwards.

    Does not modify the value of contents.
    """

    new_contents = contents[:start_line]
    new_contents.append("%s: %s" % (key, new_value))
    new_contents.append("")
    new_contents.extend(contents[start_line:])

    return new_contents


def update_key_value(contents, key, old_value, new_value):
    """
    Find key in the contents of a file and replace its value with the new value,
    returning the resulting file. This validates that the old value is constant and
    hasn't changed since parsing its value.

    Raises a ValueError when the key cannot be found in the given contents.

    Does not modify the value of contents.
    """

    new_contents = contents[:]
    old_line = key + ": " + old_value
    updated = False

    for line_num in range(0, len(new_contents)):
        line = new_contents[line_num]
        if line == old_line:
            new_contents[line_num] = key + ": " + new_value
            updated = True
            break

    if not updated:
        raise ValueError("For key:%s, cannot find the old value (%s) in the given "
                         "contents." % (key, old_value))

    return new_contents


def remove_lines(contents, lines):
    """
    Remove the lines of the section from the parsed file, returning the new contents.

    Does not modify the passed in contents.
    """

    new_contents = contents[:lines.start]
    new_contents.extend(contents[lines.end+1:])
    return new_contents


def parse_from_yaml(file_contents, lines):
    """
    Parse the given line range as a yaml, returning the parsed object.
    """

    new_file_arr = file_contents[lines.start:lines.end + 1]
    new_file = "\n".join(new_file_arr)
    return yaml.load(new_file)


def get_yaml_contents(rule_obj):
    """
    From a rule_obj description, return a namedtuple of (path, contents); where
    path is the path to the rule YAML and contents is the list of lines in
    the file.
    """

    file_description = namedtuple('file_description', ('path', 'contents'))

    yaml_file = get_rule_dir_yaml(rule_obj['dir'])
    if not os.path.exists(yaml_file):
        raise ValueError("Error: yaml file does not exist for rule_id:%s" %
                         rule_obj['id'], file=sys.stderr)

    yaml_contents = read_file_list(yaml_file)

    return file_description(yaml_file, yaml_contents)


def parse_prodtype(prodtype):
    """
    From a prodtype line, returns the set of products listed.
    """

    return set(map(lambda x: x.strip(), prodtype.split(',')))


def get_section_lines(file_path, file_contents, key_name):
    """
    From the given file_path and file_contents, find the lines describing the section
    key_name and returns the line range of the section.
    """

    section = find_section_lines(file_contents, key_name)

    if len(section) > 1:
        raise ValueError("Multiple instances (%d) of %s in %s; refusing to modify file." %
                         (len(section), key_name, file_path), file=sys.stderr)

    elif len(section) == 1:
        return section[0]

    return None


def get_line_whitespace(line):
    """
    Get the exact whitespace used at the start of this line.
    """
    stripped_line = line.lstrip()
    delta = len(line) - len(stripped_line)
    return line[:delta]


def guess_section_whitespace(file_contents, section_range, default='    '):
    """
    Hack: we need to figure out how much whitespace to add when adding a new key to
    an existing section. Since different files might be parsed differently, take the
    minimum key's whitespace length in this section.
    """
    whitespace = None
    for line_num in range(section_range.start+1, section_range.end):
        line = file_contents[line_num]
        if line and ':' in line:
            # Assume this is a key, so update our assumptions of whitespace. We ignore
            # non-key lines.
            this_whitespace = get_line_whitespace(line)

            # Only take it if we have _less_ whitespace (to avoid dealing with nested
            # sections) or if we have no whitespace yet.
            if whitespace is None or len(this_whitespace) < len(whitespace):
                whitespace = this_whitespace

    # If we don't have any whitespace, use the default to show the YAML parser it
    # is a nested section.
    if whitespace is None:
        whitespace = default

    return whitespace


def add_or_modify_nested_section_key(file_path, file_contents, section_title,
                                     key, value, new_section_after_if_missing=None):
    """
    Either modify an existing nested section key (in key: value) form or
    add it if missing. Optionally, take a section and add our new section
    after the existing section.
    """
    new_contents = file_contents[:]
    section = get_section_lines(file_path, file_contents, section_title)

    if not section:
        if not new_section_after_if_missing:
            msg = "File %s lacks all instances of section %s; refusing to modify file."
            msg = msg.format(file_path, section)
            raise ValueError(msg)

        previous_section = get_section_lines(file_path, file_contents,
                                             new_section_after_if_missing)
        if not previous_section:
            msg = "File %s lacks all instances of sections %s and %s; refusing to modify file."
            msg = msg.format(file_path, section, new_section_after_if_missing)
            raise ValueError(msg)

        new_section_header = get_line_whitespace(file_contents[previous_section.start])
        new_section_header += section_title + ':'
        new_section_kv = guess_section_whitespace(file_contents, previous_section)
        new_section_kv += key + ': ' + value

        new_section = [new_section_header, new_section_kv, '']

        tmp_contents = new_contents[:previous_section.end+1]
        tmp_contents += new_section
        tmp_contents += new_contents[previous_section.end+1:]
        new_contents = tmp_contents

        return new_contents

    # Nasty hacky assumption: assume key is 'unique' within the section and we can
    # ignore whitespaces issues with this approach. Also assume (and validate!) that
    # : does not appear in the key. This allows us to split the line by ':' and take
    # the first as the actual key in the file.
    assert ':' not in key
    key_match = ' ' + key + ':'

    found = None
    for line_num in range(section.start, section.end+1):
        line = file_contents[line_num]
        if key_match in line:
            if found:
                msg = "Expected to only have key {0} appear once in file, but appeared "
                msg += "twice: once on line {1} and once on line {2}."
                msg = msg.format(key, found, line_num)
                raise ValueError(msg)

            # Preserve leading whitespace. :-)
            key_prefix = line.split(':', maxsplit=1)[0]
            new_line = key_prefix + ': ' + value
            new_contents[line_num] = new_line
            found = line

    if not found:
        # Be lazy and add it right after the section heading. Worst case we'll just
        # come back and sort the section at a later time.
        whitespace = guess_section_whitespace(file_contents, section)
        new_line = whitespace + key + ': ' + value
        tmp_contents = new_contents[:section.start+1]
        tmp_contents += [new_line]
        tmp_contents += new_contents[section.start+1:]
        new_contents = tmp_contents

    return new_contents
