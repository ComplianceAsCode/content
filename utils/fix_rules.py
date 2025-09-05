#!/usr/bin/env python

from __future__ import print_function

import sys
import os
import jinja2
import argparse
import json

from ssg import yaml, checks
from ssg.shims import input_func
from ssg.utils import read_file_list
import ssg
import ssg.products
import ssg.rules
import ssg.rule_yaml


SSG_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
TO_SORT = ['identifiers', 'references']


def has_empty_identifier(yaml_file, product_yaml=None):
    rule = yaml.open_and_macro_expand(yaml_file, product_yaml)
    if 'identifiers' in rule and rule['identifiers'] is None:
        return True

    if 'identifiers' in rule and rule['identifiers'] is not None:
        for _, value in rule['identifiers'].items():
            if str(value).strip() == "":
                return True
    return False


def has_empty_references(yaml_file, product_yaml=None):
    rule = yaml.open_and_macro_expand(yaml_file, product_yaml)
    if 'references' in rule and rule['references'] is None:
        return True

    if 'references' in rule and rule['references'] is not None:
        for _, value in rule['references'].items():
            if str(value).strip() == "":
                return True
    return False


def has_prefix_cce(yaml_file, product_yaml=None):
    rule = yaml.open_and_macro_expand(yaml_file, product_yaml)
    if 'identifiers' in rule and rule['identifiers'] is not None:
        for i_type, i_value in rule['identifiers'].items():
            if i_type[0:3] == 'cce':
                has_prefix = i_value[0:3].upper() == 'CCE'
                remainder_valid = checks.is_cce_format_valid("CCE-" + i_value[3:])
                remainder_valid |= checks.is_cce_format_valid("CCE-" + i_value[4:])
                return has_prefix and remainder_valid
    return False


def has_invalid_cce(yaml_file, product_yaml=None):
    rule = yaml.open_and_macro_expand(yaml_file, product_yaml)
    if 'identifiers' in rule and rule['identifiers'] is not None:
        for i_type, i_value in rule['identifiers'].items():
            if i_type[0:3] == 'cce':
                if not checks.is_cce_value_valid("CCE-" + str(i_value)):
                    return True
    return False


def has_int_identifier(yaml_file, product_yaml=None):
    rule = yaml.open_and_macro_expand(yaml_file, product_yaml)
    if 'identifiers' in rule and rule['identifiers'] is not None:
        for _, value in rule['identifiers'].items():
            if type(value) != str:
                return True
    return False


def has_int_reference(yaml_file, product_yaml=None):
    rule = yaml.open_and_macro_expand(yaml_file, product_yaml)
    if 'references' in rule and rule['references'] is not None:
        for _, value in rule['references'].items():
            if type(value) != str:
                return True
    return False


def has_duplicated_subkeys(yaml_file, product_yaml=None):
    rule_lines = read_file_list(yaml_file)
    return ssg.rule_yaml.has_duplicated_subkeys(yaml_file, rule_lines, TO_SORT)


def has_unordered_sections(yaml_file, product_yaml=None):
    rule = yaml.open_and_macro_expand(yaml_file, product_yaml)
    if 'references' in rule or 'identifiers' in rule:
        rule_lines = read_file_list(yaml_file)
        new_lines = ssg.rule_yaml.sort_section_keys(yaml_file, rule_lines, TO_SORT)

        # Compare string representations to avoid issues with references being
        # different.
        return "\n".join(rule_lines) != "\n".join(new_lines)

    return False


def find_rules_generator(args, func):
    # Iterates over all know rules in the build system (according to
    # rule_dir_json.py) and attempts to load the resulting YAML files.
    # If they parse correctly, yield them as a result.
    #
    # Note: this has become a generator rather than returning a list of
    # results.

    product_yamls = dict()

    rule_dirs = json.load(open(args.json))
    for rule_id in rule_dirs:
        rule_obj = rule_dirs[rule_id]

        if 'products' not in rule_obj or not rule_obj['products']:
            print(rule_id, rule_obj)
        assert rule_obj['products']
        product = rule_obj['products'][0]

        if product not in product_yamls:
            product_path = os.path.join(args.root, "products", product, 'product.yml')
            product_yaml = ssg.products.load_product_yaml(product_path)
            product_yaml['cmake_build_type'] = 'Debug'
            product_yamls[product] = product_yaml

        local_env_yaml = dict()
        local_env_yaml.update(product_yamls[product])
        local_env_yaml['rule_id'] = rule_id

        rule_path = ssg.rules.get_rule_dir_yaml(rule_obj['dir'])
        try:
            if func(rule_path, local_env_yaml):
                yield (rule_path, product_path, local_env_yaml)
        except jinja2.exceptions.UndefinedError as ue:
            msg = "Failed to parse file {0} (with product.yml: {1}). Skipping. {2}"
            msg = msg.format(rule_path, product_path, ue)
            print(msg, file=sys.stderr)


