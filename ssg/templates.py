from __future__ import absolute_import
from __future__ import print_function

import os
import imp
import glob

import ssg.build_yaml
import ssg.utils
import ssg.yaml
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
preprocessing_file_name = "template.py"

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
    def __init__(
            self, env_yaml, resolved_rules_dir, templates_dir,
            remediations_dir, checks_dir, platforms_dir, cpe_items_dir):
        self.env_yaml = env_yaml
        self.resolved_rules_dir = resolved_rules_dir
        self.templates_dir = templates_dir
        self.remediations_dir = remediations_dir
        self.checks_dir = checks_dir
        self.platforms_dir = platforms_dir
        self.cpe_items_dir = cpe_items_dir
        self.output_dirs = dict()
        for lang_name, lang in languages.items():
            lang_dir = lang.lang_specific_dir
            if lang.template_type == template_type.check:
                output_dir = self.checks_dir
            else:
                output_dir = self.remediations_dir
            dir_ = os.path.join(output_dir, lang_dir)
            self.output_dirs[lang_name] = dir_
        # scan directory structure and dynamically create list of templates
        for item in sorted(os.listdir(self.templates_dir)):
            maybe_template = Template(templates_dir, item)
            if maybe_template.looks_like_template():
                maybe_template.load()
                templates[item] = maybe_template
        self.product_cpes = ProductCPEs()
        self.product_cpes.load_cpes_from_directory_tree(cpe_items_dir, self.env_yaml)

    def build_lang_file(
            self, rule_id, template_name, template_vars, lang, local_env_yaml):
        """
        Builds and returns templated content for a given rule for a given
        language; does not write the output to disk.
        """
        if lang not in templates[template_name].langs:
            return None

        template_file_name = lang.name + ".template"
        template_file_path = os.path.join(self.templates_dir, template_name, template_file_name)
        template_parameters = templates[template_name].preprocess(template_vars, lang.name)
        jinja_dict = ssg.utils.merge_dicts(local_env_yaml, template_parameters)
        filled_template = ssg.jinja.process_file_with_macros(
            template_file_path, jinja_dict)

        return filled_template

    def build_lang(
            self, rule_id, template_name, template_vars, lang, local_env_yaml, platforms=None):
        """
        Builds templated content for a given rule for a given language.
        Writes the output to the correct build directories.
        """
        if lang not in templates[template_name].langs or lang.name == "sce-bash":
            return

        filled_template = self.build_lang_file(rule_id, template_name,
                                               template_vars, lang,
                                               local_env_yaml)

        ext = lang.file_extension
        output_file_name = rule_id + ext
        output_filepath = os.path.join(
            self.output_dirs[lang.name], output_file_name)

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
                if lang not in languages.keys():
                    raise RuntimeError(
                        "Rule {0} wants to generate unknown language '{1}"
                        "from a template.".format(rule.id_, lang)
                    )
            langs_to_generate = []
            for lang_name, lang in languages.items():
                backend = backends.get(lang_name, "on")
                if backend == "on":
                    langs_to_generate.append(lang)
            return langs_to_generate
        else:
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
        if template_name not in templates.keys():
            raise ValueError(
                "Rule {0} uses template {1} which does not exist.".format(
                    rule_id, template_name))
        return template_name

    def get_resolved_langs_to_generate(self, rule):
        """
        Given a specific Rule instance, determine which languages are
        generated by the combination of the rule's template_backends AND
        the rule's template keys.
        """
        if rule.template is None:
            return None

        rule_langs = set(self.get_langs_to_generate(rule))
        template_name = self.get_template_name(rule.template, rule.id_)
        template_langs = set(templates[template_name].langs)
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

    def build_rule(self, rule_id, rule_title, template, langs_to_generate, identifiers,
                   platforms=None):
        """
        Builds templated content for a given rule for selected languages,
        writing the output to the correct build directories.
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
        # checks and remediations are processed with a custom YAML dict
        local_env_yaml = self.env_yaml.copy()
        local_env_yaml["rule_id"] = rule_id
        local_env_yaml["rule_title"] = rule_title
        local_env_yaml["products"] = self.env_yaml["product"]
        if identifiers is not None:
            local_env_yaml["cce_identifiers"] = identifiers

        for lang in langs_to_generate:
            try:
                self.build_lang(
                    rule_id, template_name, template_vars, lang, local_env_yaml, platforms)
            except Exception as e:
                raise e(
                    "Error building templated {0} content for rule {1}".format(lang, rule_id))

    def get_lang_for_rule(self, rule_id, rule_title, template, language):
        """
        For the specified rule, build and return only the specified language
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
        # checks and remediations are processed with a custom YAML dict
        local_env_yaml = self.env_yaml.copy()
        local_env_yaml["rule_id"] = rule_id
        local_env_yaml["rule_title"] = rule_title
        local_env_yaml["products"] = self.env_yaml["product"]

        return self.build_lang_file(rule_id, template_name, template_vars,
                                    language, local_env_yaml)

    def build_extra_ovals(self):
        declaration_path = os.path.join(self.templates_dir, "extra_ovals.yml")
        declaration = ssg.yaml.open_raw(declaration_path)
        for oval_def_id, template in declaration.items():
            langs_to_generate = [languages["oval"]]
            # Since OVAL definition ID in shorthand format is always the same
            # as rule ID, we can use it instead of the rule ID even if no rule
            # with that ID exists
            self.build_rule(
                oval_def_id, oval_def_id, template, langs_to_generate, None)

    def build_all_rules(self):
        for rule_file in sorted(os.listdir(self.resolved_rules_dir)):
            rule_path = os.path.join(self.resolved_rules_dir, rule_file)
            try:
                rule = ssg.build_yaml.Rule.from_yaml(rule_path, self.env_yaml, self.product_cpes)
            except ssg.build_yaml.DocumentationNotComplete:
                # Happens on non-debug build when a rule is "documentation-incomplete"
                continue
            if rule.template is None:
                # rule is not templated, skipping
                continue
            langs_to_generate = self.get_langs_to_generate(rule)
            self.build_rule(rule.id_, rule.title, rule.template, langs_to_generate,
                            rule.identifiers, platforms=rule.platforms)

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
