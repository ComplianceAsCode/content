from __future__ import absolute_import
from __future__ import print_function

import os
import sys
import imp
import glob

import ssg.build_yaml
import ssg.utils
import ssg.yaml

try:
    from urllib.parse import quote
except ImportError:
    from urllib import quote

languages = ["anaconda", "ansible", "bash", "oval", "puppet", "ignition", "kubernetes"]
preprocessing_file_name = "template.py"
lang_to_ext_map = {
    "anaconda": ".anaconda",
    "ansible": ".yml",
    "bash": ".sh",
    "oval": ".xml",
    "puppet": ".pp",
    "ignition": ".yml",
    "kubernetes": ".yml"
}


templates = dict()


class Template():
    def __init__(self, template_root_directory, name):
        self.template_root_directory = template_root_directory
        self.name = name
        self.template_path = os.path.join(self.template_root_directory, self.name)
        self.template_yaml_path = os.path.join(self.template_path, "template.yml")
        self.preprocessing_file_path = os.path.join(self.template_path, preprocessing_file_name)

    def load(self):
        if not os.path.exists(self.preprocessing_file_path):
            self.preprocessing_file_path = None
        self.langs = []
        template_yaml = ssg.yaml.open_raw(self.template_yaml_path)
        for lang in template_yaml["supported_languages"]:
            if lang not in languages:
                raise ValueError("The template {0} declares to support the {1} language,"
                "but this language is not supported by the content.".format(self.name, lang))
            langfilename = lang + ".template"
            if not os.path.exists(os.path.join(self.template_path, langfilename)):
                raise ValueError("The template {0} declares to support the {1} language,"
                "but the implementation file is missing.".format(self.name, lang))
            self.langs.append(lang)

    def preprocess(self, parameters, lang):
        # if no template.py file exists, skip this preprocessing part
        if self.preprocessing_file_path is not None:
            unique_dummy_module_name = "template_" + self.name
            preprocess_mod = imp.load_source(
                unique_dummy_module_name, self.preprocessing_file_path)
            if not hasattr(preprocess_mod, "preprocess"):
                msg = (
                    "The '{name}' template's preprocessing file {preprocessing_file} "
                    "doesn't define the 'preprocess' function, which is probably an omission."
                    .format(name=self.name, preprocessing_file=self.preprocessing_file_path)
                )
                raise ValueError(msg)
            parameters = preprocess_mod.preprocess(parameters.copy(), lang)
        # TODO: Remove this right after the variables in templates are renamed
        # to lowercase
        uppercases = dict()
        for k, v in parameters.items():
            uppercases[k.upper()] = v
        return uppercases

    def looks_like_template(self):
        if not os.path.isdir(self.template_root_directory):
            return False
        if os.path.islink(self.template_root_directory):
            return False
        template_sources = glob.glob(os.path.join(self.template_path, "*.template"))
        if not os.path.isfile(self.template_yaml_path) and not template_sources:
            return False
        return True


