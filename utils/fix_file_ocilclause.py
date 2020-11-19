import sys
import os
import argparse
import subprocess
import jinja2
import yaml

import ssg


def _create_profile_cache(ssg_root):
    profile_cache = {}

    product_list = ['debian9', 'debian10', 'fedora', 'ol7', 'opensuse',
                    'rhel7', 'sle12', 'ubuntu1604', 'ubuntu1804', 'ubuntu2004',
                    'wrlinux']

    for product in product_list:
        found_obj_name = False
        prod_profiles_dir = os.path.join(ssg_root, product, "profiles")
        for _, _, files in os.walk(prod_profiles_dir):
            for filename in files:
                profile_path = os.path.join(prod_profiles_dir, filename)
                parsed_profile = yaml.load(open(profile_path, 'r'))
                for _obj in parsed_profile['selections']:
                    obj = _obj
                    if '=' in obj:
                        # is a var with non-default value
                        obj = _obj[:_obj.index('=')]
                    if not obj[0].isalpha():
                        obj = obj[1:]

                    if obj not in profile_cache:
                        profile_cache[obj] = set()

                    profile_cache[obj].add(product)

    return profile_cache


def read_file(path):
    file_contents = open(path, 'r').read().split("\n")
    if file_contents[-1] == '':
        file_contents = file_contents[:-1]
    return file_contents


def write_file(path, contents):
    _f = open(path, 'w')
    for line in contents:
        _f.write(line + "\n")

    _f.flush()
    _f.close()


def find_section_lines(file_contents, sec):
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
                    if len(file_contents[line_num]) > 0 and file_contents[line_num][0] != ' ':
                        break
                    line_num += 1

                end = line_num - 1
                sec_ranges.append((begin, end))
        line_num += 1
    return sec_ranges


def update_key_value(contents, key, old_value, new_value):
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
        assert(False)

    return new_contents


def update_subkey_value(contents, key, subkey, old_value, new_value):
    new_contents = contents[:]
    old_line = "    " + subkey + ": " + old_value
    key_range = find_section_lines(contents, key)[0]
    updated = False

    for line_num in range(key_range[0], key_range[1] + 1):
        line = new_contents[line_num]
        if line == old_line:
            new_contents[line_num] = "    " + subkey + ": "
            updated = True

    if not updated:
        print(key)
        print(subkey)
        print(old_value)
        print(new_value)
        print(contents[key_range[0]:key_range[1]+1])
        assert(False)

    return new_contents


def add_key_subkey(contents, key, subkey, value):
    new_line = "    " + subkey + ": " + value
    key_range = find_section_lines(contents, key)[0]

    # Since there is always at least one line in the key_range (when [0] == [1]),
    # it is always safe to add the new value right after the key header.
    start_line = key_range[0] + 1
    new_contents = contents[0:start_line]
    new_contents.append(new_line)
    new_contents.extend(contents[start_line:])
    return new_contents


def get_key(line):
    if ':' in line and line[0].isalpha():
        char_index = 0
        _ll = len(line)
        while char_index < _ll-1 and (line[char_index].isalpha() or
                                      line[char_index] == '_'):
            char_index += 1
        if line[char_index] == ':':
            return line[0:char_index]
    return None


def get_sections(file_contents):
    global_sections = set()
    for line in file_contents:
        key = get_key(line)
        if key:
            global_sections.add(key)
    return global_sections


def range_has_jinja(file_contents, range):
    return '{{' and '}}' in "\n".join(file_contents[range[0]:range[1]+1])


def fix_ocil_clause(ssg_root, path, obj_name):
    is_file_templated = obj_name[0:4] == 'file'
    is_permissions = '_permissions_' in obj_name
    is_groupowner = '_groupowner_' in obj_name
    is_owner = '_owner_' in obj_name

    if not is_file_templated or not (is_permissions or is_groupowner or is_owner):
        return

    loaded_file = read_file(path)
    sections = get_sections(loaded_file)
    if not 'ocil_clause' in sections:
        ocil_lines = find_section_lines(loaded_file, 'ocil')
        assert(len(ocil_lines) == 1)
        ocil_lines = ocil_lines[0]

        ocil = parse_from_yaml(loaded_file, ocil_lines)['ocil']
        if '{{{' not in ocil:
            print(path)

        ocil_clause_str = ocil.replace('ocil_', 'ocil_clause_')
        new_line = "ocil_clause: '%s'" % ocil_clause_str
        new_file = loaded_file[:ocil_lines[0]]
        new_file.extend([new_line, ''])
        new_file.extend(loaded_file[ocil_lines[0]:])
        write_file(path, new_file)


def parse_from_yaml(file_contents, lines):
    new_file_arr = file_contents[lines[0]:lines[1] + 1]
    new_file = "\n".join(new_file_arr)
    return yaml.load(new_file)


def print_file(file_contents):
    for line_num in range(0, len(file_contents)):
        print("%d: %s" % (line_num, file_contents[line_num]))


def walk_dir(ssg_root, function):
    product_guide = os.path.join(ssg_root, 'linux_os', 'guide')
    _pgl = len(product_guide)

    data = None
    for root, dirs, files in os.walk(product_guide):
        for filename in files:
            path = os.path.join(root, filename)

            obj_name = filename
            is_rule = len(path) >= 5 and path[-5:] == '.rule'

            if is_rule:
                obj_name = filename[:-5]
                function(ssg_root, path, obj_name)


def parse_args():
    parser = argparse.ArgumentParser(formatter_class=argparse.RawDescriptionHelpFormatter,
                                     description="Utility for finding similar guide rules")
    parser.add_argument("ssg_root", help="Path to root of ssg git directory")
    return parser.parse_args()


def __main__():
    args = parse_args()

    pc = _create_profile_cache(args.ssg_root)
    global profile_cache
    profile_cache = pc

    walk_dir(args.ssg_root, fix_ocil_clause)


if __name__ == "__main__":
    __main__()
