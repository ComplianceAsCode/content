#!/usr/bin/env python3

import sys
import os
import argparse
import subprocess
import json

import ssg.build_remediations
import ssg.fixes
import ssg.rule_yaml
import ssg.utils

SSG_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
REMEDIATION_LANGS = list(ssg.build_remediations.REMEDIATION_TO_EXT_MAP)


def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("-j", "--json", type=str, action="store", default="build/rule_dirs.json",
                        help="File to read json output of rule_dir_json from (defaults "
                             "to build/rule_dirs.json)")
    parser.add_argument("rule_id", type=str, help="Rule to change, by id")
    parser.add_argument("fix_lang", choices=REMEDIATION_LANGS, help="Remediation to change")
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


def list_platforms(rule_obj, lang):
    print("Computed products:")
    for fix_id in sorted(rule_obj['remediations'].get(lang, {})):
        fix = rule_obj['remediations'][lang][fix_id]

        print(" - %s" % fix_id)
        for product in sorted(fix.get('products', [])):
            print("   - %s" % product)

    print("")

    print("Actual platforms:")
    for rule_id in sorted(rule_obj['remediations'].get(lang, {})):
        fix = rule_obj['remediations'][lang][rule_id]
        fix_file = ssg.fixes.get_fix_path(rule_obj, lang, rule_id)
        platforms = ssg.fixes.applicable_platforms(fix_file)

        print(" - %s" % fix_id)
        for platform in platforms:
            print("   - %s" % platform)

    print("")


def add_platforms(rule_obj, lang, platforms):
    fix_file, fix_contents = ssg.fixes.get_fix_contents(rule_obj, lang, 'shared')
    current_platforms = ssg.fixes.applicable_platforms(fix_file)

    if "multi_platform_all" in current_platforms:
        return

    new_platforms = set(current_platforms)
    new_platforms.update(platforms)

    print("Current platforms: %s" % ','.join(sorted(current_platforms)))
    print("New platforms: %s" % ','.join(sorted(new_platforms)))

    new_contents = ssg.fixes.set_applicable_platforms(fix_contents,
                                                      new_platforms)
    ssg.utils.write_list_file(fix_file, new_contents)


def remove_platforms(rule_obj, lang, platforms):
    fix_file, fix_contents = ssg.fixes.get_fix_contents(rule_obj, lang, 'shared')
    current_platforms = ssg.fixes.applicable_platforms(fix_file)
    new_platforms = set(current_platforms).difference(platforms)

    print("Current platforms: %s" % ','.join(sorted(current_platforms)))
    print("New platforms: %s" % ','.join(sorted(new_platforms)))

    new_contents = ssg.fixes.set_applicable_platforms(fix_contents,
                                                      new_platforms)
    ssg.utils.write_list_file(fix_file, new_contents)


def replace_platforms(rule_obj, lang, platforms):
    fix_file, fix_contents = ssg.fixes.get_fix_contents(rule_obj, lang, 'shared')
    current_platforms = ssg.fixes.applicable_platforms(fix_file)
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

    new_contents = ssg.fixes.set_applicable_platforms(fix_contents,
                                                      new_platforms)
    ssg.utils.write_list_file(fix_file, new_contents)


def delete_fixes(rule_obj, lang, products):
    for product in products:
        fix_file = ssg.fixes.get_fix_path(rule_obj, lang, product)
        os.remove(fix_file)
        print("Removed: %s" % fix_file)


def make_shared_fix(rule_obj, lang, products):
    if not products or len(products) > 1:
        raise ValueError("Must pass exactly one product for the make_shared option.")
    if 'remediations' not in rule_obj or lang not in rule_obj['remediations']:
        raise ValueError("Rule is missing fixes.")

    lang_ext = ssg.build_remediations.REMEDIATION_TO_EXT_MAP[lang]
    shared_name = "shared" + lang_ext
    if shared_name in rule_obj['remediations'][lang]:
        raise ValueError("Already have shared fix for rule_id:%s; refusing "
                         "to continue." % rule_obj['id'])

    fix_file = ssg.fixes.get_fix_path(rule_obj, lang, products[0])
    shared_fix_file = os.path.join(rule_obj['dir'], lang, shared_name)
    os.rename(fix_file, shared_fix_file)
    print("Moved %s -> %s" % (fix_file, shared_fix_file))


def diff_fixes(rule_obj, lang, products):
    if not products or len(products) != 2 or products[0] == products[1]:
        raise ValueError("Must pass exactly two products for the diff option.")
    if 'remediations' not in rule_obj or lang not in rule_obj['remediations']:
        raise ValueError("Rule is missing fixes.")

    left_fix_file = ssg.fixes.get_fix_path(rule_obj, lang, products[0])
    right_fix_file = ssg.fixes.get_fix_path(rule_obj, lang, products[1])

    subprocess.run(['diff', '--color=always', left_fix_file, right_fix_file])


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
        list_platforms(rule_obj, args.fix_lang)
    elif args.action == "add":
        add_platforms(rule_obj, args.fix_lang, args.products)
    elif args.action == "remove":
        remove_platforms(rule_obj, args.fix_lang, args.products)
    elif args.action == "replace":
        replace_platforms(rule_obj, args.fix_lang, args.products)
    elif args.action == 'delete':
        delete_fixes(rule_obj, args.fix_lang, args.products)
    elif args.action == 'make_shared':
        make_shared_fix(rule_obj, args.fix_lang, args.products)
    elif args.action == 'diff':
        diff_fixes(rule_obj, args.fix_lang, args.products)
    else:
        print("Unknown option: %s" % args.action)


if __name__ == "__main__":
    main()
