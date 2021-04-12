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


class Renderer(object):
    TEMPLATE_NAME = ""

    def __init__(self, product, build_dir):
        self.project_directory = pathlib.Path(os.path.dirname(__file__)).parent.resolve()

        self.product = product
        self.env_yaml = self.get_env_yaml(build_dir)

        self.built_content_path = pathlib.Path(
            "{build_dir}/{product}".format(build_dir=build_dir, product=product))

        self.template_data = dict()

    def get_env_yaml(self, build_dir):
        product_yaml = self.project_directory / self.product / "product.yml"
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

    def _set_rule_relative_definition_location(self, rule):
        rule.relative_definition_location = (
            pathlib.PurePath(rule.definition_location)
            .relative_to(self.project_directory))

    def get_result(self):
        subst_dict = self.template_data.copy()
        subst_dict.update(self.env_yaml)
        html_jinja_template = os.path.join(os.path.dirname(__file__), self.TEMPLATE_NAME)
        return ssg.jinja.process_file(html_jinja_template, subst_dict)

    def output_results(self, args):
        result = self.get_result()
        if not args.output:
            print(result)
        else:
            with open(args.output, "w") as outfile:
                outfile.write(result)

    @staticmethod
    def create_parser(description):
        parser = argparse.ArgumentParser(description=description)
        parser.add_argument(
            "product", help="The product to be built")
        parser.add_argument("--build-dir", default="build", help="Path to the build directory")
        parser.add_argument("--output", help="The filename to generate")
        return parser
