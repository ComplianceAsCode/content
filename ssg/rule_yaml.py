"""
The rule_yaml module provides various utility functions for handling YAML files
containing Jinja macros, without having to parse the macros.
"""

from __future__ import absolute_import
from __future__ import print_function

import os
import sys
from collections import namedtuple, defaultdict
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
    return yaml.load(new_file, Loader=yaml.Loader)


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


def has_duplicated_subkeys(file_path, file_contents, sections):
    """
    Checks whether a section has duplicated keys. Note that these are silently
    eaten by the YAML parser we use.
    """

    if isinstance(sections, str):
        sections = [sections]

    for section in sections:
        # Get the lines in the file which match this section. If none exists,
        # it should be safe to silently ignore it. Clearly if the section
        # exists, there are no duplicated sections.
        section_range = get_section_lines(file_path, file_contents, section)
        if not section_range:
            continue

        # Get the YAML parser's version of events. :-)
        parsed_section = parse_from_yaml(file_contents, section_range)

        # Sort the YAML parser's subkeys.
        parent_key = list(parsed_section.keys())[0]
        if not parsed_section[parent_key]:
            continue
        subkeys = parsed_section[parent_key].keys()

        # Create a dictionary for counting them.
        subkey_counts = defaultdict(lambda: 0)

        # Iterate over the lines, see if they match a known key. Ignore the
        # first line (as it is the section header).
        for line_num in range(section_range.start+1, section_range.end):
            line = file_contents[line_num]
            if not line:
                continue

            # We'll be lazy for the time being. Iterate over all keys.
            for key in subkeys:
                our_key = ' ' + key + ':'
                if our_key in line:
                    subkey_counts[our_key] += 1
                    if subkey_counts[our_key] > 1:
                        print("Duplicated key " + our_key + " in " + section + " of " + file_path)
                        return True

    return False


def sort_section_keys(file_path, file_contents, sections, sort_func=None):
    """
    Sort subkeys in a YAML file's section.
    """

    if isinstance(sections, str):
        sections = [sections]

    new_contents = file_contents[:]

    for section in sections:
        section_range = get_section_lines(file_path, new_contents, section)
        if not section_range:
            continue

        # Start by parsing the lines as YAML.
        parsed_section = parse_from_yaml(new_contents, section_range)

        # Ignore the section header. This header is included in the start range,
        # so just increment by one.
        start_offset = 1
        while not new_contents[section_range.start + start_offset].strip():
            start_offset += 1

        # Ignore any trailing empty lines.
        end_offset = 0
        while not new_contents[section_range.end - end_offset].strip():
            end_offset += 1

        # Validate we only have a single section.
        assert len(parsed_section.keys()) == 1

        # Sort the parsed subkeys.
        parent_key = list(parsed_section.keys())[0]
        if not parsed_section[parent_key]:
            continue
        subkeys = sorted(parsed_section[parent_key].keys(), key=sort_func)

        # Don't bother if there are zero or one subkeys. Sorting order thus
        # doesn't matter.
        if not subkeys or len(subkeys) == 1:
            continue

        # Now we need to map sorted subkeys onto lines in the new contents,
        # so we can re-order them appropriately. We'll assume the section is
        # small so we'll do it in O(n^2).
        subkey_mapping = dict()
        for key in subkeys:
            our_line = None
            spaced_key = ' ' + key + ':'
            tabbed_key = '\t' + key + ':'
            range_start = section_range.start + start_offset
            range_end = section_range.end - end_offset + 1
            for line_num in range(range_start, range_end):
                this_line = new_contents[line_num]
                if spaced_key in this_line or tabbed_key in this_line:
                    if our_line:
                        # Not supposed to be possible to have multiple keys
                        # matching the same value in this file. We should've
                        # already fixed this with fix-rules.py's duplicate_subkeys.
                        msg = "File {0} has duplicated key {1}: {2} vs {3}"
                        msg = msg.format(file_path, key, our_line, this_line)
                        raise ValueError(msg)
                    our_line = this_line
            assert our_line
            subkey_mapping[key] = our_line

        # Now we'll remove all the section's subkeys and start over. Include
        # section header but not any of the keys (or potential blank lines
        # in the interior -- but we preserve them on either end of the
        # section).
        prefix = new_contents[:section_range.start+start_offset]
        contents = list(map(lambda key: subkey_mapping[key], subkeys))
        suffix = new_contents[section_range.end+1-end_offset:]

        new_contents = prefix + contents + suffix

    return new_contents
