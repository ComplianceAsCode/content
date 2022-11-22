from __future__ import absolute_import
from __future__ import print_function

import os
import imp
import glob

import ssg.build_yaml
import ssg.utils
import ssg.yaml
import ssg.jinja
from ssg.build_cpe import ProductCPEs
from collections import namedtuple

templating_lang = namedtuple(
    "templating_language_attributes",
    ["name", "file_extension", "template_type", "lang_specific_dir"])

template_type = ssg.utils.enum("remediation", "check")

languages = {
    "anaconda": templating_lang("anaconda", ".anaconda", template_type.remediation, "anaconda"),
    "ansible": templating_lang("ansible", ".yml", template_type.remediation, "ansible"),
    "bash": templating_lang("bash", ".sh", template_type.remediation, "bash"),
    "blueprint": templating_lang("blueprint", ".toml", template_type.remediation, "blueprint"),
    "ignition": templating_lang("ignition", ".yml", template_type.remediation, "ignition"),
    "kubernetes": templating_lang("kubernetes", ".yml", template_type.remediation, "kubernetes"),
    "oval": templating_lang("oval", ".xml", template_type.check, "oval"),
    "puppet": templating_lang("puppet", ".pp", template_type.remediation, "puppet"),
    "sce-bash": templating_lang("sce-bash", ".sh", template_type.remediation, "sce")
}

PREPROCESSING_FILE_NAME = "template.py"
TEMPLATE_YAML_FILE_NAME = "template.yml"


