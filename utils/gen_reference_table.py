#!/usr/bin/python3

import collections
import os
import sys
import re
import pathlib
import glob

import argparse

import ssg.build_yaml
import ssg.controls
import ssg.yaml
import ssg.jinja

import template_renderer
import tables.table_renderer


class HtmlOutput(tables.table_renderer.TableHtmlOutput):
    TEMPLATE_NAME = "tables/reference_tables_template.html"

    def _fix_var_sub_in_text(self, text, varname, value):
        return re.sub(
            r'<sub\s+idref="{var}"\s*/>'.format(var=varname),
            r'<abbr title="${var}"><tt>{val}</tt></abbr>'.format(var=varname, val=value), text)

    def _get_eligible_rules(self, refcat):
        filenames = glob.glob(os.path.join(self.rules_root, "*.yml"))
        rules = []
        for fname in filenames:
            rule = ssg.build_yaml.Rule.from_yaml(fname, self.env_yaml)
            if refcat in rule.references:
                rules.append(rule)
        return rules

    def process_rules(self, ref_format, reference_category=""):
        super(HtmlOutput, self).process_rules(ref_format, reference_category)

        self.template_data["title"] = (
            "{product} rules by {refcat} references"
            .format(product=self.product, refcat=reference_category)
        )


def update_parser(parser):
    pass


def parse_args():
    parser = HtmlOutput.create_parser(
        "and with links to the upstream rule source.")
    tables.table_renderer.update_parser(parser)
    update_parser(parser)
    return parser.parse_args()


if __name__ == "__main__":
    args = parse_args()
    renderer = HtmlOutput(args.product, args.build_dir)
    renderer.process_rules(args.ref_format, args.refcategory)
    renderer.output_results(args)
