from __future__ import print_function

import yaml
import argparse
import os
import os.path
import sys

from ssg.build_yaml import Profile


def parse_args():

    script_desc = \
        "Compare selected/unselected rules from given profiles and " + \
        "produce a new profile containing only rules from profile1 that " + \
        "is not contained in profile2. Variables are not compared and " + \
        "only variables from profile1 are kept. It doesn't support " + \
        "profile inheritance, this means that only rules explicitly " + \
        "listed in profile will be taken in account."

    parser = argparse.ArgumentParser(description=script_desc)

    parser.add_argument('--profile1', type=str, dest="profile_compare_from",
                        required=True, help='YAML profile')
    parser.add_argument('--profile2', type=str, dest="profile_compare_to",
                        required=True, help='YAML profile')

    args = parser.parse_args()

    return args


def main():
    args = parse_args()

    profile1 = Profile.from_yaml(args.profile_compare_from)
    profile2 = Profile.from_yaml(args.profile_compare_to)

    profile_diff = profile1 - profile2

    exclusive_rules = len(profile_diff.get_rule_selectors())
    if exclusive_rules > 0:
        print("Exclusive rules from profile {}: {}".format(
            args.profile_compare_from, exclusive_rules))

        profile1_basename = os.path.splitext(
            os.path.basename(args.profile_compare_from))[0]
        profile2_basename = os.path.splitext(
            os.path.basename(args.profile_compare_to))[0]

        profile_with_exclusive_rules_filename = "{}-compared_to-{}.profile".format(
            profile1_basename, profile2_basename)
        print("Creating a new profile containing the exclusive rules: {}".format(
            profile_with_exclusive_rules_filename))

        profile_diff.dump_yaml(profile_with_exclusive_rules_filename)
        print("Profile {} was created successfully".format(
            profile_with_exclusive_rules_filename))
    else:
        print("No exclusive rules in profile {} compared to profile {} were found".format(
            args.profile_compare_from, args.profile_compare_to))


if __name__ == '__main__':
    main()
