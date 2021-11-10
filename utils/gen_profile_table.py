#!/usr/bin/python3

import os
import sys

import argparse

import ssg.build_yaml

import tables.table_renderer


class HtmlOutput(tables.table_renderer.TableHtmlOutput):
    TEMPLATE_NAME = "tables/profile_tables_template.html"

    def __init__(self, * args, ** kwargs):
        profile_id = kwargs.pop("profile_id")
        super(HtmlOutput, self).__init__(* args, ** kwargs)

        profile_path = str(self.built_content_path / "profiles" / (profile_id + ".profile"))
        self.profile = ssg.build_yaml.Profile.from_yaml(profile_path, self.env_yaml)
        self.profile_variables = self.profile.variables

    def _get_var_value(self, varname):
        try:
            return self.profile_variables[varname]
        except KeyError:
            return super(HtmlOutput, self)._get_var_value(varname)

    def _get_eligible_rules(self, refcat):
        eligible_rule_ids = self.profile.selected
        filenames = [os.path.join(self.rules_root, rid + ".yml") for rid in eligible_rule_ids]
        return [ssg.build_yaml.Rule.from_yaml(f, self.env_yaml) for f in filenames]

    def _generate_shortened_ref(self, ref_format, rule):
        shortened_ref = super(HtmlOutput, self)._generate_shortened_ref(ref_format, rule)
        if shortened_ref == self.DEFAULT_SHORTENED_REF:
            print("Rule '{rid}' is included in the profile {profile_id}, "
                  "but doesn't contain the corresponding reference"
                  .format(rid=rule.id_, profile_id=self.profile.id_), file=sys.stderr)
        return shortened_ref

    def process_rules(self, ref_format, reference_id, reference_title):
        super(HtmlOutput, self).process_rules(ref_format, reference_id, reference_title)

        self.template_data["profile"] = self.profile


def update_parser(parser):
    parser.add_argument(
        "profile", metavar="PROFILE_ID", help="The ID of the profile")


def parse_args():
    parser = HtmlOutput.create_parser(
        "and with links to the upstream rule source.")
    tables.table_renderer.update_parser(parser)
    update_parser(parser)
    return parser.parse_args()


if __name__ == "__main__":
    args = parse_args()
    renderer = HtmlOutput(args.product, args.build_dir, profile_id=args.profile)
    reference = ssg.constants.REFERENCES[args.refcategory]
    renderer.process_rules(reference.regex_with_groups, reference.id, reference.title)
    renderer.output_results(args)
