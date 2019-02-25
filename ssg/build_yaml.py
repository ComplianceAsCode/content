from __future__ import absolute_import
from __future__ import print_function

import os
import os.path
import datetime
import sys

import yaml

from .constants import XCCDF_PLATFORM_TO_CPE
from .constants import PRODUCT_TO_CPE_MAPPING
from .rules import get_rule_dir_id, get_rule_dir_yaml, is_rule_dir

from .checks import is_cce_valid
from .yaml import open_and_expand, open_and_macro_expand
from .utils import required_key

from .xml import ElementTree as ET
from .shims import unicode_func


def add_sub_element(parent, tag, data):
    """
    Creates a new child element under parent with tag tag, and sets
    data as the content under the tag. In particular, data is a string
    to be parsed as an XML tree, allowing sub-elements of children to be
    added.

    If data should not be parsed as an XML tree, either escape the contents
    before passing into this function, or use ElementTree.SubElement().

    Returns the newly created subelement of type tag.
    """
    # This is used because our YAML data contain XML and XHTML elements
    # ET.SubElement() escapes the < > characters by &lt; and &gt;
    # and therefore it does not add child elements
    # we need to do a hack instead
    # TODO: Remove this function after we move to Markdown everywhere in SSG
    ustr = unicode_func("<{0}>{1}</{0}>").format(tag, data)

    try:
        element = ET.fromstring(ustr.encode("utf-8"))
    except Exception:
        msg = ("Error adding subelement to an element '{0}' from string: '{1}'"
               .format(parent.tag, ustr))
        raise RuntimeError(msg)

    parent.append(element)
    return element


def add_warning_elements(element, warnings):
    # The use of [{dict}, {dict}] in warnings is to handle the following
    # scenario where multiple warnings have the same category which is
    # valid in SCAP and our content:
    #
    # warnings:
    #     - general: Some general warning
    #     - general: Some other general warning
    #     - general: |-
    #         Some really long multiline general warning
    #
    # Each of the {dict} should have only one key/value pair.
    for warning_dict in warnings:
        warning = add_sub_element(element, "warning", list(warning_dict.values())[0])
        warning.set("category", list(warning_dict.keys())[0])


class Profile(object):
    """Represents XCCDF profile
    """

    def __init__(self, id_):
        self.id_ = id_
        self.title = ""
        self.description = ""
        self.extends = None
        self.selections = []

    @staticmethod
    def from_yaml(yaml_file, env_yaml=None):
        yaml_contents = open_and_expand(yaml_file, env_yaml)
        if yaml_contents is None:
            return None

        basename, _ = os.path.splitext(os.path.basename(yaml_file))

        profile = Profile(basename)
        profile.title = required_key(yaml_contents, "title")
        del yaml_contents["title"]
        profile.description = required_key(yaml_contents, "description")
        del yaml_contents["description"]
        profile.extends = yaml_contents.pop("extends", None)
        profile.selections = required_key(yaml_contents, "selections")
        del yaml_contents["selections"]

        if yaml_contents:
            raise RuntimeError("Unparsed YAML data in '%s'.\n\n%s"
                               % (yaml_file, yaml_contents))

        return profile

    def to_xml_element(self):
        element = ET.Element('Profile')
        element.set("id", self.id_)
        if self.extends:
            element.set("extends", self.extends)
        title = add_sub_element(element, "title", self.title)
        title.set("override", "true")
        desc = add_sub_element(element, "description", self.description)
        desc.set("override", "true")

        for selection in self.selections:
            if selection.startswith("!"):
                unselect = ET.Element("select")
                unselect.set("idref", selection[1:])
                unselect.set("selected", "false")
                element.append(unselect)
            elif "=" in selection:
                refine_value = ET.Element("refine-value")
                value_id, selector = selection.split("=", 1)
                refine_value.set("idref", value_id)
                refine_value.set("selector", selector)
                element.append(refine_value)
            else:
                select = ET.Element("select")
                select.set("idref", selection)
                select.set("selected", "true")
                element.append(select)

        return element


