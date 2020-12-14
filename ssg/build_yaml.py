from __future__ import absolute_import
from __future__ import print_function

import os
import os.path
from collections import defaultdict
from copy import deepcopy
import datetime
import re
import sys
from xml.sax.saxutils import escape

import yaml

from .build_cpe import CPEDoesNotExist
from .constants import XCCDF_REFINABLE_PROPERTIES
from .rules import get_rule_dir_id, get_rule_dir_yaml, is_rule_dir
from .rule_yaml import parse_prodtype

from .checks import is_cce_format_valid, is_cce_value_valid
from .yaml import DocumentationNotComplete, open_and_expand, open_and_macro_expand
from .utils import required_key, mkdir_p

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


def reorder_according_to_ordering(unordered, ordering, regex=None):
    ordered = []
    if regex is None:
        regex = "|".join(["({0})".format(item) for item in ordering])
    regex = re.compile(regex)

    items_to_order = list(filter(regex.match, unordered))
    unordered = set(unordered)

    for priority_type in ordering:
        for item in items_to_order:
            if priority_type in item and item in unordered:
                ordered.append(item)
                unordered.remove(item)
    ordered.extend(list(unordered))
    return ordered


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


def add_nondata_subelements(element, subelement, attribute, attr_data):
    """Add multiple iterations of a sublement that contains an attribute but no data
       For example, <requires id="my_required_id"/>"""
    for data in attr_data:
        req = ET.SubElement(element, subelement)
        req.set(attribute, data)


