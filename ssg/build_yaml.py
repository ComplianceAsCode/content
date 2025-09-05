from __future__ import absolute_import
from __future__ import print_function

from collections import defaultdict
from copy import deepcopy
import datetime
import json
import os
import os.path
import re
import sys
from xml.sax.saxutils import escape
import glob

import yaml

import ssg.build_remediations
from .build_cpe import CPEDoesNotExist, CPEALLogicalTest, CPEALFactRef
from .constants import (XCCDF_REFINABLE_PROPERTIES,
                        SCE_SYSTEM,
                        cce_uri,
                        dc_namespace,
                        ocil_cs,
                        ocil_namespace,
                        oval_namespace,
                        xhtml_namespace,
                        xsi_namespace,
                        stig_ns,
                        timestamp,
                        SSG_BENCHMARK_LATEST_URI,
                        SSG_PROJECT_NAME,
                        SSG_REF_URIS,
                        PREFIX_TO_NS,
                        FIX_TYPE_TO_SYSTEM
                        )
from .rules import get_rule_dir_id, get_rule_dir_yaml, is_rule_dir
from .rule_yaml import parse_prodtype

from .cce import is_cce_format_valid, is_cce_value_valid
from .yaml import DocumentationNotComplete, open_and_expand, open_and_macro_expand
from .utils import required_key, mkdir_p

from .xml import ElementTree as ET, add_xhtml_namespace, register_namespaces, parse_file
from .shims import unicode_func
from .build_cpe import ProductCPEs
import ssg.build_stig

def dump_yaml_preferably_in_original_order(dictionary, file_object):
    try:
        return yaml.dump(dictionary, file_object, indent=4, sort_keys=False)
    except TypeError as exc:
        # Older versions of libyaml don't understand the sort_keys kwarg
        if "sort_keys" not in str(exc):
            raise exc
        return yaml.dump(dictionary, file_object, indent=4)


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
    namespaced_data = add_xhtml_namespace(data)
    # This is used because our YAML data contain XML and XHTML elements
    # ET.SubElement() escapes the < > characters by &lt; and &gt;
    # and therefore it does not add child elements
    # we need to do a hack instead
    # TODO: Remove this function after we move to Markdown everywhere in SSG
    ustr = unicode_func('<{0} xmlns:xhtml="{2}">{1}</{0}>').format(tag, namespaced_data, xhtml_namespace)

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
    ordered.extend(sorted(unordered))
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


def check_warnings(xccdf_structure):
    for warning_list in xccdf_structure.warnings:
        if len(warning_list) != 1:
            msg = "Only one key/value pair should exist for each warnings dictionary"
            raise ValueError(msg)


def add_reference_elements(element, references, ref_uri_dict):
    for ref_type, ref_vals in references.items():
        for ref_val in ref_vals.split(","):
            # This assumes that a single srg key may have items from multiple SRG types
            if ref_type == 'srg':
                if ref_val.startswith('SRG-OS-'):
                    ref_href = ref_uri_dict['os-srg']
                elif ref_val.startswith('SRG-APP-'):
                    ref_href = ref_uri_dict['app-srg']
                else:
                    raise ValueError("SRG {0} doesn't have a URI defined.".format(ref_val))
            else:
                try:
                    ref_href = ref_uri_dict[ref_type]
                except KeyError as exc:
                    msg = (
                        "Error processing reference {0}: {1} in Rule {2}."
                        .format(ref_type, ref_vals, self.id_))
                    raise ValueError(msg)

            ref = ET.SubElement(element, 'reference')
            ref.set("href", ref_href)
            ref.text = ref_val


def add_benchmark_metadata(element, contributors_file):
    metadata = ET.SubElement(element, "metadata")

    publisher = ET.SubElement(metadata, "{%s}publisher" % dc_namespace)
    publisher.text = SSG_PROJECT_NAME

    creator = ET.SubElement(metadata, "{%s}creator" % dc_namespace)
    creator.text = SSG_PROJECT_NAME

    contrib_tree = parse_file(contributors_file)
    for c in contrib_tree.iter('contributor'):
        contributor = ET.SubElement(metadata, "{%s}contributor" % dc_namespace)
        contributor.text = c.text

    source = ET.SubElement(metadata, "{%s}source" % dc_namespace)
    source.text = SSG_BENCHMARK_LATEST_URI


class SelectionHandler(object):
    def __init__(self):
        self.refine_rules = defaultdict(list)
        self.variables = dict()
        self.unselected = []
        self.selected = []

    @property
    def selections(self):
        selections = []
        for item in self.selected:
            selections.append(str(item))
        for item in self.unselected:
            selections.append("!"+str(item))
        for varname in self.variables.keys():
            selections.append(varname+"="+self.variables.get(varname))
        for rule, refinements in self.refine_rules.items():
            for prop, val in refinements:
                selections.append("{rule}.{property}={value}"
                                  .format(rule=rule, property=prop, value=val))
        return selections

    @selections.setter
    def selections(self, entries):
        for item in entries:
            self.apply_selection(item)

    def apply_selection(self, item):
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

    def update_with(self, rhs):
        extended_selects = set(rhs.selected)
        extra_selections = extended_selects.difference(set(self.selected))
        self.selected.extend(list(extra_selections))

        updated_variables = dict(rhs.variables)
        updated_variables.update(self.variables)
        self.variables = updated_variables

        extended_refinements = deepcopy(rhs.refine_rules)
        updated_refinements = self._subtract_refinements(extended_refinements)
        updated_refinements.update(self.refine_rules)
        self.refine_rules = updated_refinements


