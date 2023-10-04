#!/usr/bin/python3

import argparse

import ssg.constants

from utils import gen_reference_table


def update_parser(parser):
    parser.add_argument("--build-dir", default="build", help="Path to the build directory")
    parser.add_argument(
        "product", help="The product to be built")
    parser.add_argument(
        "output_template", help="Template of the filename to generate. "
        "Occurrence of '{ref_id}' will be substituted by the respective reference ID "
        "that the generated table describes.")
    parser.add_argument(
        "refcategory", metavar="REFERENCE_ID", nargs="+",
        help="Category of the rule reference")


def parse_args():
    parser = argparse.ArgumentParser(
        description="Render multiple reference tables at once "
        "using the gen_reference_table script functionality")
    update_parser(parser)
    return parser.parse_args()


if __name__ == "__main__":
    args = parse_args()
    renderer = gen_reference_table.HtmlOutput(args.product, args.build_dir)
    for reference in args.refcategory:
        reference = ssg.constants.REFERENCES[reference]

        renderer.process_rules(reference)
        result = renderer.get_result()
        output = args.output_template.format(ref_id=reference.id)
        with open(output, "wb") as outfile:
            result_for_output = result.encode('utf8', 'replace')
            outfile.write(result_for_output)
