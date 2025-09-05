#!/usr/bin/env python3

import sys
import os
import argparse
import subprocess
import json

import ssg.checks
import ssg.oval
import ssg.rule_yaml
import ssg.utils

SSG_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))


def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("-j", "--json", type=str, action="store", default="build/rule_dirs.json",
                        help="File to read json output of rule_dir_json from (defaults "
                             "to build/rule_dirs.json)")
    parser.add_argument("rule_id", type=str, help="Rule to change, by id")
    parser.add_argument("action", choices=['add', 'remove', 'list', 'replace', 'delete', 'make_shared', 'diff'],
                        help="Rule to change, by id")
    parser.add_argument("products", type=str, nargs='*',
                        help="Products or platforms to perform action with on rule_id. For replace, "
                             "the expected format is "
                             "platform[,other_platform]~platform[,other_platform] "
                             "where the first half is the platforms that are required to "
                             "match, and are replaced by the platforms in the second half "
                             "if all match. Add and remove require platforms and only apply "
                             "to the shared OVAL; delete, make_shared, and diff require products.")
    return parser.parse_args()


def list_platforms(rule_obj):
    print("Computed products:")
    for oval_id in sorted(rule_obj.get('ovals', {})):
        oval = rule_obj['ovals'][oval_id]

        print(" - %s" % oval_id)
        for product in sorted(oval.get('products', [])):
            print("   - %s" % product)

    print("")

    print("Actual platforms:")
    for oval_id in sorted(rule_obj.get('ovals', {})):
        oval = rule_obj['ovals'][oval_id]
        oval_file = ssg.checks.get_oval_path(rule_obj, oval_id)
        platforms = ssg.oval.applicable_platforms(oval_file)

        print(" - %s" % oval_id)
        for platform in platforms:
            print("   - %s" % platform)

    print("")


def add_platforms(rule_obj, platforms):
    oval_file, oval_contents = ssg.checks.get_oval_contents(rule_obj, 'shared')
    current_platforms = ssg.oval.applicable_platforms(oval_file)

    if "multi_platform_all" in current_platforms:
        return

    new_platforms = set(current_platforms)
    new_platforms.update(platforms)

    print("Current platforms: %s" % ','.join(sorted(current_platforms)))
    print("New platforms: %s" % ','.join(sorted(new_platforms)))

    new_contents = ssg.checks.set_applicable_platforms(oval_contents,
                                                       new_platforms)
    ssg.utils.write_list_file(oval_file, new_contents)


def remove_platforms(rule_obj, platforms):
    oval_file, oval_contents = ssg.checks.get_oval_contents(rule_obj, 'shared')
    current_platforms = ssg.oval.applicable_platforms(oval_file)
    new_platforms = set(current_platforms).difference(platforms)

    print("Current platforms: %s" % ','.join(sorted(current_platforms)))
    print("New platforms: %s" % ','.join(sorted(new_platforms)))

    new_contents = ssg.checks.set_applicable_platforms(oval_contents,
                                                       new_platforms)
    ssg.utils.write_list_file(oval_file, new_contents)


def replace_platforms(rule_obj, platforms):
    oval_file, oval_contents = ssg.checks.get_oval_contents(rule_obj, 'shared')
    current_platforms = ssg.oval.applicable_platforms(oval_file)
    new_platforms = set(current_platforms)

    for platform in platforms:
        parsed_platform = platform.split('~')
        if not len(parsed_platform) == 2:
            print("Invalid platform replacement description: %s" % platform,
                  file=sys.stderr)
            sys.exit(1)

        match = ssg.rule_yaml.parse_prodtype(parsed_platform[0])
        replacement = ssg.rule_yaml.parse_prodtype(parsed_platform[1])

        if match.issubset(current_platforms):
            new_platforms.difference_update(match)
            new_platforms.update(replacement)

    print("Current platforms: %s" % ','.join(sorted(current_platforms)))
    print("New platforms: %s" % ','.join(sorted(new_platforms)))

    new_contents = ssg.checks.set_applicable_platforms(oval_contents,
                                                       new_platforms)
    ssg.utils.write_list_file(oval_file, new_contents)


def delete_ovals(rule_obj, products):
    for product in products:
        oval_file = ssg.checks.get_oval_path(rule_obj, product)
        os.remove(oval_file)
        print("Removed: %s" % oval_file)


def make_shared_oval(rule_obj, products):
    if not products or len(products) > 1:
        raise ValueError("Must pass exactly one product for the make_shared option.")
    if 'ovals' not in rule_obj:
        raise ValueError("Rule is missing all ovals.")

    if 'shared.xml' in rule_obj['ovals']:
        raise ValueError("Already have shared oval for rule_id:%s; refusing "
                         "to continue." % rule_obj['id'])

    oval_file = ssg.checks.get_oval_path(rule_obj, products[0])
    shared_oval_file = os.path.join(rule_obj['dir'], 'oval', 'shared.xml')
    os.rename(oval_file, shared_oval_file)
    print("Moved %s -> %s" % (oval_file, shared_oval_file))


def diff_ovals(rule_obj, products):
    if not products or len(products) != 2 or products[0] == products[1]:
        raise ValueError("Must pass exactly two products for the diff option.")
    if 'ovals' not in rule_obj:
        raise ValueError("Rule is missing all ovals.")

    left_oval_file = ssg.checks.get_oval_path(rule_obj, products[0])
    right_oval_file = ssg.checks.get_oval_path(rule_obj, products[1])

    subprocess.run(['diff', '--color=always', left_oval_file, right_oval_file])


def main():
    args = parse_args()

    json_file = open(args.json, 'r')
    known_rules = json.load(json_file)

    if not args.rule_id in known_rules:
        print("Error: rule_id:%s is not known!" % args.rule_id, file=sys.stderr)
        print("If you think this is an error, try regenerating the JSON.", file=sys.stderr)
        sys.exit(1)

    if args.action != "list" and not args.products:
        print("Error: expected a list of products or replace transformations but "
              "none given.", file=sys.stderr)
        sys.exit(1)

    rule_obj = known_rules[args.rule_id]
    print("rule_id:%s\n" % args.rule_id)

    if args.action == "list":
        list_platforms(rule_obj)
    elif args.action == "add":
        add_platforms(rule_obj, args.products)
    elif args.action == "remove":
        remove_platforms(rule_obj, args.products)
    elif args.action == "replace":
        replace_platforms(rule_obj, args.products)
    elif args.action == 'delete':
        delete_ovals(rule_obj, args.products)
    elif args.action == 'make_shared':
        make_shared_oval(rule_obj, args.products)
    elif args.action == 'diff':
        diff_ovals(rule_obj, args.products)
    else:
        print("Unknown option: %s" % args.action)


if __name__ == "__main__":
    main()