class XCCDFEntity(object):
    """
    This class can load itself from a YAML with Jinja macros,
    and it can also save itself to YAML.

    It is supposed to work with the content in the project,
    when entities are defined in the benchmark tree,
    and they are compiled into flat YAMLs to the build directory.
    """
    KEYS = dict(
            id_=lambda: "",
            definition_location=lambda: "",
    )

    MANDATORY_KEYS = set()

    GENERIC_FILENAME = ""
    ID_LABEL = "id"

    def __init__(self, id_):
        super(XCCDFEntity, self).__init__()
        self._assign_defaults()
        self.id_ = id_

    def _assign_defaults(self):
        for key, default in self.KEYS.items():
            default_val = default()
            if isinstance(default_val, RuntimeError):
                default_val = None
            setattr(self, key, default_val)

    @classmethod
    def get_instance_from_full_dict(cls, data):
        """
        Given a defining dictionary, produce an instance
        by treating all dict elements as attributes.

        Extend this if you want tight control over the instance creation process.
        """
        entity = cls(data["id_"])
        for key, value in data.items():
            setattr(entity, key, value)
        return entity

    @classmethod
    def process_input_dict(cls, input_contents, env_yaml, product_cpes=None):
        """
        Take the contents of the definition as a dictionary, and
        add defaults or raise errors if a required member is not present.

        Extend this if you want to add, remove or alter the result
        that will constitute the new instance.
        """
        data = dict()

        for key, default in cls.KEYS.items():
            if key in input_contents:
                if input_contents[key] is not None:
                    data[key] = input_contents[key]
                del input_contents[key]
                continue

            if key not in cls.MANDATORY_KEYS:
                data[key] = cls.KEYS[key]()
            else:
                msg = (
                    "Key '{key}' is mandatory for definition of '{class_name}'."
                    .format(key=key, class_name=cls.__name__))
                raise ValueError(msg)

        return data

    @classmethod
    def parse_yaml_into_processed_dict(cls, yaml_file, env_yaml=None, product_cpes=None):
        """
        Given yaml filename and environment info, produce a dictionary
        that defines the instance to be created.
        This wraps :meth:`process_input_dict` and it adds generic keys on the top:

        - `id_` as the entity ID that is deduced either from thefilename,
          or from the parent directory name.
        - `definition_location` as the original location whenre the entity got defined.
        """
        file_basename = os.path.basename(yaml_file)
        entity_id = derive_id_from_file_name(file_basename)
        if file_basename == cls.GENERIC_FILENAME:
            entity_id = os.path.basename(os.path.dirname(yaml_file))

        if env_yaml:
            env_yaml[cls.ID_LABEL] = entity_id
        yaml_data = open_and_macro_expand(yaml_file, env_yaml)

        try:
            processed_data = cls.process_input_dict(yaml_data, env_yaml, product_cpes)
        except ValueError as exc:
            msg = (
                "Error processing {yaml_file}: {exc}"
                .format(yaml_file=yaml_file, exc=str(exc)))
            raise ValueError(msg)

        if yaml_data:
            msg = (
                "Unparsed YAML data in '{yaml_file}': {keys}"
                .format(yaml_file=yaml_file, keys=list(yaml_data.keys())))
            raise RuntimeError(msg)

        if not processed_data.get("definition_location", ""):
            processed_data["definition_location"] = yaml_file

        processed_data["id_"] = entity_id

        return processed_data

    @classmethod
    def from_yaml(cls, yaml_file, env_yaml=None, product_cpes=None):
        yaml_file = os.path.normpath(yaml_file)

        local_env_yaml = None
        if env_yaml:
            local_env_yaml = dict()
            local_env_yaml.update(env_yaml)

        try:
            data_dict = cls.parse_yaml_into_processed_dict(yaml_file, local_env_yaml, product_cpes)
        except DocumentationNotComplete as exc:
            raise
        except Exception as exc:
            msg = (
                "Error loading a {class_name} from {filename}: {error}"
                .format(class_name=cls.__name__, filename=yaml_file, error=str(exc)))
            raise RuntimeError(msg)

        result = cls.get_instance_from_full_dict(data_dict)

        return result

    def represent_as_dict(self):
        """
        Produce a dict representation of the class.

        Extend this method if you need the representation to be different from the object.
        """
        data = dict()
        for key in self.KEYS:
            value = getattr(self, key)
            if value or True:
                data[key] = getattr(self, key)
        del data["id_"]
        return data

    def dump_yaml(self, file_name, documentation_complete=True):
        to_dump = self.represent_as_dict()
        to_dump["documentation_complete"] = documentation_complete
        with open(file_name, "w+") as f:
            dump_yaml_preferably_in_original_order(to_dump, f)

    def to_xml_element(self):
        raise NotImplementedError()

    def to_file(self, file_name):
        root = self.to_xml_element()
        tree = ET.ElementTree(root)
        tree.write(file_name)


class Profile(XCCDFEntity, SelectionHandler):
    """Represents XCCDF profile
    """
    KEYS = dict(
        title=lambda: "",
        description=lambda: "",
        extends=lambda: "",
        metadata=lambda: None,
        reference=lambda: None,
        selections=lambda: list(),
        platforms=lambda: set(),
        cpe_names=lambda: set(),
        platform=lambda: None,
        filter_rules=lambda: "",
        ** XCCDFEntity.KEYS
    )

    MANDATORY_KEYS = {
        "title",
        "description",
        "selections",
    }

    @classmethod
    def process_input_dict(cls, input_contents, env_yaml, product_cpes):
        input_contents = super(Profile, cls).process_input_dict(input_contents, env_yaml)

        platform = input_contents.get("platform")
        if platform is not None:
            input_contents["platforms"].add(platform)

        if env_yaml:
            for platform in input_contents["platforms"]:
                try:
                    new_cpe_name = product_cpes.get_cpe_name(platform)
                    input_contents["cpe_names"].add(new_cpe_name)
                except CPEDoesNotExist:
                    msg = (
                        "Unsupported platform '{platform}' in a profile."
                        .format(platform=platform))
                    raise CPEDoesNotExist(msg)

        return input_contents

    @property
    def rule_filter(self):
        if self.filter_rules:
            return rule_filter_from_def(self.filter_rules)
        else:
            return noop_rule_filterfunc

    def to_xml_element(self):
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

        for cpe_name in self.cpe_names:
            plat = ET.SubElement(element, "platform")
            plat.set("idref", cpe_name)

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
        return self.selected + self.unselected

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
        profile.platforms = self.platforms
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

    def _controls_ids_to_controls(self, controls_manager, policy_id, control_id_list):
        items = [controls_manager.get_control(policy_id, cid) for cid in control_id_list]
        return items

    def resolve_controls(self, controls_manager):
        pass

    def extend_by(self, extended_profile):
        self.update_with(extended_profile)

    def resolve_selections_with_rules(self, rules_by_id):
        selections = set()
        for rid in self.selected:
            if rid not in rules_by_id:
                continue
            rule = rules_by_id[rid]
            if not self.rule_filter(rule):
                continue
            selections.add(rid)
        self.selected = list(selections)

    def resolve(self, all_profiles, rules_by_id, controls_manager=None):
        if self.resolved:
            return

        if controls_manager:
            self.resolve_controls(controls_manager)

        self.resolve_selections_with_rules(rules_by_id)

        if self.extends:
            if self.extends not in all_profiles:
                msg = (
                    "Profile {name} extends profile {extended}, but "
                    "only profiles {known_profiles} are available for resolution."
                    .format(name=self.id_, extended=self.extends,
                            known_profiles=list(all_profiles.keys())))
                raise RuntimeError(msg)
            extended_profile = all_profiles[self.extends]
            extended_profile.resolve(all_profiles, rules_by_id, controls_manager)

            self.extend_by(extended_profile)

        self.selected = [s for s in set(self.selected) if s not in self.unselected]

        self.unselected = []
        self.extends = None

        self.selected = sorted(self.selected)

        for rid in self.selected:
            if rid not in rules_by_id:
                msg = (
                    "Rule {rid} is selected by {profile}, but the rule is not available. "
                    "This may be caused by a discrepancy of prodtypes."
                    .format(rid=rid, profile=self.id_))
                raise ValueError(msg)

        self.resolved = True


