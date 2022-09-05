#!/usr/bin/python3

import argparse
import sys

from ssg.content_diff import StandardContentDiffer, StigContentDiffer
from ssg.xml import XMLContent
import xml.etree.ElementTree as ET


def parse_args():
    parser = argparse.ArgumentParser(
        description="Compares two datastreams with regards to presence of"
        "OVAL checks and all remediations")
    parser.add_argument(
        "old", metavar="OLD_DS_PATH",
        help="Path to the old datastream")
    parser.add_argument(
        "new", metavar="NEW_DS_PATH",
        help="Path to the new datastream")
    parser.add_argument(
        "--rule", metavar="RULE_ID",
        help="Compare only the rule specified by given RULE_ID"
    )
    parser.add_argument(
        "--no-diffs", action="store_true",
        help="Do not perform detailed comparison of checks and "
        "remediations contents."
    )
    parser.add_argument(
        "--only-rules", action="store_true",
        help="Print only removals from rule set."
    )
    parser.add_argument(
        "--rule-diffs", action="store_true",
        help="Output diffs per rule, instead of a single diff. "
             "The rule diffs are output to directory './compare_ds-diffs/'."
    )
    parser.add_argument(
        "--output-dir", metavar="OUTPUT_DIR",
        type=str, action="store", default="./compare_ds-diffs",
        help="Directory where rule diff files will be saved. Only used with --rule-diffs option. "
             "If the directory doesn't exist, it will be created."
    )
    parser.add_argument(
        "--disa-content", action="store_true",
        help="This option enables comparison between DISA contents by ignoring the release "
             "number in rule IDs."
    )
    return parser.parse_args()


def main():
    args = parse_args()
    old_tree = ET.parse(args.old)
    new_tree = ET.parse(args.new)
    old_root = old_tree.getroot()
    new_root = new_tree.getroot()

    old_xml_content = XMLContent(old_root)
    new_xml_content = XMLContent(new_root)

    if args.disa_content:
        content_differ = StigContentDiffer(old_xml_content, new_xml_content, args.rule,
                                           not args.no_diffs, args.rule_diffs,
                                           args.only_rules, args.output_dir)
    else:
        content_differ = StandardContentDiffer(old_xml_content, new_xml_content, args.rule,
                                               not args.no_diffs, args.rule_diffs,
                                               args.only_rules, args.output_dir)

    for old_benchmark in old_xml_content.get_benchmarks():
        old_benchmark_id = old_benchmark.get_attr("id")
        new_benchmark = new_xml_content.find_benchmark(old_benchmark_id)
        if not new_benchmark:
            print(
                "Warning: Skipping comparison of the following benchmark "
                "because it was not found in the new datastream: {}".format(old_benchmark_id))
            continue

        content_differ.compare_rules(old_benchmark, new_benchmark)
    return 0


if __name__ == "__main__":
    sys.exit(main())
