"""
Common functions for processing Templates in SSG
"""

from __future__ import absolute_import
from __future__ import print_function

import os
import glob

from collections import namedtuple

import ssg.utils
from ssg.utils import mkdir_p
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
    "cpe-oval": TemplatingLang("cpe-oval", ".xml",      TemplateType.CHECK,       "cpe-oval"),
    "ignition": TemplatingLang("ignition", ".yml",      TemplateType.REMEDIATION, "ignition"),
    "kubernetes": TemplatingLang("kubernetes", ".yml",  TemplateType.REMEDIATION, "kubernetes"),
    "oval": TemplatingLang("oval", ".xml",              TemplateType.CHECK,       "oval"),
    "puppet": TemplatingLang("puppet", ".pp",           TemplateType.REMEDIATION, "puppet"),
    "sce-bash": TemplatingLang("sce-bash", ".sh",       TemplateType.CHECK,       "sce"),
    "kickstart": TemplatingLang("kickstart", ".cfg",    TemplateType.REMEDIATION, "kickstart"),
    "bootc": TemplatingLang("bootc", ".bo",             TemplateType.REMEDIATION, "bootc")
}

PREPROCESSING_FILE_NAME = "template.py"
TEMPLATE_YAML_FILE_NAME = "template.yml"


def load_module(module_name, module_path):
    """
    Loads a Python module from a given file path.

    This function attempts to load a module using the `imp` module for Python 2.7 and falls back
    to using `importlib` for Python 3.x.

    Args:
        module_name (str): The name to assign to the loaded module.
        module_path (str): The file path to the module to be loaded.

    Returns:
        module: The loaded module object.

    Raises:
        ValueError: If the module cannot be loaded due to an invalid spec or loader.
    """
    try:
        # Python 2.7
        from imp import load_source
        return load_source(module_name, module_path)
    except ImportError:
        # https://docs.python.org/3/library/importlib.html#importing-a-source-file-directly
        import importlib
        spec = importlib.util.spec_from_file_location(module_name, module_path)
        if not spec:
            raise ValueError("Error loading '%s' module" % module_path)
        module = importlib.util.module_from_spec(spec)
        if not spec.loader:
            raise ValueError("Error loading '%s' module" % module_path)
        spec.loader.exec_module(module)
        return module


