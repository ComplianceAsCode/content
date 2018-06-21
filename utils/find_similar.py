import sys
import os
import argparse
import subprocess
import jinja2
import yaml

import ssg

def begin_git_transaction():
    pass

def end_git_transaction(message, paths):
    if type(paths) == str:
        paths = [paths]

    for path in paths:
        print(path)
        subprocess.call("git add %s" % path, shell=True)

    subprocess.call("git commit -m '%s'" % message, shell=True)


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


def merge_all_equal(ssg_root, path, equivalent_path):
    left = read_file(path)
    right = read_file(equivalent_path)

    if left != right:
        return

    print("Files are equal. Removing " + path)
    os.remove(path)
    _lsg = len(ssg_root) + 1
    #end_git_transaction("Removing duplicated file: %s" % (path[_lsg:]), path)


def range_has_jinja(file_contents, range):
    return '{{' and '}}' in "\n".join(file_contents[range[0]:range[1]+1])


def merge_proper(ssg_root, product, path, equivalent_path):
    left = read_file(path)
    right = read_file(equivalent_path)
    left_sections = get_sections(left)
    right_sections = get_sections(right)

    updated_file = right[:]

    if left == right:
        return

    #for section in left_sections:
    #    if len(find_section_lines(left, section)) != 1:
    #        print("Refusing to process file: " + path + " " + equivalent_path)
    #        return

    #for section in right_sections:
    #    if len(find_section_lines(right, section)) != 1:
    #        print("Refusing to process file: " + path + " " + equivalent_path)
    #        return

    if 'prodtype' in right_sections:
        _prodtype_section = find_section_lines(right, "prodtype")
        if len(_prodtype_section) != 1:
            print("Refusing to process file - right duplicate prodtypes: " + path + " " + equivalent_path)
            return
        _prodtype_section = _prodtype_section[0]

        _prodtype = parse_from_yaml(right, _prodtype_section)
        prodtype = _prodtype['prodtype']
        new_prodtype = prodtype

        assert("prodtype: " + prodtype == right[_prodtype_section[0]])

        if not 'rhel6' in prodtype:
            new_prodtype = 'rhel6,' + prodtype

        updated_file = update_key_value(updated_file, 'prodtype', prodtype, new_prodtype)


    #for common in ['identifiers']:
    #for common in ['references']:
    for common in ['identifiers', 'references']:
        if common not in left_sections and common not in right_sections:
            continue
        if common not in left_sections and common in right_sections:
            print("MISSING left " + common + ": " + path)
            return
        if common not in right_sections and common in left_sections:
            print("MISSING right " + common + ": " + equivalent_path)
            assert(False)
            return
        _left_lines = find_section_lines(left, common)
        if len(_left_lines) != 1:
            print("Refusing to process file - left duplicate " + common + ": " + path + " " + equivalent_path)
            return
        _left_lines = _left_lines[0]

        _right_lines = find_section_lines(right, common)
        if len(_right_lines) != 1:
            print("Refusing to process file - right duplicate " + common + ": " + path + " " + equivalent_path)
            return
        _right_lines = _right_lines[0]

        _left_has_jinja = range_has_jinja(left, _left_lines)
        _right_has_jinja = range_has_jinja(right, _right_lines)
        if _left_has_jinja or _right_has_jinja:
            print("Refusing to process file; jinja in identifiers or references: " +
                  path + " " + equivalent_path)
            print(path)
            print(equivalent_path)
            return

        _left_structure = parse_from_yaml(left, _left_lines)[common]
        _right_structure = parse_from_yaml(right, _right_lines)[common]
        same = _left_structure == _right_structure
        if same:
            # No difference in section. Easy for us!
            continue

        new_values = []
        updated_values = []
        for key in _left_structure:
            prod_key = key
            noprod_key = key
            all_left_values = set()
            if product in key:
                _lk = len(key)
                _lnpk = _lk - len(product) - 1
                noprod_key = key[:_lnpk]
            else:
                prod_key += "@" + product
                if prod_key in _left_structure:
                    continue


            _left_set = set(map(lambda x: x.strip(), _left_structure[key].split(',')))
            if prod_key in _left_structure:
                _left_set.update(map(lambda x: x.strip(), _left_structure[prod_key].split(',')))
            if noprod_key in _left_structure:
                _left_set.update(map(lambda x: x.strip(), _left_structure[noprod_key].split(',')))

            if prod_key not in _right_structure and noprod_key not in _right_structure:
                # Key does not exist in right at all, so we can add it as a prod_key
                # since it might not apply to all platforms.
                new_values.append((prod_key, _left_structure[key]))
            elif prod_key not in _right_structure and noprod_key in _right_structure:
                # Since noprod_key exists in right, if it differs from the value of
                # key in left, we want to create a new key with the product qualifier
                # and add it to right. Some of the changes in left might not appply
                # to right, or left might be out of date, so keeping both will let
                # someone else determine what to change later
                _right_set = set(map(lambda x: x.strip(), _right_structure[noprod_key].split(',')))
                _left_missing = set()
                for _item in _left_set:
                    if _item not in _right_set:
                        _left_missing.add(_item)

                if _left_missing:
                    new_value = ",".join(sorted(_left_missing))
                    new_values.append((prod_key, new_value))
            elif prod_key in _right_structure and noprod_key not in _right_structure:
                # Since prod_key exists in right, if it differs, we probably want to
                # update the value in right to have the union of the two values. This
                # will let someone else clean up the results. We do this regardless
                # of the value of noprod_key.
                _right_set = set(map(lambda x: x.strip(), _right_structure[prod_key].split(',')))
                if _left_set != _right_set:
                    old_value = _right_structure[prod_key]
                    new_value = ",".join(sorted(_left_set.union(_right_set)))
                    updated_values.append((prod_key, old_value, new_value))
            elif prod_key in _right_structure and noprod_key in _right_structure:
                # Since prod_key exists in right, if it differs, we probably want to
                # update the value in right to have the union of the two values. This
                # will let someone else clean up the results. We do this regardless
                # of the value of noprod_key.
                _right_set = set(map(lambda x: x.strip(), _right_structure[prod_key].split(',')))
                _right_noprod_set = set(map(lambda x: x.strip(), _right_structure[noprod_key].split(',')))
                _left_missing = _left_set.difference(_right_set).difference(_right_noprod_set)

                if _left_missing:
                    print(_left_missing)
                    _left_missing = _left_set.union(_right_set)
                    old_value = _right_structure[prod_key]
                    new_value = ",".join(sorted(_left_missing))
                    print(_left_set)
                    print(_right_set)
                    print(_right_noprod_set)
                    print(_left_missing)
                    assert(False)
                    updated_values.append((prod_key, old_value, new_value))

        if new_values or updated_values:
            print(path)
            print(equivalent_path)
            print(common)
            print(new_values)
            print(updated_values)
            updated_subkeys = set()
            for s in new_values:
                if s in updated_subkeys:
                    assert(False)
                updated_subkeys.add(s)
            for s in updated_values:
                if s in updated_subkeys:
                    assert(False)
                updated_subkeys.add(s)

        for new_value in new_values:
            subkey, val = new_value
            if val.isnumeric():
               val = "'" + val + "'"
            updated_file = add_key_subkey(updated_file, common, subkey, val)

        for updated_value in updated_values:
            subkey, old_val, new_val = updated_value
            if new_val.isnumeric():
                new_val = "'" + new_val + "'"
            if old_val.isnumeric():
                old_val = "'" + old_val + "'"
            updated_file = update_subkey_value(updated_file, common, subkey, old_val,
                                               new_val)

    for common in ['severity']:
        if common not in left_sections and common not in right_sections:
            continue
        if common not in left_sections and common in right_sections:
            print("MISSING left " + common + ": " + path)
            return
        if common not in right_sections and common in left_sections:
            print("MISSING right " + common + ": " + equivalent_path)
            assert(False)
            return

        severity_order = ['unknown', 'low', 'medium', 'high']

        _left_lines = find_section_lines(left, common)
        if len(_left_lines) != 1:
            print("Refusing to process file - left duplicate " + common + ": " + path + " " + equivalent_path)
            return
        _left_lines = _left_lines[0]

        _right_lines = find_section_lines(right, common)
        if len(_right_lines) != 1:
            print("Refusing to process file - right duplicate " + common + ": " + path + " " + equivalent_path)
            return
        _right_lines = _right_lines[0]

        _left_has_jinja = range_has_jinja(left, _left_lines)
        _right_has_jinja = range_has_jinja(right, _right_lines)
        if _left_has_jinja or _right_has_jinja:
            print("Refusing to process file; jinja in identifiers or references: " +
                  path + " " + equivalent_path)
            print(path)
            print(equivalent_path)
            return

        _left_structure = parse_from_yaml(left, _left_lines)[common]
        _right_structure = parse_from_yaml(right, _right_lines)[common]

        if severity_order.index(_left_structure) > severity_order.index(_right_structure):
            print(path)
            print(equivalent_path)
            print(_left_structure)
            print(_right_structure)
            assert(False)


    for common in left_sections.intersection(right_sections):
        #if common = 'severity':
        continue

        _left_lines = find_section_lines(left, common)[0]
        _right_lines = find_section_lines(right, common)[0]
        _left_has_jinja = range_has_jinja(left, _left_lines)
        _right_has_jinja = range_has_jinja(right, _right_lines)
        if _left_has_jinja or _right_has_jinja:
            #print("SKIPPING in " + path + " or " + equivalent_path + " due to jinja")
            #print(_left_has_jinja)
            #print(_right_has_jinja)
            continue
        _left_structure = parse_from_yaml(left, _left_lines)
        _right_structure = parse_from_yaml(right, _right_lines)
        same = _left_structure == _right_structure

        if not same:
            print("Difference in section: " + common)
            #if common == 'interactive':
            print(path)
            print(equivalent_path)
            assert(False)
            #else:
            #    print("Common section: " + common)
            pass

    #print("===")
    #print(path)
    #print(equivalent_path)
    #assert(False)

    write_file(equivalent_path, updated_file)


