import os
import logging

from . import utils, products
from .rules import get_rule_dir_ovals, find_rule_dirs_in_paths
from .oval_object_model import OVALDocument
from .build_yaml import Rule, DocumentationNotComplete
from .jinja import process_file_with_macros
from .id_translate import IDTranslator
from .xml import ElementTree


def expand_shorthand(shorthand_path, oval_path, env_yaml):
    oval_document = OVALDocument()
    oval_document.ssg_version = env_yaml.get("ssg_version", "Unknown ssg_version")
    oval_document.product_name = "test"
    oval_document.schema_version = env_yaml.get("target_oval_version_str", "5.11")

    shorthand_file_content = process_file_with_macros(shorthand_path, env_yaml)
    oval_document.load_shorthand(shorthand_file_content)

    root = oval_document.get_xml_element()

    id_translator = IDTranslator("test")
    root_translated = id_translator.translate(root)

    ElementTree.ElementTree(root_translated).write(oval_path)


class OVALBuildException(Exception):
    pass


class OVALBuilder:
    def __init__(
        self,
        env_yaml,
        product_yaml_path,
        shared_directories,
        build_ovals_dir,
    ):
        self.env_yaml = env_yaml
        self.product_yaml = products.Product(product_yaml_path)
        self.product = utils.required_key(env_yaml, "product")

        self.shared_directories = shared_directories
        self.build_ovals_dir = build_ovals_dir

        self.oval_document = OVALDocument()
        self.oval_document.ssg_version = env_yaml.get(
            "ssg_version", "Unknown ssg_version"
        )
        self.oval_document.schema_version = utils.required_key(
            env_yaml, "target_oval_version_str"
        )

        self.already_processed = []

    @property
    def product_name(self):
        return self.oval_document.product_name

    @product_name.setter
    def product_name(self, __value):
        self.oval_document.product_name = __value

    def get_oval_document_from_shorthands(self, include_benchmark):
        if self.build_ovals_dir:
            utils.mkdir_p(self.build_ovals_dir)
        if include_benchmark:
            self._load_checks_from_benchmark()
        self._load_checks_from_shared_directories()
        return self.oval_document

    def _get_dirs_rules_from_benchmark(self):
        product_dir = self.product_yaml["product_dir"]
        relative_guide_dir = utils.required_key(self.env_yaml, "benchmark_root")
        guide_dir = os.path.abspath(os.path.join(product_dir, relative_guide_dir))
        additional_content_directories = self.env_yaml.get(
            "additional_content_directories", []
        )
        dirs_to_scan = [guide_dir]
        for rd in additional_content_directories:
            abspath = os.path.abspath(os.path.join(product_dir, rd))
            dirs_to_scan.append(abspath)
        return list(find_rule_dirs_in_paths(dirs_to_scan))

    def _load_checks_from_benchmark(self):
        rule_dirs = self._get_dirs_rules_from_benchmark()
        self._process_directories(rule_dirs, True)

    def _load_checks_from_shared_directories(self):
        # earlier directory has higher priority
        reversed_dirs = self.shared_directories[::-1]
        self._process_directories(reversed_dirs, False)

    def _process_directories(self, directories, from_benchmark):
        for directory in directories:
            if not os.path.exists(directory):
                continue
            self._process_directory(directory, from_benchmark)

    def _process_directory(self, directory, from_benchmark):
        try:
            context = self._get_context(directory, from_benchmark)
        except DocumentationNotComplete:
            return
        for file_path in self._get_list_of_oval_files(directory, from_benchmark):
            self._process_oval_file(file_path, from_benchmark, context)

    def _get_context(self, directory, from_benchmark):
        if from_benchmark:
            rule_path = os.path.join(directory, "rule.yml")
            rule = Rule.from_yaml(rule_path, self.env_yaml)

            local_env_yaml = dict(**self.env_yaml)
            local_env_yaml["rule_id"] = rule.id_
            local_env_yaml["rule_title"] = rule.title
            local_env_yaml["products"] = {self.product}

            return local_env_yaml
        return self.env_yaml

    def _get_list_of_oval_files(self, directory, from_benchmark):
        if from_benchmark:
            return get_rule_dir_ovals(directory, self.product)
        return sorted([os.path.join(directory, x) for x in os.listdir(directory)])

    def _create_key(self, file_path, from_benchmark):
        if from_benchmark:
            rule_id = self._get_rule_id(file_path)
            oval_key = "%s.xml" % rule_id
        else:
            oval_key = os.path.basename(file_path)
        return oval_key

    def _get_rule_id(self, file_path):
        return os.path.basename(os.path.dirname(os.path.dirname(file_path)))

    def _process_oval_file(self, file_path, from_benchmark, context):
        oval_key = self._create_key(file_path, from_benchmark)
        if oval_key in self.already_processed:
            return

        xml_content = self._read_oval_file(file_path, context, from_benchmark)

        rule_id = None
        if from_benchmark:
            rule_id = self._get_rule_id(file_path)
            self._store_intermediate_file(rule_id, xml_content)

        if self.oval_document.load_shorthand(xml_content, self.product, rule_id):
            self.already_processed.append(oval_key)

    def _read_oval_file(self, file_path, context, from_benchmark):
        if not file_path.endswith(".xml"):
            logging.critical("File name '{}' doesn't end with '.xml'.".format(file_path))

        if from_benchmark or "checks_from_templates" not in file_path:
            return process_file_with_macros(file_path, context)

        with open(file_path, "r") as f:
            return f.read()

    def _store_intermediate_file(self, rule_id, xml_content):
        if not self.build_ovals_dir:
            return
        output_file_name = rule_id + ".xml"
        output_filepath = os.path.join(self.build_ovals_dir, output_file_name)
        with open(output_filepath, "w") as f:
            f.write(xml_content)