def find_rules(args, func):
    # Returns find_rules_generator as a list
    return list(find_rules_generator(args, func))


def print_file(file_contents):
    for line_num in range(0, len(file_contents)):
        print("%d: %s" % (line_num, file_contents[line_num]))


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


def remove_lines(file_contents, lines):
    # Returns a series of lines and returns a new copy
    new_file = []
    for line_num in range(0, len(file_contents)):
        if line_num not in lines:
            new_file.append(file_contents[line_num])

    return new_file


def remove_section_keys(file_contents, yaml_contents, section, removed_keys):
    # Remove a series of keys from a section. Refuses to operate if there is more
    # than one instance of the section. If the section is empty (because all keys
    # are removed), then the section is also removed. Otherwise, only matching keys
    # are removed. Note that all instances of the keys will be removed, if it appears
    # more than once.
    sec_ranges = find_section_lines(file_contents, section)
    if len(sec_ranges) != 1:
        raise RuntimeError("Refusing to fix file: %s -- could not find one section: %d"
                           % (path, sec_ranges))

    begin, end = sec_ranges[0]
    r_lines = set()

    if (yaml_contents[section] is None or len(yaml_contents[section].keys()) == len(removed_keys)):
        r_lines = set(range(begin, end+1))
        print("Removing entire section since all keys are empty")
    else:
        # Don't include section header
        for line_num in range(begin+1, end+1):
            line = file_contents[line_num].strip()
            len_line = len(line)

            for key in removed_keys:
                k_l = len(key)+1
                k_i = key + ":"
                if len_line >= k_l and line[0:k_l] == k_i:
                    r_lines.add(line_num)
                    break

    return remove_lines(file_contents, r_lines)


def rewrite_value_int_str(line):
    # Rewrites a key's value to explicitly be a string. Assumes it starts
    # as an integer. Takes a line.
    key_end = line.index(':')
    key = line[0:key_end]
    value = line[key_end+1:].strip()
    str_value = '"' + value + '"'
    return key + ": " + str_value


def rewrite_value_remove_prefix(line):
    # Rewrites a key's value to remove a "CCE" prefix.
    key_end = line.index(':')
    key = line[0:key_end]
    value = line[key_end+1:].strip()
    new_value = value
    if checks.is_cce_format_valid("CCE-" + value[3:]):
        new_value = value[3:]
    elif checks.is_cce_format_valid("CCE-" + value[4:]):
        new_value = value[4:]
    return key + ": " + new_value


def rewrite_section_value(file_contents, yaml_contents, section, keys, transform):
    # For a given section, rewrite the keys in int_keys to be strings. Refuses to
    # operate if the given section appears more than once in the file. Assumes all
    # instances of key are an integer; all will get updated.
    new_contents = file_contents[:]

    sec_ranges = find_section_lines(file_contents, section)
    if len(sec_ranges) != 1:
        raise RuntimeError("Refusing to fix file: %s -- could not find one section: %d"
                           % (path, sec_ranges))

    begin, end = sec_ranges[0]
    r_lines = set()

    # Don't include section header
    for line_num in range(begin+1, end+1):
        line = file_contents[line_num].strip()
        len_line = len(line)

        for key in keys:
            k_l = len(key)+1
            k_i = key + ":"

            if len_line >= k_l and line[0:k_l] == k_i:
                new_contents[line_num] = transform(file_contents[line_num])
                break

    return new_contents


def rewrite_section_value_int_str(file_contents, yaml_contents, section, int_keys):
    return rewrite_section_value(file_contents, yaml_contents, section, int_keys,
                                 rewrite_value_int_str)


def fix_empty_identifier(file_contents, yaml_contents):
    section = 'identifiers'

    empty_identifiers = []
    if yaml_contents[section] is not None:
        for i_type, i_value in yaml_contents[section].items():
            if str(i_value).strip() == "":
                empty_identifiers.append(i_type)

    return remove_section_keys(file_contents, yaml_contents, section, empty_identifiers)


