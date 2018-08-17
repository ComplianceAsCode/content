import sys
import os
import argparse
import subprocess
import jinja2
import yaml

import ssg.products


linux_os = set()


def abs_join(a, *p):
    return os.path.abspath(os.path.join(a, *p))

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


def move_rule_other(ssg_root, current_product, path, obj_name):
    base_path = os.path.dirname(path)
    new_rule_dir = abs_join(base_path, obj_name)
    new_rule_path = abs_join(new_rule_dir, "rule.yml")

    assert not os.path.exists(new_rule_dir)

    sub_dirs = ['oval', 'bash', 'ansible', 'anaconda', 'puppet']
    new_rule_subdirs = [abs_join(new_rule_dir, j) for j in sub_dirs]

    move_templates = [
        {
            'source_dir': "%s/checks/oval",
            'source_name': "%s.xml",
            'dest_dir': new_rule_subdirs[0],
            'dest_name': "%s.xml"
        },
        {
            'source_dir': "%s/fixes/bash",
            'source_name': "%s.sh",
            'dest_dir': new_rule_subdirs[1],
            'dest_name': "%s.sh"
        },
        {
            'source_dir': "%s/fixes/ansible",
            'source_name': "%s.yml",
            'dest_dir': new_rule_subdirs[2],
            'dest_name': "%s.yml"
        },
        {
            'source_dir': "%s/fixes/anaconda",
            'source_name': "%s.anaconda",
            'dest_dir': new_rule_subdirs[3],
            'dest_name': "%s.anaconda"
        },
        {
            'source_dir': "%s/fixes/puppet",
            'source_name': "%s.pp",
            'dest_dir': new_rule_subdirs[4],
            'dest_name': "%s.pp"
        },
    ]

    moves = []

    # Generate possible build artifact paths and add them to the move queue.
    # The queue will later be filtered for existance before the move is
    # performed.
    for move_template in move_templates:
        source_dir = move_template['source_dir'] % current_product
        source_name = move_template['source_name'] % obj_name
        source_file = abs_join(ssg_root, source_dir, source_name)

        dest_dir = move_template['dest_dir']
        dest_name = move_template['dest_name'] % current_product
        dest_file = abs_join(dest_dir, dest_name)

        moves.append((source_file, dest_file))

    print("mkdir -p '%s'" % new_rule_dir)
    for sub_dir in new_rule_subdirs:
        print("mkdir -p '%s'" % sub_dir)
    print("mv '%s' -v '%s'" % (path, new_rule_path))
    for move_tuple in moves:
        if os.path.exists(move_tuple[0]):
            print("mv '%s' -v '%s'" % move_tuple)

    print()


def move_rule_linux_os(ssg_root, current_product, path, obj_name):
    global linux_os

    base_path = os.path.dirname(path)
    new_rule_dir = abs_join(base_path, obj_name)
    new_rule_path = abs_join(new_rule_dir, "rule.yml")

    assert not os.path.exists(new_rule_dir)

    sub_dirs = ['oval', 'bash', 'ansible', 'anaconda', 'puppet']
    new_rule_subdirs = [abs_join(new_rule_dir, j) for j in sub_dirs]

    product_list = set(['shared']).union(linux_os)

    move_templates = [
        {
            'source_dir': "%s/checks/oval",
            'source_name': "%s.xml",
            'dest_dir': new_rule_subdirs[0],
            'dest_name': "%s.xml"
        },
        {
            'source_dir': "%s/fixes/bash",
            'source_name': "%s.sh",
            'dest_dir': new_rule_subdirs[1],
            'dest_name': "%s.sh"
        },
        {
            'source_dir': "%s/fixes/ansible",
            'source_name': "%s.yml",
            'dest_dir': new_rule_subdirs[2],
            'dest_name': "%s.yml"
        },
        {
            'source_dir': "%s/fixes/anaconda",
            'source_name': "%s.anaconda",
            'dest_dir': new_rule_subdirs[3],
            'dest_name': "%s.anaconda"
        },
        {
            'source_dir': "%s/fixes/puppet",
            'source_name': "%s.pp",
            'dest_dir': new_rule_subdirs[4],
            'dest_name': "%s.pp"
        },
    ]

    moves = []

    # Generate possible build artifact paths and add them to the move queue.
    # The queue will later be filtered for existance before the move is
    # performed.
    for move_template in move_templates:
        for product in product_list:
            source_dir = move_template['source_dir'] % product
            source_name = move_template['source_name'] % obj_name
            source_file = abs_join(ssg_root, source_dir, source_name)

            dest_dir = move_template['dest_dir']
            dest_name = move_template['dest_name'] % product
            dest_file = abs_join(dest_dir, dest_name)

            moves.append((source_file, dest_file))

    # Find the test case location
    #assert path.startswith(ssg_root + "/")
    #without_ssg_root = path[len(ssg_root)+1:]
    #assert without_ssg_root.startswith("linux_os/guide/")
    #without_linuxos_guide = without_ssg_root[len("linux_os/guide/"):]
    #slash_split_paths = without_linuxos_guide.split(os.path.sep)
    #group_parts = list(map(lambda x: "group_" + x, slash_split_paths[:-1]))
    #rule_part = "rule_" + obj_name
    #test_path = abs_join(ssg_root, "tests", "data", *group_parts, rule_part)

    #if os.path.isdir(test_path):
    #    for _file in os.listdir(test_path):
    #        start_path = abs_join(test_path, _file)
    #        dest_path = abs_join(new_rule_subdirs[5], _file)
    #        moves.append((start_path, dest_path))

    print("mkdir -p '%s'" % new_rule_dir)
    for sub_dir in new_rule_subdirs:
        print("mkdir -p '%s'" % sub_dir)
    print("mv '%s' -v '%s'" % (path, new_rule_path))
    for move_tuple in moves:
        if os.path.exists(move_tuple[0]):
            print("mv '%s' -v '%s'" % move_tuple)

    print()


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


def walk_dir(ssg_root, product, function):
    product_guide = os.path.join(ssg_root, product, 'guide')
    _pgl = len(product_guide)

    data = None
    for root, dirs, files in os.walk(product_guide):
        for filename in files:
            path = os.path.join(root, filename)

            obj_name = filename
            is_rule = len(path) >= 5 and path[-5:] == '.rule'

            if is_rule:
                obj_name = filename[:-5]
                function(ssg_root, product, path, obj_name)


def parse_args():
    parser = argparse.ArgumentParser(formatter_class=argparse.RawDescriptionHelpFormatter,
                                     description="Utility for finding similar guide rules")
    parser.add_argument("ssg_root", help="Path to root of ssg git directory")
    return parser.parse_args()


def __main__():
    global linux_os

    args = parse_args()
    _linux_os, other_products = ssg.products.get_all(args.ssg_root)
    linux_os.update(_linux_os)

    print("#!/bin/bash")
    print("set -e")
    print()

    walk_dir(args.ssg_root, "linux_os", move_rule_linux_os)

    for product in other_products:
        walk_dir(args.ssg_root, product, move_rule_other)


if __name__ == "__main__":
    __main__()
