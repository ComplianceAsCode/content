#!/usr/bin/python2

from __future__ import print_function

import argparse
import os
import os.path
import datetime
import sys


try:
    from xml.etree import cElementTree as ET
except ImportError:
    import cElementTree as ET

# Put shared python modules in path
sys.path.insert(0, os.path.join(
        os.path.dirname(os.path.dirname(os.path.realpath(__file__))),
        "modules"))
from ssgcommon import required_yaml_key
import ssgcommon


def add_sub_element(parent, tag, data):
    # This is used because our YAML data contain XML and XHTML elements
    # ET.SubElement() escapes the < > characters by &lt; and &gt;
    # and therefore it does not add child elements
    # we need to do a hack instead
    # TODO: Remove this function after we move to Markdown everywhere in SSG
    try:
        ustr = unicode("<{0}>{1}</{0}>").format(tag, data)
    except NameError:
        ustr = str("<{0}>{1}</{0}>").format(tag, data)

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
    def from_yaml(yaml_file, product_yaml=None):
        yaml_contents = ssgcommon.open_and_expand_yaml(yaml_file, product_yaml)
        if yaml_contents is None:
            return None

        basename, _ = os.path.splitext(os.path.basename(yaml_file))

        profile = Profile(basename)
        profile.title = required_yaml_key(yaml_contents, "title")
        del yaml_contents["title"]
        profile.description = required_yaml_key(yaml_contents, "description")
        del yaml_contents["description"]
        profile.extends = yaml_contents.pop("extends", None)
        profile.selections = required_yaml_key(yaml_contents, "selections")
        del yaml_contents["selections"]

        if yaml_contents:
            raise RuntimeError("Unparsed YAML data in '%s'.\n\n%s"
                               % (yaml_file, yaml_contents))

        return profile

    def to_xml_element(self):
        el = ET.Element('Profile')
        el.set("id", self.id_)
        if self.extends:
            el.set("extends", self.extends)
        title = add_sub_element(el, "title", self.title)
        title.set("override", "true")
        desc = add_sub_element(el, "description", self.description)
        desc.set("override", "true")

        for selection in self.selections:
            if selection.startswith("!"):
                unselect = ET.Element("select")
                unselect.set("idref", selection[1:])
                unselect.set("selected", "false")
                el.append(unselect)
            elif "=" in selection:
                refine_value = ET.Element("refine-value")
                value_id, selector = selection.split("=", 1)
                refine_value.set("idref", value_id)
                refine_value.set("selector", selector)
                el.append(refine_value)
            else:
                select = ET.Element("select")
                select.set("idref", selection)
                select.set("selected", "true")
                el.append(select)

        return el


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
    def from_yaml(yaml_file, product_yaml=None):
        yaml_contents = ssgcommon.open_and_expand_yaml(yaml_file, product_yaml)
        if yaml_contents is None:
            return None

        value_id, _ = os.path.splitext(os.path.basename(yaml_file))
        value = Value(value_id)
        value.title = required_yaml_key(yaml_contents, "title")
        del yaml_contents["title"]
        value.description = required_yaml_key(yaml_contents, "description")
        del yaml_contents["description"]
        value.type_ = required_yaml_key(yaml_contents, "type")
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

        value.options = required_yaml_key(yaml_contents, "options")
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
        yaml_contents = ssgcommon.open_and_expand_yaml(yaml_file, product_yaml)
        if yaml_contents is None:
            return None

        benchmark = Benchmark(id_)
        benchmark.title = required_yaml_key(yaml_contents, "title")
        del yaml_contents["title"]
        benchmark.status = required_yaml_key(yaml_contents, "status")
        del yaml_contents["status"]
        benchmark.description = required_yaml_key(yaml_contents, "description")
        del yaml_contents["description"]
        notice_contents = required_yaml_key(yaml_contents, "notice")
        benchmark.notice_id = required_yaml_key(notice_contents, "id")
        del notice_contents["id"]
        benchmark.notice_description = required_yaml_key(notice_contents,
                                                         "description")
        del notice_contents["description"]
        if not notice_contents:
            del yaml_contents["notice"]

        benchmark.front_matter = required_yaml_key(yaml_contents,
                                                   "front-matter")
        del yaml_contents["front-matter"]
        benchmark.rear_matter = required_yaml_key(yaml_contents,
                                                  "rear-matter")
        del yaml_contents["rear-matter"]
        benchmark.cpes = yaml_contents.pop("cpes", [])
        benchmark.version = str(required_yaml_key(yaml_contents, "version"))
        del yaml_contents["version"]

        if yaml_contents:
            raise RuntimeError("Unparsed YAML data in '%s'.\n\n%s"
                               % (yaml_file, yaml_contents))

        return benchmark

    def add_profiles_from_dir(self, action, dir_, product_yaml):
        for dir_item in os.listdir(dir_):
            dir_item_path = os.path.join(dir_, dir_item)
            if not os.path.isfile(dir_item_path):
                continue

            basename, ext = os.path.splitext(os.path.basename(dir_item_path))
            if ext != '.profile':
                sys.stderr.write(
                    "Encountered file '%s' while looking for profiles, "
                    "extension '%s' is unknown. Skipping..\n"
                    % (dir_item, ext)
                )
                continue

            self.profiles.append(Profile.from_yaml(dir_item_path, product_yaml))
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
        for cpe in self.cpes:
            if "platform-cpes-macro" in cpe:
                ET.SubElement(root, "platform-cpes-macro")
            else:
                add_sub_element(root, "platform", cpe)
        version = ET.SubElement(root, 'version')
        version.text = self.version
        ET.SubElement(root, "metadata")

        for profile in self.profiles:
            if profile is not None:
                root.append(profile.to_xml_element())

        for v in self.values.values():
            root.append(v.to_xml_element())
        if self.bash_remediation_fns_group is not None:
            root.append(self.bash_remediation_fns_group)
        for g in self.groups.values():
            root.append(g.to_xml_element())
        for r in self.rules.values():
            root.append(r.to_xml_element())

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

    @staticmethod
    def from_yaml(yaml_file, product_yaml=None):
        yaml_contents = ssgcommon.open_and_macro_expand_yaml(yaml_file, product_yaml)
        if yaml_contents is None:
            return None

        group_id, _ = os.path.splitext(os.path.basename(yaml_file))
        group = Group(group_id)
        group.prodtype = yaml_contents.pop("prodtype", "all")
        group.title = required_yaml_key(yaml_contents, "title")
        del yaml_contents["title"]
        group.description = required_yaml_key(yaml_contents, "description")
        del yaml_contents["description"]
        group.warnings = yaml_contents.pop("warnings", [])

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

        for v in self.values.values():
            group.append(v.to_xml_element())
        for g in self.groups.values():
            group.append(g.to_xml_element())
        for r in self.rules.values():
            group.append(r.to_xml_element())

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
        self.groups[group.id_] = group

    def add_rule(self, rule):
        if rule is None:
            return
        self.rules[rule.id_] = rule

    def __str__(self):
        return self.id_


