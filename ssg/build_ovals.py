from __future__ import absolute_import
from __future__ import print_function

import os
import os.path
import sys
from copy import deepcopy
import collections

from .build_yaml import Rule, DocumentationNotComplete
from .constants import oval_namespace as oval_ns
from .constants import oval_footer
from .constants import oval_header
from .constants import MULTI_PLATFORM_LIST
from .id_translate import IDTranslator
from .jinja import process_file_with_macros
from .rule_yaml import parse_prodtype
from .rules import get_rule_dir_ovals, find_rule_dirs_in_paths
from . import utils, products
from .utils import mkdir_p
from .xml import ElementTree, oval_generated_header
from .oval_object_model import get_product_name


def _create_subtree(shorthand_tree, category):
    parent_tag = "{%s}%ss" % (oval_ns, category)
    parent = ElementTree.Element(parent_tag)
    for node in shorthand_tree.findall(".//{%s}def-group/*" % oval_ns):
        if node.tag is ElementTree.Comment:
            continue
        elif node.tag.endswith(category):
            append(parent, node)
    return parent


def expand_shorthand(shorthand_path, oval_path, env_yaml):
    shorthand_file_content = process_file_with_macros(shorthand_path, env_yaml)
    wrapped_shorthand = (oval_header + shorthand_file_content + oval_footer)
    shorthand_tree = ElementTree.fromstring(wrapped_shorthand.encode("utf-8"))
    header = oval_generated_header("test", "5.11", "1.0")
    skeleton = header + oval_footer
    root = ElementTree.fromstring(skeleton.encode("utf-8"))
    for category in ["definition", "test", "object", "state", "variable"]:
        subtree = _create_subtree(shorthand_tree, category)
        if list(subtree):
            root.append(subtree)
    id_translator = IDTranslator("test")
    root_translated = id_translator.translate(root)

    ElementTree.ElementTree(root_translated).write(oval_path)


def _check_is_applicable_for_product(oval_check_def, product):
    """Based on the <platform> specifier of the OVAL check determine if this
    OVAL check is applicable for this product. Return 'True' if so, 'False'
    otherwise"""

    product, product_version = utils.parse_name(product)

    # Define general platforms
    multi_platforms = ['<platform>multi_platform_all',
                       '<platform>multi_platform_' + product]

    # First test if OVAL check isn't for 'multi_platform_all' or
    # 'multi_platform_' + product
    for multi_prod in multi_platforms:
        if multi_prod in oval_check_def and product in MULTI_PLATFORM_LIST:
            return True

    # Current SSG checks aren't unified which element of '<platform>'
    # and '<product>' to use as OVAL AffectedType metadata element,
    # e.g. Chromium content uses both of them across the various checks
    # Thus for now check both of them when checking concrete platform / product
    affected_type_elements = ['<platform>', '<product>']

    for afftype in affected_type_elements:
        # Get official name for product (prefixed with content of afftype)
        product_name = afftype + get_product_name(product, product_version)

        # Test if this OVAL check is for the concrete product version
        if product_name in oval_check_def:
            return True

    # OVAL check isn't neither a multi platform one, nor isn't applicable
    # for this product => return False to indicate that

    return False


def finalize_affected_platforms(xml_tree, env_yaml):
    """Depending on your use-case of OVAL you may not need the <affected>
    element. Such use-cases including using OVAL as a check engine for XCCDF
    benchmarks. Since the XCCDF Benchmarks use cpe:platform with CPE IDs,
    the affected element in OVAL definitions is redundant and just bloats the
    files. This function removes all *irrelevant* affected platform elements
    from given OVAL tree. It then adds one platform of the product we are
    building.
    """

    for affected in xml_tree.findall(".//{%s}affected" % (oval_ns)):
        for platform in affected.findall("./{%s}platform" % (oval_ns)):
            affected.remove(platform)
        for product in affected.findall("./{%s}product" % (oval_ns)):
            affected.remove(product)

        final = ElementTree.SubElement(
            affected, "{%s}%s" % (oval_ns, utils.required_key(env_yaml, "type")))
        final.text = utils.required_key(env_yaml, "full_name")

    return xml_tree


