#!/usr/bin/env python2

from __future__ import print_function

import json
import argparse
import os
import os.path
import sys

import ssg.build_profile
import ssg.constants
import ssg.xml
import ssg.build_yaml


def parse_args():
    script_desc = \
        "Obtains and displays XCCDF profile statistics. Namely number " + \
        "of rules in the profile, how many of these rules have their OVAL " + \
        "check implemented, how many have a remediation available, ..."

    parser = argparse.ArgumentParser(description="Profile statistics and utilities tool")
    subparsers = parser.add_subparsers(title='subcommands', dest="subcommand")
    parser_stats = subparsers.add_parser("stats", description=script_desc,
                                           help=("Show profile statistics"))
    parser_stats.add_argument("--profile", "-p",
                        action="store",
                        help="Show statistics for this XCCDF Profile only. If "
                        "not provided the script will show stats for all "
                        "available profiles.")
    parser_stats.add_argument("--benchmark", "-b", required=True,
                        action="store",
                        help="Specify XCCDF file to act on. Must be a plain "
                        "XCCDF file, doesn't work on source datastreams yet!")
    parser_stats.add_argument("--implemented-ovals", default=False,
                        action="store_true", dest="implemented_ovals",
                        help="Show IDs of implemented OVAL checks.")
    parser_stats.add_argument("--missing-stig-ids", default=False,
                        action="store_true", dest="missing_stig_ids",
                        help="Show rules in STIG profiles that don't have STIG IDs.")
    parser_stats.add_argument("--missing-ovals", default=False,
                        action="store_true", dest="missing_ovals",
                        help="Show IDs of unimplemented OVAL checks.")
    parser_stats.add_argument("--implemented-fixes", default=False,
                        action="store_true", dest="implemented_fixes",
                        help="Show IDs of implemented remediations.")
    parser_stats.add_argument("--missing-fixes", default=False,
                        action="store_true", dest="missing_fixes",
                        help="Show IDs of unimplemented remediations.")
    parser_stats.add_argument("--assigned-cces", default=False,
                        action="store_true", dest="assigned_cces",
                        help="Show IDs of rules having CCE assigned.")
    parser_stats.add_argument("--missing-cces", default=False,
                        action="store_true", dest="missing_cces",
                        help="Show IDs of rules missing CCE element.")
    parser_stats.add_argument("--implemented", default=False,
                        action="store_true",
                        help="Equivalent of --implemented-ovals, "
                        "--implemented_fixes and --assigned-cves "
                        "all being set.")
    parser_stats.add_argument("--missing", default=False,
                        action="store_true",
                        help="Equivalent of --missing-ovals, --missing-fixes"
                        " and --missing-cces all being set.")
    parser_stats.add_argument("--all", default=False,
                        action="store_true", dest="all",
                        help="Show all available statistics.")
    parser_stats.add_argument("--format", default="plain",
                        choices=["plain", "json", "csv"],
                        help="Which format to use for output.")

    profile_diff_desc = \
        "Compare selected/unselected rules from given profiles and " + \
        "produce a new profile containing only rules from profile1 that " + \
        "is not contained in profile2. Variables are not compared and " + \
        "only variables from profile1 are kept. It doesn't support " + \
        "profile inheritance, this means that only rules explicitly " + \
        "listed in profile will be taken in account."

    parser_diff = subparsers.add_parser("diff", description=profile_diff_desc,
                                           help=("Create a diff between two given YAML profiles."))
    parser_diff.add_argument('--profile1', type=str, dest="profile_compare_from",
                        required=True, help='YAML profile')
    parser_diff.add_argument('--profile2', type=str, dest="profile_compare_to",
                        required=True, help='YAML profile')

    args = parser.parse_args()

    if args.subcommand == "stats":
        if args.all:
            args.implemented = True
            args.missing = True

        if args.implemented:
            args.implemented_ovals = True
            args.implemented_fixes = True
            args.assigned_cces = True

        if args.missing:
            args.missing_ovals = True
            args.missing_fixes = True
            args.missing_cces = True
            args.missing_stig_ids = True

    return args


def main():
    args = parse_args()

    if args.subcommand == "diff":
        profile1 = ssg.build_yaml.Profile.from_yaml(args.profile_compare_from)
        profile2 = ssg.build_yaml.Profile.from_yaml(args.profile_compare_to)

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
        exit(0)

    benchmark = ssg.build_profile.XCCDFBenchmark(args.benchmark)
    ret = []
    if args.profile:
        ret.append(benchmark.show_profile_stats(args.profile, args))
    else:
        all_profile_elems = benchmark.tree.findall("./{%s}Profile" % (ssg.constants.XCCDF11_NS))
        ret = []
        for elem in all_profile_elems:
            profile = elem.get('id')
            if profile is not None:
                ret.append(benchmark.show_profile_stats(profile, args))

    if args.format == "json":
        print(json.dumps(ret, indent=4))
    elif args.format == "csv":
        # we can assume ret has at least one element
        # CSV header
        print(",".join(ret[0].keys()))
        for line in ret:
            print(",".join([str(value) for value in line.values()]))


if __name__ == '__main__':
    main()
