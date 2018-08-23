#!/usr/bin/env python

from __future__ import print_function

import argparse
import os
import sys

import json
import pprint

import ssg.build_yaml
import ssg.oval
import ssg.build_remediations
import ssg.rule_dir_stats as rds
import ssg.rules
import ssg.yaml


SSG_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))


def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("--left", type=str, action="store", default="build/old_rule_dirs.json",
                        help="File to read json output of rule_dir_json from (defaults to " +
                             "build/old_rule_dirs.json); left such file for diffing")
    parser.add_argument("--right", type=str, action="store", default="build/rule_dirs.json",
                        help="File to read json output of rule_dir_json from (defaults to " +
                             "build/rule_dirs.json); right such file for diffing")

    parser.add_argument("-p", "--products", type=str, action="store", default="all",
                        help="Products to inquire about, as a comma separated list")
    parser.add_argument("-t", "--strict", action="store_true",
                        help="Enforce strict --products checking against rule.yml prodtype only")
    parser.add_argument("-q", "--query", type=str, action="store", default=None,
                        help="Limit actions to only act on a comma separated list of rule_ids")

    parser.add_argument("-m", "--missing", action="store_true",
                        help="List rules which are missing OVALs or fixes")
    parser.add_argument("-2", "--two-plus", action="store_true",
                        help="List rules which have two or more OVALs or fixes")
    parser.add_argument("-r", "--prodtypes", action="store_true",
                        help="List rules which have different YAML prodtypes from checks+fix prodtypes")
    parser.add_argument("-n", "--product-names", action="store_true",
                        help="List rules which have product specific objects with broader accepted products")

    parser.add_argument("-o", "--ovals-only", action="store_true",
                        help="Only output information about OVALs")
    parser.add_argument("-f", "--fixes-only", action="store_true",
                        help="Only output information about fixes")

    parser.add_argument("--left-only", action="store_true",
                        help="Print only information from the left that is " +
                             "not in the right")
    parser.add_argument("--right-only", action="store_true",
                        help="Print only information from the right that is " +
                             "not in the left")
    parser.add_argument("--show-common", action="store_true",
                        help="Also print information that is common to both")

    parser.add_argument("-s", "--summary-only", action="store_true",
                        help="Only output summary information")

    return parser.parse_args()


def prefixed_print(statement, prefix):
    print("%s %s" % (prefix, statement))


def print_specifics(args, headline, data, prefix):
    if not args.summary_only and data:
        prefixed_print(headline, prefix)
        for line in data:
            prefixed_print(line, prefix)
        print("\n")


def print_summary(args, statements, data, prefix):
    affected_rules, affected_ovals, affected_remediations, affected_remediations_type = data

    prefixed_print(statements[0], prefix)
    prefixed_print(statements[1] % affected_rules, prefix)
    if not args.fixes_only:
        prefixed_print(statements[2] % (affected_ovals, affected_rules), prefix)
    if not args.ovals_only:
        prefixed_print(statements[3] % (affected_remediations, affected_rules), prefix)
        for r_type in ssg.build_remediations.REMEDIATION_TO_EXT_MAP:
            r_missing = affected_remediations_type[r_type]
            prefixed_print(statements[4] % (r_type, r_missing, affected_rules), prefix)
    print("\n")


def select_indices(data, indices):
    return [data[index] for index in indices]


def process_diff_missing(args, left_rules, right_rules):
    data = rds.walk_rules_diff(args, left_rules, right_rules, rds.missing_oval, rds.missing_remediation)
    result = rds.walk_rules_diff_stats(data)
    left_only_data, right_only_data, left_changed_data, right_changed_data, common_data = result

    statements = ["Missing Objects Summary",
                  "Total affected rules: %d",
                  "Rules with no OVALs: %d / %d",
                  "Rules without any remediations: %d / %d",
                  "Rules with no %s remediations: %d / %d"]

    if not args.right_only:
        print_specifics(args, "Missing Objects Specifics - Left Only:", left_only_data[5], '<')
        print_specifics(args, "Missing Objects Specifics - Left Changed:", left_changed_data[5], '<')

    if args.show_common:
        print_specifics(args, "Missing Objects Specifics - Common:", common_data[5], '=')

    if not args.left_only:
        print_specifics(args, "Missing Objects Specifics - Right Changed:", right_changed_data[5], '>')
        print_specifics(args, "Missing Objects Specifics - Right Only:", right_only_data[5], '>')

    data_indices = [0, 1, 3, 4]

    if not args.right_only:
        statements[0] = "Missing Objects Summary - Left Only:"
        l_d = select_indices(left_only_data, data_indices)
        print_summary(args, statements, l_d, '<')

        statements[0] = "Missing Objects Summary - Left Changed:"
        l_d = select_indices(left_changed_data, data_indices)
        print_summary(args, statements, l_d, '<')

    if args.show_common:
        statements[0] = "Missing Objects Summary - Common:"
        c_d = select_indices(common_data, data_indices)
        print_summary(args, statements, c_d, '=')

    if not args.left_only:
        statements[0] = "Missing Objects Summary - Right Changed:"
        r_d = select_indices(right_changed_data, data_indices)
        print_summary(args, statements, r_d, '>')

        statements[0] = "Missing Objects Summary - Right Only:"
        r_d = select_indices(right_only_data, data_indices)
        print_summary(args, statements, r_d, '>')


