#!/usr/bin/python3

import os
import re

import argparse

import ssg.build_yaml
import ssg.controls
import ssg.environment
import ssg.jinja


def get_var_value(var_dir, varname, profile=None):
    var_path = os.path.join(var_dir, varname + ".json")
    var = ssg.build_yaml.Value.from_compiled_json(var_path)
    if profile is None:
        return var.options["default"]
    for s in profile.selections:
        if s.startswith(varname + "="):
            selector = s.split("=")[1]
            return var.options[selector]


def fix_var_sub_in_text(text, varname, value):
    if text is None:
        return None
    return re.sub(
        r'<sub\s+idref="{var}"\s*/>'.format(var=varname),
        r"<tt>{val}</tt>".format(val=value), text)


def resolve_var_substitutions(var_dir, rule, profile=None):
    variables = set(re.findall(r'<sub\s+idref="([^"]*)"\s*/>', rule.description))
    for var in variables:
        val = get_var_value(var_dir, var, profile)
        rule.description = fix_var_sub_in_text(rule.description, var, val)
        rule.ocil = fix_var_sub_in_text(rule.ocil, var, val)
        rule.ocil_clause = fix_var_sub_in_text(rule.ocil_clause, var, val)
    return rule


def render_template(data, template_path, output_filename):
    loader = FlexibleLoader(os.path.dirname(template_path))
    return ssg.jinja.render_template(
        data, template_path, output_filename, loader)


"""
Loader that extends the AbsolutePathFileSystemLoader so it accepts
relative paths of templates if those are located in selected directories.

This is intended to be used when templates reference other templates.
"""
class FlexibleLoader(ssg.jinja.AbsolutePathFileSystemLoader):
    def __init__(self, lookup_dirs=None, ** kwargs):
        super(FlexibleLoader, self).__init__(** kwargs)
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
            potential_location = os.path.join(directory, path)
            if os.path.exists(potential_location):
                return str(os.path.abspath(potential_location))
        return path

    def get_source(self, environment, template):
        template = self._find_absolute_path(template)
        return super(FlexibleLoader, self).get_source(environment, template)


class Renderer(object):
    TEMPLATE_NAME = ""

    def __init__(self, product, build_dir, verbose=False):
        self.project_directory = os.path.abspath(os.path.dirname(os.path.dirname(__file__)))

        self.product = product
        self.env_yaml = self.get_env_yaml(build_dir)

        self.built_content_path = (
            "{build_dir}/{product}".format(build_dir=build_dir, product=product))

        self.template_data = dict()
        self.verbose = verbose

    def get_env_yaml(self, build_dir):
        product_yaml = os.path.join(build_dir, self.product, "product.yml")
        build_config_yaml = os.path.join(build_dir, "build_config.yml")
        if not (os.path.exists(product_yaml) and os.path.exists(build_config_yaml)):
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
        rule.relative_definition_location = rule.definition_location.replace(
            self.project_directory, "")

    def _get_template_basedir(self):
        if not self.TEMPLATE_NAME:
            return None
        path_components = os.path.split(self.TEMPLATE_NAME)
        if len(path_components) == 1:
            return None
        return os.path.join(* path_components[:-1])

    def get_result(self):
        subst_dict = self.template_data.copy()
        subst_dict.update(self.env_yaml)
        html_jinja_template = os.path.join(os.path.dirname(__file__), self.TEMPLATE_NAME)
        lookup_dirs = [os.path.join(self.project_directory, "utils")]

        template_basedir = self._get_template_basedir()
        if template_basedir:
            abs_basedir = os.path.join(lookup_dirs[0], template_basedir)
            lookup_dirs.append(abs_basedir)

        env = ssg.jinja._get_jinja_environment({})
        env.loader = FlexibleLoader(lookup_dirs)
        return ssg.jinja.process_file(html_jinja_template, subst_dict)

    def output_results(self, args):
        if "title" not in self.template_data:
            self.template_data["title"] = args.title
        result = self.get_result()
        if not args.output:
            print(result)
        else:
            dir = os.path.dirname(args.output)
            if not os.path.exists(dir):
                os.makedirs(dir)
            with open(args.output, "wb") as outfile:
                result_for_output = result.encode('utf8', 'replace')
                outfile.write(result_for_output)

    @staticmethod
    def create_parser(description):
        parser = argparse.ArgumentParser(description=description)
        parser.add_argument(
            "product", help="The product to be built")
        parser.add_argument("--build-dir", default="build", help="Path to the build directory")
        parser.add_argument("--title", "-t", default="", help="Title of the document")
        parser.add_argument("--output", help="The filename to generate")
        parser.add_argument("--verbose", action="store_true", default=False)
        return parser