def fix_empty_reference(file_contents, yaml_contents):
    section = 'references'

    empty_identifiers = []

    if yaml_contents[section] is not None:
        for i_type, i_value in yaml_contents[section].items():
            if str(i_value).strip() == "":
                empty_identifiers.append(i_type)

    return remove_section_keys(file_contents, yaml_contents, section, empty_identifiers)


def fix_prefix_cce(file_contents, yaml_contents):
    section = 'identifiers'

    prefixed_identifiers = []

    if yaml_contents[section] is not None:
        for i_type, i_value in yaml_contents[section].items():
            if i_type[0:3] == 'cce':
                has_prefix = i_value[0:3].upper() == 'CCE'
                remainder_valid = checks.is_cce_format_valid("CCE-" + str(i_value[3:]))
                remainder_valid |= checks.is_cce_format_valid("CCE-" + str(i_value[4:]))
                if has_prefix and remainder_valid:
                    prefixed_identifiers.append(i_type)

    return rewrite_section_value(file_contents, yaml_contents, section, prefixed_identifiers,
                                 rewrite_value_remove_prefix)


def fix_invalid_cce(file_contents, yaml_contents):
    section = 'identifiers'

    invalid_identifiers = []

    if yaml_contents[section] is not None:
        for i_type, i_value in yaml_contents[section].items():
            if i_type[0:3] == 'cce':
                if not checks.is_cce_value_valid("CCE-" + str(i_value)):
                    invalid_identifiers.append(i_type)

    return remove_section_keys(file_contents, yaml_contents, section, invalid_identifiers)


def fix_int_identifier(file_contents, yaml_contents):
    section = 'identifiers'

    int_identifiers = []
    for i_type, i_value in yaml_contents[section].items():
        if type(i_value) != str:
            int_identifiers.append(i_type)

    return rewrite_section_value_int_str(file_contents, yaml_contents, section, int_identifiers)


def fix_int_reference(file_contents, yaml_contents):
    section = 'references'

    int_identifiers = []
    for i_type, i_value in yaml_contents[section].items():
        if type(i_value) != str:
            int_identifiers.append(i_type)

    return rewrite_section_value_int_str(file_contents, yaml_contents, section, int_identifiers)


def sort_rule_subkeys(file_contents, yaml_contents):
    return ssg.rule_yaml.sort_section_keys(None, file_contents, TO_SORT)


def fix_file(path, product_yaml, func, args):
    file_contents = open(path, 'r').read().split("\n")
    if file_contents[-1] == '':
        file_contents = file_contents[:-1]

    yaml_contents = yaml.open_and_macro_expand(path, product_yaml)

    need_input = not args.assume_yes and not args.dry_run

    if need_input:
        print("====BEGIN BEFORE====")
        print_file(file_contents)
        print("====END BEFORE====")

    file_contents = func(file_contents, yaml_contents)

    if need_input:
        print("====BEGIN AFTER====")
        print_file(file_contents)
        print("====END AFTER====")

    response = 'n'
    if need_input:
        response = input_func("Confirm writing output to %s: (y/n): " % path)

    if args.assume_yes or response.strip().lower() == 'y':
        f = open(path, 'w')
        for line in file_contents:
            f.write(line)
            f.write("\n")
        f.flush()
        f.close()


def fix_empty_identifiers(args):
    results = find_rules(args, has_empty_identifier)
    print("Number of rules with empty identifiers: %d" % len(results))

    for result in results:
        rule_path = result[0]
        product_yaml = result[2]

        if args.dry_run:
            print(rule_path + " has one or more empty identifiers")
            continue

        fix_file(rule_path, product_yaml, fix_empty_identifier, args)

    return int(len(results) > 0)


def fix_empty_references(args):
    results = find_rules(args, has_empty_references)
    print("Number of rules with empty references: %d" % len(results))

    for result in results:
        rule_path = result[0]
        product_yaml = result[2]

        if args.dry_run:
            print(rule_path + " has one or more empty references")
            continue

        fix_file(rule_path, product_yaml, fix_empty_reference, args)

    return int(len(results) > 0)


def find_prefix_cce(args):
    results = find_rules(args, has_prefix_cce)
    print("Number of rules with prefixed CCEs: %d" % len(results))

    for result in results:
        rule_path = result[0]
        product_yaml = result[2]

        if args.dry_run:
            print(rule_path + " has one or more CCE with CCE- prefix")
            continue

        fix_file(rule_path, product_yaml, fix_prefix_cce, args)

    return int(len(results) > 0)