class ProfileWithInlinePolicies(ResolvableProfile):
    def __init__(self, * args, ** kwargs):
        super(ProfileWithInlinePolicies, self).__init__(* args, ** kwargs)
        self.controls_by_policy = defaultdict(list)

    def apply_selection(self, item):
        # ":" is the delimiter for controls but not when the item is a variable
        if ":" in item and "=" not in item:
            policy_id, control_id = item.split(":", 1)
            self.controls_by_policy[policy_id].append(control_id)
        else:
            super(ProfileWithInlinePolicies, self).apply_selection(item)

    def _process_controls_ids_into_controls(self, controls_manager, policy_id, controls_ids):
        controls = []
        for cid in controls_ids:
            if not cid.startswith("all"):
                controls.extend(
                    self._controls_ids_to_controls(controls_manager, policy_id, [cid]))
            elif ":" in cid:
                _, level_id = cid.split(":", 1)
                controls.extend(
                    controls_manager.get_all_controls_of_level(policy_id, level_id))
            else:
                controls.extend(
                    controls_manager.get_all_controls(policy_id))
        return controls

    def resolve_controls(self, controls_manager):
        for policy_id, controls_ids in self.controls_by_policy.items():
            controls = self._process_controls_ids_into_controls(
                controls_manager, policy_id, controls_ids)

            for c in controls:
                self.update_with(c)


class Value(XCCDFEntity):
    """Represents XCCDF Value
    """
    KEYS = dict(
        title=lambda: "",
        description=lambda: "",
        type=lambda: "",
        operator=lambda: "equals",
        interactive=lambda: False,
        options=lambda: dict(),
        warnings=lambda: list(),
        ** XCCDFEntity.KEYS
    )

    MANDATORY_KEYS = {
        "title",
        "description",
        "type",
    }

    @classmethod
    def process_input_dict(cls, input_contents, env_yaml, product_cpes=None):
        input_contents["interactive"] = (
            input_contents.get("interactive", "false").lower() == "true")

        data = super(Value, cls).process_input_dict(input_contents, env_yaml)

        possible_operators = ["equals", "not equal", "greater than",
                              "less than", "greater than or equal",
                              "less than or equal", "pattern match"]

        if data["operator"] not in possible_operators:
            raise ValueError(
                "Found an invalid operator value '%s'. "
                "Expected one of: %s"
                % (data["operator"], ", ".join(possible_operators))
            )

        return data

    @classmethod
    def from_yaml(cls, yaml_file, env_yaml=None, product_cpes=None):
        value = super(Value, cls).from_yaml(yaml_file, env_yaml)

        check_warnings(value)

        return value

    def to_xml_element(self):
        value = ET.Element('Value')
        value.set('id', self.id_)
        value.set('type', self.type)
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


class Benchmark(XCCDFEntity):
    """Represents XCCDF Benchmark
    """
    KEYS = dict(
        title=lambda: "",
        status=lambda: "",
        description=lambda: "",
        notice_id=lambda: "",
        notice_description=lambda: "",
        front_matter=lambda: "",
        rear_matter=lambda: "",
        cpes=lambda: list(),
        version=lambda: "",
        profiles=lambda: list(),
        values=lambda: dict(),
        groups=lambda: dict(),
        rules=lambda: dict(),
        platforms=lambda: dict(),
        product_cpe_names=lambda: list(),
        ** XCCDFEntity.KEYS
    )

    MANDATORY_KEYS = {
        "title",
        "status",
        "description",
        "front_matter",
        "rear_matter",
    }

    GENERIC_FILENAME = "benchmark.yml"

    def load_entities(self, rules_by_id, values_by_id, groups_by_id):
        for rid, val in self.rules.items():
            if not val:
                self.rules[rid] = rules_by_id[rid]

        for vid, val in self.values.items():
            if not val:
                self.values[vid] = values_by_id[vid]

        for gid, val in self.groups.items():
            if not val:
                self.groups[gid] = groups_by_id[gid]

    @classmethod
    def process_input_dict(cls, input_contents, env_yaml, product_cpes):
        input_contents["front_matter"] = input_contents["front-matter"]
        del input_contents["front-matter"]
        input_contents["rear_matter"] = input_contents["rear-matter"]
        del input_contents["rear-matter"]

        data = super(Benchmark, cls).process_input_dict(input_contents, env_yaml, product_cpes)

        notice_contents = required_key(input_contents, "notice")
        del input_contents["notice"]

        data["notice_id"] = required_key(notice_contents, "id")
        del notice_contents["id"]

        data["notice_description"] = required_key(notice_contents, "description")
        del notice_contents["description"]

        return data

    def represent_as_dict(self):
        data = super(Benchmark, cls).represent_as_dict()
        data["rear-matter"] = data["rear_matter"]
        del data["rear_matter"]

        data["front-matter"] = data["front_matter"]
        del data["front_matter"]
        return data

    @classmethod
    def from_yaml(cls, yaml_file, env_yaml=None, product_cpes=None):
        benchmark = super(Benchmark, cls).from_yaml(yaml_file, env_yaml)
        if env_yaml:
            benchmark.product_cpe_names = product_cpes.get_product_cpe_names()
            benchmark.product_cpes = product_cpes
            benchmark.id_ = env_yaml["benchmark_id"]
            benchmark.version = env_yaml["ssg_version_str"]
        else:
            benchmark.id_ = "product-name"
            benchmark.version = "0.0"

        return benchmark

    def add_profiles_from_dir(self, dir_, env_yaml, product_cpes):
        for dir_item in sorted(os.listdir(dir_)):
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
                new_profile = ProfileWithInlinePolicies.from_yaml(dir_item_path, env_yaml, product_cpes)
            except DocumentationNotComplete:
                continue
            except Exception as exc:
                msg = ("Error building profile from '{fname}': '{error}'"
                       .format(fname=dir_item_path, error=str(exc)))
                raise RuntimeError(msg)
            if new_profile is None:
                continue

            self.profiles.append(new_profile)

    def to_xml_element(self, env_yaml=None, product_cpes=None):
        root = ET.Element('Benchmark')
        root.set('id', self.id_)
        root.set('xmlns', "http://checklists.nist.gov/xccdf/1.1")
        root.set('xmlns:xsi', 'http://www.w3.org/2001/XMLSchema-instance')
        root.set('xsi:schemaLocation',
                 'http://checklists.nist.gov/xccdf/1.1 xccdf-1.1.4.xsd')
        root.set('style', 'SCAP_1.1')
        root.set('resolved', 'true')
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
        # if there are no platforms, do not output platform-specification at all
        if len(self.product_cpes.platforms) > 0:
            cpe_platform_spec = ET.Element(
                "{%s}platform-specification" % PREFIX_TO_NS["cpe-lang"])
            for platform in self.product_cpes.platforms.values():
                cpe_platform_spec.append(platform.to_xml_element())
            root.append(cpe_platform_spec)

        # The Benchmark applicability is determined by the CPEs
        # defined in the product.yml
        for cpe_name in self.product_cpe_names:
            plat = ET.SubElement(root, "platform")
            plat.set("idref", cpe_name)

        version = ET.SubElement(root, 'version')
        version.text = self.version
        version.set('update', SSG_BENCHMARK_LATEST_URI)

        contributors_file = os.path.join(os.path.dirname(__file__), "../Contributors.xml")
        add_benchmark_metadata(root, contributors_file)

        for profile in self.profiles:
            root.append(profile.to_xml_element())

        for value in self.values.values():
            root.append(value.to_xml_element())

        groups_in_bench = list(self.groups.keys())
        priority_order = ["system", "services"]
        groups_in_bench = reorder_according_to_ordering(groups_in_bench, priority_order)

        # Make system group the first, followed by services group
        for group_id in groups_in_bench:
            group = self.groups.get(group_id)
            # Products using application benchmark don't have system or services group
            if group is not None:
                root.append(group.to_xml_element(env_yaml))

        for rule in self.rules.values():
            root.append(rule.to_xml_element(env_yaml))

        return root

    def to_file(self, file_name, env_yaml=None):
        root = self.to_xml_element(env_yaml)
        tree = ET.ElementTree(root)
        tree.write(file_name)

    def add_value(self, value):
        if value is None:
            return
        self.values[value.id_] = value

    # The benchmark is also considered a group, so this function signature needs to match
    # Group()'s add_group()
    def add_group(self, group, env_yaml=None, product_cpes=None):
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