def oval_entities_are_identical(firstelem, secondelem):
    """Check if OVAL entities represented by XML elements are identical
       Return: True if identical, False otherwise
       Based on: http://stackoverflow.com/a/24349916"""

    # Per https://github.com/ComplianceAsCode/content/pull/1343#issuecomment-234541909
    # and https://github.com/ComplianceAsCode/content/pull/1343#issuecomment-234545296
    # ignore the differences in 'comment', 'version', 'state_operator', and
    # 'deprecated' attributes. Also ignore different nsmap, since all these
    # don't affect the semantics of the OVAL entities

    # Operate on copies of the elements (since we will modify
    # some attributes). Deepcopy will also reset the namespace map
    # on copied elements for us
    firstcopy = deepcopy(firstelem)
    secondcopy = deepcopy(secondelem)

    # Ignore 'comment', 'version', 'state_operator', and 'deprecated'
    # attributes since they don't change the semantics of an element
    for copy in [firstcopy, secondcopy]:
        for key in copy.keys():
            if key in ["comment", "version", "state_operator",
                       "deprecated"]:
                del copy.attrib[key]

    # Compare the equality of the copies
    if firstcopy.tag != secondcopy.tag:
        return False
    if firstcopy.text != secondcopy.text:
        return False
    if firstcopy.tail != secondcopy.tail:
        return False
    if firstcopy.attrib != secondcopy.attrib:
        return False
    if len(firstcopy) != len(secondcopy):
        return False

    return all(oval_entities_are_identical(
        fchild, schild) for fchild, schild in zip(firstcopy, secondcopy))


def oval_entity_is_extvar(elem):
    """Check if OVAL entity represented by XML element is OVAL
       <external_variable> element
       Return: True if <external_variable>, False otherwise"""

    return elem.tag == '{%s}external_variable' % oval_ns


element_child_cache = collections.defaultdict(dict)


def append(element, newchild):
    """Append new child ONLY if it's not a duplicate"""

    global element_child_cache

    newid = newchild.get("id")
    existing = element_child_cache[element].get(newid, None)

    if existing is not None:
        # ID is identical and OVAL entities are identical
        if oval_entities_are_identical(existing, newchild):
            # Moreover the entity is OVAL <external_variable>
            if oval_entity_is_extvar(newchild):
                # If OVAL entity is identical to some already included
                # in the benchmark and represents an OVAL <external_variable>
                # it's safe to ignore this ID (since external variables are
                # in multiple checks for clarity reasons)
                pass
            # Some other OVAL entity
            else:
                # If OVAL entity is identical, but not external_variable, the
                # implementation should be rewritten each entity to be present
                # just once
                sys.stderr.write("ERROR: OVAL ID '%s' is used multiple times "
                                 "and should represent the same elements.\n"
                                 % (newid))
                sys.stderr.write("Rewrite the OVAL checks. Place the identical "
                                 "IDs into their own definition and extend "
                                 "this definition by it.\n")
                sys.exit(1)
        # ID is identical, but OVAL entities are semantically difference =>
        # report and error and exit with failure
        # Fixes: https://github.com/ComplianceAsCode/content/issues/1275
        else:
            if not oval_entity_is_extvar(existing) and \
              not oval_entity_is_extvar(newchild):
                # This is an error scenario - since by skipping second
                # implementation and using the first one for both references,
                # we might evaluate wrong requirement for the second entity
                # => report an error and exit with failure in that case
                # See
                #   https://github.com/ComplianceAsCode/content/issues/1275
                # for a reproducer and what could happen in this case
                sys.stderr.write("ERROR: it's not possible to use the " +
                                 "same ID: %s " % newid + "for two " +
                                 "semantically different OVAL entities:\n")
                sys.stderr.write("First entity  %s\n" % ElementTree.tostring(existing))
                sys.stderr.write("Second entity %s\n" % ElementTree.tostring(newchild))
                sys.stderr.write("Use different ID for the second entity!!!\n")
                sys.exit(1)
    else:
        element.append(newchild)
        element_child_cache[element][newid] = newchild


def check_oval_version(oval_version):
    """Not necessary, but should help with typos"""

    supported_versions = ["5.11"]
    if oval_version not in supported_versions:
        supported_versions_str = ", ".join(supported_versions)
        sys.stderr.write(
            "Suspicious oval version \"%s\", one of {%s} is "
            "expected.\n" % (oval_version, supported_versions_str))
        sys.exit(1)


