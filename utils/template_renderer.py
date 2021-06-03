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


"""
Loader that extends the AbsolutePathFileSystemLoader so it accepts
relative paths of templates if those are located in selected directories.

This is intended to be used when templates reference other templates.
"""
class FlexibleLoader(ssg.jinja.AbsolutePathFileSystemLoader):
    def __init__(self, lookup_dirs=None, ** kwargs):
        super().__init__(** kwargs)
        self.lookup_dirs = []
        if lookup_dirs:
            if isinstance(lookup_dirs, str):
                self.lookup_dirs = [lookup_dirs]
            else:
                self.lookup_dirs = list(lookup_dirs)

    def _find_absolute_path(self, path):
        if os.path.isabs(path):
            return path
        for directory in self.lookup_dirs:
            potential_location = pathlib.Path(directory / path)
            if potential_location.exists():
                return str(potential_location.absolute())
        return path

    def get_source(self, environment, template):
        template = self._find_absolute_path(template)
        return super().get_source(environment, template)


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
        env_yaml = ssg.environment.open_environment(build_config_yaml, product_yaml)
        return env_yaml

    def _set_rule_relative_definition_location(self, rule):
        rule.relative_definition_location = (
            pathlib.PurePath(rule.definition_location)
            .relative_to(self.project_directory))

    def get_result(self):
        subst_dict = self.template_data.copy()
        subst_dict.update(self.env_yaml)
        html_jinja_template = os.path.join(os.path.dirname(__file__), self.TEMPLATE_NAME)
        ssg.jinja._get_jinja_environment.env.loader = FlexibleLoader([self.project_directory / "utils"])
        return ssg.jinja.process_file(html_jinja_template, subst_dict)

    def output_results(self, args):
        if "title" not in self.template_data:
            self.template_data["title"] = args.title
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
        parser.add_argument("--title", "-t", default="", help="Title of the document")
        parser.add_argument("--output", help="The filename to generate")
        return parser