class Profile(object):
    """Represents XCCDF profile
    """

    def __init__(self, id_):
        self.id_ = id_
        self.title = ""
        self.description = ""
        self.extends = None
        self.selected = []
        self.unselected = []
        self.variables = dict()
        self.refine_rules = defaultdict(list)
        self.metadata = None
        self.reference = None
        self.platform = None

    @classmethod
    def from_yaml(cls, yaml_file, env_yaml=None):
        yaml_contents = open_and_expand(yaml_file, env_yaml)
        if yaml_contents is None:
            return None

        basename, _ = os.path.splitext(os.path.basename(yaml_file))

        profile = cls(basename)
        profile.title = required_key(yaml_contents, "title")
        del yaml_contents["title"]
        profile.description = required_key(yaml_contents, "description")
        del yaml_contents["description"]
        profile.extends = yaml_contents.pop("extends", None)
        selection_entries = required_key(yaml_contents, "selections")
        if selection_entries:
            profile._parse_selections(selection_entries)
        del yaml_contents["selections"]

        profile.reference = yaml_contents.pop("reference", None)
        profile.platform = yaml_contents.pop("platform", None)

        # At the moment, metadata is not used to build content
        if "metadata" in yaml_contents:
            del yaml_contents["metadata"]

        if yaml_contents:
            raise RuntimeError("Unparsed YAML data in '%s'.\n\n%s"
                               % (yaml_file, yaml_contents))

        return profile

    def dump_yaml(self, file_name, documentation_complete=True):
        to_dump = {}
        to_dump["documentation_complete"] = documentation_complete
        to_dump["title"] = self.title
        to_dump["description"] = self.description
        to_dump["reference"] = self.reference
        if self.metadata is not None:
            to_dump["metadata"] = self.metadata

        if self.extends is not None:
            to_dump["extends"] = self.extends

        if self.platform is not None:
            to_dump["platform"] = self.platform

        selections = []
        for item in self.selected:
            selections.append(item)
        for item in self.unselected:
            selections.append("!"+item)
        for varname in self.variables.keys():
            selections.append(varname+"="+self.variables.get(varname))
        for rule, refinements in self.refine_rules.items():
            for prop, val in refinements:
                selections.append("{rule}.{property}={value}"
                                  .format(rule=rule, property=prop, value=val))
        to_dump["selections"] = selections
        with open(file_name, "w+") as f:
            yaml.dump(to_dump, f, indent=4)

    def _parse_selections(self, entries):
        for item in entries:
            if "." in item:
                rule, refinement = item.split(".", 1)
                property_, value = refinement.split("=", 1)
                if property_ not in XCCDF_REFINABLE_PROPERTIES:
                    msg = ("Property '{property_}' cannot be refined. "
                           "Rule properties that can be refined are {refinables}. "
                           "Fix refinement '{rule_id}.{property_}={value}' in profile '{profile}'."
                           .format(property_=property_, refinables=XCCDF_REFINABLE_PROPERTIES,
                                   rule_id=rule, value=value, profile=self.id_)
                           )
                    raise ValueError(msg)
                self.refine_rules[rule].append((property_, value))
            elif "=" in item:
                varname, value = item.split("=", 1)
                self.variables[varname] = value
            elif item.startswith("!"):
                self.unselected.append(item[1:])
            else:
                self.selected.append(item)

    def to_xml_element(self, product_cpes):
        element = ET.Element('Profile')
        element.set("id", self.id_)
        if self.extends:
            element.set("extends", self.extends)
        title = add_sub_element(element, "title", self.title)
        title.set("override", "true")
        desc = add_sub_element(element, "description", self.description)
        desc.set("override", "true")

        if self.reference:
            add_sub_element(element, "reference", escape(self.reference))

        if self.platform:
            try:
                platform_cpe = product_cpes.get_cpe_name(self.platform)
            except KeyError:
                raise ValueError("Unsupported platform '%s' in profile '%s'." % (self.platform, self.id_))
            plat = ET.SubElement(element, "platform")
            plat.set("idref", platform_cpe)

        for selection in self.selected:
            select = ET.Element("select")
            select.set("idref", selection)
            select.set("selected", "true")
            element.append(select)

        for selection in self.unselected:
            unselect = ET.Element("select")
            unselect.set("idref", selection)
            unselect.set("selected", "false")
            element.append(unselect)

        for value_id, selector in self.variables.items():
            refine_value = ET.Element("refine-value")
            refine_value.set("idref", value_id)
            refine_value.set("selector", selector)
            element.append(refine_value)

        for refined_rule, refinement_list in self.refine_rules.items():
            refine_rule = ET.Element("refine-rule")
            refine_rule.set("idref", refined_rule)
            for refinement in refinement_list:
                refine_rule.set(refinement[0], refinement[1])
            element.append(refine_rule)

        return element

    def get_rule_selectors(self):
        return list(self.selected + self.unselected)

    def get_variable_selectors(self):
        return self.variables

    def validate_refine_rules(self, rules):
        existing_rule_ids = [r.id_ for r in rules]
        for refine_rule, refinement_list in self.refine_rules.items():
            # Take first refinement to ilustrate where the error is
            # all refinements in list are invalid, so it doesn't really matter
            a_refinement = refinement_list[0]

            if refine_rule not in existing_rule_ids:
                msg = (
                    "You are trying to refine a rule that doesn't exist. "
                    "Rule '{rule_id}' was not found in the benchmark. "
                    "Please check all rule refinements for rule: '{rule_id}', for example: "
                    "- {rule_id}.{property_}={value}' in profile {profile_id}."
                    .format(rule_id=refine_rule, profile_id=self.id_,
                            property_=a_refinement[0], value=a_refinement[1])
                    )
                raise ValueError(msg)

            if refine_rule not in self.get_rule_selectors():
                msg = ("- {rule_id}.{property_}={value}' in profile '{profile_id}' is refining "
                       "a rule that is not selected by it. The refinement will not have any "
                       "noticeable effect. Either select the rule or remove the rule refinement."
                       .format(rule_id=refine_rule, property_=a_refinement[0],
                               value=a_refinement[1], profile_id=self.id_)
                       )
                raise ValueError(msg)

    def validate_variables(self, variables):
        variables_by_id = dict()
        for var in variables:
            variables_by_id[var.id_] = var

        for var_id, our_val in self.variables.items():
            if var_id not in variables_by_id:
                all_vars_list = [" - %s" % v for v in variables_by_id.keys()]
                msg = (
                    "Value '{var_id}' in profile '{profile_name}' is not known. "
                    "We know only variables:\n{var_names}"
                    .format(
                        var_id=var_id, profile_name=self.id_,
                        var_names="\n".join(sorted(all_vars_list)))
                )
                raise ValueError(msg)

            allowed_selectors = [str(s) for s in variables_by_id[var_id].options.keys()]
            if our_val not in allowed_selectors:
                msg = (
                    "Value '{var_id}' in profile '{profile_name}' "
                    "uses the selector '{our_val}'. "
                    "This is not possible, as only selectors {all_selectors} are available. "
                    "Either change the selector used in the profile, or "
                    "add the selector-value pair to the variable definition."
                    .format(
                        var_id=var_id, profile_name=self.id_, our_val=our_val,
                        all_selectors=allowed_selectors,
                    )
                )
                raise ValueError(msg)

    def validate_rules(self, rules, groups):
        existing_rule_ids = [r.id_ for r in rules]
        rule_selectors = self.get_rule_selectors()
        for id_ in rule_selectors:
            if id_ in groups:
                msg = (
                    "You have selected a group '{group_id}' instead of a "
                    "rule. Groups have no effect in the profile and are not "
                    "allowed to be selected. Please remove '{group_id}' "
                    "from profile '{profile_id}' before proceeding."
                    .format(group_id=id_, profile_id=self.id_)
                )
                raise ValueError(msg)
            if id_ not in existing_rule_ids:
                msg = (
                    "Rule '{rule_id}' was not found in the benchmark. Please "
                    "remove rule '{rule_id}' from profile '{profile_id}' "
                    "before proceeding."
                    .format(rule_id=id_, profile_id=self.id_)
                )
                raise ValueError(msg)

    def __sub__(self, other):
        profile = Profile(self.id_)
        profile.title = self.title
        profile.description = self.description
        profile.extends = self.extends
        profile.platform = self.platform
        profile.selected = list(set(self.selected) - set(other.selected))
        profile.selected.sort()
        profile.unselected = list(set(self.unselected) - set(other.unselected))
        profile.variables = dict ((k, v) for (k, v) in self.variables.items()
                             if k not in other.variables or v != other.variables[k])
        return profile