def _check_is_loaded(loaded_dict, filename, version):
    if filename in loaded_dict:
        if loaded_dict[filename] >= version:
            return True

        # Should rather fail, than override something unwanted
        sys.stderr.write(
            "You cannot override generic OVAL file in version '%s' "
            "by more specific one in older version '%s'" %
            (version, loaded_dict[filename])
        )
        sys.exit(1)

    return False


def _create_oval_tree_from_string(xml_content):
    try:
        argument = oval_header + xml_content + oval_footer
        oval_file_tree = ElementTree.fromstring(argument)
    except ElementTree.ParseError as error:
        line, column = error.position
        lines = argument.splitlines()
        before = '\n'.join(lines[:line])
        column_pointer = ' ' * (column - 1) + '^'
        sys.stderr.write(
            "%s\n%s\nError when parsing OVAL file.\n" %
            (before, column_pointer))
        sys.exit(1)
    return oval_file_tree


def _check_oval_version_from_oval(oval_file_tree, oval_version):
    for defgroup in oval_file_tree.findall("./{%s}def-group" % oval_ns):
        file_oval_version = defgroup.get("oval_version")

    if file_oval_version is None:
        # oval_version does not exist in <def-group/>
        # which means the OVAL is supported for any version.
        # By default, that version is 5.11
        file_oval_version = "5.11"

    if tuple(oval_version.split(".")) >= tuple(file_oval_version.split(".")):
        return True


def _check_rule_id(oval_file_tree, rule_id):
    for definition in oval_file_tree.findall(
            "./{%s}def-group/{%s}definition" % (oval_ns, oval_ns)):
        definition_id = definition.get("id")
        return definition_id == rule_id
    return False


def _list_full_paths(directory):
    full_paths = [os.path.join(directory, x) for x in os.listdir(directory)]
    return sorted(full_paths)


