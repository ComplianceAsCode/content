#!/usr/bin/env python2

from __future__ import print_function

import json
import argparse
import os
import os.path
import sys

import ssg
ElementTree = ssg.xml.ElementTree


def parse_args():
    script_desc = \
        "Obtains and displays XCCDF profile statistics. Namely number " + \
        "of rules in the profile, how many of these rules have their OVAL " + \
        "check implemented, how many have a remediation available, ..."

    parser = argparse.ArgumentParser(description=script_desc)
    parser.add_argument("--profile", "-p",
                        action="store",
                        help="Show statistics for this XCCDF Profile only. If "
                        "not provided the script will show stats for all "
                        "available profiles.")
    parser.add_argument("--benchmark", "-b", required=True,
                        action="store",
                        help="Specify XCCDF file to act on. Must be a plain "
                        "XCCDF file, doesn't work on source datastreams yet!")
    parser.add_argument("--implemented-ovals", default=False,
                        action="store_true", dest="implemented_ovals",
                        help="Show IDs of implemented OVAL checks.")
    parser.add_argument("--missing-stig-ids", default=False,
                        action="store_true", dest="missing_stig_ids",
                        help="Show rules in STIG profiles that don't have STIG IDs.")
    parser.add_argument("--missing-ovals", default=False,
                        action="store_true", dest="missing_ovals",
                        help="Show IDs of unimplemented OVAL checks.")
    parser.add_argument("--implemented-fixes", default=False,
                        action="store_true", dest="implemented_fixes",
                        help="Show IDs of implemented remediations.")
    parser.add_argument("--missing-fixes", default=False,
                        action="store_true", dest="missing_fixes",
                        help="Show IDs of unimplemented remediations.")
    parser.add_argument("--assigned-cces", default=False,
                        action="store_true", dest="assigned_cces",
                        help="Show IDs of rules having CCE assigned.")
    parser.add_argument("--missing-cces", default=False,
                        action="store_true", dest="missing_cces",
                        help="Show IDs of rules missing CCE element.")
    parser.add_argument("--implemented", default=False,
                        action="store_true",
                        help="Equivalent of --implemented-ovals, "
                        "--implemented_fixes and --assigned-cves "
                        "all being set.")
    parser.add_argument("--missing", default=False,
                        action="store_true",
                        help="Equivalent of --missing-ovals, --missing-fixes"
                        " and --missing-cces all being set.")
    parser.add_argument("--all", default=False,
                        action="store_true", dest="all",
                        help="Show all available statistics.")
    parser.add_argument("--format", default="plain",
                        choices=["plain", "json", "csv"],
                        help="Which format to use for output.")

    args = parser.parse_args()

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

    benchmark = ssg.build_profile.XCCDFBenchmark(args.benchmark)
    ret = []
    if args.profile:
        ret.append(benchmark.show_profile_stats(args.profile, args))
    else:
        all_profile_elems = benchmark.tree.findall("./{%s}Profile" % (xccdf_ns))
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
