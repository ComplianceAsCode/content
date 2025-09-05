#!/usr/bin/python3

import os
import argparse
import xml.etree.ElementTree as ET
import sys
import ssg.constants
import ssg.yaml
import io
import re


BASH_MACHINE_CONDITIONAL = re.compile(
    r'^.*\[ ! -f /.dockerenv \] && \[ ! -f /run/.containerenv \].*$', re.M)
ANSIBLE_MACHINE_CONDITIONAL = re.compile(
    r'ansible_virtualization_type not in \["docker", "lxc", "openvz", "podman", "container"\]',
    re.M)
MACHINE_PLATFORM_ONE_LINE = re.compile(
    r'^\s*platform:\s+machine\s*$', re.M)
MACHINE_PLATFORM_MULTILINE = re.compile(
    r'^\s*platforms:\s*\n(\s+-\s+.*machine.*)+', re.M)


def main():
    args = parse_command_line_args()
    test_result = 0
    for product in ssg.constants.product_directories:
        ds_path = os.path.join(args.build_dir, "ssg-" + product + "-ds.xml")
        if not os.path.exists(ds_path):
            sys.stderr.write("The product datastream '%s' hasn't been build, "
                             "skipping the test.\n" % (ds_path))
            continue
        product_dir = os.path.join(args.source_dir, "products", product)
        product_yaml_path = os.path.join(product_dir, "product.yml")
        product_yaml = ssg.yaml.open_raw(product_yaml_path)
        guide_dir = os.path.abspath(
            os.path.join(product_dir, product_yaml['benchmark_root']))
        additional_content_directories = product_yaml.get("additional_content_directories", [])
        add_content_dirs = [os.path.abspath(
            os.path.join(product_dir, rd)) for rd in additional_content_directories]
        if not check_product(ds_path, [guide_dir] + add_content_dirs):
            test_result = 1
    if test_result:
        sys.exit(1)


def check_product(ds_path, rules_dirs):
    input_rules = scan_rules_groups(rules_dirs, False)
    return not machine_platform_missing_in_rules(ds_path, input_rules)


def shorten_id(full_id):
    id_prefix = ssg.constants.OSCAP_RULE
    return full_id.replace(id_prefix, "")


def get_only_elements_to_check_from_benchmark(benchmark, element_query, short_ids_to_check):
    elements = []
    for elem in benchmark.findall(element_query):
        elem_short_id = shorten_id(elem.get("id"))
        if elem_short_id in short_ids_to_check:
            elements.append(elem)
    return elements


def get_element_fix_text_by_system(element):
    all_fixes = element.findall("{%s}fix" % ssg.constants.XCCDF12_NS)
    fixes_by_system = dict()
    for f in all_fixes:
        system = f.get("system")
        fixes_by_system[system] = "".join(f.itertext())
    return fixes_by_system


def machine_platform_missing_in_rules(ds_path, short_ids_to_check):
    machine_platform_missing = False
    tree = ET.parse(ds_path)
    root = tree.getroot()
    only_rules_query = ".//{%s}Rule" % ssg.constants.XCCDF12_NS
    benchmark = root.find(".//{%s}Benchmark" % ssg.constants.XCCDF12_NS)
    elements_to_check = get_only_elements_to_check_from_benchmark(
            benchmark, only_rules_query, short_ids_to_check)

    for elem in elements_to_check:
        element_fixes = get_element_fix_text_by_system(elem)

        maybe_bash_fix_text = element_fixes.get(ssg.constants.bash_system)
        if maybe_bash_fix_text is None:
            bash_fix_present = False
            bash_fix_has_machine_conditional = False
        else:
            bash_fix_present = True
            bash_fix_has_machine_conditional = BASH_MACHINE_CONDITIONAL.search(
                    maybe_bash_fix_text)

        maybe_ansible_fix_text = element_fixes.get(ssg.constants.ansible_system)
        if maybe_ansible_fix_text is None:
            ansible_fix_present = False
            ansible_fix_has_machine_conditional = False
        else:
            ansible_fix_present = True
            ansible_fix_has_machine_conditional = ANSIBLE_MACHINE_CONDITIONAL.search(
                    maybe_ansible_fix_text)

        elem_short_id = shorten_id(elem.get("id"))
        if ansible_fix_present and not ansible_fix_has_machine_conditional:
            sys.stderr.write(
                "Rule %s in %s is missing a machine conditional in Ansible remediation\n" %
                (elem_short_id, ds_path))
            machine_platform_missing = True
        if bash_fix_present and not bash_fix_has_machine_conditional:
            sys.stderr.write(
                "Rule %s in %s is missing a machine conditional in Bash remediation\n" %
                (elem_short_id, ds_path))
            machine_platform_missing = True
    return machine_platform_missing


def parse_command_line_args():
    parser = argparse.ArgumentParser(
        description="Tests if 'machine' CPEs are "
                    "propagated to the built datastream")
    parser.add_argument("--source_dir", required=True,
                        help="Content source directory path")
    parser.add_argument("--build_dir", required=True,
                        help="Build directory containing built datastreams")
    args = parser.parse_args()
    return args


def check_if_machine_only(dirpath, name, is_machine_only_group):
    if name in os.listdir(dirpath):
        if is_machine_only_group:
            return True
        yml_path = os.path.join(dirpath, name)
        with io.open(yml_path, "r", encoding="utf-8") as yml_file:
            yml_file_contents = yml_file.read()
            single_line_platform_found = MACHINE_PLATFORM_ONE_LINE.search(yml_file_contents)
            multiline_platform_found = MACHINE_PLATFORM_MULTILINE.search(yml_file_contents)
            if single_line_platform_found or multiline_platform_found:
                return True
    return False


def scan_rules_groups(dir_paths, parent_machine_only):
    groups = set()
    rules = set()
    for dir_path in dir_paths:
        _, rules = scan_rules_group(dir_path, parent_machine_only, groups, rules)
    return rules


def scan_rules_group(dir_path, parent_machine_only, groups, rules):
    name = os.path.basename(dir_path)
    is_machine_only = False
    if check_if_machine_only(dir_path, "group.yml", parent_machine_only):
        groups.add(name)
        is_machine_only = True
    if check_if_machine_only(dir_path, "rule.yml", parent_machine_only):
        rules.add(name)
    for dir_item in os.listdir(dir_path):
        subdir_path = os.path.join(dir_path, dir_item)
        if os.path.isdir(subdir_path):
            subdir_groups, subdir_rules = scan_rules_group(
                subdir_path, is_machine_only, groups, rules)
            groups |= subdir_groups
            rules |= subdir_rules
    return groups, rules


if __name__ == "__main__":
    main()