class OVALBuilder:
    def __init__(
            self, env_yaml, product_yaml_path, shared_directories,
            build_ovals_dir):
        self.env_yaml = env_yaml
        self.product_yaml = products.Product(product_yaml_path)
        self.shared_directories = shared_directories
        self.build_ovals_dir = build_ovals_dir
        self.already_loaded = dict()
        self.oval_version = utils.required_key(
            env_yaml, "target_oval_version_str")
        self.product = utils.required_key(env_yaml, "product")

    def build_shorthand(self, include_benchmark):
        if self.build_ovals_dir:
            mkdir_p(self.build_ovals_dir)
        all_checks = []
        if include_benchmark:
            all_checks += self._get_checks_from_benchmark()
        all_checks += self._get_checks_from_shared_directories()
        document_body = "".join(all_checks)
        return document_body

    def _get_checks_from_benchmark(self):
        product_dir = self.product_yaml["product_dir"]
        relative_guide_dir = utils.required_key(self.env_yaml, "benchmark_root")
        guide_dir = os.path.abspath(
            os.path.join(product_dir, relative_guide_dir))
        additional_content_directories = self.env_yaml.get(
            "additional_content_directories", [])
        dirs_to_scan = [guide_dir]
        for rd in additional_content_directories:
            abspath = os.path.abspath(os.path.join(product_dir, rd))
            dirs_to_scan.append(abspath)
        rule_dirs = list(find_rule_dirs_in_paths(dirs_to_scan))
        oval_checks = self._process_directories(rule_dirs, True)
        return oval_checks

    def _get_checks_from_shared_directories(self):
        # earlier directory has higher priority
        reversed_dirs = self.shared_directories[::-1]
        oval_checks = self._process_directories(reversed_dirs, False)
        return oval_checks

    def _process_directories(self, directories, from_benchmark):
        oval_checks = []
        for directory in directories:
            if not os.path.exists(directory):
                continue
            oval_checks += self._process_directory(directory, from_benchmark)
        return oval_checks

    def _get_list_of_oval_files(self, directory, from_benchmark):
        if from_benchmark:
            oval_files = get_rule_dir_ovals(directory, self.product)
        else:
            oval_files = _list_full_paths(directory)
        return oval_files

    def _process_directory(self, directory, from_benchmark):
        try:
            context = self._get_context(directory, from_benchmark)
        except DocumentationNotComplete:
            return []
        oval_files = self._get_list_of_oval_files(directory, from_benchmark)
        oval_checks = self._get_directory_oval_checks(
            context, oval_files, from_benchmark)
        return oval_checks

    def _get_directory_oval_checks(self, context, oval_files, from_benchmark):
        oval_checks = []
        for file_path in oval_files:
            xml_content = self._process_oval_file(
                file_path, from_benchmark, context)
            if xml_content is None:
                continue
            oval_checks.append(xml_content)
        return oval_checks

    def _read_oval_file(self, file_path, context, from_benchmark):
        if from_benchmark or "checks_from_templates" not in file_path:
            xml_content = process_file_with_macros(file_path, context)
        else:
            with open(file_path, "r") as f:
                xml_content = f.read()
        return xml_content

    def _create_key(self, file_path, from_benchmark):
        if from_benchmark:
            rule_id = os.path.basename(
                (os.path.dirname(os.path.dirname(file_path))))
            oval_key = "%s.xml" % rule_id
        else:
            oval_key = os.path.basename(file_path)
        return oval_key

    def _process_oval_file(self, file_path, from_benchmark, context):
        if not file_path.endswith(".xml"):
            return None
        oval_key = self._create_key(file_path, from_benchmark)
        if _check_is_loaded(self.already_loaded, oval_key, self.oval_version):
            return None
        xml_content = self._read_oval_file(file_path, context, from_benchmark)
        if not self._manage_oval_file_xml_content(
                file_path, xml_content, from_benchmark):
            return None
        self.already_loaded[oval_key] = self.oval_version
        return xml_content

    def _check_affected(self, tree):
        definitions = tree.findall(".//{%s}definition" % (oval_ns))
        for definition in definitions:
            def_id = definition.get("id")
            affected = definition.findall(
                "./{%s}metadata/{%s}affected" % (oval_ns, oval_ns))
            if not affected:
                raise ValueError(
                    "Definition '%s' doesn't contain OVAL 'affected' element"
                    % (def_id))

    def _manage_oval_file_xml_content(
            self, file_path, xml_content, from_benchmark):
        oval_file_tree = _create_oval_tree_from_string(xml_content)
        self._check_affected(oval_file_tree)
        if not _check_is_applicable_for_product(xml_content, self.product):
            return False
        if not _check_oval_version_from_oval(oval_file_tree, self.oval_version):
            return False
        if from_benchmark:
            self._benchmark_specific_actions(
                file_path, xml_content, oval_file_tree)
        return True

    def _benchmark_specific_actions(
            self, file_path, xml_content, oval_file_tree):
        rule_id = os.path.basename(
            (os.path.dirname(os.path.dirname(file_path))))
        self._store_intermediate_file(rule_id, xml_content)
        if not _check_rule_id(oval_file_tree, rule_id):
            msg = "ERROR: OVAL definition in '%s' doesn't match rule ID '%s'." % (
                file_path, rule_id)
            print(msg, file=sys.stderr)
            sys.exit(1)

    def _get_context(self, directory, from_benchmark):
        if from_benchmark:
            rule_path = os.path.join(directory, "rule.yml")
            rule = Rule.from_yaml(rule_path, self.env_yaml)
            context = self._create_local_env_yaml_for_rule(rule)
        else:
            context = self.env_yaml
        return context

    def _create_local_env_yaml_for_rule(self, rule):
        local_env_yaml = dict()
        local_env_yaml.update(self.env_yaml)
        local_env_yaml['rule_id'] = rule.id_
        local_env_yaml['rule_title'] = rule.title
        prodtypes = parse_prodtype(rule.prodtype)
        local_env_yaml['products'] = prodtypes  # default is all
        return local_env_yaml

    def _store_intermediate_file(self, rule_id, xml_content):
        if not self.build_ovals_dir:
            return
        output_file_name = rule_id + ".xml"
        output_filepath = os.path.join(self.build_ovals_dir, output_file_name)
        with open(output_filepath, "w") as f:
            f.write(xml_content)
