from __future__ import print_function

import yaml
import argparse
import os
import os.path
import sys


def read_file(path):
    try:
        f = open(path, 'r')
        f_str = f.read()
        if len(f_str) == 0:
            print("File {} is empty.".format(path))
            exit(1)
        return f_str
    except FileNotFoundError:
        print("File {} was not found.".format(path))
        exit(1)
    except Exception as e:
        print(e)
        exit(1)


def parse_args():

    script_desc = \
        "Compare rules from given profiles and produce a new profile " + \
        "containing only rules from profile1 that is not contained " + \
        "in profile2. Variables are treated as the same, they need " + \
        "to be identical to match, both variable name and value. " + \
        "It doesn't support profile inheritance, this means that " + \
        "only rules explicitly listed in profile will be accounted."

    parser = argparse.ArgumentParser(description=script_desc)

    parser.add_argument('--profile1', type=str, dest="profile_compare_from",
                        required=True, help='YAML profile')
    parser.add_argument('--profile2', type=str, dest="profile_compare_to",
                        required=True,
                        help='YAML profile, also can be a list of rules ' + \
                            'separated by newline')

    args = parser.parse_args()

    return args


def main():
    args = parse_args()

    profile_compare_from_str = read_file(args.profile_compare_from)
    profile_compare_to_str = read_file(args.profile_compare_to)

    try:
        profile1 = yaml.load(profile_compare_from_str)
        profile1_rules_list = profile1.get('selections')
    except Exception as e:
        msg="A problem occurred while parsing the profile. " + \
            "Is the file '{}' a valid YAML profile?"
        print(msg.format(args.profile_compare_from))
        exit(1)

    profile2_rules_list = []
    try:
        profile2 = yaml.load(profile_compare_to_str)
        profile2_rules_list = profile2.get('selections')
    except:
        with open(args.profile_compare_to, 'r') as rules:
            for rule in rules:
                rule = rule.replace(os.linesep, '')
                profile2_rules_list += [rule]

    profile1_exclusive_rules = list(
        set(profile1_rules_list) - set(profile2_rules_list))

    exclusive_rules = len(profile1_exclusive_rules)
    if exclusive_rules > 0:
        print("Exclusive rules from profile {}: {}".format(
            args.profile_compare_from, exclusive_rules))
        profile1['selections'] = profile1_exclusive_rules
        profile1['title'] = "EXCLUSIVE RULES compared to file: {}; {}".format(
            args.profile_compare_to, profile1['title'])

        profile1_basename=os.path.splitext(
            os.path.basename(args.profile_compare_from))[0]
        profile2_basename=os.path.splitext(
            os.path.basename(args.profile_compare_to))[0]

        profile_with_exclusive_rules_filename = "{}-compared_to-{}.profile".format(
            profile1_basename, profile2_basename)
        print("Creating a new profile containing those exclusive rules: {}".format(
            profile_with_exclusive_rules_filename))
        with open(profile_with_exclusive_rules_filename, 'w+') as f:
            yaml.dump(profile1, f)
        print("Profile {} was created successfully".format(
            profile_with_exclusive_rules_filename))
    else:
        print("No exclusive rules in profile {} compared to profile {} were found".format(
            args.profile_compare_from, args.profile_compare_to))


if __name__ == '__main__':
    main()