class Group(XCCDFEntity):
    """Represents XCCDF Group
    """
    ATTRIBUTES_TO_PASS_ON = (
        "platforms",
        "cpe_platform_names",
    )

    GENERIC_FILENAME = "group.yml"

    KEYS = dict(
        prodtype=lambda: "all",
        title=lambda: "",
        description=lambda: "",
        warnings=lambda: list(),
        requires=lambda: list(),
        conflicts=lambda: list(),
        values=lambda: dict(),
        groups=lambda: dict(),
        rules=lambda: dict(),
        platform=lambda: "",
        platforms=lambda: set(),
        cpe_platform_names=lambda: set(),
        ** XCCDFEntity.KEYS
    )

    MANDATORY_KEYS = {
        "title",
        "status",
        "description",
        "front_matter",
        "rear_matter",
    }

    @classmethod
    def process_input_dict(cls, input_contents, env_yaml, product_cpes=None):
        data = super(Group, cls).process_input_dict(input_contents, env_yaml, product_cpes)
        if data["rules"]:
            rule_ids = data["rules"]
            data["rules"] = {rid: None for rid in rule_ids}

        if data["groups"]:
            group_ids = data["groups"]
            data["groups"] = {gid: None for gid in group_ids}

        if data["values"]:
            value_ids = data["values"]
            data["values"] = {vid: None for vid in value_ids}

        if data["platform"]:
            data["platforms"].add(data["platform"])

        # parse platform definition and get CPEAL platform if cpe_platform_names not already defined
        if data["platforms"] and not data["cpe_platform_names"]:
            for platform in data["platforms"]:
                cpe_platform = Platform.from_text(platform, product_cpes)
                cpe_platform = add_platform_if_not_defined(cpe_platform, product_cpes)
                data["cpe_platform_names"].add(cpe_platform.id_)
        return data

    def load_entities(self, rules_by_id, values_by_id, groups_by_id):
        for rid, val in self.rules.items():
            if not val:
                self.rules[rid] = rules_by_id[rid]

        for vid, val in self.values.items():
            if not val:
                self.values[vid] = values_by_id[vid]

        for gid in list(self.groups):
            val = self.groups.get(gid, None)
            if not val:
                try:
                    self.groups[gid] = groups_by_id[gid]
                except KeyError:
                    # Add only the groups we have compiled and loaded
                    del self.groups[gid]
                    pass

    def represent_as_dict(self):
        yaml_contents = super(Group, self).represent_as_dict()

        if self.rules:
            yaml_contents["rules"] = sorted(list(self.rules.keys()))
        if self.groups:
            yaml_contents["groups"] = sorted(list(self.groups.keys()))
        if self.values:
            yaml_contents["values"] = sorted(list(self.values.keys()))

        return yaml_contents

    def to_xml_element(self, env_yaml=None):
        group = ET.Element('Group')
        group.set('id', self.id_)
        title = ET.SubElement(group, 'title')
        title.text = self.title
        add_sub_element(group, 'description', self.description)
        add_warning_elements(group, self.warnings)

        # This is where references should be put if there are any
        # This is where rationale should be put if there are any

        for cpe_platform_name in self.cpe_platform_names:
            platform_el = ET.SubElement(group, "platform")
            platform_el.set("idref", "#"+cpe_platform_name)

        add_nondata_subelements(group, "requires", "idref", self.requires)
        add_nondata_subelements(group, "conflicts", "idref", self.conflicts)

        for _value in self.values.values():
            group.append(_value.to_xml_element())

        # Rules that install or remove packages affect remediation
        # of other rules.
        # When packages installed/removed rules come first:
        # The Rules are ordered in more logical way, and
        # remediation order is natural, first the package is installed, then configured.
        rules_in_group = list(self.rules.keys())
        regex = (r'(package_.*_(installed|removed))|' +
                 r'(service_.*_(enabled|disabled))|' +
                 r'install_smartcard_packages|' +
                 r'sshd_set_keepalive(_0)?|' +
                 r'sshd_set_idle_timeout$')
        priority_order = ["enable_authselect", "installed", "install_smartcard_packages", "removed",
                          "enabled", "disabled", "sshd_set_keepalive_0",
                          "sshd_set_keepalive", "sshd_set_idle_timeout"]
        rules_in_group = reorder_according_to_ordering(rules_in_group, priority_order, regex)

        # Add rules in priority order, first all packages installed, then removed,
        # followed by services enabled, then disabled
        for rule_id in rules_in_group:
            group.append(self.rules.get(rule_id).to_xml_element(env_yaml))

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
            group.append(_group.to_xml_element(env_yaml))

        return group

    def add_value(self, value):
        if value is None:
            return
        self.values[value.id_] = value

    def add_group(self, group, env_yaml=None, product_cpes=None):
        self._add_child(group, self.groups, env_yaml, product_cpes)

    def _pass_our_properties_on_to(self, obj):
        for attr in self.ATTRIBUTES_TO_PASS_ON:
            if hasattr(obj, attr) and getattr(obj, attr) is None:
                setattr(obj, attr, getattr(self, attr))

    def add_rule(self, rule, env_yaml=None, product_cpes=None):
        self._add_child(rule, self.rules, env_yaml, product_cpes)

    def _add_child(self, child, childs, env_yaml=None, product_cpes=None):
        if child is None:
            return
        if self.platforms and not child.platforms:
            child.platforms = self.platforms
        childs[child.id_] = child
        self._pass_our_properties_on_to(child)

        # Once the child has inherited properties, update cpe_names
        if env_yaml:
            for platform in child.platforms:
                cpe_platform = Platform.from_text(platform, product_cpes)
                cpe_platform = add_platform_if_not_defined(cpe_platform, product_cpes)
                child.cpe_platform_names.add(cpe_platform.id_)

    def __str__(self):
        return self.id_