def process_diff_two_plus(args, left_rules, right_rules):
    data = rds.walk_rules_diff(args, left_rules, right_rules, rds.two_plus_oval, rds.two_plus_remediation)
    result = rds.walk_rules_diff_stats(data)
    left_only_data, right_only_data, left_changed_data, right_changed_data, common_data = result

    statements = ["Two Plus Objects Summary:",
                  "Total affected rules: %d",
                  "Rules with two or more OVALs: %d / %d",
                  "Rules with two or more remediations: %d / %d",
                  "Rules with two or more %s remediations: %d / %d"]

    if not args.right_only:
        print_specifics(args, "Two Plus Objects Specifics - Left Only:", left_only_data[5], '<')
        print_specifics(args, "Two Plus Objects Specifics - Left Changed:", left_changed_data[5], '<')

    if args.show_common:
        print_specifics(args, "Two Plus Objects Specifics - Common:", common_data[5], '=')

    if not args.left_only:
        print_specifics(args, "Two Plus Objects Specifics - Right Changed:", right_changed_data[5], '>')
        print_specifics(args, "Two Plus Objects Specifics - Right Only:", right_only_data[5], '>')

    data_indices = [0, 1, 2, 4]

    if not args.right_only:
        statements[0] = "Two Plus Objects Summary - Left Only:"
        l_d = select_indices(left_only_data, data_indices)
        print_summary(args, statements, l_d, '<')

        statements[0] = "Two Plus Objects Summary - Left Changed:"
        l_d = select_indices(left_changed_data, data_indices)
        print_summary(args, statements, l_d, '<')

    if args.show_common:
        statements[0] = "Two Plus Objects Summary - Common:"
        c_d = select_indices(common_data, data_indices)
        print_summary(args, statements, c_d, '=')

    if not args.left_only:
        statements[0] = "Two Plus Objects Summary - Right Changed:"
        r_d = select_indices(right_changed_data, data_indices)
        print_summary(args, statements, r_d, '>')

        statements[0] = "Two Plus Objects Summary - Right Only:"
        r_d = select_indices(right_only_data, data_indices)
        print_summary(args, statements, r_d, '>')


def process_diff_prodtypes(args, left_rules, right_rules):
    data = rds.walk_rules_diff(args, left_rules, right_rules, rds.prodtypes_oval, rds.prodtypes_remediation)
    result = rds.walk_rules_diff_stats(data)
    left_only_data, right_only_data, left_changed_data, right_changed_data, common_data = result

    statements = ["Prodtypes Objects Summary",
                  "Total affected rules: %d",
                  "Rules with differing prodtypes between YAML and OVALs: %d / %d",
                  "Rules with differing prodtypes between YAML and remediations: %d / %d",
                  "Rules with differing prodtypes between YAML and %s remediations: %d / %d"]

    if not args.right_only:
        print_specifics(args, "Prodtypes Objects Specifics - Left Only:", left_only_data[5], '<')
        print_specifics(args, "Prodtypes Objects Specifics - Left Changed:", left_changed_data[5], '<')

    if args.show_common:
        print_specifics(args, "Prodtypes Objects Specifics - Common:", common_data[5], '=')

    if not args.left_only:
        print_specifics(args, "Prodtypes Objects Specifics - Right Changed:", right_changed_data[5], '>')
        print_specifics(args, "Prodtypes Objects Specifics - Right Only:", right_only_data[5], '>')

    data_indices = [0, 1, 2, 4]

    if not args.right_only:
        statements[0] = "Prodtypes Objects Summary - Left Only:"
        l_d = select_indices(left_only_data, data_indices)
        print_summary(args, statements, l_d, '<')

        statements[0] = "Prodtypes Objects Summary - Left Changed:"
        l_d = select_indices(left_changed_data, data_indices)
        print_summary(args, statements, l_d, '<')

    if args.show_common:
        statements[0] = "Prodtypes Objects Summary - Common:"
        c_d = select_indices(common_data, data_indices)
        print_summary(args, statements, c_d, '=')

    if not args.left_only:
        statements[0] = "Prodtypes Objects Summary - Right Changed:"
        r_d = select_indices(right_changed_data, data_indices)
        print_summary(args, statements, r_d, '>')

        statements[0] = "Prodtypes Objects Summary - Right Only:"
        r_d = select_indices(right_only_data, data_indices)
        print_summary(args, statements, r_d, '>')


