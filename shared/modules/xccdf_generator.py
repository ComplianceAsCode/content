import os
import os.path
import re
import sys
import argparse
import datetime
import yaml

from xccdf_macros import *

from collections import defaultdict


SUFFIX_TO_SYSTEM = {
    ".yml": "urn:xccdf:fix:script:ansible",
    ".sh": "urn:xccdf:fix:script:sh",
    ".anaconda": "urn:redhat:anaconda:pre",
    ".pp": "urn:xccdf:fix:script:puppet",
    ".chef": "urn:xccdf:fix:script:chef",
    ".rb": "urn:xccdf:fix:script:ruby",
    ".py": "urn:xccdf:fix:script:python",
}

try:
    from xml.etree import cElementTree as ET
except ImportError:
    import cElementTree as ET

try:
    set
except NameError:
    # for python2
    from sets import Set as set


xccdf_ns = {"xsi": "http://www.w3.org/2001/XMLSchema-instance",
            "xhtml": "http://www.w3.org/1999/xhtml",
            "dc": "http://purl.org/dc/elements/1.1/"}

# Temporary: Need to remove later
script_extensions = (".yml", ".sh", ".anaconda", ".pp", ".rb", "chef", "py")

datestamp = datetime.datetime.utcnow().strftime("%Y-%m-%d")


def yaml_key_value(content, key):
    try:
        return content[key]
    except KeyError as e:
        print("Key error " + str(e))
    else:
        raise


def custom_sort(files_list, ordered_list):
    custom_list = []

    for order in ordered_list:
        for files in files_list:
            if files.endswith(order):
                custom_list.append(files)

    return custom_list


def read_content_in_dirs(directory):
    guide_files = []
    script_files = []

    for dirs in directory:
        for root, dirs, files in sorted(os.walk(dirs)):
            for filename in sorted(files):
                filename = os.path.join(root, filename)
                if filename.endswith(ssg_guide_extensions):
                    guide_files.append(filename)
                if filename.endswith(script_extensions):
                    script_files.append(filename)

    return (guide_files, script_files)


def add_sub_group(xccdftree, xccdf_element, yamlcontent, yaml_key, xccdf_subelement):
    yaml_key = yaml_key_value(yamlcontent, yaml_key)

    if yaml_key:
        for elem in xccdftree.iter("Group"):
            if elem.attrib["id"] == yaml_key:
                elem.append(xccdf_subelement)
        return xccdftree
    else:
        return xccdftree.append(xccdf_subelement)

def add_sub_rule(xccdftree, xccdf_element, yamlcontent, yaml_key, xccdf_subelement):
    print("Add_sub_rule")
    yaml_key = yaml_key_value(yamlcontent, yaml_key)

    if yaml_key:
        to_append = None
        for elem in xccdftree.iter("Group"):
            if elem.attrib["id"] == yaml_key:
                print(elem.attrib["id"])
                to_append = elem
        to_append.append(xccdf_subelement)
        print("Return add_ssub_rule")
        return xccdftree
    else:
        return xccdftree.append(xccdf_subelement)


def add_attrib_to_element(xccdf_element, dictionary, yamlcontent=None):
    for key, value in dictionary.items():
        if yamlcontent is not None:
            if yaml_key_value(yamlcontent, value) is not None:
                xccdf_element.set(key, str(yaml_key_value(yamlcontent, value)))
        else:
            xccdf_element.set(key, value)

    return xccdf_element


def xccdf_element(xccdf_element, yamlcontent, yaml_key=None, attrib=None):
    yaml_key = yaml_key_value(yamlcontent, yaml_key)

    new_element = ET.Element(xccdf_element)

    if attrib is not None:
        new_element = add_attrib_to_element(new_element, attrib, yamlcontent)

    return new_element


def xccdf_subelement(xccdftree, xccdf_element, yamlcontent, yaml_key, override=None, attrib=None):
    yaml_key = yaml_key_value(yamlcontent, yaml_key)

    if yaml_key:
        new_element = ET.SubElement(xccdftree, xccdf_element)
        if type(yaml_key) is dict:
            if 'id' in yaml_key.keys():
                new_element.set("id", yaml_key["id"])
            if "clause" in yaml_key.keys():
                new_element.set("clause", yaml_key["clause"])
            if "description" in yaml_key.keys():
                new_element = transform_text_variables(new_element, yaml_key["description"])
        else:
            if xccdf_element is not "oval":
                new_element = transform_text_variables(new_element, str(yaml_key))
        if yaml_key_value(yamlcontent, override) is not None:
            new_element.set("override", str(yaml_key_value(yamlcontent, override)).lower())
        if attrib is not None:
            if type(attrib) is dict:
                new_element = add_attrib_to_element(new_element, attrib, yamlcontent)
            else:
                new_element = add_attrib_to_element(new_element, attrib)

    return xccdftree