def noop_rule_filterfunc(rule):
    return True

def rule_filter_from_def(filterdef):
    if filterdef is None or filterdef == "":
        return noop_rule_filterfunc

    def filterfunc(rule):
        # Remove globals for security and only expose
        # variables relevant to the rule
        return eval(filterdef, {"__builtins__": None}, rule.__dict__)
    return filterfunc


class Rule(XCCDFEntity):
    """Represents XCCDF Rule
    """
    KEYS = dict(
        prodtype=lambda: "all",
        title=lambda: "",
        description=lambda: "",
        rationale=lambda: "",
        severity=lambda: "",
        references=lambda: dict(),
        identifiers=lambda: dict(),
        ocil_clause=lambda: None,
        ocil=lambda: None,
        oval_external_content=lambda: None,
        fixtext=lambda: "",
        srg_requirement=lambda: "",
        warnings=lambda: list(),
        conflicts=lambda: list(),
        requires=lambda: list(),
        platform=lambda: None,
        platforms=lambda: set(),
        sce_metadata=lambda: dict(),
        inherited_platforms=lambda: list(),
        template=lambda: None,
        cpe_platform_names=lambda: set(),
        inherited_cpe_platform_names=lambda: list(),
        bash_conditional=lambda: None,
        fixes=lambda: dict(),
        ** XCCDFEntity.KEYS
    )

    MANDATORY_KEYS = {
        "title",
        "description",
        "rationale",
        "severity",
    }

    GENERIC_FILENAME = "rule.yml"
    ID_LABEL = "rule_id"

    PRODUCT_REFERENCES = ("stigid", "cis",)
    GLOBAL_REFERENCES = ("srg", "vmmsrg", "disa", "cis-csc",)

    def __init__(self, id_):
        super(Rule, self).__init__(id_)
        self.sce_metadata = None

    def __deepcopy__(self, memo):
        cls = self.__class__
        result = cls.__new__(cls)
        memo[id(self)] = result
        for k, v in self.__dict__.items():
            # These are difficult to deep copy, so let's just re-use them.
            if k != "template" and k != "local_env_yaml":
                setattr(result, k, deepcopy(v, memo))
            else:
                setattr(result, k, v)
        return result

    @classmethod
    def from_yaml(cls, yaml_file, env_yaml=None, product_cpes=None, sce_metadata=None):
        rule = super(Rule, cls).from_yaml(yaml_file, env_yaml, product_cpes)

        # platforms are read as list from the yaml file
        # we need them to convert to set again
        rule.platforms = set(rule.platforms)

        # rule.platforms.update(set(rule.inherited_platforms))

        check_warnings(rule)

        # ensure that content of rule.platform is in rule.platforms as
        # well
        if rule.platform is not None:
            rule.platforms.add(rule.platform)

        # Convert the platform names to CPE names
        # But only do it if an env_yaml was specified (otherwise there would be no product CPEs
        # to lookup), and the rule's prodtype matches the product being built
        # also if the rule already has cpe_platform_names specified (compiled rule)
        # do not evaluate platforms again
        if (
                env_yaml and env_yaml["product"] in parse_prodtype(rule.prodtype)
                or env_yaml and rule.prodtype == "all") and product_cpes and not rule.cpe_platform_names:
            # parse platform definition and get CPEAL platform
            for platform in rule.platforms:
                cpe_platform = Platform.from_text(platform, product_cpes)
                cpe_platform = add_platform_if_not_defined(cpe_platform, product_cpes)
                rule.cpe_platform_names.add(cpe_platform.id_)


        if sce_metadata and rule.id_ in sce_metadata:
            rule.sce_metadata = sce_metadata[rule.id_]
            rule.sce_metadata["relative_path"] = os.path.join(
                env_yaml["product"], "checks/sce", rule.sce_metadata['filename'])

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

    def add_stig_references(self, stig_references):
        stig_id = self.references.get("stigid", None)
        if not stig_id:
            return
        reference = stig_references.get(stig_id, None)
        if not reference:
            return
        self.references["stigref"] = reference

    def _get_product_only_references(self):
        product_references = dict()

        for ref in Rule.PRODUCT_REFERENCES:
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
        for ref in Rule.PRODUCT_REFERENCES:
            if ref in general_references:
                msg = "Unexpected reference identifier ({0}) without "
                msg += "product qualifier ({0}@{1}) while building rule "
                msg += "{2}"
                msg = msg.format(ref, product, self.id_)
                raise ValueError(msg)

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

            label = full_label.split("@")[0]

            # this test should occur before matching product_suffix with the product qualifier
            # present in the reference, so it catches problems even for products that are not
            # being built at the moment
            if label in Rule.GLOBAL_REFERENCES:
                msg = (
                    "You cannot use product-qualified for the '{item_u}' reference. "
                    "Please remove the product-qualifier and merge values with the "
                    "existing reference if there is any. Original line: {item_q}: {value_q}"
                    .format(item_u=label, item_q=full_label, value_q=value)
                )
                raise ValueError(msg)

            if not full_label.endswith(product_suffix):
                continue

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

    def add_fixes(self, fixes):
        self.fixes = fixes

    def _add_fixes_elements(self, rule_el):
        for fix_type, fix in self.fixes.items():
            fix_el = ET.SubElement(rule_el, "fix")
            fix_el.set("system", FIX_TYPE_TO_SYSTEM[fix_type])
            fix_el.set("id", self.id_)
            fix_contents, config = fix
            for key in ssg.build_remediations.REMEDIATION_ELM_KEYS:
                if config[key]:
                    fix_el.set(key, config[key])
            fix_el.text = fix_contents + "\n"
            # Expand shell variables and remediation functions
            # into corresponding XCCDF <sub> elements
            ssg.build_remediations.expand_xccdf_subs(fix_el, fix_type)

    def to_xml_element(self, env_yaml=None):
        rule = ET.Element('Rule')
        rule.set('selected', 'false')
        rule.set('id', self.id_)
        rule.set('severity', self.severity)
        add_sub_element(rule, 'title', self.title)
        add_sub_element(rule, 'description', self.description)
        add_warning_elements(rule, self.warnings)

        if env_yaml:
            ref_uri_dict = env_yaml['reference_uris']
        else:
            ref_uri_dict = SSG_REF_URIS
        add_reference_elements(rule, self.references, ref_uri_dict)

        add_sub_element(rule, 'rationale', self.rationale)

        for cpe_platform_name in sorted(self.cpe_platform_names):
            platform_el = ET.SubElement(rule, "platform")
            platform_el.set("idref", "#"+cpe_platform_name)

        add_nondata_subelements(rule, "requires", "idref", self.requires)
        add_nondata_subelements(rule, "conflicts", "idref", self.conflicts)

        for ident_type, ident_val in self.identifiers.items():
            ident = ET.SubElement(rule, 'ident')
            if ident_type == 'cce':
                ident.set('system', cce_uri)
                ident.text = ident_val
        self._add_fixes_elements(rule)

        ocil_parent = rule
        check_parent = rule

        if self.sce_metadata:
            # TODO: This is pretty much another hack, just like the previous OVAL
            # one. However, we avoided the external SCE content as I'm not sure it
            # is generally useful (unlike say, CVE checking with external OVAL)
            #
            # Additionally, we build the content (check subelement) here rather
            # than in xslt due to the nature of our SCE metadata.
            #
            # Finally, before we begin, we might have an element with both SCE
            # and OVAL. We have no way of knowing (right here) whether that is
            # the case (due to a variety of issues, most notably, that linking
            # hasn't yet occurred). So we must rely on the content author's
            # good will, by annotating SCE content with a complex-check tag
            # if necessary.

            if 'complex-check' in self.sce_metadata:
                # Here we have an issue: XCCDF allows EITHER one or more check
                # elements OR a single complex-check. While we have an explicit
                # case handling the OVAL-and-SCE interaction, OCIL entries have
                # (historically) been alongside OVAL content and been in an
                # "OR" manner -- preferring OVAL to SCE. In order to accomplish
                # this, we thus need to add _yet another parent_ when OCIL data
                # is present, and add update ocil_parent accordingly.
                if self.ocil or self.ocil_clause:
                    ocil_parent = ET.SubElement(ocil_parent, "complex-check")
                    ocil_parent.set('operator', 'OR')

                check_parent = ET.SubElement(ocil_parent, "complex-check")
                check_parent.set('operator', self.sce_metadata['complex-check'])

            # Now, add the SCE check element to the tree.
            check = ET.SubElement(check_parent, "check")
            check.set("system", SCE_SYSTEM)

            if 'check-import' in self.sce_metadata:
                if isinstance(self.sce_metadata['check-import'], str):
                    self.sce_metadata['check-import'] = [self.sce_metadata['check-import']]
                for entry in self.sce_metadata['check-import']:
                    check_import = ET.SubElement(check, 'check-import')
                    check_import.set('import-name', entry)
                    check_import.text = None

            if 'check-export' in self.sce_metadata:
                if isinstance(self.sce_metadata['check-export'], str):
                    self.sce_metadata['check-export'] = [self.sce_metadata['check-export']]
                for entry in self.sce_metadata['check-export']:
                    export, value = entry.split('=')
                    check_export = ET.SubElement(check, 'check-export')
                    check_export.set('value-id', value)
                    check_export.set('export-name', export)
                    check_export.text = None

            check_ref = ET.SubElement(check, "check-content-ref")
            href = self.sce_metadata['relative_path']
            check_ref.set("href", href)

        check = ET.SubElement(check_parent, 'check')
        check.set("system", oval_namespace)
        check_content_ref = ET.SubElement(check, "check-content-ref")
        if self.oval_external_content:
            check_content_ref.set("href", self.oval_external_content)
        else:
            # TODO: This is pretty much a hack, oval ID will be the same as rule ID
            #       and we don't want the developers to have to keep them in sync.
            #       Therefore let's just add an OVAL ref of that ID.
            # TODO  Can we not add the check element if the rule doesn't have an OVAL check?
            #       At the moment, the check elements of rules without OVAL are removed by
            #       relabel_ids.py
            check_content_ref.set("href", "oval-unlinked.xml")
            check_content_ref.set("name", self.id_)

        patches_up_to_date = (self.id_ == "security_patches_up_to_date")
        if (self.ocil or self.ocil_clause) and not patches_up_to_date:
            ocil_check = ET.SubElement(check_parent, "check")
            ocil_check.set("system", ocil_cs)
            ocil_check_ref = ET.SubElement(ocil_check, "check-content-ref")
            ocil_check_ref.set("href", "ocil-unlinked.xml")
            ocil_check_ref.set("name", self.id_ + "_ocil")

        return rule

    def to_ocil(self):
        if not self.ocil and not self.ocil_clause:
            raise ValueError("Rule {0} doesn't have OCIL".format(self.id_))
        # Create <questionnaire> for the rule
        questionnaire = ET.Element("questionnaire", id=self.id_ + "_ocil")
        title = ET.SubElement(questionnaire, "title")
        title.text = self.title
        actions = ET.SubElement(questionnaire, "actions")
        test_action_ref = ET.SubElement(actions, "test_action_ref")
        test_action_ref.text = self.id_ + "_action"
        # Create <boolean_question_test_action> for the rule
        action = ET.Element(
            "boolean_question_test_action",
            id=self.id_ + "_action",
            question_ref=self.id_ + "_question")
        when_true = ET.SubElement(action, "when_true")
        result = ET.SubElement(when_true, "result")
        result.text = "PASS"
        when_true = ET.SubElement(action, "when_false")
        result = ET.SubElement(when_true, "result")
        result.text = "FAIL"
        # Create <boolean_question>
        boolean_question = ET.Element(
            "boolean_question", id=self.id_ + "_question")
        # TODO: The contents of <question_text> element used to be broken in
        # the legacy XSLT implementation. The following code contains hacks
        # to get the same results as in the legacy XSLT implementation.
        # This enabled us a smooth transition to new OCIL generator
        # without a need to mass-edit rule YAML files.
        # We need to solve:
        # TODO: using variables (aka XCCDF Values) in OCIL content
        # TODO: using HTML formating tags eg. <pre> in OCIL content
        #
        # The "ocil" key in compiled rules contains HTML and XML elements
        # but OCIL question texts shouldn't contain HTML or XML elements,
        # therefore removing them.
        if self.ocil is not None:
            ocil_without_tags = re.sub(r"</?[^>]+>", "", self.ocil)
        else:
            ocil_without_tags = ""
        # The "ocil" key in compiled rules contains XML entities which would
        # be escaped by ET.Subelement() so we need to use add_sub_element()
        # instead because we don't want to escape them.
        question_text = add_sub_element(
            boolean_question, "question_text", ocil_without_tags)
        # The "ocil_clause" key in compiled rules also contains HTML and XML
        # elements but unlike the "ocil" we want to escape the '<' and '>'
        # characters.
        # The empty ocil_clause causing broken question is in line with the
        # legacy XSLT implementation.
        ocil_clause = self.ocil_clause if self.ocil_clause else ""
        question_text.text = (
            u"{0}\n      Is it the case that {1}?\n      ".format(
                question_text.text if question_text.text is not None else "",
                ocil_clause))
        return (questionnaire, action, boolean_question)

    def __hash__(self):
        """ Controls are meant to be unique, so using the
        ID should suffice"""
        return hash(self.id_)

    def __eq__(self, other):
        return isinstance(other, self.__class__) and self.id_ == other.id_

    def __ne__(self, other):
        return not self != other

    def __lt__(self, other):
        return self.id_ < other.id_

    def __str__(self):
        return self.id_