class Builder(object):
    """
    Class for building all templated content for a given product.

    To generate content from templates, pass the env_yaml, path to the
    directory with resolved rule YAMLs, path to the directory that contains
    templates, path to the output directory for checks and a path to the
    output directory for remediations into the constructor. Then, call the
    method build() to perform a build.
    """
    def __init__(
            self, env_yaml, resolved_rules_dir, templates_dir,
            remediations_dir, checks_dir):
        self.env_yaml = env_yaml
        self.resolved_rules_dir = resolved_rules_dir
        self.templates_dir = templates_dir
        self.remediations_dir = remediations_dir
        self.checks_dir = checks_dir
        self.output_dirs = dict()
        for lang in languages:
            if lang == "oval":
                # OVAL checks need to be put to a different directory because
                # they are processed differently than remediations later in the
                # build process
                output_dir = self.checks_dir
            else:
                output_dir = self.remediations_dir
            dir_ = os.path.join(output_dir, lang)
            self.output_dirs[lang] = dir_
        # scan directory structure and dynamically create list of templates
        for item in os.listdir(self.templates_dir):
            itempath = os.path.join(self.templates_dir, item)
            maybe_template = Template(templates_dir, item)
            if maybe_template.looks_like_template():
                maybe_template.load()
                templates[item] = maybe_template


    def build_lang(
            self, rule_id, template_name, template_vars, lang, local_env_yaml):
        """
        Builds templated content for a given rule for a given language.
        Writes the output to the correct build directories.
        """
        if lang not in templates[template_name].langs:
            return
        template_file_name = lang + ".template"
        template_file_path = os.path.join(self.templates_dir, template_name, template_file_name)
        ext = lang_to_ext_map[lang]
        output_file_name = rule_id + ext
        output_filepath = os.path.join(
            self.output_dirs[lang], output_file_name)
        template_parameters = templates[template_name].preprocess(template_vars, lang)
        jinja_dict = ssg.utils.merge_dicts(local_env_yaml, template_parameters)
        filled_template = ssg.jinja.process_file_with_macros(
            template_file_path, jinja_dict)
        with open(output_filepath, "w") as f:
            f.write(filled_template)

    def get_langs_to_generate(self, rule):
        """
        For a given rule returns list of languages that should be generated
        from templates. This is controlled by "template_backends" in rule.yml.
        """
        if "backends" in rule.template:
            backends = rule.template["backends"]
            for lang in backends:
                if lang not in languages:
                    raise RuntimeError(
                        "Rule {0} wants to generate unknown language '{1}"
                        "from a template.".format(rule.id_, lang)
                    )
            langs_to_generate = []
            for lang in languages:
                backend = backends.get(lang, "on")
                if backend == "on":
                    langs_to_generate.append(lang)
            return langs_to_generate
        else:
            return languages

    def build_rule(self, rule_id, rule_title, template, langs_to_generate):
        """
        Builds templated content for a given rule for selected languages,
        writing the output to the correct build directories.
        """
        try:
            template_name = template["name"]
        except KeyError:
            raise ValueError(
                "Rule {0} is missing template name under template key".format(
                    rule_id))
        if template_name not in templates.keys():
            raise ValueError(
                "Rule {0} uses template {1} which does not exist.".format(
                    rule_id, template_name))
        try:
            template_vars = template["vars"]
        except KeyError:
            raise ValueError(
                "Rule {0} does not contain mandatory 'vars:' key under "
                "'template:' key.".format(rule_id))
        # Add the rule ID which will be reused in OVAL templates as OVAL
        # definition ID so that the build system matches the generated
        # check with the rule.
        template_vars["_rule_id"] = rule_id
        # checks and remediations are processed with a custom YAML dict
        local_env_yaml = self.env_yaml.copy()
        local_env_yaml["rule_id"] = rule_id
        local_env_yaml["rule_title"] = rule_title
        local_env_yaml["products"] = self.env_yaml["product"]
        for lang in langs_to_generate:
            self.build_lang(
                rule_id, template_name, template_vars, lang, local_env_yaml)

    def build_extra_ovals(self):
        declaration_path = os.path.join(self.templates_dir, "extra_ovals.yml")
        declaration = ssg.yaml.open_raw(declaration_path)
        for oval_def_id, template in declaration.items():
            langs_to_generate = ["oval"]
            # Since OVAL definition ID in shorthand format is always the same
            # as rule ID, we can use it instead of the rule ID even if no rule
            # with that ID exists
            self.build_rule(
                oval_def_id, oval_def_id, template, langs_to_generate)

    def build_all_rules(self):
        for rule_file in os.listdir(self.resolved_rules_dir):
            rule_path = os.path.join(self.resolved_rules_dir, rule_file)
            try:
                rule = ssg.build_yaml.Rule.from_yaml(rule_path, self.env_yaml)
            except ssg.build_yaml.DocumentationNotComplete:
                # Happens on non-debug build when a rule is "documentation-incomplete"
                continue
            if rule.template is None:
                # rule is not templated, skipping
                continue
            langs_to_generate = self.get_langs_to_generate(rule)
            self.build_rule(
                rule.id_, rule.title, rule.template, langs_to_generate)

    def build(self):
        """
        Builds all templated content for all languages, writing
        the output to the correct build directories.
        """

        for dir_ in self.output_dirs.values():
            if not os.path.exists(dir_):
                os.makedirs(dir_)

        self.build_extra_ovals()
        self.build_all_rules()