class Value(object):
    """Represents XCCDF Value
    """

    def __init__(self, id_):
        self.id_ = id_
        self.title = ""
        self.description = ""
        self.type_ = "string"
        self.operator = "equals"
        self.interactive = False
        self.options = {}
        self.warnings = []

    @staticmethod
    def from_yaml(yaml_file, env_yaml=None):
        yaml_contents = open_and_expand(yaml_file, env_yaml)
        if yaml_contents is None:
            return None

        value_id, _ = os.path.splitext(os.path.basename(yaml_file))
        value = Value(value_id)
        value.title = required_key(yaml_contents, "title")
        del yaml_contents["title"]
        value.description = required_key(yaml_contents, "description")
        del yaml_contents["description"]
        value.type_ = required_key(yaml_contents, "type")
        del yaml_contents["type"]
        value.operator = yaml_contents.pop("operator", "equals")
        possible_operators = ["equals", "not equal", "greater than",
                              "less than", "greater than or equal",
                              "less than or equal", "pattern match"]

        if value.operator not in possible_operators:
            raise ValueError(
                "Found an invalid operator value '%s' in '%s'. "
                "Expected one of: %s"
                % (value.operator, yaml_file, ", ".join(possible_operators))
            )

        value.interactive = \
            yaml_contents.pop("interactive", "false").lower() == "true"

        value.options = required_key(yaml_contents, "options")
        del yaml_contents["options"]
        value.warnings = yaml_contents.pop("warnings", [])

        for warning_list in value.warnings:
            if len(warning_list) != 1:
                raise ValueError("Only one key/value pair should exist for each dictionary")

        if yaml_contents:
            raise RuntimeError("Unparsed YAML data in '%s'.\n\n%s"
                               % (yaml_file, yaml_contents))

        return value

    def to_xml_element(self):
        value = ET.Element('Value')
        value.set('id', self.id_)
        value.set('type', self.type_)
        if self.operator != "equals":  # equals is the default
            value.set('operator', self.operator)
        if self.interactive:  # False is the default
            value.set('interactive', 'true')
        title = ET.SubElement(value, 'title')
        title.text = self.title
        add_sub_element(value, 'description', self.description)
        add_warning_elements(value, self.warnings)

        for selector, option in self.options.items():
            # do not confuse Value with big V with value with small v
            # value is child element of Value
            value_small = ET.SubElement(value, 'value')
            # by XCCDF spec, default value is value without selector
            if selector != "default":
                value_small.set('selector', str(selector))
            value_small.text = str(option)

        return value

    def to_file(self, file_name):
        root = self.to_xml_element()
        tree = ET.ElementTree(root)
        tree.write(file_name)


