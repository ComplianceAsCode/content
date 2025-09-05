#!/usr/bin/python3

from glob import glob
import collections
import os
import pathlib

import argparse

import ssg.build_yaml
import ssg.controls
import ssg.environment
import ssg.jinja
import template_renderer


class HtmlOutput(template_renderer.Renderer):
    TEMPLATE_NAME = "rendering/controls-template.html"

    def set_all_rules_with_metadata(self):
        compiled_rules = os.path.join(self.built_content_path, 'rules')
        rule_files = glob("{compiled_rules}/*".format(compiled_rules=compiled_rules))
        if not rule_files:
            msg = (
                "No files found in '{compiled_rules}', please make sure that "
                "you select the build dir correctly and that the appropriate product is built."
                .format(compiled_rules=compiled_rules)
            )
            raise ValueError(msg)

        rules_dict = dict()
        for r_file in rule_files:
            rule = ssg.build_yaml.Rule.from_yaml(r_file, self.env_yaml)
            self._set_rule_relative_definition_location(rule)
            rules_dict[rule.id_] = rule
        self.template_data["rules"] = rules_dict

    def set_policy(self, policy_file):
        policy = ssg.controls.Policy(policy_file, self.env_yaml, )
        policy.load()
        self.template_data["policy"] = policy
        self.template_data["title"] = (
            "Definition of {policy_title} for {product}"
            .format(policy_title=policy.title, product=self.product)
        )


def parse_args():
    parser = HtmlOutput.create_parser(
        description="Render a policy file typically located in 'controls' directory "
        "of the project to HTML in a context of a product. "
        "The product must be built.")
    parser.add_argument(
        "policy", metavar="FILENAME", help="The policy YAML file")
    return parser.parse_args()


if __name__ == "__main__":
    args = parse_args()
    renderer = HtmlOutput(args.product, args.build_dir)
    renderer.set_all_rules_with_metadata()
    renderer.set_policy(args.policy)
    renderer.output_results(args)