def xccdf_multiple_subelements(xccdftree, xccdf_element, yamlcontent, yaml_key):
    yaml_key = yaml_key_value(yamlcontent, yaml_key)
    value = ""
    attrib_type = "idref"
    attrib = "true"

    if yaml_key:
        if type(yaml_key) is dict:
            for key, val in yaml_key.iteritems():
                if val is None:
                    val = ""
                dict_element = ET.SubElement(xccdftree, xccdf_element)
                dict_element.set(key, val)

            return xccdftree

        if type(yaml_key) is list:
            for rules in yaml_key:
                if "item" in rules.keys():
                    value = rules["item"]
                if "rule" in rules.keys():
                    value = rules["rule"]

                if "option" in rules.keys():
                    for key, val in rules["option"].iteritems():
                        opt = ET.SubElement(xccdftree, xccdf_element)
                        opt.set(attrib_type, key)
                        opt.text = val
                else:
                    rule = ET.SubElement(xccdftree, xccdf_element)
                    rule.set(attrib_type, value)
                    if "selector" in rules.keys():
                        rule.set("selector", rules["selector"])
                    if "selected" in rules.keys():
                        rule.set("selected", str(rules["selected"]).lower())
                    else:
                        if "item" not in rules.keys():
                            rule.set("selected", "true")

    return xccdftree


def common_xccdf_content(xccdftree, yamlcontent, title_override=None, desc_override=None):
    title = xccdf_subelement(xccdftree, "title", yamlcontent, "title", title_override)
    description = xccdf_subelement(xccdftree, "description", yamlcontent, "description", desc_override)

    return xccdftree