class Benchmark(object):
    """Represents XCCDF Benchmark
    """
    def __init__(self, id_):
        self.id_ = id_
        self.title = ""
        self.status = ""
        self.description = ""
        self.notice_id = ""
        self.notice_description = ""
        self.front_matter = ""
        self.rear_matter = ""
        self.cpes = []
        self.version = "0.1"
        self.profiles = []
        self.values = {}
        self.bash_remediation_fns_group = None
        self.groups = {}
        self.rules = {}

        # This is required for OCIL clauses
        conditional_clause = Value("conditional_clause")
        conditional_clause.title = "A conditional clause for check statements."
        conditional_clause.description = conditional_clause.title
        conditional_clause.type_ = "string"
        conditional_clause.options = {"": "This is a placeholder"}

        self.add_value(conditional_clause)

    @staticmethod
    def from_yaml(yaml_file, id_, product_yaml=None):
        yaml_contents = open_and_macro_expand(yaml_file, product_yaml)
        if yaml_contents is None:
            return None

        benchmark = Benchmark(id_)
        benchmark.title = required_key(yaml_contents, "title")
        del yaml_contents["title"]
        benchmark.status = required_key(yaml_contents, "status")
        del yaml_contents["status"]
        benchmark.description = required_key(yaml_contents, "description")
        del yaml_contents["description"]
        notice_contents = required_key(yaml_contents, "notice")
        benchmark.notice_id = required_key(notice_contents, "id")
        del notice_contents["id"]
        benchmark.notice_description = required_key(notice_contents,
                                                    "description")
        del notice_contents["description"]
        if not notice_contents:
            del yaml_contents["notice"]

        benchmark.front_matter = required_key(yaml_contents,
                                              "front-matter")
        del yaml_contents["front-matter"]
        benchmark.rear_matter = required_key(yaml_contents,
                                             "rear-matter")
        del yaml_contents["rear-matter"]
        benchmark.version = str(required_key(yaml_contents, "version"))
        del yaml_contents["version"]

        if yaml_contents:
            raise RuntimeError("Unparsed YAML data in '%s'.\n\n%s"
                               % (yaml_file, yaml_contents))

        if product_yaml:
            benchmark.cpes = PRODUCT_TO_CPE_MAPPING[product_yaml["product"]]

        return benchmark

    def add_profiles_from_dir(self, action, dir_, env_yaml):
        for dir_item in os.listdir(dir_):
            dir_item_path = os.path.join(dir_, dir_item)
            if not os.path.isfile(dir_item_path):
                continue

            _, ext = os.path.splitext(os.path.basename(dir_item_path))
            if ext != '.profile':
                sys.stderr.write(
                    "Encountered file '%s' while looking for profiles, "
                    "extension '%s' is unknown. Skipping..\n"
                    % (dir_item, ext)
                )
                continue

            self.profiles.append(Profile.from_yaml(dir_item_path, env_yaml))
            if action == "list-inputs":
                print(dir_item_path)

    def add_bash_remediation_fns_from_file(self, action, file_):
        if action == "list-inputs":
            print(file_)
        else:
            tree = ET.parse(file_)
            self.bash_remediation_fns_group = tree.getroot()

    def to_xml_element(self):
        root = ET.Element('Benchmark')
        root.set('xmlns:xsi', 'http://www.w3.org/2001/XMLSchema-instance')
        root.set('xmlns:xhtml', 'http://www.w3.org/1999/xhtml')
        root.set('xmlns:dc', 'http://purl.org/dc/elements/1.1/')
        root.set('id', 'product-name')
        root.set('xsi:schemaLocation',
                 'http://checklists.nist.gov/xccdf/1.1 xccdf-1.1.4.xsd')
        root.set('style', 'SCAP_1.1')
        root.set('resolved', 'false')
        root.set('xml:lang', 'en-US')
        status = ET.SubElement(root, 'status')
        status.set('date', datetime.date.today().strftime("%Y-%m-%d"))
        status.text = self.status
        add_sub_element(root, "title", self.title)
        add_sub_element(root, "description", self.description)
        notice = add_sub_element(root, "notice", self.notice_description)
        notice.set('id', self.notice_id)
        add_sub_element(root, "front-matter", self.front_matter)
        add_sub_element(root, "rear-matter", self.rear_matter)

        for idref in self.cpes:
            plat = ET.SubElement(root, "platform")
            plat.set("idref", idref)

        version = ET.SubElement(root, 'version')
        version.text = self.version
        ET.SubElement(root, "metadata")

        for profile in self.profiles:
            if profile is not None:
                root.append(profile.to_xml_element())

        for value in self.values.values():
            root.append(value.to_xml_element())
        if self.bash_remediation_fns_group is not None:
            root.append(self.bash_remediation_fns_group)
        for group in self.groups.values():
            root.append(group.to_xml_element())
        for rule in self.rules.values():
            root.append(rule.to_xml_element())

        return root

    def to_file(self, file_name):
        root = self.to_xml_element()
        tree = ET.ElementTree(root)
        tree.write(file_name)

    def add_value(self, value):
        if value is None:
            return
        self.values[value.id_] = value

    def add_group(self, group):
        if group is None:
            return
        self.groups[group.id_] = group

    def add_rule(self, rule):
        if rule is None:
            return
        self.rules[rule.id_] = rule

    def to_xccdf(self):
        """We can easily extend this script to generate a valid XCCDF instead
        of SSG SHORTHAND.
        """
        raise NotImplementedError

    def __str__(self):
        return self.id_


