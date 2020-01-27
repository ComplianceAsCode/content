#!/usr/bin/env python3

import sys
import os
import argparse
import json

import ssg.rules
import ssg.utils
import ssg.rule_yaml

SSG_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))


def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("-j", "--json", type=str, action="store", default="build/rule_dirs.json",
                        help="File to read json output of rule_dir_json from (defaults "
                             "to build/rule_dirs.json)")
    parser.add_argument("rule_id", type=str, help="Rule to change, by id")
    parser.add_argument("action", choices=['add', 'remove', 'list', 'replace'],
                        help="Rule to change, by id")
    parser.add_argument("products", type=str, nargs='*',
                        help="Products to perform action with on rule_id. For replace, "
                             "the expected format is "
                             "product[,other_product]~product[,other_product] "
                             "where the first half is the products that are required to "
                             "match, and are replaced by the products in the second half "
                             "if all match.")
    return parser.parse_args()


def list_products(rule_obj):
    yaml_file, yaml_contents = ssg.rule_yaml.get_yaml_contents(rule_obj)
    prodtype_section = ssg.rule_yaml.get_section_lines(yaml_file, yaml_contents, 'prodtype')

    print("Computed products:")
    for product in sorted(rule_obj.get('products', [])):
        print(" - %s" % product)
    print("")

    if prodtype_section:
        prodtype_contents = ssg.rule_yaml.parse_from_yaml(yaml_contents, prodtype_section)
        prodtype = ssg.rule_yaml.parse_prodtype(prodtype_contents['prodtype'])
        print("Listed products:")
        for product in prodtype:
            print(" - %s" % product)
    else:
        print("Empty listed prodtype in the file")


def add_products(rule_obj, products):
    yaml_file, yaml_contents = ssg.rule_yaml.get_yaml_contents(rule_obj)
    prodtype_section = ssg.rule_yaml.get_section_lines(yaml_file, yaml_contents, 'prodtype')

    if not prodtype_section:
        new_prodtype = sorted(set(products))
        new_prodtype_str = ','.join(new_prodtype)

        doc_complete_section = ssg.rule_yaml.get_section_lines(yaml_file, yaml_contents,
                                                               'documentation_complete')
        if not doc_complete_section:
            print("Cannot modify empty prodtype with missing documentation_complete... "
                  "Are you sure this is a rule file? %s" % yaml_file, file=sys.stderr)
            sys.exit(1)

        start_line = doc_complete_section[1]+1

        print("Current prodtype is empty, not adding the new prodtype.")
    else:
        prodtype_contents = ssg.rule_yaml.parse_from_yaml(yaml_contents, prodtype_section)
        prodtype = prodtype_contents['prodtype']

        new_prodtype = ssg.rule_yaml.parse_prodtype(prodtype)
        new_prodtype.update(products)
        new_prodtype_str = ','.join(sorted(new_prodtype))

        print("Current prodtype: %s" % prodtype)
        print("New prodtype: %s" % new_prodtype_str)

        yaml_contents = ssg.rule_yaml.update_key_value(yaml_contents, 'prodtype',
                                                       prodtype, new_prodtype_str)

    ssg.utils.write_list_file(yaml_file, yaml_contents)


def remove_products(rule_obj, products):
    yaml_file, yaml_contents = ssg.rule_yaml.get_yaml_contents(rule_obj)
    prodtype_section = ssg.rule_yaml.get_section_lines(yaml_file, yaml_contents, 'prodtype')

    if not prodtype_section:
        print("Cannot modify empty prodtype to remove products from %s" %
              yaml_file, file=sys.stderr)
        sys.exit(1)

    prodtype_contents = ssg.rule_yaml.parse_from_yaml(yaml_contents, prodtype_section)
    prodtype = prodtype_contents['prodtype']

    new_prodtype = ssg.rule_yaml.parse_prodtype(prodtype)
    new_prodtype = new_prodtype.difference(products)
    new_prodtype_str = ','.join(sorted(new_prodtype))

    print("Current prodtype: %s" % prodtype)

    if new_prodtype:
        print("New prodtype: %s" % new_prodtype_str)
        yaml_contents = ssg.rule_yaml.update_key_value(yaml_contents, 'prodtype',
                                                       prodtype, new_prodtype_str)
    else:
        print("New prodtype is empty")
        yaml_contents = ssg.rule_yaml.remove_lines(yaml_contents, prodtype_section)

    ssg.utils.write_list_file(yaml_file, yaml_contents)


def replace_products(rule_obj, products):
    yaml_file, yaml_contents = ssg.rule_yaml.get_yaml_contents(rule_obj)
    prodtype_section = ssg.rule_yaml.get_section_lines(yaml_file, yaml_contents, 'prodtype')

    if not prodtype_section:
        print("Cannot modify empty prodtype to replace products from %s" % yaml_file,
              file=sys.stderr)
        sys.exit(1)

    parsed_changes = []
    for product in products:
        parsed_product = product.split('~')
        if not len(parsed_product) == 2:
            print("Invalid product replacement description: %s" % product,
                  file=sys.stderr)
            sys.exit(1)

        change = {
            'match': ssg.rule_yaml.parse_prodtype(parsed_product[0]),
            'replacement': ssg.rule_yaml.parse_prodtype(parsed_product[1]),
        }
        parsed_changes.append(change)

    prodtype_contents = ssg.rule_yaml.parse_from_yaml(yaml_contents, prodtype_section)
    prodtype = prodtype_contents['prodtype']

    current_prodtypes = ssg.rule_yaml.parse_prodtype(prodtype)
    new_prodtypes = set(current_prodtypes)

    for change in parsed_changes:
        if change['match'].issubset(current_prodtypes):
            new_prodtypes.difference_update(change['match'])
            new_prodtypes.update(change['replacement'])

    new_prodtype_str = ','.join(sorted(new_prodtypes))

    print("Current prodtype: %s" % prodtype)
    print("New prodtype: %s" % new_prodtype_str)

    yaml_contents = ssg.rule_yaml.update_key_value(yaml_contents, 'prodtype',
                                                   prodtype, new_prodtype_str)

    ssg.utils.write_list_file(yaml_file, yaml_contents)


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
        list_products(rule_obj)
    elif args.action == "add":
        add_products(rule_obj, args.products)
    elif args.action == "remove":
        remove_products(rule_obj, args.products)
    elif args.action == "replace":
        replace_products(rule_obj, args.products)
    else:
        print("Unknown option: %s" % args.action)


if __name__ == "__main__":
    main()