class Rule(object):
    """Represents XCCDF Rule
    """
    def __init__(self, id_):
        self.id_ = id_
        self.prodtype = "all"
        self.title = ""
        self.description = ""
        self.rationale = ""
        self.severity = "unknown"
        self.references = []
        self.identifiers = []
        self.ocil_clause = None
        self.ocil = None
        self.external_oval = None
        self.warnings = []

    @staticmethod
    def from_yaml(yaml_file, product_yaml=None):
        yaml_contents = ssgcommon.open_and_macro_expand_yaml(yaml_file, product_yaml)
        if yaml_contents is None:
            return None

        rule_id, _ = os.path.splitext(os.path.basename(yaml_file))
        rule = Rule(rule_id)
        rule.prodtype = yaml_contents.pop("prodtype", "all")
        rule.title = required_yaml_key(yaml_contents, "title")
        del yaml_contents["title"]
        rule.description = required_yaml_key(yaml_contents, "description")
        del yaml_contents["description"]
        rule.rationale = required_yaml_key(yaml_contents, "rationale")
        del yaml_contents["rationale"]
        rule.severity = required_yaml_key(yaml_contents, "severity")
        del yaml_contents["severity"]
        rule.references = yaml_contents.pop("references", [])
        rule.identifiers = yaml_contents.pop("identifiers", [])
        rule.ocil_clause = yaml_contents.pop("ocil_clause", None)
        rule.ocil = yaml_contents.pop("ocil", None)
        rule.external_oval = yaml_contents.pop("oval_external_content", None)
        rule.warnings = yaml_contents.pop("warnings", [])

        for warning_list in rule.warnings:
            if len(warning_list) != 1:
                raise ValueError("Only one key/value pair should exist for each dictionary")

        if yaml_contents:
            raise RuntimeError("Unparsed YAML data in '%s'.\n\n%s"
                               % (yaml_file, yaml_contents))

        return rule

    def to_xml_element(self):
        rule = ET.Element('Rule')
        rule.set('id', self.id_)
        if self.prodtype != "all":
            rule.set("prodtype", self.prodtype)
        rule.set('severity', self.severity)
        add_sub_element(rule, 'title', self.title)
        add_sub_element(rule, 'description', self.description)
        add_sub_element(rule, 'rationale', self.rationale)

        if self.identifiers:
            main_ident = ET.Element('ident')
            for ident_type, ident_val in self.identifiers.items():
                if '@' in ident_type:
                    # the ident is applicable only on some product
                    # format : 'policy@product', eg. 'stigid@product'
                    # for them, we create a separate <ref> element
                    policy, product = ident_type.split('@')
                    ident = ET.SubElement(rule, 'ident')
                    ident.set(policy, str(ident_val))
                    ident.set('prodtype', product)
                else:
                    main_ident.set(ident_type, str(ident_val))

            if main_ident.attrib:
                rule.append(main_ident)

        if self.references:
            main_ref = ET.Element('ref')
            for ref_type, ref_val in self.references.items():
                if '@' in ref_type:
                    # the reference is applicable only on some product
                    # format : 'policy@product', eg. 'stigid@product'
                    # for them, we create a separate <ref> element
                    policy, product = ref_type.split('@')
                    ref = ET.SubElement(rule, 'ref')
                    ref.set(policy, str(ref_val))
                    ref.set('prodtype', product)
                else:
                    main_ref.set(ref_type, str(ref_val))

            if main_ref.attrib:
                rule.append(main_ref)

        if self.external_oval:
            check = ET.SubElement(rule, 'check')
            check.set("system", "http://oval.mitre.org/XMLSchema/oval-definitions-5")
            external_content = ET.SubElement(check, "check-content-ref")
            external_content.set("href", self.external_oval)
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

        return rule

    def to_file(self, file_name):
        root = self.to_xml_element()
        tree = ET.ElementTree(root)
        tree.write(file_name)


