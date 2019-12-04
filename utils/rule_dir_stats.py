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
import ssg.products
import ssg.rule_dir_stats as rds
import ssg.rules
import ssg.yaml


SSG_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))


def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("-i", "--input", type=str, action="store", default="build/rule_dirs.json",
                        help="File to read json output of rule_dir_json from (defaults to build/rule_dirs.json)")

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
    parser.add_argument("-?", "--introspect", action="store_true",
                        help="Dump raw objects for explicitly queried rule_ids")
    parser.add_argument("-u", "--unassociated", action="store_true",
                        help="Search for rules without any product association")

    parser.add_argument("-o", "--ovals-only", action="store_true",
                        help="Only output information about OVALs")
    parser.add_argument("-f", "--fixes-only", action="store_true",
                        help="Only output information about fixes")

    parser.add_argument("-s", "--summary-only", action="store_true",
                        help="Only output summary information")

    return parser.parse_args()


def process_missing(args, known_rules):
    result = rds.walk_rules_stats(args, known_rules, rds.missing_oval, rds.missing_remediation)
    affected_rules = result[0]
    affected_ovals = result[1]
    affected_remediations = result[3]
    affected_remediations_type = result[4]
    verbose_output = result[5]

    if not args.summary_only:
        print("Missing Objects Specifics:")
        for line in verbose_output:
            print(line)
        print("\n")

    print("Missing Objects Summary:")
    print("Total affected rules: %d" % affected_rules)
    if not args.fixes_only:
        print("Rules with no OVALs: %d / %d" % (affected_ovals, affected_rules))
    if not args.ovals_only:
        print("Rules without any remediations: %d / %d" % (affected_remediations, affected_rules))
        for r_type in ssg.build_remediations.REMEDIATION_TO_EXT_MAP:
            r_missing = affected_remediations_type[r_type]
            print("Rules with no %s remediations: %d / %d" % (r_type, r_missing, affected_rules))
    print("\n")


def process_two_plus(args, known_rules):
    result = rds.walk_rules_stats(args, known_rules, rds.two_plus_oval, rds.two_plus_remediation)
    affected_rules = result[0]
    affected_ovals = result[1]
    affected_remediations = result[2]
    affected_remediations_type = result[4]
    verbose_output = result[5]

    if not args.summary_only:
        print("Two Plus Object Specifics:")
        for line in verbose_output:
            print(line)
        print("\n")

    print("Two Plus Objects Summary:")
    print("Total affected rules: %d" % affected_rules)
    if not args.fixes_only:
        print("Rules with two or more OVALs: %d / %d" % (affected_ovals, affected_rules))
    if not args.ovals_only:
        print("Rules with two or more remediations: %d / %d" % (affected_remediations, affected_rules))
        for r_type in ssg.build_remediations.REMEDIATION_TO_EXT_MAP:
            r_missing = affected_remediations_type[r_type]
            print("Rules with two or more %s remediations: %d / %d" % (r_type, r_missing, affected_rules))

    print("\n")


def process_prodtypes(args, known_rules):
    result = rds.walk_rules_stats(args, known_rules, rds.prodtypes_oval, rds.prodtypes_remediation)
    affected_rules = result[0]
    affected_ovals = result[1]
    affected_remediations = result[2]
    affected_remediations_type = result[4]
    verbose_output = result[5]

    if not args.summary_only:
        print("Prodtypes Object Specifics:")
        for line in verbose_output:
            print(line)
        print("\n")

    print("Prodtypes Objects Summary:")
    print("Total affected rules: %d" % affected_rules)
    if not args.fixes_only:
        print("Rules with differing prodtypes between YAML and OVALs: %d / %d" % (affected_ovals, affected_rules))
    if not args.ovals_only:
        print("Rules with differing prodtypes between YAML and remediations: %d / %d" % (affected_remediations, affected_rules))
        for r_type in ssg.build_remediations.REMEDIATION_TO_EXT_MAP:
            r_missing = affected_remediations_type[r_type]
            print("Rules with differing prodtypes between YAML and %s remediations: %d / %d" % (r_type, r_missing, affected_rules))

    print("\n")


def process_product_names(args, known_rules):
    result = rds.walk_rules_stats(args, known_rules, rds.product_names_oval, rds.product_names_remediation)
    affected_rules = result[0]
    affected_ovals = result[1]
    affected_remediations = result[2]
    affected_remediations_type = result[4]
    verbose_output = result[5]

    if not args.summary_only:
        print("Product Names Specifics:")
        for line in verbose_output:
            print(line)
        print("\n")

    print("Product Names Summary:")
    print("Total affected rules: %d" % affected_rules)
    if not args.fixes_only:
        print("Rules with differing products and OVAL names: %d / %d" % (affected_ovals, affected_rules))
    if not args.ovals_only:
        print("Rules with differing product and remediation names: %d / %d" % (affected_remediations, affected_rules))
        for r_type in ssg.build_remediations.REMEDIATION_TO_EXT_MAP:
            r_missing = affected_remediations_type[r_type]
            print("Rules with differing product and %s remediation names: %d / %d" % (r_type, r_missing, affected_rules))

    print("\n")


def process_introspection(args, known_rules):
    for rule_id in args.query:
        if not args.summary_only:
            pprint.pprint(known_rules[rule_id])
            print("\n")
        else:
            print(rule_id)


def process_unassociated(args, known_rules, all_products):
    save_ovals_only = args.ovals_only
    save_fixes_only = args.fixes_only
    save_strict = args.strict

    args.ovals_only = False
    args.fixes_only = False
    args.strict = False

    for rule_id in known_rules:
        rule_obj = known_rules[rule_id]
        affected_products = rds.get_all_affected_products(args, rule_obj)
        if affected_products.intersection(all_products):
            continue

        print("Unassociated Rule: rule_id:%s" % rule_id)

    args.ovals_only = save_ovals_only
    args.fixes_only = save_fixes_only
    args.stict = save_strict


def main():
    args = parse_args()

    linux_products, other_products = ssg.products.get_all(SSG_ROOT)
    all_products = linux_products.union(other_products)

    json_file = open(args.input, 'r')
    known_rules = json.load(json_file)

    if args.products.lower() == 'all':
        args.products = all_products
    elif args.products.lower() == 'linux':
        args.products = linux_products
    elif args.products.lower() == 'other':
        args.products = other_products
    else:
        args.products = args.products.split(',')
    args.products = set(args.products)

    args.query = rds.filter_rule_ids(set(known_rules), args.query)

    if not args.missing and not args.two_plus and not args.prodtypes and not args.introspect and not args.unassociated and not args.product_names:
        args.missing = True
        args.two_plus = True
        args.prodtypes = True

    print("Total number of known rule directories: %d" % len(known_rules))
    print("Total number of queried rules: %d\n" % len(args.query))

    if args.missing:
        process_missing(args, known_rules)
    if args.two_plus:
        process_two_plus(args, known_rules)
    if args.prodtypes:
        process_prodtypes(args, known_rules)
    if args.product_names:
        process_product_names(args, known_rules)
    if args.introspect and args.query:
        process_introspection(args, known_rules)
    if args.unassociated:
        process_unassociated(args, known_rules, all_products)

if __name__ == "__main__":
    main()
