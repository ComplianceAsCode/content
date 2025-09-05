from __future__ import absolute_import
from __future__ import print_function

import os
import imp
import glob

from collections import namedtuple

import ssg.utils
import ssg.yaml
import ssg.jinja
import ssg.build_yaml

from ssg.build_cpe import ProductCPEs

TemplatingLang = namedtuple(
    "templating_language_attributes",
    ["name", "file_extension", "template_type", "lang_specific_dir"])

TemplateType = ssg.utils.enum("REMEDIATION", "CHECK")

LANGUAGES = {
    "anaconda": TemplatingLang("anaconda", ".anaconda", TemplateType.REMEDIATION, "anaconda"),
    "ansible": TemplatingLang("ansible", ".yml",        TemplateType.REMEDIATION, "ansible"),
    "bash": TemplatingLang("bash", ".sh",               TemplateType.REMEDIATION, "bash"),
    "blueprint": TemplatingLang("blueprint", ".toml",   TemplateType.REMEDIATION, "blueprint"),
    "ignition": TemplatingLang("ignition", ".yml",      TemplateType.REMEDIATION, "ignition"),
    "kubernetes": TemplatingLang("kubernetes", ".yml",  TemplateType.REMEDIATION, "kubernetes"),
    "oval": TemplatingLang("oval", ".xml",              TemplateType.CHECK,       "oval"),
    "puppet": TemplatingLang("puppet", ".pp",           TemplateType.REMEDIATION, "puppet"),
    "sce-bash": TemplatingLang("sce-bash", ".sh",       TemplateType.CHECK,       "sce")
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
    def load_template(cls, templates_root_directory, name):
        maybe_template = cls(templates_root_directory, name)
        if maybe_template._looks_like_template():
            maybe_template._load()
            return maybe_template
        return None

    def _load(self):
        if not os.path.exists(self.preprocessing_file_path):
            self.preprocessing_file_path = None

        template_yaml = ssg.yaml.open_raw(self.template_yaml_path)
        for supported_lang in template_yaml["supported_languages"]:
            if supported_lang not in LANGUAGES.keys():
                raise ValueError(
                    "The template {0} declares to support the {1} language,"
                    "but this language is not supported by the content.".format(
                        self.name, supported_lang))
            lang = LANGUAGES[supported_lang]
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
            preprocess_mod = imp.load_source(unique_dummy_module_name,
                                             self.preprocessing_file_path)
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
        if cpe_items_dir is not None:
            self.product_cpes.load_cpes_from_directory_tree(cpe_items_dir, self.env_yaml)

    def _init_and_load_templates(self):
        for item in sorted(os.listdir(self.templates_dir)):
            maybe_template = Template.load_template(self.templates_dir, item)
            if maybe_template is not None:
                self.templates[item] = maybe_template

    def _init_lang_output_dirs(self):
        for lang_name, lang in LANGUAGES.items():
            lang_dir = lang.lang_specific_dir
            if lang.template_type == TemplateType.CHECK:
                output_dir = self.checks_dir
            else:
                output_dir = self.remediations_dir
            dir_ = os.path.join(output_dir, lang_dir)
            self.output_dirs[lang_name] = dir_

    def get_resolved_langs_to_generate(self, templatable):
        """
        Given a specific Templatable instance, determine which languages are
        generated by the combination of the template supported_languages AND
        the Templatable's template configuration 'backends'.
        """
        template_name = templatable.get_template_name()
        if template_name not in self.templates.keys():
            raise ValueError(
                "Templatable {0} uses template {1} which does not exist."
                .format(templatable, template_name))
        template_langs = set(self.templates[template_name].langs)
        rule_langs = set(templatable.extract_configured_backend_lang(LANGUAGES))
        return rule_langs.intersection(template_langs)

    def process_template_lang_file(self, template_name, template_vars, lang, local_env_yaml):
        """
        Processes template for a given template name and language and returns rendered content.
        """
        if lang not in self.templates[template_name].langs:
            raise ValueError("Language {0} is not available for template {1}."
                             .format(lang.name, template_name))

        template_file_name = lang.name + ".template"
        template_file_path = os.path.join(self.templates_dir, template_name, template_file_name)
        template_parameters = self.templates[template_name].preprocess(template_vars, lang.name)
        env_yaml = self.env_yaml.copy()
        env_yaml.update(local_env_yaml)
        jinja_dict = ssg.utils.merge_dicts(env_yaml, template_parameters)
        return ssg.jinja.process_file_with_macros(template_file_path, jinja_dict)

    def get_lang_contents_for_templatable(self, templatable, language):
        """
        For the specified Templatable, build and return only the specified language content.
        """
        template_name = templatable.get_template_name()
        template_vars = templatable.get_template_vars(self.env_yaml)

        # Checks and remediations are processed with a custom YAML dict
        local_env_yaml = templatable.get_template_context(self.env_yaml)
        try:
            return self.process_template_lang_file(template_name, template_vars,
                                                   language, local_env_yaml)
        except Exception as e:
            raise RuntimeError("Unable to generate {0} template language for Templatable {1}: {2}"
                               .format(language.name, templatable, e))

    def write_lang_contents_for_templatable(self, filled_template, lang, templatable):
        output_file_name = templatable.id_ + lang.file_extension
        output_filepath = os.path.join(self.output_dirs[lang.name], output_file_name)
        with open(output_filepath, "w") as f:
            f.write(filled_template)

    def build_lang_for_templatable(self, templatable, lang):
        """
        Builds templated content of a given Templatable for a selected language
        returning the filled template.
        """
        return self.get_lang_contents_for_templatable(templatable, lang)

    def build_cpe(self, cpe):
        for lang in self.get_resolved_langs_to_generate(cpe):
            filled_template = self.build_lang_for_templatable(cpe, lang)
            if lang.template_type == TemplateType.REMEDIATION:
                cpe.set_conditional(lang.name, filled_template)
            if lang.template_type == TemplateType.CHECK:
                self.write_lang_contents_for_templatable(filled_template, lang, cpe)
        self.product_cpes.add_cpe_item(cpe)
        cpe_path = os.path.join(self.cpe_items_dir, cpe.id_+".yml")
        cpe.dump_yaml(cpe_path)

    def build_platform(self, platform):
        """
        Builds templated content of a given Platform (all CPEs/Symbols) for all available
        languages, writing the output to the correct build directories
        and updating the platform it self.
        """
        langs_affecting_this_platform = set()
        for fact_ref in platform.test.get_symbols():
            cpe = self.product_cpes.get_cpe_for_fact_ref(fact_ref)
            if cpe.is_templated():
                self.build_cpe(cpe)
                langs_affecting_this_platform.update(
                    self.get_resolved_langs_to_generate(cpe))
        for lang in langs_affecting_this_platform:
            if lang.template_type == TemplateType.REMEDIATION:
                platform.update_conditional_from_cpe_items(lang.name, self.product_cpes)
        platform_path = os.path.join(self.platforms_dir, platform.id_+".yml")
        platform.dump_yaml(platform_path)

    def build_rule(self, rule):
        """
        Builds templated content of a given Rule for all available languages,
        writing the output to the correct build directories.
        """
        for lang in self.get_resolved_langs_to_generate(rule):
            if lang.name != "sce-bash":
                filled_template = self.build_lang_for_templatable(rule, lang)
                self.write_lang_contents_for_templatable(filled_template, lang, rule)

    def build_extra_ovals(self):
        declaration_path = os.path.join(self.templates_dir, "extra_ovals.yml")
        declaration = ssg.yaml.open_raw(declaration_path)
        for oval_def_id, template in declaration.items():
            # Since OVAL definition ID in shorthand format is always the same
            # as rule ID, we can use it instead of the rule ID even if no rule
            # with that ID exists
            rule = ssg.build_yaml.Rule.get_instance_from_full_dict({
                "id_": oval_def_id,
                "title": oval_def_id,
                "template": template,
            })
            filled_template = self.build_lang_for_templatable(rule, LANGUAGES["oval"])
            self.write_lang_contents_for_templatable(filled_template, LANGUAGES["oval"], rule)

    def build_all_platforms(self):
        for platform_file in sorted(os.listdir(self.platforms_dir)):
            platform_path = os.path.join(self.platforms_dir, platform_file)
            platform = ssg.build_yaml.Platform.from_yaml(platform_path, self.env_yaml,
                                                         self.product_cpes)
            self.build_platform(platform)

    def build_all_rules(self):
        for rule_file in sorted(os.listdir(self.resolved_rules_dir)):
            rule_path = os.path.join(self.resolved_rules_dir, rule_file)
            try:
                rule = ssg.build_yaml.Rule.from_yaml(rule_path, self.env_yaml, self.product_cpes)
            except ssg.build_yaml.DocumentationNotComplete:
                # Happens on non-debug build when a rule is "documentation-incomplete"
                continue
            if rule.is_templated():
                self.build_rule(rule)

    def build(self):
        """
        Builds all templated content for all languages,
        writing the output to the correct build directories.
        """
        for dir_ in self.output_dirs.values():
            if not os.path.exists(dir_):
                os.makedirs(dir_)

        self.build_extra_ovals()
        self.build_all_rules()
        self.build_all_platforms()
