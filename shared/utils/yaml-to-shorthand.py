#!/usr/bin/python2

import argparse
import yaml
import os
import os.path
import datetime

try:
    from xml.etree import cElementTree as ET
except ImportError:
    import cElementTree as ET


class Benchmark(object):
    """Represents XCCDF Benchmark
    """
    def __init__(self, id_):
        self.id_ = id_
        self.values = {}
        self.groups = {}
        self.rules = {}

    @staticmethod
    def from_yaml(yaml_file, id_):
        yaml_contents = open_yaml(yaml_file)
        benchmark = Benchmark(id_)
        benchmark.title = yaml_contents["title"]
        benchmark.status = yaml_contents["status"]
        benchmark.description = yaml_contents["description"]
        benchmark.notice_id = yaml_contents["notice"]['id']
        benchmark.notice_description = yaml_contents['notice']["description"]
        benchmark.front_matter = yaml_contents["front-matter"]
        benchmark.rear_matter = yaml_contents["rear-matter"]
        benchmark.cpes = yaml_contents["cpes"]
        benchmark.version = str(yaml_contents["version"])
        return benchmark

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
        title = ET.SubElement(root, 'title')
        title.text = self.title
        description = ET.SubElement(root, 'description')
        description.text = self.description
        notice = ET.SubElement(root, 'notice')
        notice.set('id', self.notice_id)
        notice.text = self.notice_description
        front_matter = ET.SubElement(root, 'front-matter')
        front_matter.text = self.front_matter
        rear_matter = ET.SubElement(root, 'rear-matter')
        rear_matter.text = self.rear_matter
        version = ET.SubElement(root, 'version')
        version.text = self.version

        for v in self.values.values():
            root.append(v.to_xml_element())
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
        self.values[value.id_] = value

    def add_group(self, group):
        self.groups[group.id_] = group

    def add_rule(self, rule):
        self.rules[rule.id_] = rule

    def to_xccdf(self):
        """We can easily extend this script to generate a valid XCCDF instead
        of SSG SHORTHAND.
        """
        raise NotImplementedError

    def __str__(self):
        return self.id_


class Group(object):
    """
    Represents XCCDF Group
    """
    def __init__(self, id_):
        self.id_ = id_
        self.values = {}
        self.groups = {}
        self.rules = {}

    @staticmethod
    def from_yaml(yaml_file):
        yaml_contents = open_yaml(yaml_file)

        group_id, _ = os.path.splitext(os.path.basename(yaml_file))
        group = Group(group_id)
        group.title = yaml_contents['title']
        group.description = yaml_contents['description']
        return group

    def to_xml_element(self):
        group = ET.Element('Group')
        group.set('id', self.id_)
        title = ET.SubElement(group, 'title')
        title.text = self.title
        add_sub_element(group, 'description', self.description)
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
        self.values[value.id_] = value

    def add_group(self, group):
        self.groups[group.id_] = group

    def add_rule(self, rule):
        self.rules[rule.id_] = rule

    def __str__(self):
        return self.id_


class Rule(object):
    """Represents XCCDF Rule
    """
    def __init__(self, id_):
        self.id_ = id_

    @staticmethod
    def from_yaml(yaml_file):
        yaml_contents = open_yaml(yaml_file)
        rule_id, _ = os.path.splitext(os.path.basename(yaml_file))
        rule = Rule(rule_id)
        rule.title = yaml_contents['title']
        rule.description = yaml_contents['description']
        rule.rationale = yaml_contents['rationale']
        rule.severity = yaml_contents['severity']
        rule.references = yaml_contents.get('references')
        rule.identifiers = yaml_contents.get('identifiers')
        return rule

    def to_xml_element(self):
        rule = ET.Element('Rule')
        rule.set('id', self.id_)
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

        # TODO: This is pretty much a hack, oval ID will be the same as rule ID
        #       and we don't want the developers to have to keep them in sync.
        #       Therefore let's just add an OVAL ref of that ID.
        oval_ref = ET.SubElement(rule, "oval")
        oval_ref.set("id", self.id_)

        return rule

    def to_file(self, file_name):
        root = self.to_xml_element()
        tree = ET.ElementTree(root)
        tree.write(file_name)


class Value(object):
    """
    Represents XCCDF Value
    """

    def __init__(self, id_):
        self.id_ = id_

    @staticmethod
    def from_yaml(yaml_file):
        yaml_contents = open_yaml(yaml_file)
        value_id, _ = os.path.splitext(os.path.basename(yaml_file))
        value = Value(value_id)
        value.title = yaml_contents['title']
        value.description = yaml_contents['description']
        value.type = yaml_contents['type']
        value.options = yaml_contents['options']
        return value

    def to_xml_element(self):
        value = ET.Element('Value')
        value.set('id', self.id_)
        value.set('type', self.type)
        title = ET.SubElement(value, 'title')
        title.text = self.title
        add_sub_element(value, 'description', self.description)
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


def open_yaml(yaml_file):
    with open(yaml_file, 'r') as stream:
        yaml_contents = yaml.load(stream)
        return yaml_contents


def add_sub_element(parent, tag, data):
    # This is used because our YAML data contain XML and XHTML elements
    # ET.SubElement() escapes the < > characters by &lt; and &gt;
    # and therefore it does not add child elements
    # we need to do a hack instead
    # TODO: Remove this function after we move to Markdown everywhere in SSG
    element = ET.fromstring("<{0}>{1}</{0}>".format(tag, data))
    parent.append(element)
    return element


def add_from_directory(parent_group, directory, recurse, output_file):
    benchmark_file = None
    group_file = None
    rules = []
    values = []
    subdirectories = []
    for dir_item in os.listdir(directory):
        dir_item_path = os.path.join(directory, dir_item)
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
                print("Encountered file '%s' while recursing, extension '%s' "
                      "is unknown. Skipping.."
                      % (dir_item, extension))

    if group_file and benchmark_file:
        raise ValueError("A .benchmark file and a .group file were found in "
                         "the same directory '%s'" % (directory))

    # we treat benchmark as a special form of group in the following code
    group = None
    if benchmark_file:
        group = Benchmark.from_yaml(benchmark_file, 'product-name')

    if group_file:
        group = Group.from_yaml(group_file)

    if group is not None:
        for value_yaml in values:
            value = Value.from_yaml(value_yaml)
            group.add_value(value)
        if recurse:
            for subdir in subdirectories:
                add_from_directory(group, subdir, recurse, output_file)
        for rule_yaml in rules:
            rule = Rule.from_yaml(rule_yaml)
            group.add_rule(rule)

        if parent_group:
            parent_group.add_group(group)
        else:
            # We are on the top level!
            # Lets dump the XCCDF group or benchmark to a file
            group.to_file(output_file)


def main():
    parser = argparse.ArgumentParser(
        description="Converts SCAP Security Guide YAML benchmark data "
        "(benchmark, rules, groups) to XCCDF Shorthand Format"
    )
    parser.add_argument(
        "--source_dir", required=True,
        help="Input directory with the YAML structure, "
        "e.g.: ~/scap-security-guide/shared/guide/services/ntp"
    )
    parser.add_argument("--output", required=True,
                        help="Output XCCDF shorthand file. "
                        "e.g.: /tmp/shorthand.xml")
    parser.add_argument("--recurse", action="store_true",
                        help="Include subdirectories.")
    args = parser.parse_args()

    add_from_directory(None, args.source_dir, args.recurse, args.output)


if __name__ == "__main__":
    main()