class XCCDFGeneratorFromYAML(object):
    def __init__(self, product, schema, version, resolved, lang):
        self.product = product
        self.schema = schema
        self.version = version.upper()
        self.resolved = resolved.lower()
        self.lang = lang

    def benchmark(self, benchmark_file):
        xccdftree = ET.Element("Benchmark")
        xccdftree.set("id", self.product)
        xccdftree.set("xsi:schemaLocation", self.schema)
        xccdftree.set("style", self.version.upper())
        xccdftree.set("resolved", self.resolved.lower())
        xccdftree.set("xml:lang", self.lang)

        for prefix, uri in xccdf_ns.items():
            xccdftree.set("xmlns:" + prefix, uri)

        status = xccdf_subelement(xccdftree, "status", benchmark_file, "status", attrib={"date": datestamp})
        common_content = common_xccdf_content(xccdftree, benchmark_file)
        notice = xccdf_subelement(xccdftree, "notice", benchmark_file, "notice", attrib={"id": benchmark_file["notice"]["id"]})
        front_matter = xccdf_subelement(xccdftree, "front-matter", benchmark_file, "front-matter")
        rear_matter = xccdf_subelement(xccdftree, "rear-matter", benchmark_file, "rear-matter")
        version = xccdf_subelement(xccdftree, "version", benchmark_file, "version")

        return xccdftree

    def profile(self, xccdftree, profile_file, filename):
        profile = xccdf_element("Profile", profile_file, attrib={"id": "profile_id", "extends": "extends"})
        profile = common_xccdf_content(profile, profile_file, "title_override", "desc_override")
        profile = xccdf_multiple_subelements(profile, "refined-value", profile_file, "rule_configuration")
        profile = xccdf_multiple_subelements(profile, "select", profile_file, "rule_selection")

        xccdftree.append(profile)

        return xccdftree

    def create_group(self, group_file):
        group = xccdf_element("Group", group_file, attrib={"id": "group_id"})
        group = common_xccdf_content(group, group_file)
        group = xccdf_subelement(group, "warning", group_file, "warning")
        group = xccdf_multiple_subelements(group, "ident", group_file, "identifiers")
        group = xccdf_multiple_subelements(group, "ref", group_file, "references")
        return group

    def group(self, xccdftree, group_file, filename):
        group_id = os.path.basename(filename).split('.')[0]
        group_file["group_id"] = group_id
        primary_group = os.path.basename(os.path.dirname(filename))
        group_file["primary_group"] = primary_group
        group = self.create_group(group_file)
        group = add_sub_group(xccdftree, "Group", group_file, "primary_group", group)
        return xccdftree

    def variable(self, xccdftree, var_file, filename):
        var = xccdf_element("Value", var_file, attrib={"id": "var_id", "type": "type", "operator": "operator", "interactive": "interactive"})
        var = common_xccdf_content(var, var_file)
        var = xccdf_multiple_subelements(var, "value", var_file, "options")

        group = add_sub_group(xccdftree, "Group", var_file, "primary_group", var)

        return xccdftree

    def rule(self, xccdftree, rule_file, filename):
        rule_id = os.path.basename(filename).split('.')[0]
        rule_file["rule_id"] = rule_id
        primary_group = os.path.basename(os.path.dirname(filename))
        group_file["primary_group"] = primary_group
        rule = xccdf_element("Rule", rule_file, attrib={"id": "rule_id", "severity": "severity"})
        rule = common_xccdf_content(rule, rule_file)
        rule = xccdf_subelement(rule, "ocil", rule_file, "ocil")
        rule = xccdf_subelement(rule, "rationale", rule_file, "rationale")
        rule = xccdf_subelement(rule, "oval", rule_file, "rule_id", attrib={"id": "rule_id", "value": "var_id"})
        rule = xccdf_subelement(rule, "warning", rule_file, "warning")
        rule = xccdf_multiple_subelements(rule, "ident", rule_file, "identifiers")
        rule = xccdf_multiple_subelements(rule, "ref", rule_file, "references")

        rule = add_sub_rule(xccdftree, "Group", rule_file, "primary_group", rule)

        return xccdftree

    def script_to_rule_mapping(self, xccdftree, filename, script_content):
        system = None
        for ending, system_template in SUFFIX_TO_SYSTEM.items():
            if filename.endswith(ending):
                system = system_template
                break
        assert system is not None, \
            "File with unknown suffix '{}': Unable to detect system for it.".format(filename)

        filename = os.path.basename(filename).split(".")[0]
        for rule in xccdftree.iter("Rule"):
            if rule.attrib["id"] == filename:
                script = ET.SubElement(rule, "fix", system=system)
                script.text = script_content

        return xccdftree

    def _split_file_list(self, file_list):
        dictionary = defaultdict(list)
        for f in file_list:
            name, extension = f.rsplit('.', 1)
            if extension.endswith(script_extensions):
                dictionary['scripts'].append(f)
            else:
                dictionary[extension].append(f)
        return dictionary

    def _build_from_files(self, callback, xccdftree, filelist):
        for filename in filelist:
            with open(filename, "r") as yaml_file:
                yamlcontent = yaml.safe_load(yaml_file)
                xccdftree = callback(xccdftree, yamlcontent, filename)
        return xccdftree

    def _build_scripts_from_files(self, xccdftree, filelist):
        for filename in filelist:
            with open(filename, "r") as yaml_file:
                script_content = yaml_file.read()
                xccdftree = self.script_to_rule_mapping(xccdftree, filename, script_content)
        return xccdftree

    def build(self, guide_file_list, document_type, script_guide_list=None):
        guide_file_list = self._split_file_list(guide_file_list)
        if len(guide_file_list['benchmark']) == 1:
            benchmark = guide_file_list['benchmark'][0]
            with open(benchmark, "r") as yaml_file:
                yamlcontent = yaml.safe_load(yaml_file)
                xccdftree = self.benchmark(yamlcontent)
        else:
            print("No .benchmark was found")
            groupfile = guide_file_list['group'][0]
            with open(groupfile, "r") as yaml_file:
                yamlcontent = yaml.safe_load(yaml_file)
                xccdftree = self.create_group(yamlcontent)
        xccdftree = self._build_from_files(self.profile, xccdftree, guide_file_list['profile'])
        xccdftree = self._build_from_files(self.group, xccdftree, guide_file_list['group'])
        xccdftree = self._build_from_files(self.variable, xccdftree, guide_file_list['var'])
        xccdftree = self._build_from_files(self.rule, xccdftree, guide_file_list['rule'])
        xccdftree = self._build_scripts_from_files(xccdftree, guide_file_list['scripts'])
        return xccdftree