def add_from_directory(action, parent_group, guide_directory, profiles_dir,
                       bash_remediation_fns, output_file, product_yaml):
    benchmark_file = None
    group_file = None
    rules = []
    values = []
    subdirectories = []
    for dir_item in os.listdir(guide_directory):
        dir_item_path = os.path.join(guide_directory, dir_item)
        if os.path.isdir(dir_item_path):
            subdirectories.append(dir_item_path)
        else:
            name, extension = os.path.splitext(dir_item)
            if extension == '.var':
                values.append(dir_item_path)
            elif extension == '.benchmark':
                if benchmark_file:
                    raise ValueError("Multiple benchmarks in one directory")
                benchmark_file = dir_item_path
            elif extension == '.group':
                if group_file:
                    raise ValueError("Multiple groups in one directory")
                group_file = dir_item_path
            elif extension == '.rule':
                rules.append(dir_item_path)
            else:
                sys.stderr.write(
                    "Encountered file '%s' while recursing, extension '%s' "
                    "is unknown. Skipping..\n"
                    % (dir_item, extension)
                )

    if group_file and benchmark_file:
        raise ValueError("A .benchmark file and a .group file were found in "
                         "the same directory '%s'" % (guide_directory))

    # we treat benchmark as a special form of group in the following code
    group = None
    if benchmark_file:
        group = Benchmark.from_yaml(
            benchmark_file, 'product-name', product_yaml
        )
        if profiles_dir:
            group.add_profiles_from_dir(action, profiles_dir, product_yaml)
        group.add_bash_remediation_fns_from_file(action, bash_remediation_fns)
        if action == "list-inputs":
            print(benchmark_file)

    if group_file:
        group = Group.from_yaml(group_file, product_yaml)
        if action == "list-inputs":
            print(group_file)

    if group is not None:
        for value_yaml in values:
            if action == "list-inputs":
                print(value_yaml)
            else:
                value = Value.from_yaml(value_yaml, product_yaml)
                group.add_value(value)

        for subdir in subdirectories:
            add_from_directory(action, group, subdir, profiles_dir,
                               bash_remediation_fns, output_file,
                               product_yaml)

        for rule_yaml in rules:
            if action == "list-inputs":
                print(rule_yaml)
            else:
                rule = Rule.from_yaml(rule_yaml, product_yaml)
                group.add_rule(rule)

        if parent_group:
            parent_group.add_group(group)
        else:
            # We are on the top level!
            # Lets dump the XCCDF group or benchmark to a file
            if action == "build":
                group.to_file(output_file)


def main():
    parser = argparse.ArgumentParser(
        description="Converts SCAP Security Guide YAML benchmark data "
        "(benchmark, rules, groups) to XCCDF Shorthand Format"
    )
    parser.add_argument(
        "--product-yaml", required=True, dest="product_yaml",
        help="YAML file with information about the product we are building. "
        "e.g.: ~/scap-security-guide/rhel7/product.yml"
    )
    parser.add_argument("--bash_remediation_fns", required=True,
                        help="XML with the XCCDF Group containing all bash "
                        "remediation functions stored as values."
                        "e.g.: build/bash-remediation-functions.xml")
    parser.add_argument("--output", required=True,
                        help="Output XCCDF shorthand file. "
                        "e.g.: /tmp/shorthand.xml")
    parser.add_argument("action",
                        choices=["build", "list-inputs", "list-outputs"],
                        help="Which action to perform.")
    args = parser.parse_args()

    # save a whole bunch of time
    if args.action == "list-outputs":
        print(args.output)
        sys.exit(0)

    product_yaml = ssgcommon.open_yaml(args.product_yaml)
    base_dir = os.path.dirname(args.product_yaml)
    benchmark_root = required_yaml_key(product_yaml, "benchmark_root")
    profiles_root = required_yaml_key(product_yaml, "profiles_root")
    # we have to "absolutize" the paths the right way, relative to the
    # product yaml path
    if not os.path.isabs(benchmark_root):
        benchmark_root = os.path.join(base_dir, benchmark_root)
    if not os.path.isabs(profiles_root):
        profiles_root = os.path.join(base_dir, profiles_root)

    add_from_directory(args.action, None, benchmark_root, profiles_root,
                       args.bash_remediation_fns, args.output, product_yaml)


if __name__ == "__main__":
    main()