class ResolvableProfile(Profile):
    def __init__(self, * args, ** kwargs):
        super(ResolvableProfile, self).__init__(* args, ** kwargs)
        self.resolved = False

    def resolve(self, all_profiles):
        if self.resolved:
            return

        resolved_selections = set(self.selected)
        if self.extends:
            if self.extends not in all_profiles:
                msg = (
                    "Profile {name} extends profile {extended}, but "
                    "only profiles {profiles} are available for resolution."
                    .format(name=self.id_, extended=self.extends,
                            profiles=list(all_profiles.keys())))
                raise RuntimeError(msg)
            extended_profile = all_profiles[self.extends]
            extended_profile.resolve(all_profiles)

            extended_selects = set(extended_profile.selected)
            resolved_selections.update(extended_selects)

            updated_variables = dict(extended_profile.variables)
            updated_variables.update(self.variables)
            self.variables = updated_variables

            extended_refinements = deepcopy(extended_profile.refine_rules)
            updated_refinements = self._subtract_refinements(extended_refinements)
            updated_refinements.update(self.refine_rules)
            self.refine_rules = updated_refinements

        for uns in self.unselected:
            resolved_selections.discard(uns)

        self.unselected = []
        self.extends = None

        self.selected = sorted(resolved_selections)

        self.resolved = True

    def _subtract_refinements(self, extended_refinements):
        """
        Given a dict of rule refinements from the extended profile,
        "undo" every refinement prefixed with '!' in this profile.
        """
        for rule, refinements in list(self.refine_rules.items()):
            if rule.startswith("!"):
                for prop, val in refinements:
                    extended_refinements[rule[1:]].remove((prop, val))
                del self.refine_rules[rule]
        return extended_refinements


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
        yaml_contents = open_and_macro_expand(yaml_file, env_yaml)
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

    @classmethod
    def from_yaml(cls, yaml_file, id_, product_yaml=None):
        yaml_contents = open_and_macro_expand(yaml_file, product_yaml)
        if yaml_contents is None:
            return None

        benchmark = cls(id_)
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

        return benchmark

    def add_profiles_from_dir(self, dir_, env_yaml):
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

            try:
                new_profile = Profile.from_yaml(dir_item_path, env_yaml)
            except DocumentationNotComplete:
                continue
            except Exception as exc:
                msg = ("Error building profile from '{fname}': '{error}'"
                       .format(fname=dir_item_path, error=str(exc)))
                raise RuntimeError(msg)
            if new_profile is None:
                continue

            self.profiles.append(new_profile)

    def add_bash_remediation_fns_from_file(self, file_):
        if not file_:
            # bash-remediation-functions.xml doens't exist
            return

        tree = ET.parse(file_)
        self.bash_remediation_fns_group = tree.getroot()

    def to_xml_element(self, product_cpes):
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

        # The Benchmark applicability is determined by the CPEs
        # defined in the product.yml
        product_cpe_names = product_cpes.get_product_cpe_names()
        for cpe_name in product_cpe_names:
            plat = ET.SubElement(root, "platform")
            plat.set("idref", cpe_name)

        version = ET.SubElement(root, 'version')
        version.text = self.version
        ET.SubElement(root, "metadata")

        for profile in self.profiles:
            root.append(profile.to_xml_element(product_cpes))

        for value in self.values.values():
            root.append(value.to_xml_element())
        if self.bash_remediation_fns_group is not None:
            root.append(self.bash_remediation_fns_group)

        groups_in_bench = list(self.groups.keys())
        priority_order = ["system", "services"]
        groups_in_bench = reorder_according_to_ordering(groups_in_bench, priority_order)

        # Make system group the first, followed by services group
        for group_id in groups_in_bench:
            group = self.groups.get(group_id)
            # Products using application benchmark don't have system or services group
            if group is not None:
                root.append(group.to_xml_element(product_cpes))

        for rule in self.rules.values():
            root.append(rule.to_xml_element(product_cpes))

        return root

    def to_file(self, file_name, product_cpes):
        root = self.to_xml_element(product_cpes)
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
    ATTRIBUTES_TO_PASS_ON = (
        "platform",
    )

    def __init__(self, id_):
        self.id_ = id_
        self.prodtype = "all"
        self.title = ""
        self.description = ""
        self.warnings = []
        self.requires = []
        self.conflicts = []
        self.values = {}
        self.groups = {}
        self.rules = {}
        self.platform = None

    @classmethod
    def from_yaml(cls, yaml_file, env_yaml=None):
        yaml_contents = open_and_macro_expand(yaml_file, env_yaml)
        if yaml_contents is None:
            return None

        group_id = os.path.basename(os.path.dirname(yaml_file))
        group = cls(group_id)
        group.prodtype = yaml_contents.pop("prodtype", "all")
        group.title = required_key(yaml_contents, "title")
        del yaml_contents["title"]
        group.description = required_key(yaml_contents, "description")
        del yaml_contents["description"]
        group.warnings = yaml_contents.pop("warnings", [])
        group.conflicts = yaml_contents.pop("conflicts", [])
        group.requires = yaml_contents.pop("requires", [])
        group.platform = yaml_contents.pop("platform", None)

        for warning_list in group.warnings:
            if len(warning_list) != 1:
                raise ValueError("Only one key/value pair should exist for each dictionary")

        if yaml_contents:
            raise RuntimeError("Unparsed YAML data in '%s'.\n\n%s"
                               % (yaml_file, yaml_contents))
        group.validate_prodtype(yaml_file)
        return group

    def validate_prodtype(self, yaml_file):
        for ptype in self.prodtype.split(","):
            if ptype.strip() != ptype:
                msg = (
                    "Comma-separated '{prodtype}' prodtype "
                    "in {yaml_file} contains whitespace."
                    .format(prodtype=self.prodtype, yaml_file=yaml_file))
                raise ValueError(msg)

    def to_xml_element(self, product_cpes):
        group = ET.Element('Group')
        group.set('id', self.id_)
        if self.prodtype != "all":
            group.set("prodtype", self.prodtype)
        title = ET.SubElement(group, 'title')
        title.text = self.title
        add_sub_element(group, 'description', self.description)
        add_warning_elements(group, self.warnings)
        add_nondata_subelements(group, "requires", "id", self.requires)
        add_nondata_subelements(group, "conflicts", "id", self.conflicts)

        if self.platform:
            platform_el = ET.SubElement(group, "platform")
            try:
                platform_cpe = product_cpes.get_cpe_name(self.platform)
            except CPEDoesNotExist:
                print("Unsupported platform '%s' in rule '%s'." % (self.platform, self.id_))
                raise
            platform_el.set("idref", platform_cpe)

        for _value in self.values.values():
            group.append(_value.to_xml_element())

        # Rules that install or remove packages affect remediation
        # of other rules.
        # When packages installed/removed rules come first:
        # The Rules are ordered in more logical way, and
        # remediation order is natural, first the package is installed, then configured.
        rules_in_group = list(self.rules.keys())
        regex = r'(package_.*_(installed|removed))|(service_.*_(enabled|disabled))$'
        priority_order = ["installed", "removed", "enabled", "disabled"]
        rules_in_group = reorder_according_to_ordering(rules_in_group, priority_order, regex)

        # Add rules in priority order, first all packages installed, then removed,
        # followed by services enabled, then disabled
        for rule_id in rules_in_group:
            group.append(self.rules.get(rule_id).to_xml_element(product_cpes))

        # Add the sub groups after any current level group rules.
        # As package installed/removed and service enabled/disabled rules are usuallly in
        # top level group, this ensures groups that further configure a package or service
        # are after rules that install or remove it.
        groups_in_group = list(self.groups.keys())
        priority_order = [
            # Make sure rpm_verify_(hashes|permissions|ownership) are run before any other rule.
            # Due to conflicts between rules rpm_verify_* rules and any rule that configures
            # stricter settings, like file_permissions_grub2_cfg and sudo_dedicated_group,
            # the rules deviating from the system default should be evaluated later.
            # So that in the end the system has contents, permissions and ownership reset, and
            # any deviations or stricter settings are applied by the rules in the profile.
            "software", "integrity", "integrity-software", "rpm_verification",

            # The account group has to precede audit group because
            # the rule package_screen_installed is desired to be executed before the rule
            # audit_rules_privileged_commands, othervise the rule
            # does not catch newly installed screen binary during remediation
            # and report fail
            "accounts", "auditing",


            # The FIPS group should come before Crypto,
            # if we want to set a different (stricter) Crypto Policy than FIPS.
            "fips", "crypto",

            # The firewalld_activation must come before ruleset_modifications, othervise
            # remediations for ruleset_modifications won't work
            "firewalld_activation", "ruleset_modifications",

            # Rules from group disabling_ipv6 must precede rules from configuring_ipv6,
            # otherwise the remediation prints error although it is successful
            "disabling_ipv6", "configuring_ipv6"
        ]
        groups_in_group = reorder_according_to_ordering(groups_in_group, priority_order)
        for group_id in groups_in_group:
            _group = self.groups[group_id]
            group.append(_group.to_xml_element(product_cpes))

        return group

    def to_file(self, file_name, product_cpes):
        root = self.to_xml_element(product_cpes)
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
        self._pass_our_properties_on_to(group)

    def _pass_our_properties_on_to(self, obj):
        for attr in self.ATTRIBUTES_TO_PASS_ON:
            if hasattr(obj, attr) and getattr(obj, attr) is None:
                setattr(obj, attr, getattr(self, attr))

    def add_rule(self, rule):
        if rule is None:
            return
        if self.platform and not rule.platform:
            rule.platform = self.platform
        self.rules[rule.id_] = rule
        self._pass_our_properties_on_to(rule)

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
        "conflicts": lambda: list(),
        "requires": lambda: list(),
        "platform": lambda: None,
        "inherited_platforms": lambda: list(),
        "template": lambda: None,
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
        self.requires = []
        self.conflicts = []
        self.platform = None
        self.inherited_platforms = [] # platforms inherited from the group
        self.template = None

    @classmethod
    def from_yaml(cls, yaml_file, env_yaml=None):
        yaml_file = os.path.normpath(yaml_file)

        yaml_contents = open_and_macro_expand(yaml_file, env_yaml)
        if yaml_contents is None:
            return None

        rule_id, ext = os.path.splitext(os.path.basename(yaml_file))
        if rule_id == "rule" and ext == ".yml":
            rule_id = get_rule_dir_id(yaml_file)

        rule = cls(rule_id)

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

        rule.validate_prodtype(yaml_file)
        rule.validate_identifiers(yaml_file)
        rule.validate_references(yaml_file)
        return rule

    def _verify_stigid_format(self, product):
        stig_id = self.references.get("stigid", None)
        if not stig_id:
            return
        if "," in stig_id:
            raise ValueError("Rules can not have multiple STIG IDs.")

    def _verify_disa_cci_format(self):
        cci_id = self.references.get("disa", None)
        if not cci_id:
            return
        cci_ex = re.compile(r'^CCI-[0-9]{6}$')
        for cci in cci_id.split(","):
            if not cci_ex.match(cci):
                raise ValueError("CCI '{}' is in the wrong format! "
                                 "Format should be similar to: "
                                 "CCI-XXXXXX".format(cci))
        self.references["disa"] = cci_id

    def normalize(self, product):
        try:
            self.make_refs_and_identifiers_product_specific(product)
            self.make_template_product_specific(product)
        except Exception as exc:
            msg = (
                "Error normalizing '{rule}': {msg}"
                .format(rule=self.id_, msg=str(exc))
            )
            raise RuntimeError(msg)

    def _get_product_only_references(self):
        PRODUCT_REFERENCES = ("stigid",)

        product_references = dict()

        for ref in PRODUCT_REFERENCES:
            start = "{0}@".format(ref)
            for gref, gval in self.references.items():
                if ref == gref or gref.startswith(start):
                    product_references[gref] = gval
        return product_references

    def make_template_product_specific(self, product):
        product_suffix = "@{0}".format(product)

        if not self.template:
            return

        not_specific_vars = self.template.get("vars", dict())
        specific_vars = self._make_items_product_specific(
            not_specific_vars, product_suffix, True)
        self.template["vars"] = specific_vars

        not_specific_backends = self.template.get("backends", dict())
        specific_backends = self._make_items_product_specific(
            not_specific_backends, product_suffix, True)
        self.template["backends"] = specific_backends

    def make_refs_and_identifiers_product_specific(self, product):
        product_suffix = "@{0}".format(product)

        product_references = self._get_product_only_references()
        general_references = self.references.copy()
        for todel in product_references:
            general_references.pop(todel)

        to_set = dict(
            identifiers=(self.identifiers, False),
            general_references=(general_references, True),
            product_references=(product_references, False),
        )
        for name, (dic, allow_overwrites) in to_set.items():
            try:
                new_items = self._make_items_product_specific(
                    dic, product_suffix, allow_overwrites)
            except ValueError as exc:
                msg = (
                    "Error processing {what} for rule '{rid}': {msg}"
                    .format(what=name, rid=self.id_, msg=str(exc))
                )
                raise ValueError(msg)
            dic.clear()
            dic.update(new_items)

        self.references = general_references
        self._verify_disa_cci_format()
        self.references.update(product_references)

        self._verify_stigid_format(product)

    def _make_items_product_specific(self, items_dict, product_suffix, allow_overwrites=False):
        new_items = dict()
        for full_label, value in items_dict.items():
            if "@" not in full_label and full_label not in new_items:
                new_items[full_label] = value
                continue

            if not full_label.endswith(product_suffix):
                continue

            label = full_label.split("@")[0]
            if label in items_dict and not allow_overwrites and value != items_dict[label]:
                msg = (
                    "There is a product-qualified '{item_q}' item, "
                    "but also an unqualified '{item_u}' item "
                    "and those two differ in value - "
                    "'{value_q}' vs '{value_u}' respectively."
                    .format(item_q=full_label, item_u=label,
                            value_q=value, value_u=items_dict[label])
                )
                raise ValueError(msg)
            new_items[label] = value
        return new_items

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
                if not is_cce_format_valid(ident_val):
                    raise ValueError("CCE Identifier format must be valid: invalid format '%s' for CEE '%s'"
                                     " in file '%s'" % (ident_val, ident_type, yaml_file))
                if not is_cce_value_valid("CCE-" + ident_val):
                    raise ValueError("CCE Identifier value is not a valid checksum: invalid value '%s' for CEE '%s'"
                                     " in file '%s'" % (ident_val, ident_type, yaml_file))

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

        for ref_type, ref_val in self.references.items():
            for ref in ref_val.split(","):
                if ref.strip() != ref:
                    msg = (
                        "Comma-separated '{ref_type}' reference "
                        "in {yaml_file} contains whitespace."
                        .format(ref_type=ref_type, yaml_file=yaml_file))
                    raise ValueError(msg)

    def validate_prodtype(self, yaml_file):
        for ptype in self.prodtype.split(","):
            if ptype.strip() != ptype:
                msg = (
                    "Comma-separated '{prodtype}' prodtype "
                    "in {yaml_file} contains whitespace."
                    .format(prodtype=self.prodtype, yaml_file=yaml_file))
                raise ValueError(msg)

    def to_xml_element(self, product_cpes):
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
            # This is not true if items were normalized
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
            # This is not true if items were normalized
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
        add_nondata_subelements(rule, "requires", "id", self.requires)
        add_nondata_subelements(rule, "conflicts", "id", self.conflicts)

        if self.platform:
            platform_el = ET.SubElement(rule, "platform")
            try:
                platform_cpe = product_cpes.get_cpe_name(self.platform)
            except CPEDoesNotExist:
                print("Unsupported platform '%s' in rule '%s'." % (self.platform, self.id_))
                raise
            platform_el.set("idref", platform_cpe)

        return rule

    def to_file(self, file_name, product_cpes):
        root = self.to_xml_element(product_cpes)
        tree = ET.ElementTree(root)
        tree.write(file_name)


