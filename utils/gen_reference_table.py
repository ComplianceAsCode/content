#!/usr/bin/python3

import os
import re
import glob

import ssg.build_yaml
import ssg.constants

import tables.table_renderer


class HtmlOutput(tables.table_renderer.TableHtmlOutput):
    TEMPLATE_NAME = "tables/reference_tables_template.html"

    def __init__(self, * args, ** kwargs):
        super(HtmlOutput, self).__init__(* args, ** kwargs)
        self.cached_rules = []

    def _fix_var_sub_in_text(self, text, varname, value):
        return re.sub(
            r'<sub\s+idref="{var}"\s*/>'.format(var=varname),
            r'<abbr title="${var}"><tt>{val}</tt></abbr>'.format(var=varname, val=value), text)

    def _get_eligible_rules(self, refcat):
        filenames = glob.glob(os.path.join(self.rules_root, "*.yml"))
        if self.cached_rules:
            all_rules = self.cached_rules
        else:
            all_rules = [ssg.build_yaml.Rule.from_yaml(f, self.env_yaml) for f in filenames]
            self.cached_rules = all_rules

        rules = []
        for rule in all_rules:
            if refcat in rule.references:
                rules.append(rule)
        return rules

    def process_rules(self, ref_format, reference_id, reference_title):
        super(HtmlOutput, self).process_rules(ref_format, reference_id, reference_title)

        self.template_data["title"] = (
            "{product} rules by {refcat} references"
            .format(product=self.product, refcat=reference_title)
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
    reference = ssg.constants.REFERENCES[args.refcategory]
    renderer.process_rules(reference.regex_with_groups, reference.id, reference.title)
    renderer.output_results(args)