class Template:
    def __init__(self, templates_root_directory, name):
        self.langs = []
        self.templates_root_directory = templates_root_directory
        self.name = name
        self.template_path = os.path.join(self.templates_root_directory, self.name)
        self.template_yaml_path = os.path.join(self.template_path, TEMPLATE_YAML_FILE_NAME)
        self.preprocessing_file_path = os.path.join(self.template_path, PREPROCESSING_FILE_NAME)

    @classmethod
    def load_template(cls, template_root_directory, name):
        maybe_template = cls(template_root_directory, name)
        if maybe_template._looks_like_template():
            maybe_template._load()
            return maybe_template
        return None

    def _load(self):
        if not os.path.exists(self.preprocessing_file_path):
            self.preprocessing_file_path = None

        template_yaml = ssg.yaml.open_raw(self.template_yaml_path)
        for supported_lang in template_yaml["supported_languages"]:
            if supported_lang not in languages.keys():
                raise ValueError(
                    "The template {0} declares to support the {1} language,"
                    "but this language is not supported by the content.".format(
                        self.name, supported_lang))
            lang = languages[supported_lang]
            langfilename = lang.name + ".template"
            if not os.path.exists(os.path.join(self.template_path, langfilename)):
                raise ValueError(
                    "The template {0} declares to support the {1} language,"
                    "but the implementation file is missing.".format(self.name, lang))
            self.langs.append(lang)

    def preprocess(self, parameters, lang):
        parameters = self._preprocess_with_template_module(parameters, lang)
        # TODO: Remove this right after the variables in templates are renamed to lowercase
        parameters = {k.upper(): v for k, v in parameters.items()}
        return parameters

    def _preprocess_with_template_module(self, parameters, lang):
        if self.preprocessing_file_path is not None:
            unique_dummy_module_name = "template_" + self.name
            preprocess_mod = imp.load_source(unique_dummy_module_name, self.preprocessing_file_path)
            if not hasattr(preprocess_mod, "preprocess"):
                msg = (
                    "The '{name}' template's preprocessing file {preprocessing_file} "
                    "doesn't define the 'preprocess' function, which is probably an omission."
                    .format(name=self.name, preprocessing_file=self.preprocessing_file_path)
                )
                raise ValueError(msg)
            parameters = preprocess_mod.preprocess(parameters.copy(), lang)
        return parameters

    def _looks_like_template(self):
        if not os.path.isdir(self.template_path):
            return False
        if os.path.islink(self.template_path):
            return False
        template_sources = sorted(glob.glob(os.path.join(self.template_path, "*.template")))
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
    def __init__(self, env_yaml, resolved_rules_dir, templates_dir,
                 remediations_dir, checks_dir, platforms_dir, cpe_items_dir):
        self.env_yaml = env_yaml
        self.resolved_rules_dir = resolved_rules_dir
        self.templates_dir = templates_dir
        self.remediations_dir = remediations_dir
        self.checks_dir = checks_dir
        self.platforms_dir = platforms_dir
        self.cpe_items_dir = cpe_items_dir
        self.output_dirs = dict()
        self.templates = dict()
        self._init_lang_output_dirs()
        self._init_and_load_templates()
        self.product_cpes = ProductCPEs()
        self.product_cpes.load_cpes_from_directory_tree(cpe_items_dir, self.env_yaml)

    def _init_and_load_templates(self):
        for item in sorted(os.listdir(self.templates_dir)):
            maybe_template = Template.load_template(self.templates_dir, item)
            if maybe_template is not None:
                self.templates[item] = maybe_template

    def _init_lang_output_dirs(self):
        for lang_name, lang in languages.items():
            lang_dir = lang.lang_specific_dir
            if lang.template_type == template_type.check:
                output_dir = self.checks_dir
            else:
                output_dir = self.remediations_dir
            dir_ = os.path.join(output_dir, lang_dir)
            self.output_dirs[lang_name] = dir_

    def get_template_backend_langs(self, template, rule_id):
        """
        Returns list of languages that should be generated from a template
        configuration, controlled by backends.
        """
        if "backends" in template:
            backends = template["backends"]
            for lang in backends:
                if lang not in languages:
                    raise RuntimeError("Rule {0} wants to generate unknown language '{1}"
                                       "from a template.".format(rule_id, lang))
            return [lang for name, lang in languages.items() if backends.get(name, "on") == "on"]
        return languages.values()

    def get_template_name(self, template, rule_id):
        """
        Given a template dictionary from a Rule instance, determine the name
        of the template (from templates) this rule uses.
        """
        try:
            template_name = template["name"]
        except KeyError:
            raise ValueError(
                "Rule {0} is missing template name under template key".format(
                    rule_id))
        if template_name not in self.templates.keys():
            raise ValueError(
                "Rule {0} uses template {1} which does not exist.".format(
                    rule_id, template_name))
        return template_name

    def get_resolved_langs_to_generate(self, rule):
        """
        Given a specific Rule instance, determine which languages are
        generated by the combination of the rule's template supported_languages AND
        the rule's template configuration backends.
        """
        if rule.template is None:
            return None

        rule_langs = set(self.get_template_backend_langs(rule.template, rule.id_))
        template_name = self.get_template_name(rule.template, rule.id_)
        template_langs = set(self.templates[template_name].langs)
        return rule_langs.intersection(template_langs)

    def process_product_vars(self, all_variables):
        """
        Given a dictionary with the format key[@<product>]=value, filter out
        and only take keys that apply to this product (unqualified or qualified
        to exactly this product). Returns a new dict.
        """
        processed = dict(filter(lambda item: '@' not in item[0], all_variables.items()))
        suffix = '@' + self.env_yaml['product']
        for variable in filter(lambda key: key.endswith(suffix), all_variables):
            new_variable = variable[:-len(suffix)]
            value = all_variables[variable]
            processed[new_variable] = value

        return processed

    def render_lang_file(self, template_name, template_vars, lang, local_env_yaml):
        """
        Builds and returns templated content for a given rule for a given
        language; does not write the output to disk.
        """
        if lang not in self.templates[template_name].langs:
            return None

        template_file_name = lang.name + ".template"
        template_file_path = os.path.join(self.templates_dir, template_name, template_file_name)
        template_parameters = self.templates[template_name].preprocess(template_vars, lang.name)
        env_yaml = self.env_yaml.copy()
        env_yaml.update(local_env_yaml)
        jinja_dict = ssg.utils.merge_dicts(env_yaml, template_parameters)
        try:
            filled_template = ssg.jinja.process_file_with_macros(template_file_path, jinja_dict)
        except Exception as e:
            print("Error in template: %s (lang: %s)" % (template_name, lang.name))
            raise e

        return filled_template

    def get_lang_contents(self, rule_id, rule_title, template, language, extra_env=None):
        """
        For the specified template, build and return only the specified language
        content.
        """
        template_name = self.get_template_name(template, rule_id)
        try:
            template_vars = self.process_product_vars(template["vars"])
        except KeyError:
            raise ValueError(
                "Rule {0} does not contain mandatory 'vars:' key under "
                "'template:' key.".format(rule_id))
        # Add the rule ID which will be reused in OVAL templates as OVAL
        # definition ID so that the build system matches the generated
        # check with the rule.
        template_vars["_rule_id"] = rule_id

        # Checks and remediations are processed with a custom YAML dict
        local_env_yaml = {"rule_id": rule_id, "rule_title": rule_title,
                          "products": self.env_yaml["product"]}
        if extra_env is not None:
            local_env_yaml.update(extra_env)

        return self.render_lang_file(template_name, template_vars, language, local_env_yaml)

    def build_lang(self, rule_id, rule_title, template, lang, extra_env=None):
        """
        Builds templated content for a given rule for a given language.
        Writes the output to the correct build directories.
        """
        filled_template = self.get_lang_contents(rule_id, rule_title, template, lang, extra_env)

        output_file_name = rule_id + lang.file_extension
        output_filepath = os.path.join(self.output_dirs[lang.name], output_file_name)

        with open(output_filepath, "w") as f:
            f.write(filled_template)

    def build_rule(self, rule):
        """
        Builds templated content for a given rule for selected languages,
        writing the output to the correct build directories.
        """
        extra_env = {}
        if rule.identifiers is not None:
            extra_env["cce_identifiers"] = rule.identifiers

        for lang in self.get_resolved_langs_to_generate(rule):
            if lang.name != "sce-bash":
                self.build_lang(rule.id_, rule.title, rule.template, lang, extra_env)

    def build_extra_ovals(self):
        declaration_path = os.path.join(self.templates_dir, "extra_ovals.yml")
        declaration = ssg.yaml.open_raw(declaration_path)
        for oval_def_id, template in declaration.items():
            # Since OVAL definition ID in shorthand format is always the same
            # as rule ID, we can use it instead of the rule ID even if no rule
            # with that ID exists
            self.build_lang(oval_def_id, oval_def_id, template, languages["oval"])

    def build_all_rules(self):
        for rule_file in sorted(os.listdir(self.resolved_rules_dir)):
            rule_path = os.path.join(self.resolved_rules_dir, rule_file)
            try:
                rule = ssg.build_yaml.Rule.from_yaml(rule_path, self.env_yaml, self.product_cpes)
            except ssg.build_yaml.DocumentationNotComplete:
                # Happens on non-debug build when a rule is "documentation-incomplete"
                continue
            if rule.template is not None:
                self.build_rule(rule)

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