class DirectoryLoader(object):
    def __init__(self, profiles_dir, bash_remediation_fns, env_yaml):
        self.benchmark_file = None
        self.group_file = None
        self.loaded_group = None
        self.rule_files = []
        self.value_files = []
        self.subdirectories = []

        self.all_values = set()
        self.all_rules = set()
        self.all_groups = set()

        self.profiles_dir = profiles_dir
        self.bash_remediation_fns = bash_remediation_fns
        self.env_yaml = env_yaml
        self.product = env_yaml["product"]

        self.parent_group = None

    def _collect_items_to_load(self, guide_directory):
        for dir_item in os.listdir(guide_directory):
            dir_item_path = os.path.join(guide_directory, dir_item)
            _, extension = os.path.splitext(dir_item)

            if extension == '.var':
                self.value_files.append(dir_item_path)
            elif dir_item == "benchmark.yml":
                if self.benchmark_file:
                    raise ValueError("Multiple benchmarks in one directory")
                self.benchmark_file = dir_item_path
            elif dir_item == "group.yml":
                if self.group_file:
                    raise ValueError("Multiple groups in one directory")
                self.group_file = dir_item_path
            elif extension == '.rule':
                self.rule_files.append(dir_item_path)
            elif is_rule_dir(dir_item_path):
                self.rule_files.append(get_rule_dir_yaml(dir_item_path))
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
        group_file, in the context of guide_directory, profiles_dir,
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
                group.add_profiles_from_dir(self.profiles_dir, self.env_yaml)
            group.add_bash_remediation_fns_from_file(self.bash_remediation_fns)

        if self.group_file:
            group = Group.from_yaml(self.group_file, self.env_yaml)
            self.all_groups.add(group.id_)

        return group

    def _load_group_process_and_recurse(self, guide_directory):
        self.loaded_group = self.load_benchmark_or_group(guide_directory)

        if self.loaded_group:
            if self.parent_group:
                self.parent_group.add_group(self.loaded_group)

            self._process_values()
            self._recurse_into_subdirs()
            self._process_rules()

    def process_directory_tree(self, start_dir, extra_group_dirs=None):
        self._collect_items_to_load(start_dir)
        if extra_group_dirs is not None:
            self.subdirectories += extra_group_dirs
        self._load_group_process_and_recurse(start_dir)

    def _recurse_into_subdirs(self):
        for subdir in self.subdirectories:
            loader = self._get_new_loader()
            loader.parent_group = self.loaded_group
            loader.process_directory_tree(subdir)
            self.all_values.update(loader.all_values)
            self.all_rules.update(loader.all_rules)
            self.all_groups.update(loader.all_groups)

    def _get_new_loader(self):
        raise NotImplementedError()

    def _process_values(self):
        raise NotImplementedError()

    def _process_rules(self):
        raise NotImplementedError()


