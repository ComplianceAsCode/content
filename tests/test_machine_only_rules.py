#!/usr/bin/python3

import os
import argparse
import xml.etree.ElementTree as ET
import sys
import ssg.constants
import ssg.yaml
import io

machine_cpe = "cpe:/a:machine"


def main():
    args = parse_command_line_args()
    test_result = 0
    for product in ssg.constants.product_directories:
        product_dir = os.path.join(args.source_dir, "products", product)
        product_yaml_path = os.path.join(product_dir, "product.yml")
        product_yaml = ssg.yaml.open_raw(product_yaml_path)
        guide_dir = os.path.abspath(
            os.path.join(product_dir, product_yaml['benchmark_root']))
        additional_content_directories = product_yaml.get("additional_content_directories", [])
        add_content_dirs = [os.path.abspath(os.path.join(product_dir, rd)) for rd in additional_content_directories]
        if not check_product(args.build_dir, product, [guide_dir] + add_content_dirs):
            test_result = 1
    if test_result:
        sys.exit(1)

def check_product(build_dir, product, rules_dirs):
    input_groups, input_rules = scan_rules_groups(rules_dirs, False)
    ds_path = os.path.join(build_dir, "ssg-" + product + "-ds.xml")
    if not check_ds(ds_path, "Group", input_groups):
        return False
    if not check_ds(ds_path, "Rule", input_rules):
        return False
    return True


def check_ds(ds_path, what, input_elems):
    try:
        tree = ET.parse(ds_path)
    except IOError as e:
        sys.stderr.write("The product datastream '%s' hasn't been build, "
                         "skipping the test.\n" % (ds_path))
        return True

    platform_missing = False
    root = tree.getroot()
    if what == "Group":
        replacement = "xccdf_org.ssgproject.content_group_"
        xpath_query = ".//{%s}Group" % ssg.constants.XCCDF12_NS
    if what == "Rule":
        replacement = "xccdf_org.ssgproject.content_rule_"
        xpath_query = ".//{%s}Rule" % ssg.constants.XCCDF12_NS
    benchmark = root.find(".//{%s}Benchmark" % ssg.constants.XCCDF12_NS)
    for elem in benchmark.findall(xpath_query):
        elem_id = elem.get("id")
        elem_short_id = elem_id.replace(replacement, "")
        if elem_short_id not in input_elems:
            continue
        platforms = elem.findall("{%s}platform" % ssg.constants.XCCDF12_NS)
        machine_platform = False
        for p in platforms:
            idref = p.get("idref")
            if idref == machine_cpe:
                machine_platform = True
        # If the rule already has any platform,
        # it is not required to inherit machine CPE from its parent group
        if not platforms and not machine_platform:
            sys.stderr.write("%s %s in %s is missing a machine <platform> element\n" %
                             (what, elem_short_id, ds_path))
            platform_missing = True

    return not platform_missing


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
            if "platform: machine" in yml_file_contents:
                return True
    return False


def scan_rules_groups(dir_paths, parent_machine_only):
    groups = set()
    rules = set()
    for dir_path in dir_paths:
        groups, rules = scan_rules_group(dir_path, parent_machine_only, groups, rules)
    return groups, rules


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