def process_diff_product_names(args, left_rules, right_rules):
    data = rds.walk_rules_diff(args, left_rules, right_rules, rds.product_names_oval, rds.product_names_remediation)
    result = rds.walk_rules_diff_stats(data)
    left_only_data, right_only_data, left_changed_data, right_changed_data, common_data = result

    if not args.right_only:
        print_specifics(args, "Product Names Objects Specifics - Left Only:", left_only_data[5], '<')
        print_specifics(args, "Product Names Objects Specifics - Left Changed:", left_changed_data[5], '<')

    if args.show_common:
        print_specifics(args, "Product Names Objects Specifics - Common:", common_data[5], '=')

    if not args.left_only:
        print_specifics(args, "Product Names Objects Specifics - Right Changed:", right_changed_data[5], '>')
        print_specifics(args, "Product Names Objects Specifics - Right Only:", right_only_data[5], '>')

    data_indices = [0, 1, 2, 4]
    statements = ["Product Names Objects Summary:",
                  "Total affected rules: %d",
                  "Rules with differing products and OVAL names: %d / %d",
                  "Rules with differing product and remediation names: %d / %d",
                  "Rules with differing product and %s remediation names: %d / %d"]

    if not args.right_only:
        statements[0] = "Product Names Objects Summary - Left Only:"
        l_d = select_indices(left_only_data, data_indices)
        print_summary(args, statements, l_d, '<')

        statements[0] = "Product Names Objects Summary - Left Changed:"
        l_d = select_indices(left_changed_data, data_indices)
        print_summary(args, statements, l_d, '<')

    if args.show_common:
        statements[0] = "Product Names Objects Summary - Common:"
        c_d = select_indices(common_data, data_indices)
        print_summary(args, statements, c_d, '=')

    if not args.left_only:
        statements[0] = "Product Names Objects Summary - Right Changed:"
        r_d = select_indices(right_changed_data, data_indices)
        print_summary(args, statements, r_d, '>')

        statements[0] = "Product Names Objects Summary - Right Only:"
        r_d = select_indices(right_only_data, data_indices)
        print_summary(args, statements, r_d, '>')


def main():
    args = parse_args()

    linux_products, other_products = ssg.products.get_all(SSG_ROOT)
    all_products = linux_products.union(other_products)

    left_file = open(args.left, 'r')
    left_rules = json.load(left_file)

    right_file = open(args.right, 'r')
    right_rules = json.load(right_file)

    if left_rules == right_rules:
        print("No difference. Please use rule_dir_stats to inspect one of these files.")
        sys.exit(0)

    if args.products.lower() == 'all':
        args.products = all_products
    elif args.products.lower() == 'linux':
        args.products = linux_products
    elif args.products.lower() == 'other':
        args.products = other_products
    else:
        args.products = args.products.split(',')
    args.products = set(args.products)

    left_query_keys = rds.filter_rule_ids(set(left_rules), args.query)
    right_query_keys = rds.filter_rule_ids(set(right_rules), args.query)
    args.query = left_query_keys.union(right_query_keys)
    print("Total number of queried rules: %d\n" % len(args.query))

    if not args.missing and not args.two_plus and not args.prodtypes and not args.product_names:
        args.missing = True
        args.two_plus = True
        args.prodtypes = True

    print("< Total number of known rule directories: %d" % len(left_rules))
    print("> Total number of known rule directories: %d\n" % len(right_rules))
    print("= Total number of queried rules: %d\n" % len(args.query))

    if args.missing:
        process_diff_missing(args, left_rules, right_rules)
    if args.two_plus:
        process_diff_two_plus(args, left_rules, right_rules)
    if args.prodtypes:
        process_diff_prodtypes(args, left_rules, right_rules)
    if args.product_names:
        process_diff_product_names(args, left_rules, right_rules)


if __name__ == "__main__":
    main()