class BuildLoader(DirectoryLoader):
    def __init__(self, profiles_dir, bash_remediation_fns, env_yaml, resolved_rules_dir=None):
        super(BuildLoader, self).__init__(profiles_dir, bash_remediation_fns, env_yaml)

        self.resolved_rules_dir = resolved_rules_dir
        if resolved_rules_dir and not os.path.isdir(resolved_rules_dir):
            os.mkdir(resolved_rules_dir)

    def _process_values(self):
        for value_yaml in self.value_files:
            value = Value.from_yaml(value_yaml, self.env_yaml)
            self.all_values.add(value)
            self.loaded_group.add_value(value)

    def _process_rules(self):
        for rule_yaml in self.rule_files:
            try:
                rule = Rule.from_yaml(rule_yaml, self.env_yaml)
            except DocumentationNotComplete:
                # Happens on non-debug build when a rule is "documentation-incomplete"
                continue
            prodtypes = parse_prodtype(rule.prodtype)
            if "all" not in prodtypes and self.product not in prodtypes:
                continue
            self.all_rules.add(rule)
            self.loaded_group.add_rule(rule)

            rule.inherited_platforms.append(self.loaded_group.platform)

            if self.resolved_rules_dir:
                output_for_rule = os.path.join(
                    self.resolved_rules_dir, "{id_}.yml".format(id_=rule.id_))
                mkdir_p(self.resolved_rules_dir)
                with open(output_for_rule, "w") as f:
                    rule.normalize(self.env_yaml["product"])
                    yaml.dump(rule.to_contents_dict(), f)

    def _get_new_loader(self):
        return BuildLoader(
            self.profiles_dir, self.bash_remediation_fns, self.env_yaml, self.resolved_rules_dir)

    def export_group_to_file(self, filename, product_cpes):
        return self.loaded_group.to_file(filename, product_cpes)