class DirectoryLoader(object):
    def __init__(self, profiles_dir, env_yaml, product_cpes):
        self.benchmark_file = None
        self.group_file = None
        self.loaded_group = None
        self.rule_files = []
        self.value_files = []
        self.subdirectories = []

        self.all_values = dict()
        self.all_rules = dict()
        self.all_groups = dict()

        self.profiles_dir = profiles_dir
        self.env_yaml = env_yaml
        self.product = env_yaml["product"]

        self.parent_group = None
        self.product_cpes = product_cpes

    def _collect_items_to_load(self, guide_directory):
        for dir_item in sorted(os.listdir(guide_directory)):
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
        group_file, in the context of guide_directory, profiles_dir and env_yaml.

        Returns the loaded group or benchmark.
        """
        group = None
        if self.group_file and self.benchmark_file:
            raise ValueError("A .benchmark file and a .group file were found in "
                             "the same directory '%s'" % (guide_directory))

        # we treat benchmark as a special form of group in the following code
        if self.benchmark_file:
            group = Benchmark.from_yaml(
                self.benchmark_file, self.env_yaml, self.product_cpes
            )
            if self.profiles_dir:
                group.add_profiles_from_dir(self.profiles_dir, self.env_yaml)

        if self.group_file:
            group = Group.from_yaml(self.group_file, self.env_yaml, self.product_cpes)
            prodtypes = parse_prodtype(group.prodtype)
            if "all" in prodtypes or self.product in prodtypes:
                self.all_groups[group.id_] = group

        return group

    def _load_group_process_and_recurse(self, guide_directory):
        self.loaded_group = self.load_benchmark_or_group(guide_directory)

        if self.loaded_group:

            if self.parent_group:
                self.parent_group.add_group(
                    self.loaded_group, env_yaml=self.env_yaml, product_cpes=self.product_cpes)

            self._process_values()
            self._recurse_into_subdirs()
            self._process_rules()

    def process_directory_tree(self, start_dir, extra_group_dirs=None):
        self._collect_items_to_load(start_dir)
        if extra_group_dirs:
            self.subdirectories += extra_group_dirs
        self._load_group_process_and_recurse(start_dir)

    def process_directory_trees(self, directories):
        start_dir = directories[0]
        extra_group_dirs = directories[1:]
        return self.process_directory_tree(start_dir, extra_group_dirs)

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

    def save_all_entities(self, base_dir):
        destdir = os.path.join(base_dir, "rules")
        mkdir_p(destdir)
        if self.all_rules:
            self.save_entities(self.all_rules.values(), destdir)

        destdir = os.path.join(base_dir, "groups")
        mkdir_p(destdir)
        if self.all_groups:
            self.save_entities(self.all_groups.values(), destdir)

        destdir = os.path.join(base_dir, "values")
        mkdir_p(destdir)
        if self.all_values:
            self.save_entities(self.all_values.values(), destdir)

        destdir = os.path.join(base_dir, "platforms")
        mkdir_p(destdir)
        if self.product_cpes.platforms:
            self.save_entities(self.product_cpes.platforms.values(), destdir)

    def save_entities(self, entities, destdir):
        if not entities:
            return
        for entity in entities:
            basename = entity.id_ + ".yml"
            dest_filename = os.path.join(destdir, basename)
            entity.dump_yaml(dest_filename)


class BuildLoader(DirectoryLoader):
    def __init__(
            self, profiles_dir, env_yaml, product_cpes,
            sce_metadata_path=None, stig_reference_path=None):
        super(BuildLoader, self).__init__(profiles_dir, env_yaml, product_cpes)

        self.sce_metadata = None
        if sce_metadata_path and os.path.getsize(sce_metadata_path):
            self.sce_metadata = json.load(open(sce_metadata_path, 'r'))
        self.stig_references = None
        if stig_reference_path:
            self.stig_references = ssg.build_stig.map_versions_to_rule_ids(stig_reference_path)

    def _process_values(self):
        for value_yaml in self.value_files:
            value = Value.from_yaml(value_yaml, self.env_yaml)
            self.all_values[value.id_] = value
            self.loaded_group.add_value(value)

    def _process_rules(self):
        for rule_yaml in self.rule_files:
            try:
                rule = Rule.from_yaml(
                    rule_yaml, self.env_yaml, self.product_cpes, self.sce_metadata)
            except DocumentationNotComplete:
                # Happens on non-debug build when a rule is "documentation-incomplete"
                continue
            prodtypes = parse_prodtype(rule.prodtype)
            if "all" not in prodtypes and self.product not in prodtypes:
                continue
            self.all_rules[rule.id_] = rule
            self.loaded_group.add_rule(
                rule, env_yaml=self.env_yaml, product_cpes=self.product_cpes)

            if self.loaded_group.cpe_platform_names:
                rule.inherited_cpe_platform_names += self.loaded_group.cpe_platform_names

            rule.normalize(self.env_yaml["product"])
            if self.stig_references:
                rule.add_stig_references(self.stig_references)

    def _get_new_loader(self):
        loader = BuildLoader(
            self.profiles_dir, self.env_yaml, self.product_cpes)
        # Do it this way so we only have to parse the SCE metadata once.
        loader.sce_metadata = self.sce_metadata
        # Do it this way so we only have to parse the STIG references once.
        loader.stig_references = self.stig_references
        return loader

    def export_group_to_file(self, filename):
        return self.loaded_group.to_file(filename)


class LinearLoader(object):
    def __init__(self, env_yaml, resolved_path):
        self.resolved_rules_dir = os.path.join(resolved_path, "rules")
        self.rules = dict()

        self.resolved_profiles_dir = os.path.join(resolved_path, "profiles")
        self.profiles = dict()

        self.resolved_groups_dir = os.path.join(resolved_path, "groups")
        self.groups = dict()

        self.resolved_values_dir = os.path.join(resolved_path, "values")
        self.values = dict()

        self.resolved_platforms_dir = os.path.join(resolved_path, "platforms")
        self.platforms = dict()

        self.fixes_dir = os.path.join(resolved_path, "fixes")
        self.fixes = dict()

        self.benchmark = None
        self.env_yaml = env_yaml
        self.product_cpes = ProductCPEs(env_yaml)

    def find_first_groups_ids(self, start_dir):
        group_files = glob.glob(os.path.join(start_dir, "*", "group.yml"))
        group_ids = [fname.split(os.path.sep)[-2] for fname in group_files]
        return group_ids

    def load_entities_by_id(self, filenames, destination, cls):
        for fname in filenames:
            entity = cls.from_yaml(fname, self.env_yaml, self.product_cpes)
            destination[entity.id_] = entity

    def add_fixes_to_rules(self):
        for rule_id, rule_fixes in self.fixes.items():
            self.rules[rule_id].add_fixes(rule_fixes)

    def load_benchmark(self, directory):
        self.benchmark = Benchmark.from_yaml(
            os.path.join(directory, "benchmark.yml"), self.env_yaml, self.product_cpes)

        self.benchmark.add_profiles_from_dir(self.resolved_profiles_dir, self.env_yaml, self.product_cpes)

        benchmark_first_groups = self.find_first_groups_ids(directory)
        for gid in benchmark_first_groups:
            try:
                self.benchmark.add_group(self.groups[gid], self.env_yaml, self.product_cpes)
            except KeyError as exc:
                # Add only the groups we have compiled and loaded
                pass

    def load_compiled_content(self):
        self.fixes = ssg.build_remediations.load_compiled_remediations(self.fixes_dir)

        filenames = glob.glob(os.path.join(self.resolved_rules_dir, "*.yml"))
        self.load_entities_by_id(filenames, self.rules, Rule)

        filenames = glob.glob(os.path.join(self.resolved_groups_dir, "*.yml"))
        self.load_entities_by_id(filenames, self.groups, Group)

        filenames = glob.glob(os.path.join(self.resolved_profiles_dir, "*.yml"))
        self.load_entities_by_id(filenames, self.profiles, Profile)

        filenames = glob.glob(os.path.join(self.resolved_values_dir, "*.yml"))
        self.load_entities_by_id(filenames, self.values, Value)

        filenames = glob.glob(os.path.join(self.resolved_platforms_dir, "*.yml"))
        self.load_entities_by_id(filenames, self.platforms, Platform)
        self.product_cpes.platforms = self.platforms

        for g in self.groups.values():
            g.load_entities(self.rules, self.values, self.groups)

    def export_benchmark_to_file(self, filename):
        register_namespaces()
        return self.benchmark.to_file(filename, self.env_yaml)

    def export_ocil_to_file(self, filename):
        root = ET.Element('ocil')
        root.set('xmlns:xsi', xsi_namespace)
        root.set("xmlns", ocil_namespace)
        root.set("xmlns:xhtml", xhtml_namespace)
        tree = ET.ElementTree(root)
        generator = ET.SubElement(root, "generator")
        product_name = ET.SubElement(generator, "product_name")
        product_name.text = "build_shorthand.py from SCAP Security Guide"
        product_version = ET.SubElement(generator, "product_version")
        product_version.text = "ssg: " + self.env_yaml["ssg_version_str"]
        schema_version = ET.SubElement(generator, "schema_version")
        schema_version.text = "2.0"
        timestamp_el = ET.SubElement(generator, "timestamp")
        timestamp_el.text = timestamp
        questionnaires = ET.SubElement(root, "questionnaires")
        test_actions = ET.SubElement(root, "test_actions")
        questions = ET.SubElement(root, "questions")
        for rule in self.rules.values():
            if not rule.ocil and not rule.ocil_clause:
                continue
            questionnaire, action, boolean_question = rule.to_ocil()
            questionnaires.append(questionnaire)
            test_actions.append(action)
            questions.append(boolean_question)
        tree.write(filename)


class Platform(XCCDFEntity):

    KEYS = dict(
        name=lambda: "",
        original_expression=lambda: "",
        xml_content=lambda: "",
        bash_conditional=lambda: "",
        ansible_conditional=lambda: "",
        ** XCCDFEntity.KEYS
    )

    MANDATORY_KEYS = [
        "name",
        "xml_content",
        "original_expression",
        "bash_conditional",
        "ansible_conditional"
    ]

    prefix = "cpe-lang"
    ns = PREFIX_TO_NS[prefix]

    @classmethod
    def from_text(cls, expression, product_cpes):
        if not product_cpes:
            return None
        test = product_cpes.algebra.parse(
            expression, simplify=True)
        id = test.as_id()
        platform = cls(id)
        platform.test = test
        platform.test.enrich_with_cpe_info(product_cpes)
        platform.name = id
        platform.original_expression = expression
        platform.xml_content = platform.get_xml()
        platform.bash_conditional = platform.test.to_bash_conditional()
        platform.ansible_conditional = platform.test.to_ansible_conditional()
        return platform

    def get_xml(self):
        cpe_platform = ET.Element("{%s}platform" % Platform.ns)
        cpe_platform.set('id', self.name)
        # in case the platform contains only single CPE name, fake the logical test
        # we have to athere to CPE specification
        if isinstance(self.test, CPEALFactRef):
            cpe_test = ET.Element("{%s}logical-test" % CPEALLogicalTest.ns)
            cpe_test.set('operator', 'AND')
            cpe_test.set('negate', 'false')
            cpe_test.append(self.test.to_xml_element())
            cpe_platform.append(cpe_test)
        else:
            cpe_platform.append(self.test.to_xml_element())
        xmlstr = ET.tostring(cpe_platform).decode()
        return xmlstr

    def to_xml_element(self):
        return self.xml_content

    def to_bash_conditional(self):
        return self.bash_conditional

    def to_ansible_conditional(self):
        return self.ansible_conditional

    @classmethod
    def from_yaml(cls, yaml_file, env_yaml=None, product_cpes=None):
        platform = super(Platform, cls).from_yaml(yaml_file, env_yaml)
        platform.xml_content = ET.fromstring(platform.xml_content)
        # if we did receive a product_cpes, we can restore also the original test object
        # it can be later used e.g. for comparison
        if product_cpes:
            platform.test = product_cpes.algebra.parse(
                platform.original_expression, simplify=True)
        return platform

    def __eq__(self, other):
        if not isinstance(other, Platform):
            return False
        else:
            return self.test == other.test


def add_platform_if_not_defined(platform, product_cpes):
    # check if the platform is already in the dictionary. If yes, return the existing one
    for p in product_cpes.platforms.values():
        if platform == p:
            return p
    product_cpes.platforms[platform.id_] = platform
    return platform


def derive_id_from_file_name(filename):
    return os.path.splitext(filename)[0]
