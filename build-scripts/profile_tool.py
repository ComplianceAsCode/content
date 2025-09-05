#!/usr/bin/python3

from __future__ import print_function

import argparse

try:
    from utils.profile_tool import command_stats, command_sub
except ImportError:
    print("The ssg module could not be found.")
    print(
        "Run .pyenv.sh available in the project root directory,"
        " or add it to PYTHONPATH manually."
    )
    print("$ source .pyenv.sh")
    exit(1)


def parse_stats_subcommand(subparsers):
    parser_stats = subparsers.add_parser(
        "stats",
        description=(
            "Obtains and displays XCCDF profile statistics. Namely number of rules in the profile,"
            " how many of these rules have their OVAL check implemented, how many have "
            "a remediation available, ..."
        ),
        help=("Show profile statistics"),
    )
    parser_stats.add_argument(
        "--profile",
        "-p",
        action="store",
        help=(
            "Show statistics for this XCCDF Profile only. If not provided the script will show "
            "stats for all available profiles."
        ),
    )
    parser_stats.add_argument(
        "--benchmark",
        "-b",
        required=True,
        action="store",
        help="Specify XCCDF file or a SCAP source data stream file to act on.",
    )
    parser_stats.add_argument(
        "--implemented-ovals",
        default=False,
        action="store_true",
        dest="implemented_ovals",
        help="Show IDs of implemented OVAL checks.",
    )
    parser_stats.add_argument(
        "--implemented-sces",
        default=False,
        action="store_true",
        dest="implemented_sces",
        help="Show IDs of implemented SCE checks.",
    )
    parser_stats.add_argument(
        "--missing-stig-ids",
        default=False,
        action="store_true",
        dest="missing_stig_ids",
        help="Show rules in STIG profiles that don't have STIG IDs.",
    )
    parser_stats.add_argument(
        "--missing-cis-refs",
        default=False,
        action="store_true",
        dest="missing_cis_refs",
        help="Show rules in CIS profiles that don't have CIS references.",
    )
    parser_stats.add_argument(
        "--missing-hipaa-refs",
        default=False,
        action="store_true",
        dest="missing_hipaa_refs",
        help="Show rules in HIPAA profiles that don't have HIPAA references.",
    )
    parser_stats.add_argument(
        "--missing-anssi-refs",
        default=False,
        action="store_true",
        dest="missing_anssi_refs",
        help="Show rules in ANSSI profiles that don't have ANSSI references.",
    )
    parser_stats.add_argument(
        "--missing-ospp-refs",
        default=False,
        action="store_true",
        dest="missing_ospp_refs",
        help="Show rules in OSPP profiles that don't have OSPP references.",
    )
    parser_stats.add_argument(
        "--missing-cui-refs",
        default=False,
        action="store_true",
        dest="missing_cui_refs",
        help="Show rules in CUI profiles that don't have CUI references.",
    )
    parser_stats.add_argument(
        "--missing-ovals",
        default=False,
        action="store_true",
        dest="missing_ovals",
        help="Show IDs of unimplemented OVAL checks.",
    )
    parser_stats.add_argument(
        "--missing-sces",
        default=False,
        action="store_true",
        dest="missing_sces",
        help="Show IDs of unimplemented SCE checks.",
    )
    parser_stats.add_argument(
        "--implemented-fixes",
        default=False,
        action="store_true",
        dest="implemented_fixes",
        help="Show IDs of implemented remediations.",
    )
    parser_stats.add_argument(
        "--missing-fixes",
        default=False,
        action="store_true",
        dest="missing_fixes",
        help="Show IDs of unimplemented remediations.",
    )
    parser_stats.add_argument(
        "--assigned-cces",
        default=False,
        action="store_true",
        dest="assigned_cces",
        help="Show IDs of rules having CCE assigned.",
    )
    parser_stats.add_argument(
        "--missing-cces",
        default=False,
        action="store_true",
        dest="missing_cces",
        help="Show IDs of rules missing CCE element.",
    )
    parser_stats.add_argument(
        "--implemented",
        default=False,
        action="store_true",
        help="Equivalent of --implemented-ovals, --implemented_fixes and --assigned-cves "
        "all being set.",
    )
    parser_stats.add_argument(
        "--missing",
        default=False,
        action="store_true",
        help="Equivalent of --missing-ovals, --missing-fixes and --missing-cces all being set.",
    )
    parser_stats.add_argument(
        "--ansible-parity",
        action="store_true",
        help="Show IDs of rules with Bash fix which miss Ansible fix."
        " Rules missing both Bash and Ansible are not shown.",
    )
    parser_stats.add_argument(
        "--all",
        default=False,
        action="store_true",
        dest="all",
        help="Show all available statistics.",
    )
    parser_stats.add_argument(
        "--product",
        action="store",
        dest="product",
        help="Product directory to evaluate XCCDF under (e.g., ~/scap-security-guide/rhel8)",
    )
    parser_stats.add_argument(
        "--skip-stats",
        default=False,
        action="store_true",
        dest="skip_overall_stats",
        help="Do not show overall statistics.",
    )
    parser_stats.add_argument(
        "--format",
        default="plain",
        choices=["plain", "json", "csv", "html"],
        help="Which format to use for output.",
    )
    parser_stats.add_argument(
        "--output", help="If defined, statistics will be stored under this directory."
    )


def parse_sub_subcommand(subparsers):
    parser_sub = subparsers.add_parser(
        "sub",
        description=(
            "Subtract rules and variable selections from profile1 based on rules present in "
            "profile2. As a result, a new profile is generated. It doesn't support profile "
            "inheritance, this means that only rules explicitly "
            "listed in the profiles will be taken in account."
        ),
        help=(
            "Subtract rules and variables from profile1 "
            "based on selections present in profile2."
        ),
    )
    parser_sub.add_argument(
        "--build-config-yaml",
        required=True,
        help="YAML file with information about the build configuration. "
        "e.g.: ~/scap-security-guide/build/build_config.yml "
        "needed for autodetection of profile root",
    )
    parser_sub.add_argument(
        "--ssg-root",
        required=True,
        help="Directory containing the source tree. e.g. ~/scap-security-guide/",
    )
    parser_sub.add_argument(
        "--product",
        required=True,
        help="ID of the product for which we are building Playbooks. e.g.: 'fedora'",
    )
    parser_sub.add_argument(
        "--profile1", type=str, dest="profile1", required=True, help="YAML profile"
    )
    parser_sub.add_argument(
        "--profile2", type=str, dest="profile2", required=True, help="YAML profile"
    )


def parse_args():
    parser = argparse.ArgumentParser(description="Profile statistics and utilities tool")
    subparsers = parser.add_subparsers(title="subcommands", dest="subcommand", required=True)
    parse_stats_subcommand(subparsers)
    parse_sub_subcommand(subparsers)

    args = parser.parse_args()

    if args.subcommand == "stats":
        if args.all:
            args.implemented = True
            args.missing = True
            args.ansible_parity = True

        if args.implemented:
            args.implemented_ovals = True
            args.implemented_fixes = True
            args.assigned_cces = True

        if args.missing:
            args.missing_ovals = True
            args.missing_sces = True
            args.missing_fixes = True
            args.missing_cces = True
            args.missing_stig_ids = True
            args.missing_cis_refs = True
            args.missing_hipaa_refs = True
            args.missing_anssi_refs = True
            args.missing_ospp_refs = True
            args.missing_cui_refs = True

    return args


SUBCMDS = dict(stats=command_stats, sub=command_sub)


def main():
    args = parse_args()
    SUBCMDS[args.subcommand](args)


if __name__ == "__main__":
    main()