def find_invalid_cce(args):
    results = find_rules(args, has_invalid_cce)
    print("Number of rules with invalid CCEs: %d" % len(results))

    for result in results:
        rule_path = result[0]
        product_yaml = result[2]

        if args.dry_run:
            print(rule_path + " has one or more invalid CCEs")
            continue

        fix_file(rule_path, product_yaml, fix_invalid_cce, args)

    return int(len(results) > 0)


def find_int_identifiers(args):
    results = find_rules(args, has_int_identifier)
    print("Number of rules with integer identifiers: %d" % len(results))

    for result in results:
        rule_path = result[0]
        product_yaml = result[2]

        if args.dry_run:
            print(rule_path + " has one or more integer references")
            continue

        fix_file(rule_path, product_yaml, fix_int_identifier, args)

    return int(len(results) > 0)


def find_int_references(args):
    results = find_rules(args, has_int_reference)
    print("Number of rules with integer references: %d" % len(results))

    for result in results:
        rule_path = result[0]
        product_yaml = result[2]

        if args.dry_run:
            print(rule_path + " has one or more unsorted references")
            continue

        fix_file(rule_path, product_yaml, fix_int_reference, args)

    return int(len(results) > 0)


def duplicate_subkeys(args):
    results = find_rules(args, has_duplicated_subkeys)
    print("Number of rules with duplicated subkeys: %d" % len(results))

    for result in results:
        print(result[0] + " has one or more duplicated subkeys")

    return int(len(results) > 0)


def sort_subkeys(args):
    results = find_rules(args, has_unordered_sections)
    print("Number of modified rules: %d" % len(results))

    for result in results:
        rule_path = result[0]
        product_yaml = result[2]

        if args.dry_run:
            print(rule_path + " has one or more unsorted references")
            continue

        fix_file(rule_path, product_yaml, sort_rule_subkeys, args)

    return int(len(results) > 0)


def parse_args():
    parser = argparse.ArgumentParser(formatter_class=argparse.RawDescriptionHelpFormatter,
                                     description="Utility for fixing mistakes in .rule files",
                                     epilog="""
Commands:
\tempty_identifiers - check and fix rules with empty identifiers
\tprefixed_identifiers - check and fix rules with prefixed (CCE-) identifiers
\tinvalid_identifiers - check and fix rules with invalid identifiers
\tint_identifiers - check and fix rules with pseudo-integer identifiers
\tempty_references - check and fix rules with empty references
\tint_references - check and fix rules with pseudo-integer references
\tduplicate_subkeys - check for duplicated references and identifiers
\tsort_subkeys - sort references and identifiers
                                     """)
    parser.add_argument("-y", "--assume-yes", default=False, action="store_true",
                        help="Assume yes and overwrite all files (no prompt)")
    parser.add_argument("-d", "--dry-run", default=False, action="store_true",
                        help="Assume no and don't overwrite any files")
    parser.add_argument("-j", "--json", type=str, action="store",
                        default="build/rule_dirs.json", help="File to read json "
                        "output of rule_dir_json.py from (defaults to "
                        "build/rule_dirs.json")
    parser.add_argument("-r", "--root", default=SSG_ROOT, action="store", type=str,
                        help="Path to root of ssg git directory")
    parser.add_argument("command", help="Which fix to perform.",
                        choices=['empty_identifiers', 'prefixed_identifiers',
                                 'invalid_identifiers', 'int_identifiers',
                                 'empty_references', 'int_references',
                                 'duplicate_subkeys', 'sort_subkeys'])
    return parser.parse_args()


def __main__():
    args = parse_args()

    abs_json = os.path.join(args.root, args.json)
    if not os.path.exists(args.json) and os.path.exists(abs_json):
        args.json = abs_json

    ret = 1
    if args.command == 'empty_identifiers':
        ret = fix_empty_identifiers(args)
    elif args.command == 'prefixed_identifiers':
        ret = find_prefix_cce(args)
    elif args.command == 'invalid_identifiers':
        ret = find_invalid_cce(args)
    elif args.command == 'int_identifiers':
        ret = find_int_identifiers(args)
    elif args.command == 'empty_references':
        ret = fix_empty_references(args)
    elif args.command == 'int_references':
        ret = find_int_references(args)
    elif args.command == 'duplicate_subkeys':
        ret = duplicate_subkeys(args)
    elif args.command == 'sort_subkeys':
        ret = sort_subkeys(args)

    sys.exit(ret)

if __name__ == "__main__":
    __main__()