def parse_from_yaml(file_contents, lines):
    new_file_arr = file_contents[lines[0]:lines[1] + 1]
    new_file = "\n".join(new_file_arr)
    return yaml.load(new_file)


def try_merge(ssg_root, product, path, equivalent_path):
    begin_git_transaction()
    merge_proper(ssg_root, product, path, equivalent_path)


def print_file(file_contents):
    for line_num in range(0, len(file_contents)):
        print("%d: %s" % (line_num, file_contents[line_num]))


def deduplicate(ssg_root, product, path, equivalent_path):
    if not os.path.isfile(equivalent_path):
        return

    try_merge(ssg_root, product, path, equivalent_path)


def get_title(ssg_root, product, data, path, equivalent_path):
    left = read_file(path)
    left_sections = get_sections(left)
    if not 'title' in left_sections:
        print("MISSING TITLE: " + path)

    title_lines = find_section_lines(left, 'title')
    if len(title_lines) != 1:
        print("DUPLICATED TITLE: " + path)
    title_lines = title_lines[0]

    title_jinja = range_has_jinja(left, title_lines)
    if title_jinja:
        print("JINJA TITLE: " + path)

    _title = parse_from_yaml(left, title_lines)
    title = _title['title']

    if data == None:
        data = {}
        data[title] = path
        return data

    if title in data:
        print("REUSED TITLE: " + path + " -- " + data[title])

    data[title] = path
    return data



def walk_dir(ssg_root, product, base, function):
    product_guide = os.path.join(ssg_root, product, 'guide')
    _pgl = len(product_guide)
    base_guide = os.path.join(ssg_root, base, 'guide')

    for root, dirs, files in os.walk(product_guide):
        for filename in files:
            path = os.path.join(root, filename)
            equivalent_path = base_guide + path[_pgl:]
            is_rule = len(path) >= 5 and path[-5:] == '.rule'
            is_var = len(path) >= 4 and path[-4:] == '.var'
            is_group = filename == 'group.yml'
            if is_rule or is_group or is_var:
                function(ssg_root, product, path, equivalent_path)


def parse_args():
    parser = argparse.ArgumentParser(formatter_class=argparse.RawDescriptionHelpFormatter,
                                     description="Utility for finding similar guide rules")
    parser.add_argument("product", help="Product to search")
    parser.add_argument("base", help="Base directory to compare against")
    parser.add_argument("ssg_root", help="Path to root of ssg git directory")
    return parser.parse_args()


def __main__():
    args = parse_args()
    walk_dir(args.ssg_root, args.product, args.base, deduplicate)
    #walk_dir(args.ssg_root, args.product, args.base, get_title)


if __name__ == "__main__":
    __main__()