class Template:
    """
    A class to represent a template for content generation.

    Attributes:
        templates_root_directory (str): The root directory where templates are stored.
        name (str): The name of the template.
        langs (list): A list to store supported languages.
        template_path (str): The path to the template directory.
        template_yaml_path (str): The path to the template's YAML configuration file.
        preprocessing_file_path (str): The path to the template's preprocessing file.
    """
    def __init__(self, templates_root_directory, name):
        self.langs = []
        self.templates_root_directory = templates_root_directory
        self.name = name
        self.template_path = os.path.join(self.templates_root_directory, self.name)
        self.template_yaml_path = os.path.join(self.template_path, TEMPLATE_YAML_FILE_NAME)
        self.preprocessing_file_path = os.path.join(self.template_path, PREPROCESSING_FILE_NAME)

    @classmethod
    def load_template(cls, templates_root_directory, name):
        """
        Load a template if it exists and looks like a template.

        Args:
            cls: The class that this method belongs to.
            templates_root_directory (str): The root directory where templates are stored.
            name (str): The name of the template to load.

        Returns:
            An instance of the template if it exists and looks like a template, otherwise None.
        """
        maybe_template = cls(templates_root_directory, name)
        if maybe_template._looks_like_template():
            maybe_template._load()
            return maybe_template
        return None

    def _load(self):
        """
        Loads the template configuration and validates the supported languages.

        This method performs the following steps:
        1. Checks if the preprocessing file path exists. If it does not exist, sets it to None.
        2. Opens and reads the template YAML file.
        3. Iterates over the supported languages declared in the template YAML file.
        4. For each supported language, checks if it is in the predefined LANGUAGES dictionary.
           - If not, raises a ValueError indicating the unsupported language.
        5. For each supported language, constructs the expected template filename.
        6. Checks if the template file exists in the specified template path.
           - If not, raises a ValueError indicating the missing implementation file.
        7. Appends the language object to the `langs` list.

        Raises:
            ValueError: If a declared supported language is not in the LANGUAGES dictionary.
            ValueError: If the implementation file for a declared supported language is missing.
        """
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
        """
        Preprocess the given parameters by applying template module preprocessing and converting
        parameter keys to uppercase.

        Args:
            parameters (dict): The parameters to preprocess.
            lang (str): The language code.

        Returns:
            dict: The preprocessed parameters with keys in uppercase.
        """
        parameters = self._preprocess_with_template_module(parameters, lang)
        # TODO: Remove this right after the variables in templates are renamed to lowercase
        parameters = {k.upper(): v for k, v in parameters.items()}
        return parameters

    def _preprocess_with_template_module(self, parameters, lang):
        """
        Preprocesses the given parameters using a template module if a preprocessing file path
        is specified.

        This method dynamically loads a module from the specified preprocessing file path and
        calls its 'preprocess' function, passing the parameters and language as arguments. If the
        preprocessing file does not define a 'preprocess' function, a ValueError is raised.

        Args:
            parameters (dict): The parameters to preprocess.
            lang (str): The language code to be used during preprocessing.

        Returns:
            dict: The preprocessed parameters.

        Raises:
            ValueError: If the preprocessing file does not define a 'preprocess' function.
        """
        if self.preprocessing_file_path is not None:
            unique_dummy_module_name = "template_" + self.name
            preprocess_mod = load_module(
                unique_dummy_module_name, self.preprocessing_file_path)
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
        """
        Check if the given path looks like a valid template directory.

        This method verifies the following conditions:
        1. The path specified by `self.template_path` must be a directory.
        2. The path must not be a symbolic link.
        3. The directory must contain at least one file with a ".template" extension.
        4. The directory must contain a YAML file specified by `self.template_yaml_path`.

        Returns:
            bool: True if the path meets all the conditions to be considered a template directory,
                  False otherwise.
        """
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

    To generate content from templates, pass the env_yaml, path to the directory with resolved
    rule YAMLs, path to the directory that contains templates, path to the output directory for
    checks and a path to the output directory for remediations into the constructor. Then, call
    the method build() to perform a build.

    Attributes:
        env_yaml (dict): Environment YAML configuration.
        resolved_rules_dir (str): Path to the directory with resolved rule YAMLs.
        templates_dir (str): Path to the directory that contains templates.
        remediations_dir (str): Path to the output directory for remediations.
        checks_dir (str): Path to the output directory for checks.
        platforms_dir (str): Path to the directory for platforms.
        cpe_items_dir (str): Path to the directory for CPE items.
        output_dirs (dict): Dictionary of output directories for different languages.
        templates (dict): Dictionary of loaded templates.
        product_cpes (ProductCPEs): Instance of ProductCPEs for managing CPE items.
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
        """
        Initializes and loads templates from the specified directory.

        This method iterates over all items in the `templates_dir` directory, attempts to load
        each item as a template, and if successful, adds it to the `templates` dictionary with
        the item name as the key.

        Returns:
            None

        Raises:
            OSError: If there is an issue accessing the `templates_dir` directory.
        """
        for item in sorted(os.listdir(self.templates_dir)):
            maybe_template = Template.load_template(self.templates_dir, item)
            if maybe_template is not None:
                self.templates[item] = maybe_template

    def _init_lang_output_dirs(self):
        """
        Initializes the output directories for each language based on their template type.

        This method iterates over the LANGUAGES dictionary, which contains language configurations.
        For each language, it determines the appropriate output directory (either checks_dir or
        remediations_dir) based on the template type of the language. It then constructs the full
        path for the language-specific directory and stores it in the output_dirs dictionary with
        the language name as the key.

        Returns:
            None

        Raises:
            KeyError: If LANGUAGES dictionary does not contain expected keys.
        """
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
        Determine the languages to generate for a given Templatable instance.

        This method calculates the intersection of the languages supported by the template and the
        languages specified in the Templatable's template configuration 'backends'.

        Args:
            templatable (Templatable): An instance of a Templatable object.

        Returns:
            set: A set of languages that are both supported by the template and specified in the
                 Templatable's configuration.

        Raises:
            ValueError: If the template used by the Templatable does not exist.
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
        Processes a template for a given template name and language, and returns the rendered content.

        Args:
            template_name (str): The name of the template to process.
            template_vars (dict): A dictionary of variables to be used in the template.
            lang (object): An object representing the language, which should have a 'name'
                           attribute.
            local_env_yaml (dict): A dictionary of local environment variables to be merged with
                                   the global environment variables.

        Returns:
            str: The rendered content of the template.

        Raises:
            ValueError: If the specified language is not available for the given template.
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
        Generate and return the content for a specified language for a given Templatable object.

        Args:
            templatable (Templatable): The Templatable object for which to generate content.
            language (Language): The language for which to generate content.

        Returns:
            str: The generated content for the specified language.

        Raises:
            RuntimeError: If there is an error generating the template language content.
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
        """
        Writes the filled template content to a file specific to the given language.

        Args:
            filled_template (str): The content to be written to the file.
            lang (Language): The language object containing language-specific details.
            templatable (Templatable): The templatable object containing the id_ attribute.

        The output file name is generated by appending the language-specific file extension to the
        templatable's id_. The file is then written to the appropriate output directory for the
        given language.
        """
        output_file_name = templatable.id_ + lang.file_extension
        output_filepath = os.path.join(self.output_dirs[lang.name], output_file_name)
        with open(output_filepath, "w") as f:
            f.write(filled_template)

    def build_lang_for_templatable(self, templatable, lang):
        """
        Builds templated content of a given Templatable for a selected language.

        Args:
            templatable (Templatable): The object that contains the template to be filled.
            lang (str): The language code for which the template should be filled.

        Returns:
            str: The filled template content for the specified language.
        """
        return self.get_lang_contents_for_templatable(templatable, lang)

    def build_cpe(self, cpe):
        """
        Builds and processes a CPE (Common Platform Enumeration) item.

        This method generates language-specific templates for the given CPE item, processes them
        based on their template type, and then adds the CPE item to the product's CPE list.
        Finally, it dumps the CPE item to a YAML file.

        Args:
            cpe (CPE): The CPE item to be processed.

        Returns:
            None
        """
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
        Builds templated content for a given platform, processing all CPEs/Symbols for all
        available languages.

        The method writes the output to the appropriate build directories and updates the platform
        itself.

        Args:
            platform (Platform): The platform object containing CPEs/Symbols to be processed.

        The method performs the following steps:
        1. Identifies languages affecting the platform by examining the symbols associated with the platform's tests.
        2. For each CPE that is templated, it builds the CPE and determines the languages that need to be generated.
        3. Updates the platform's conditional items based on the resolved languages and CPE items.
        4. Dumps the platform's data into a YAML file in the designated platforms directory.
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
        Builds templated content of a given Rule for all available languages, writing the output
        to the correct build directories.

        Args:
            rule (Rule): The rule object containing the data to be templated.

        Returns:
            None
        """
        for lang in self.get_resolved_langs_to_generate(rule):
            if lang.name != "sce-bash":
                filled_template = self.build_lang_for_templatable(rule, lang)
                self.write_lang_contents_for_templatable(filled_template, lang, rule)

    def build_extra_ovals(self):
        """
        Builds and processes extra OVAL definitions from a YAML declaration file.

        This method reads a YAML file named "extra_ovals.yml" located in the templates directory.
        It iterates over the items in the YAML file, where each item represents an OVAL definition.
        For each OVAL definition, it creates a rule instance using the definition ID and template,
        builds the corresponding language-specific content, and writes the content to the
        appropriate location.

        Returns:
            None

        Raises:
            FileNotFoundError: If the "extra_ovals.yml" file does not exist in the templates directory.
            ssg.yaml.YAMLError: If there is an error parsing the YAML file.
        """
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
        """
        Builds all platforms by iterating through the files in the platforms directory.

        This method reads each platform file, constructs a Platform object from the YAML
        data, and then builds the platform using the build_platform method.
        The platforms are processed in sorted order based on their filenames.

        Returns:
            None

        Raises:
            OSError: If there is an issue reading the platforms directory or files.
            ssg.build_yaml.PlatformError: If there is an issue constructing the Platform object.
        """
        for platform_file in sorted(os.listdir(self.platforms_dir)):
            platform_path = os.path.join(self.platforms_dir, platform_file)
            platform = ssg.build_yaml.Platform.from_yaml(platform_path, self.env_yaml,
                                                         self.product_cpes)
            self.build_platform(platform)

    def build_all_rules(self):
        """
        Builds all rules from YAML files located in the resolved rules directory.

        This method iterates over all files in the resolved rules directory, sorts them, and
        attempts to create a Rule object from each file. If a rule is marked as
        "documentation-incomplete" and the build is not in debug mode, it skips that rule.
        If a rule is templated, it calls the build_rule method to process it.

        Returns:
            None

        Raises:
            ssg.build_yaml.DocumentationNotComplete: If a rule's documentation is incomplete and
                                                     the build is not in debug mode.
        """
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
        Builds all templated content for all languages and writes the output to the correct build
        directories.

        This method performs the following steps:
        1. Creates the necessary output directories.
        2. Builds extra OVAL definitions.
        3. Builds all rules.
        4. Builds all platforms.

        Returns:
            None

        Raises:
            OSError: If there is an issue creating the output directories.
        """
        for dir_ in self.output_dirs.values():
            mkdir_p(dir_)

        self.build_extra_ovals()
        self.build_all_rules()
        self.build_all_platforms()
