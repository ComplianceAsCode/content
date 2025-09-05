#!/usr/bin/python3

from glob import glob
import collections
import os
import pathlib

import argparse

import ssg.build_yaml
import ssg.controls
import ssg.yaml
import ssg.jinja


class HtmlOutput(object):
    def __init__(self, product, build_dir, policy_file):
        self.project_directory = pathlib.Path(os.path.dirname(__file__)).parent.resolve()

        self.env_yaml = self.get_env_yaml(product, build_dir)

        policy = ssg.controls.Policy(policy_file, self.env_yaml)
        policy.load()
        self.policy = policy

        self.product = product
        self.rules_dict = self.get_rules_with_metadata(product, build_dir)

    def get_rules_with_metadata(self, product, build_dir):
        compiled_rules = "{build_dir}/{product}/rules".format(build_dir=build_dir, product=product)
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
            rule.relative_definition_location = (
                pathlib.PurePath(rule.definition_location)
                .relative_to(self.project_directory))
            rules_dict[rule.id_] = rule
        return rules_dict

    def get_env_yaml(self, product, build_dir):
        product_yaml = self.project_directory / product / "product.yml"
        build_config_yaml = pathlib.Path(build_dir) / "build_config.yml"
        if not (product_yaml.exists() and build_config_yaml.exists()):
            msg = (
                "No product yaml and/or build config found in "
                "'{product_yaml}' and/or '{build_config_yaml}', respectively, please make sure "
                "that you got the product right, and that it is built."
                .format(product_yaml=product_yaml, build_config_yaml=build_config_yaml)
            )
            raise ValueError(msg)
        env_yaml = ssg.yaml.open_environment(build_config_yaml, product_yaml)
        return env_yaml

    def get_result(self):
        subst_dict = dict(rules=self.rules_dict, product=self.product, policy=self.policy)
        subst_dict.update(self.env_yaml)
        html_jinja_template = os.path.join(os.path.dirname(__file__), "controls-template.html")
        return ssg.jinja.process_file(html_jinja_template, subst_dict)


def parse_args():
    parser = argparse.ArgumentParser(
        description="Render a policy file typically located in 'controls' directory "
        "of the project to HTML in a context of a product. "
        "The product must be built.")
    parser.add_argument(
        "policy", metavar="FILENAME", help="The policy YAML file")
    parser.add_argument(
        "product", metavar="PRODTYPE",
        help="Product that provides context to the policy. It must already be built")
    parser.add_argument("--build-dir", default="build", help="Path to the build directory")
    parser.add_argument("--output", help="The filename to generate")
    return parser.parse_args()


if __name__ == "__main__":
    args = parse_args()
    result = HtmlOutput(args.product, args.build_dir, args.policy).get_result()
    if not args.output:
        print(result)
    else:
        with open(args.output, "w") as outfile:
            outfile.write(result)