class Group(object):
    """Represents XCCDF Group
    """
    def __init__(self, id_):
        self.id_ = id_
        self.prodtype = "all"
        self.title = ""
        self.description = ""
        self.warnings = []
        self.values = {}
        self.groups = {}
        self.rules = {}
        self.platform = None

    @staticmethod
    def from_yaml(yaml_file, env_yaml=None):
        yaml_contents = open_and_macro_expand(yaml_file, env_yaml)
        if yaml_contents is None:
            return None

        group_id = os.path.basename(os.path.dirname(yaml_file))
        group = Group(group_id)
        group.prodtype = yaml_contents.pop("prodtype", "all")
        group.title = required_key(yaml_contents, "title")
        del yaml_contents["title"]
        group.description = required_key(yaml_contents, "description")
        del yaml_contents["description"]
        group.warnings = yaml_contents.pop("warnings", [])
        group.platform = yaml_contents.pop("platform", None)

        for warning_list in group.warnings:
            if len(warning_list) != 1:
                raise ValueError("Only one key/value pair should exist for each dictionary")

        if yaml_contents:
            raise RuntimeError("Unparsed YAML data in '%s'.\n\n%s"
                               % (yaml_file, yaml_contents))

        return group

    def to_xml_element(self):
        group = ET.Element('Group')
        group.set('id', self.id_)
        if self.prodtype != "all":
            group.set("prodtype", self.prodtype)
        title = ET.SubElement(group, 'title')
        title.text = self.title
        add_sub_element(group, 'description', self.description)
        add_warning_elements(group, self.warnings)

        if self.platform:
            platform_el = ET.SubElement(group, "platform")
            try:
                platform_cpe = XCCDF_PLATFORM_TO_CPE[self.platform]
            except KeyError:
                raise ValueError("Unsupported platform '%s' in rule '%s'." % (self.platform, self.id_))
            platform_el.set("idref", platform_cpe)

        for _value in self.values.values():
            group.append(_value.to_xml_element())
        for _group in self.groups.values():
            group.append(_group.to_xml_element())
        for _rule in self.rules.values():
            group.append(_rule.to_xml_element())

        return group

    def to_file(self, file_name):
        root = self.to_xml_element()
        tree = ET.ElementTree(root)
        tree.write(file_name)

    def add_value(self, value):
        if value is None:
            return
        self.values[value.id_] = value

    def add_group(self, group):
        if group is None:
            return
        if self.platform and not group.platform:
            group.platform = self.platform
        self.groups[group.id_] = group

    def add_rule(self, rule):
        if rule is None:
            return
        if self.platform and not rule.platform:
            rule.platform = self.platform
        self.rules[rule.id_] = rule

    def __str__(self):
        return self.id_


