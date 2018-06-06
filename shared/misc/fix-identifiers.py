#!/usr/bin/env python2

import sys
import os

# Put shared python modules in path
sys.path.insert(0, os.path.join(
        os.path.dirname(os.path.dirname(os.path.realpath(__file__))),
        "modules"))
from ssgcommon import required_yaml_key
import ssgcommon


def has_empty_identifier(yaml_file, product_yaml=None):
    rule = ssgcommon.open_and_macro_expand_yaml(yaml_file, product_yaml)
    if 'identifiers' in rule:
        for _, value in rule['identifiers'].items():
            if value.strip() == "":
                return True
    return False


def has_invalid_cce(yaml_file, product_yaml=None):
    rule = ssgcommon.open_and_macro_expand_yaml(yaml_file, product_yaml)
    if 'identifiers' in rule and 'cce' in rule['identifiers']:
        if not ssgcommon.cce_is_valid("CCE-" + rule['identifiers']['cce']):
            return True
    return False


def find_rules(directory, func):
    results = []
    product_yamls = {}
    product_yaml_paths = {}
    for root, dirs, files in os.walk(directory):
        product_yaml = None
        product_yaml_path = None

        if "product.yml" in files:
            product_yaml_path = os.path.join(root, "product.yml")
            product_yaml = ssgcommon.open_yaml(product_yaml_path)
            product_yamls[root] = product_yaml
            product_yaml_paths[root] = product_yaml_path
            for d in dirs:
                product_yamls[os.path.join(root, d)] = product_yaml
                product_yaml_paths[os.path.join(root, d)] = product_yaml_path
        elif root in product_yamls:
            product_yaml = product_yamls[root]
            product_yaml_path = product_yaml_paths[root]
            for d in dirs:
                product_yamls[os.path.join(root, d)] = product_yaml
                product_yaml_paths[os.path.join(root, d)] = product_yaml_path
        else:
            pass
            # print("No product yaml for file: %s" % root)

        for filename in files:
            path = os.path.join(root, filename)
            if len(path) < 5 or path[-5:] != '.rule':
                continue

            if func(path, product_yaml):
                results.append((path, product_yaml_path))

    return results


def print_file(file_contents):
    for line_num in range(0, len(file_contents)):
        print("%d: %s" % (line_num, file_contents[line_num]))


def find_section_lines(file_contents, sec):
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


def fix_empty_identifier(path, product_yaml):
    file_contents = open(path, 'r').read().split("\n")
    if file_contents[-1] == '':
        file_contents = file_contents[:-1]

    yaml_contents = ssgcommon.open_and_macro_expand_yaml(path, product_yaml)

    empty_identifiers = []
    for i_type, i_value in yaml_contents['identifiers'].items():
        if i_value.strip() == "":
            empty_identifiers.append(i_type)

    print("====BEGIN BEFORE====")
    print_file(file_contents)
    print("====END BEFORE====")
    sec_ranges = find_section_lines(file_contents, 'identifiers')
    if len(sec_ranges) != 1:
        raise RuntimeError("Refusing to fix file: %s -- could not find one section: %d"
            % (path, sec_ranges))

    begin, end = sec_ranges[0]

    # If num keys == num empty identifiers, then we can remove the entire
    # identifiers section
    if len(yaml_contents['identifiers'].keys()) == len(empty_identifiers):
        file_contents = file_contents[:begin] + file_contents[end+1:]
        print("Removing entire section since all keys are empty")
    else:
        raise RuntimeError("Refusing to fix file: %s -- additional keys in section" % path)

    print("====BEGIN AFTER====")
    print_file(file_contents)
    print("====END AFTER====")

    response = raw_input("Confirm writing output to %s: (y/n): " % path)
    if response.strip() == 'y':
        f = open(path, 'w')
        for line in file_contents:
            f.write(line)
            f.write("\n")
        f.flush()
        f.close()


def fix_empty_identifiers(directory):
    results = find_rules(directory, has_empty_identifier)
    print("Number of rules with empty identifiers: %d" % len(results))

    for result in results:
        rule_path = result[0]
        product_yaml_path = result[1]

        product_yaml = None
        if product_yaml_path is not None:
            product_yaml = ssgcommon.open_yaml(product_yaml_path)

        fix_empty_identifier(rule_path, product_yaml)


def find_invalid_cce(directory):
    results = find_rules(directory, has_invalid_cce)
    print("Number of rules with invalid CCEs: %d" % len(results))

    for result in results:
        rule_path = result[0]
        print(rule_path)


def __main__():
    if sys.argv[1] == 'empty':
        fix_empty_identifiers(sys.argv[2])
    elif sys.argv[1] == 'invalid':
        find_invalid_cce(sys.argv[2])
    else:
        print("Usage: %s mode /full/path/to/src/directory" % sys.argv[0])
        print("Modes:")
        print("\tempty - check and fix rules with empty identifiers")
        print("\tinvalid - find rules with invalid identifiers")


if __name__ == "__main__":
    __main__()