class Rule(object):
    """Represents XCCDF Rule
    """
    YAML_KEYS_DEFAULTS = {
        "prodtype": lambda: "all",
        "title": lambda: RuntimeError("Missing key 'title'"),
        "description": lambda: RuntimeError("Missing key 'description'"),
        "rationale": lambda: RuntimeError("Missing key 'rationale'"),
        "severity": lambda: RuntimeError("Missing key 'severity'"),
        "references": lambda: dict(),
        "identifiers": lambda: dict(),
        "ocil_clause": lambda: None,
        "ocil": lambda: None,
        "oval_external_content": lambda: None,
        "warnings": lambda: list(),
        "platform": lambda: None,
    }

    def __init__(self, id_):
        self.id_ = id_
        self.prodtype = "all"
        self.title = ""
        self.description = ""
        self.rationale = ""
        self.severity = "unknown"
        self.references = {}
        self.identifiers = {}
        self.ocil_clause = None
        self.ocil = None
        self.oval_external_content = None
        self.warnings = []
        self.platform = None

    @staticmethod
    def from_yaml(yaml_file, env_yaml=None):
        yaml_contents = open_and_macro_expand(yaml_file, env_yaml)
        if yaml_contents is None:
            return None

        rule_id, ext = os.path.splitext(os.path.basename(yaml_file))
        if rule_id == "rule" and ext == ".yml":
            rule_id = get_rule_dir_id(yaml_file)

        rule = Rule(rule_id)

        try:
            rule._set_attributes_from_dict(yaml_contents)
        except RuntimeError as exc:
            msg = ("Error processing '{fname}': {err}"
                   .format(fname=yaml_file, err=str(exc)))
            raise RuntimeError(msg)

        for warning_list in rule.warnings:
            if len(warning_list) != 1:
                raise ValueError("Only one key/value pair should exist for each dictionary")

        if yaml_contents:
            raise RuntimeError("Unparsed YAML data in '%s'.\n\n%s"
                               % (yaml_file, yaml_contents))

        rule.validate_identifiers(yaml_file)
        rule.validate_references(yaml_file)
        return rule

    def _set_attributes_from_dict(self, yaml_contents):
        for key, default_getter in self.YAML_KEYS_DEFAULTS.items():
            if key not in yaml_contents:
                value = default_getter()
                if isinstance(value, Exception):
                    raise value
            else:
                value = yaml_contents.pop(key)

            setattr(self, key, value)

    def to_contents_dict(self):
        """
        Returns a dictionary that is the same schema as the dict obtained when loading rule YAML.
        """

        yaml_contents = dict()
        for key in Rule.YAML_KEYS_DEFAULTS:
            yaml_contents[key] = getattr(self, key)

        return yaml_contents

    def validate_identifiers(self, yaml_file):
        if self.identifiers is None:
            raise ValueError("Empty identifier section in file %s" % yaml_file)

        # Validate all identifiers are non-empty:
        for ident_type, ident_val in self.identifiers.items():
            if not isinstance(ident_type, str) or not isinstance(ident_val, str):
                raise ValueError("Identifiers and values must be strings: %s in file %s"
                                 % (ident_type, yaml_file))
            if ident_val.strip() == "":
                raise ValueError("Identifiers must not be empty: %s in file %s"
                                 % (ident_type, yaml_file))
            if ident_type[0:3] == 'cce':
                if not is_cce_valid("CCE-" + ident_val):
                    raise ValueError("CCE Identifiers must be valid: value %s for cce %s"
                                     " in file %s" % (ident_val, ident_type, yaml_file))

    def validate_references(self, yaml_file):
        if self.references is None:
            raise ValueError("Empty references section in file %s" % yaml_file)

        for ref_type, ref_val in self.references.items():
            if not isinstance(ref_type, str) or not isinstance(ref_val, str):
                raise ValueError("References and values must be strings: %s in file %s"
                                 % (ref_type, yaml_file))
            if ref_val.strip() == "":
                raise ValueError("References must not be empty: %s in file %s"
                                 % (ref_type, yaml_file))

    def to_xml_element(self):
        rule = ET.Element('Rule')
        rule.set('id', self.id_)
        if self.prodtype != "all":
            rule.set("prodtype", self.prodtype)
        rule.set('severity', self.severity)
        add_sub_element(rule, 'title', self.title)
        add_sub_element(rule, 'description', self.description)
        add_sub_element(rule, 'rationale', self.rationale)

        main_ident = ET.Element('ident')
        for ident_type, ident_val in self.identifiers.items():
            if '@' in ident_type:
                # the ident is applicable only on some product
                # format : 'policy@product', eg. 'stigid@product'
                # for them, we create a separate <ref> element
                policy, product = ident_type.split('@')
                ident = ET.SubElement(rule, 'ident')
                ident.set(policy, ident_val)
                ident.set('prodtype', product)
            else:
                main_ident.set(ident_type, ident_val)

        if main_ident.attrib:
            rule.append(main_ident)

        main_ref = ET.Element('ref')
        for ref_type, ref_val in self.references.items():
            if '@' in ref_type:
                # the reference is applicable only on some product
                # format : 'policy@product', eg. 'stigid@product'
                # for them, we create a separate <ref> element
                policy, product = ref_type.split('@')
                ref = ET.SubElement(rule, 'ref')
                ref.set(policy, ref_val)
                ref.set('prodtype', product)
            else:
                main_ref.set(ref_type, ref_val)

        if main_ref.attrib:
            rule.append(main_ref)

        if self.oval_external_content:
            check = ET.SubElement(rule, 'check')
            check.set("system", "http://oval.mitre.org/XMLSchema/oval-definitions-5")
            external_content = ET.SubElement(check, "check-content-ref")
            external_content.set("href", self.oval_external_content)
        else:
            # TODO: This is pretty much a hack, oval ID will be the same as rule ID
            #       and we don't want the developers to have to keep them in sync.
            #       Therefore let's just add an OVAL ref of that ID.
            oval_ref = ET.SubElement(rule, "oval")
            oval_ref.set("id", self.id_)

        if self.ocil or self.ocil_clause:
            ocil = add_sub_element(rule, 'ocil', self.ocil if self.ocil else "")
            if self.ocil_clause:
                ocil.set("clause", self.ocil_clause)

        add_warning_elements(rule, self.warnings)

        if self.platform:
            platform_el = ET.SubElement(rule, "platform")
            try:
                platform_cpe = XCCDF_PLATFORM_TO_CPE[self.platform]
            except KeyError:
                raise ValueError("Unsupported platform '%s' in rule '%s'." % (self.platform, self.id_))
            platform_el.set("idref", platform_cpe)

        return rule

    def to_file(self, file_name):
        root = self.to_xml_element()
        tree = ET.ElementTree(root)
        tree.write(file_name)


class DirectoryLoader(object):
    def __init__(self, profiles_dir, bash_remediation_fns, env_yaml):
        self.benchmark_file = None
        self.group_file = None
        self.loaded_group = None
        self.rules = []
        self.values = []
        self.subdirectories = []

        self.profiles_dir = profiles_dir
        self.bash_remediation_fns = bash_remediation_fns
        self.env_yaml = env_yaml

        self.parent_group = None

    def _collect_items_to_load(self, guide_directory):
        for dir_item in os.listdir(guide_directory):
            dir_item_path = os.path.join(guide_directory, dir_item)
            _, extension = os.path.splitext(dir_item)

            if extension == '.var':
                self.values.append(dir_item_path)
            elif dir_item == "benchmark.yml":
                if self.benchmark_file:
                    raise ValueError("Multiple benchmarks in one directory")
                self.benchmark_file = dir_item_path
            elif dir_item == "group.yml":
                if self.group_file:
                    raise ValueError("Multiple groups in one directory")
                self.group_file = dir_item_path
            elif extension == '.rule':
                self.rules.append(dir_item_path)
            elif is_rule_dir(dir_item_path):
                self.rules.append(get_rule_dir_yaml(dir_item_path))
            elif dir_item != "tests":
                if os.path.isdir(dir_item_path):
                    self.subdirectories.append(dir_item_path)
                else:
                    sys.stderr.write(
                        "Encountered file '%s' while recursing, extension '%s' "
                        "is unknown. Skipping..\n"
                        % (dir_item, extension)
                    )

    def load_benchmark_or_group(self, guide_directory):
        """
        Loads a given benchmark or group from the specified benchmark_file or
        group_file, in the context of guide_directory, action, profiles_dir,
        env_yaml, and bash_remediation_fns.

        Returns the loaded group or benchmark.
        """
        group = None
        if self.group_file and self.benchmark_file:
            raise ValueError("A .benchmark file and a .group file were found in "
                             "the same directory '%s'" % (guide_directory))

        # we treat benchmark as a special form of group in the following code
        if self.benchmark_file:
            group = Benchmark.from_yaml(
                self.benchmark_file, 'product-name', self.env_yaml
            )
            if self.profiles_dir:
                group.add_profiles_from_dir(self.action, self.profiles_dir, self.env_yaml)
            group.add_bash_remediation_fns_from_file(self.action, self.bash_remediation_fns)

        if self.group_file:
            group = Group.from_yaml(self.group_file, self.env_yaml)

        return group

    def _load_group_process_and_recurse(self, guide_directory):
        self.loaded_group = self.load_benchmark_or_group(guide_directory)

        if self.loaded_group:
            if self.parent_group:
                self.parent_group.add_group(self.loaded_group)

            self._process_values()
            self._recurse_into_subdirs()
            self._process_rules()

    def process_directory_tree(self, start_dir):
        self._collect_items_to_load(start_dir)
        self._load_group_process_and_recurse(start_dir)

    def _recurse_into_subdirs(self):
        for subdir in self.subdirectories:
            loader = self._get_new_loader()
            loader.parent_group = self.loaded_group
            loader.process_directory_tree(subdir)

    def _get_new_loader(self):
        raise NotImplementedError()

    def _process_values(self):
        raise NotImplementedError()

    def _process_rules(self):
        raise NotImplementedError()


class BuildLoader(DirectoryLoader):
    def __init__(self, profiles_dir, bash_remediation_fns, env_yaml, resolved_rules_dir=None):
        super(BuildLoader, self).__init__(profiles_dir, bash_remediation_fns, env_yaml)

        self.action = "build"

        self.resolved_rules_dir = resolved_rules_dir
        if resolved_rules_dir and not os.path.isdir(resolved_rules_dir):
            os.mkdir(resolved_rules_dir)

    def _process_values(self):
        for value_yaml in self.values:
            value = Value.from_yaml(value_yaml, self.env_yaml)
            self.loaded_group.add_value(value)

    def _process_rules(self):
        for rule_yaml in self.rules:
            rule = Rule.from_yaml(rule_yaml, self.env_yaml)
            if self.resolved_rules_dir:
                output_for_rule = os.path.join(
                    self.resolved_rules_dir, "{id_}.yml".format(id_=rule.id_))
                with open(output_for_rule, "w") as f:
                    yaml.dump(rule.to_contents_dict(), f)
            self.loaded_group.add_rule(rule)

    def _get_new_loader(self):
        return BuildLoader(
            self.profiles_dir, self.bash_remediation_fns, self.env_yaml, self.resolved_rules_dir)

    def export_group_to_file(self, filename):
        return self.loaded_group.to_file(filename)


class ListInputsLoader(DirectoryLoader):
    def __init__(self, profiles_dir, bash_remediation_fns, env_yaml):
        super(ListInputsLoader, self).__init__(profiles_dir, bash_remediation_fns, env_yaml)

        self.action = "list-inputs"

    def _process_values(self):
        for value_yaml in self.values:
            print(value_yaml)

    def _process_rules(self):
        for rule_yaml in self.rules:
            print(rule_yaml)

    def _get_new_loader(self):
        return ListInputsLoader(
            self.profiles_dir, self.bash_remediation_fns, self.env_yaml)

    def load_benchmark_or_group(self, guide_directory):
        result = super(ListInputsLoader, self).load_benchmark_or_group(guide_directory)

        if self.benchmark_file:
            print(self.benchmark_file)

        if self.group_file:
            print(self.group_file)

        return result
