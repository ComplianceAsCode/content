"""
Common functions for building YAML in SSG.
Also contains definitions of basic classes like Rule, Group, Value and Platform.
"""

from __future__ import absolute_import
from __future__ import print_function

from copy import deepcopy
import datetime
import time
import json
import os
import os.path
import re
import sys
import glob


import ssg.build_remediations
import ssg.components
from .build_cpe import CPEALLogicalTest, CPEALCheckFactRef, ProductCPEs
from .constants import (XCCDF12_NS,
                        OSCAP_BENCHMARK,
                        OSCAP_GROUP,
                        OSCAP_RULE,
                        OSCAP_VALUE,
                        SCE_SYSTEM,
                        cce_uri,
                        dc_namespace,
                        ocil_cs,
                        ocil_namespace,
                        oval_namespace,
                        xhtml_namespace,
                        xsi_namespace,
                        timestamp,
                        timestamp_yyyy_mm_dd,
                        SSG_BENCHMARK_LATEST_URI,
                        SSG_PROJECT_NAME,
                        SSG_REF_URIS,
                        SSG_IDENT_URIS,
                        PREFIX_TO_NS,
                        FIX_TYPE_TO_SYSTEM
                        )
from .rules import get_rule_dir_yaml, is_rule_dir

from .cce import is_cce_format_valid, is_cce_value_valid
from .yaml import DocumentationNotComplete, open_and_macro_expand
from .utils import required_key, mkdir_p

from .xml import ElementTree as ET, register_namespaces, parse_file
import ssg.build_stig

from .entities.common import add_sub_element, make_items_product_specific, \
                             XCCDFEntity, Templatable
from .entities.profile import Profile, ProfileWithInlinePolicies


def _get_cpe_platforms_of_sub_groups(group, rule_ids_list):
    """
    Retrieves the set of CPE platforms used by the sub-groups of a given group.

    Args:
        group (Group): The group object containing sub-groups.
        rule_ids_list (list): A list of rule IDs to filter the CPE platforms.

    Returns:
        set: A set of CPE platforms used by the sub-groups.
    """
    cpe_platforms = set()
    for sub_group in group.groups.values():
        cpe_platforms_of_sub_group = sub_group.get_used_cpe_platforms(rule_ids_list)
        cpe_platforms.update(cpe_platforms_of_sub_group)
    return cpe_platforms


def reorder_according_to_ordering(unordered, ordering, regex=None):
    """
    Reorders a list of items according to a specified ordering.

    Args:
        unordered (list): The list of unordered items.
        ordering (list): The list of items specifying the desired order.
        regex (str, optional): A regex pattern to filter items to be ordered.
                               If None, a pattern is created from the ordering list.

    Returns:
        list: A list of items ordered according to the ordering list, followed by any remaining
              items sorted alphabetically.
    """
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
    """
    Adds warning elements to the given XML element.

    This function iterates over a list of warning dictionaries and adds each warning as a
    sub-element to the provided XML element. Each dictionary in the warnings list should contain
    a single key-value pair, where the key represents the warning category and the value
    represents the warning text.

    Args:
        element (xml.etree.ElementTree.Element): The XML element to which the warning elements
                                                 will be added.
        warnings (list of dict): A list of dictionaries, each containing a single key-value pair
                                 representing the warning category and text.
    Returns:
        None
    """
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
        warning = add_sub_element(
            element, "warning", XCCDF12_NS, list(warning_dict.values())[0])
        warning.set("category", list(warning_dict.keys())[0])


def add_nondata_subelements(element, subelement, attribute, attr_data):
    """
    Add multiple iterations of a subelement that contains an attribute but no data.

    This function creates subelements under a given XML element. Each subelement will have a
    specified attribute set to a value from the provided list of attribute data.

    Args:
        element (xml.etree.ElementTree.Element): The parent XML element to which subelements will
                                                 be added.
        subelement (str): The tag name of the subelements to be created.
        attribute (str): The name of the attribute to be set on each subelement.
        attr_data (list): A list of values to be assigned to the specified attribute of each
                          subelement.
    """
    for data in attr_data:
        req = ET.SubElement(element, "{%s}%s" % (XCCDF12_NS, subelement))
        req.set(attribute, data)


def check_warnings(xccdf_structure):
    """
    Checks the warnings in the given xccdf_structure.

    This function iterates through the warnings in the xccdf_structure and ensures that each
    warning dictionary contains exactly one key/value pair. If a warning dictionary contains more
    than one key/value pair, a ValueError is raised with an appropriate message.

    Args:
        xccdf_structure (object): An object that contains a list of warning dictionaries under the
                                  attribute 'warnings'.

    Returns:
        None

    Raises:
        ValueError: If any warning dictionary contains more than one key/value pair.
    """
    for warning_list in xccdf_structure.warnings:
        if len(warning_list) != 1:
            msg = "Only one key/value pair should exist for each warnings dictionary"
            raise ValueError(msg)


def add_reference_elements(element, references, ref_uri_dict):
    """
    Adds reference elements to an XML element based on provided references and their
    corresponding URIs.

    Args:
        element (xml.etree.ElementTree.Element): The XML element to which reference elements will
                                                 be added.
        references (dict): A dictionary where keys are reference types (e.g., 'srg') and values
                           are lists of reference values.
        ref_uri_dict (dict): A dictionary mapping reference types to their corresponding URIs.

    Returns:
        None

    Raises:
        ValueError: If an SRG reference does not have a defined URI or if an unknown reference
                    type is encountered.
    """
    for ref_type, ref_vals in references.items():
        for ref_val in ref_vals:
            # This assumes that a single srg key may have items from multiple SRG types
            if ref_type == 'srg':
                if ref_val.startswith('SRG-OS-'):
                    ref_href = ref_uri_dict['os-srg']
                elif re.match(r'SRG-APP-\d{5,}-CTR-\d{5,}', ref_val):
                    # The more specific case needs to come first, otherwise the generic SRG-APP
                    # will catch everything
                    ref_href = ref_uri_dict['app-srg-ctr']
                elif ref_val.startswith('SRG-APP-'):
                    ref_href = ref_uri_dict['app-srg']
                else:
                    raise ValueError("SRG {0} doesn't have a URI defined.".format(ref_val))
            else:
                if ref_type not in ref_uri_dict.keys():
                    msg = (
                        "Error processing reference {0}: {1}. A reference type "
                        "has been added that the project doesn't know about."
                        .format(ref_type, ref_vals))
                    raise ValueError(msg)
                ref_href = ref_uri_dict[ref_type]

            ref = ET.SubElement(element, '{%s}reference' % XCCDF12_NS)
            ref.set("href", ref_href)
            ref.text = ref_val


def add_reference_title_elements(benchmark_el, env_yaml):
    """
    Adds reference title elements to the given benchmark element.

    This function creates and appends reference elements to the provided benchmark element.
    The references are sourced from the `env_yaml` if provided, otherwise from the default
    `SSG_REF_URIS`.

    Args:
        benchmark_el (xml.etree.ElementTree.Element): The benchmark element to which reference
                                                      elements will be added.
        env_yaml (dict): A dictionary containing reference URIs. If None, the default
                         `SSG_REF_URIS` will be used.

    Returns:
        None
    """
    if env_yaml:
        ref_uri_dict = env_yaml['reference_uris']
    else:
        ref_uri_dict = SSG_REF_URIS
    for title, uri in ref_uri_dict.items():
        reference = ET.SubElement(benchmark_el, "{%s}reference" % XCCDF12_NS)
        reference.set("href", uri)
        reference.text = title


def add_benchmark_metadata(element, contributors_file):
    """
    Adds benchmark metadata to an XML element.

    This function appends metadata information to the provided XML element, including publisher,
    creator, contributors, and source information.

    Args:
        element (xml.etree.ElementTree.Element): The XML element to which the metadata will be added.
        contributors_file (str): Path to the file containing contributors information.

    Returns:
        None
    """
    metadata = ET.SubElement(element, "{%s}metadata" % XCCDF12_NS)

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


class Value(XCCDFEntity):
    """
    Represents an XCCDF Value entity.

    Attributes:
        KEYS (dict): A dictionary of default values for various attributes.
        MANDATORY_KEYS (set): A set of keys that are mandatory for the Value entity.
    """
    KEYS = dict(
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
        """
        Processes the input dictionary for a given environment YAML and optional product CPEs.

        Args:
            input_contents (dict): The input dictionary containing various parameters.
            env_yaml (dict): The environment YAML configuration.
            product_cpes (optional): Product CPEs, if any.

        Returns:
            dict: Processed data dictionary with validated and possibly modified contents.

        Raises:
            ValueError: If the operator in the input data is not one of the expected possible operators.
        """
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
        """
        Create an instance of the class from a YAML file.

        Args:
            yaml_file (str): Path to the YAML file.
            env_yaml (str, optional): Path to an environment YAML file. Defaults to None.
            product_cpes (str, optional): Product CPEs information. Defaults to None.

        Returns:
            Value: An instance of the class created from the YAML file.
        """
        value = super(Value, cls).from_yaml(yaml_file, env_yaml)

        check_warnings(value)

        return value

    def to_xml_element(self):
        """
        Converts the current object to an XML element.

        This method creates an XML element representing the current object using the XCCDF 1.2
        namespace. It sets attributes and child elements based on the object's properties.

        Returns:
            xml.etree.ElementTree.Element: The XML element representing the object.
        """
        value = ET.Element('{%s}Value' % XCCDF12_NS)
        value.set('id', OSCAP_VALUE + self.id_)
        value.set('type', self.type)
        if self.operator != "equals":  # equals is the default
            value.set('operator', self.operator)
        if self.interactive:  # False is the default
            value.set('interactive', 'true')
        title = ET.SubElement(value, '{%s}title' % XCCDF12_NS)
        title.text = self.title
        add_sub_element(value, 'description', XCCDF12_NS, self.description)
        add_warning_elements(value, self.warnings)

        for selector, option in self.options.items():
            # do not confuse Value with big V with value with small v
            # value is child element of Value
            value_small = ET.SubElement(value, '{%s}value' % XCCDF12_NS)
            # by XCCDF spec, default value is value without selector
            if selector != "default":
                value_small.set('selector', str(selector))
            value_small.text = str(option)

        return value


class Benchmark(XCCDFEntity):
    """
    Represents an XCCDF Benchmark entity with various attributes and methods to manipulate and
    represent the benchmark data.

    Attributes:
        KEYS (dict): Dictionary of keys with default values.
        MANDATORY_KEYS (set): Set of mandatory keys for the benchmark.
        GENERIC_FILENAME (str): Default filename for the benchmark.
    """
    KEYS = dict(
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
        """
        Load entities into the current object from provided dictionaries if they are not already set.

        Args:
            rules_by_id (dict): A dictionary containing rule entities indexed by their IDs.
            values_by_id (dict): A dictionary containing value entities indexed by their IDs.
            groups_by_id (dict): A dictionary containing group entities indexed by their IDs.

        This method updates the `rules`, `values`, and `groups` attributes of the current object.
        If an entity in these attributes is not already set (i.e., its value is falsy), it will be
        loaded from the corresponding provided dictionary.
        """
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
        """
        Processes the input dictionary by transforming specific keys and extracting required data.

        Args:
            cls (type): The class that calls this method.
            input_contents (dict): The dictionary containing the input data to be processed.
            env_yaml (dict): The environment YAML data.
            product_cpes (list): The list of product CPEs.

        Returns:
            dict: The processed data dictionary with transformed and extracted information.

        Raises:
            KeyError: If any required key is missing in the input dictionaries.
        """
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
        """
        Converts the instance attributes to a dictionary representation, modifying specific keys
        for compatibility.

        Returns:
            dict: A dictionary representation of the instance with modified keys.
        """
        data = super(Benchmark, self).represent_as_dict()
        data["rear-matter"] = data["rear_matter"]
        del data["rear_matter"]

        data["front-matter"] = data["front_matter"]
        del data["front_matter"]
        return data

    @classmethod
    def from_yaml(cls, yaml_file, env_yaml=None, product_cpes=None):
        """
        Creates a Benchmark instance from a YAML file.

        Args:
            yaml_file (str): Path to the YAML file.
            env_yaml (dict, optional): Environment-specific YAML data. Defaults to None.
            product_cpes (ProductCPEs, optional): Product CPEs instance. Defaults to None.

        Returns:
            Benchmark: An instance of the Benchmark class populated with data from the YAML file.
        """
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
        """
        Adds profiles from the specified directory to the current instance.

        This method scans the given directory for files with the '.profile' extension, attempts to
        create ProfileWithInlinePolicies objects from them, and appends them to the instance's
        profiles list.

        Args:
            dir_ (str): The directory to scan for profile files.
            env_yaml (dict): The environment YAML data used for profile creation.
            product_cpes (list): The list of product CPEs used for profile creation.

        Returns:
            None

        Raises:
            RuntimeError: If there is an error building a profile from a file.

        Notes:
            - Files that do not have the '.profile' extension are skipped.
            - If a profile file is incomplete or an error occurs during its creation, it is skipped.
        """
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
                new_profile = ProfileWithInlinePolicies.from_yaml(
                    dir_item_path, env_yaml, product_cpes)
            except DocumentationNotComplete:
                continue
            except Exception as exc:
                msg = ("Error building profile from '{fname}': '{error}'"
                       .format(fname=dir_item_path, error=str(exc)))
                raise RuntimeError(msg)
            if new_profile is None:
                continue

            self.profiles.append(new_profile)

    def unselect_empty_groups(self):
        """
        Unselects empty groups from each profile in the profiles list.

        This method iterates through each profile in the `profiles` list and calls the
        `unselect_empty_groups` method on each profile, passing the current instance as an
        argument.

        Returns:
            None
        """
        for p in self.profiles:
            p.unselect_empty_groups(self)

    def drop_rules_not_included_in_a_profile(self):
        """
        Removes rules from groups that are not included in any profile.

        This method retrieves the set of rules that are selected in all profiles and removes any
        rules from each group that are not listed in this set.

        Returns:
            None
        """
        selected_rules = self.get_rules_selected_in_all_profiles()
        for g in self.groups.values():
            g.remove_rules_with_ids_not_listed(selected_rules)

    def get_components_not_included_in_a_profiles(self, profiles,  rules_and_variables_dict):
        """
        Identify and return the sets of rules, groups, and variables that are not included in any
        of the given profiles.

        Args:
            profiles (list): A list of profiles to check against.
            rules_and_variables_dict (dict): A dictionary containing rules and their associated
                                             variables.

        Returns:
            tuple: A tuple containing three sets:
                - rules (set): A set of rules not included in any of the profiles.
                - groups (set): A set of groups not included in any of the profiles.
                - variables (set): A set of variables not included in any of the profiles.
        """
        selected_rules = self.get_rules_selected_in_all_profiles(profiles)
        selected_variables = self.get_variables_of_rules(
            profiles, selected_rules, rules_and_variables_dict
        )
        rules = set()
        groups = set()
        variables = set()

        out_sets = dict(rules_set=rules, groups_set=groups, variables_set=variables)

        for sub_group in self.groups.values():
            self._update_not_included_components(
                sub_group, selected_rules, selected_variables, out_sets
            )

        return rules, groups, variables

    def get_used_cpe_platforms(self, profiles):
        """
        Retrieves the CPE platforms used by the selected rules in the given profiles.

        Args:
            profiles (list): A list of profiles to check for selected rules.

        Returns:
            list: A list of CPE platforms associated with the selected rules.
        """
        selected_rules = self.get_rules_selected_in_all_profiles(profiles)
        cpe_platforms = _get_cpe_platforms_of_sub_groups(self, selected_rules)
        return cpe_platforms

    def get_not_used_cpe_platforms(self, profiles):
        """
        Get the CPE platforms that are not used in the given profiles.

        Args:
            profiles (list): A list of profiles to check for used CPE platforms.

        Returns:
            set: A set of CPE platforms that are not used in the given profiles.
        """
        used_cpe_platforms = self.get_used_cpe_platforms(profiles)
        out = set()
        for cpe_platform in self.product_cpes.platforms.keys():
            if cpe_platform not in used_cpe_platforms:
                out.add(cpe_platform)
        return out

    @staticmethod
    def get_variables_of_rules(profiles, rule_ids, rules_and_variables_dict):
        """
        Collects and returns a set of variables associated with the given rules and profiles.

        Args:
            profiles (list): A list of profile objects, each containing a dictionary of variables.
            rule_ids (list): A list of rule identifiers.
            rules_and_variables_dict (dict): A dictionary mapping rule identifiers to sets of variables.

        Returns:
            set: A set of variables associated with the specified rules and profiles.
        """
        selected_variables = set()
        for rule in rule_ids:
            selected_variables.update(rules_and_variables_dict.get(rule))
        for profile in profiles:
            selected_variables.update(profile.variables.keys())
        return selected_variables

    def get_rules_selected_in_all_profiles(self, profiles=None):
        """
        Get the set of rules that are selected in all given profiles.

        Args:
            profiles (list, optional): A list of profile objects. If None, the method will use the
                                       instance's profiles attribute.

        Returns:
            set: A set of rules that are selected in all provided profiles.
        """
        selected_rules = set()
        if profiles is None:
            profiles = self.profiles
        for p in profiles:
            selected_rules.update(p.selected)
        return selected_rules

    def _create_benchmark_xml_skeleton(self, env_yaml):
        """
        Creates the skeleton of a benchmark XML document.

        This method initializes the root element of the XML document with the necessary attributes
        and sub-elements based on the provided environment YAML configuration.

        Args:
            env_yaml (dict): A dictionary containing environment configuration parameters.

        Returns:
            xml.etree.ElementTree.Element: The root element of the benchmark XML document.
        """
        root = ET.Element('{%s}Benchmark' % XCCDF12_NS)
        root.set('id', OSCAP_BENCHMARK + self.id_)
        root.set('xmlns:xsi', 'http://www.w3.org/2001/XMLSchema-instance')
        root.set(
            'xsi:schemaLocation',
            'http://checklists.nist.gov/xccdf/1.2 xccdf-1.2.xsd')
        root.set('style', 'SCAP_1.2')
        root.set('resolved', 'true')
        root.set('xml:lang', 'en-US')

        status = ET.SubElement(root, '{%s}status' % XCCDF12_NS)
        status.set('date', timestamp_yyyy_mm_dd)
        status.text = self.status

        add_sub_element(root, "title", XCCDF12_NS, self.title)
        add_sub_element(root, "description", XCCDF12_NS, self.description)

        notice = add_sub_element(
            root, "notice", XCCDF12_NS, self.notice_description
        )
        notice.set('id', self.notice_id)

        add_sub_element(root, "front-matter", XCCDF12_NS, self.front_matter)
        add_sub_element(root, "rear-matter",  XCCDF12_NS, self.rear_matter)

        return root

    def _add_cpe_xml(self, root, cpe_platforms_to_not_include, product_cpes=None):
        """
        Adds CPE XML elements to the given root element.

        This method creates a platform-specification element and appends platform elements to it
        based on the product CPEs, excluding those specified in cpe_platforms_to_not_include. If
        there are any platform elements added, the platform-specification element is appended to
        the root element. Additionally, it adds platform elements to the root element based on the
        product CPE names.

        Args:
            root (xml.etree.ElementTree.Element): The root XML element to which the CPE elements
                                                  will be added.
            cpe_platforms_to_not_include (list): A list of platform IDs to be excluded from the
                                                 CPE XML.
            product_cpes (dict, optional): An object containing product CPEs. Defaults to None.

        Returns:
            None
        """
        # if there are no platforms, do not output platform-specification at all

        cpe_platform_spec = ET.Element(
            "{%s}platform-specification" % PREFIX_TO_NS["cpe-lang"])
        for platform_id, platform in self.product_cpes.platforms.items():
            if platform_id in cpe_platforms_to_not_include:
                continue
            cpe_platform_spec.append(platform.to_xml_element())

        if len(cpe_platform_spec) > 0:
            root.append(cpe_platform_spec)

        # The Benchmark applicability is determined by the CPEs
        # defined in the product.yml
        for cpe_name in self.product_cpe_names:
            plat = ET.SubElement(root, "{%s}platform" % XCCDF12_NS)
            plat.set("idref", cpe_name)

    def _add_profiles_xml(self, root, components_to_not_include):
        """
        Adds profile XML elements to the given root element, excluding specified components.

        This method iterates over the profiles and appends their XML representation to the root
        element, excluding profiles and their components that are specified in the
        components_to_not_include dictionary.

        Args:
            root (xml.etree.ElementTree.Element): The root XML element to which profile elements
                                                  will be added.
            components_to_not_include (dict): A dictionary specifying components to exclude. It
                                              should have a key "profiles" with a set of profile
                                              IDs to exclude.

        Returns:
            None
        """
        profiles_to_not_include = components_to_not_include.get("profiles", set())
        for profile in self.profiles:
            if profile.id_ in profiles_to_not_include:
                continue
            profile.remove_components_not_included(components_to_not_include)
            root.append(profile.to_xml_element())

    def _add_values_xml(self, root, components_to_not_include):
        """
        Adds XML elements for values to the given root element, excluding specified components.

        Args:
            root (xml.etree.ElementTree.Element): The root XML element to which value elements
                                                  will be added.
            components_to_not_include (dict): A dictionary specifying components to exclude. The
                                              key "variables" should map to a set of value IDs to
                                              be excluded.

        Returns:
            None
        """
        variables_to_not_include = components_to_not_include.get("variables", set())
        for value_id, value in self.values.items():
            if value_id in variables_to_not_include:
                continue
            root.append(value.to_xml_element())

    def _add_groups_xml(self, root, components_to_not_include, env_yaml=None):
        """
        Adds XML elements for groups to the given root element.

        This method processes the groups defined in the benchmark, reorders them according to a
        specified priority, and appends their XML representation to the root element. Groups that
        are specified in the components_to_not_include are skipped.

        Args:
            root (xml.etree.ElementTree.Element): The root XML element to which the group elements
                                                  will be appended.
            components_to_not_include (dict): A dictionary specifying components (e.g., groups)
                                              that should not be included.
            env_yaml (dict, optional): An optional environment YAML configuration that may be passed
                                       to the group's to_xml_element method.
        """
        groups_in_bench = list(self.groups.keys())
        priority_order = ["system", "services", "auditing"]
        groups_in_bench = reorder_according_to_ordering(groups_in_bench, priority_order)

        groups_to_not_include = components_to_not_include.get("groups", set())
        # Make system group the first, followed by services group
        for group_id in groups_in_bench:
            if group_id in groups_to_not_include:
                continue
            group = self.groups.get(group_id)
            # Products using application benchmark don't have system or services group
            if group is not None:
                root.append(group.to_xml_element(env_yaml, components_to_not_include))

    def _add_rules_xml(self, root, rules_to_not_include, env_yaml=None):
        """
        Adds XML elements for rules to the given root element, excluding specified rules.

        Args:
            root (xml.etree.ElementTree.Element): The root XML element to which rule elements will be added.
            rules_to_not_include (set): A set of rule IDs to be excluded from the XML.
            env_yaml (dict, optional): An optional dictionary containing environment variables for the rules.

        Returns:
            None
        """
        for rule in self.rules.values():
            if rule.id_ in rules_to_not_include:
                continue
            root.append(rule.to_xml_element(env_yaml))

    def _add_version_xml(self, root):
        """
        Adds a version element to the provided XML root element.

        This method creates a new 'version' subelement under the given root element and sets its
        text to the instance's version attribute. Additionally, it sets the 'update' attribute of
        the version element to the latest SSG benchmark URI.

        Args:
            root (xml.etree.ElementTree.Element): The root element to which the version element
                                                  will be added.
        """
        version = ET.SubElement(root, '{%s}version' % XCCDF12_NS)
        version.text = self.version
        version.set('update', SSG_BENCHMARK_LATEST_URI)

    def to_xml_element(self, env_yaml=None, product_cpes=None, components_to_not_include=None):
        """
        Converts the current object to an XML element.

        Args:
            env_yaml (dict, optional): Environment YAML data. Defaults to None.
            product_cpes (list, optional): List of product CPEs. Defaults to None.
            components_to_not_include (dict, optional): Components to exclude from the XML.
                                                        Defaults to None.

        Returns:
            xml.etree.ElementTree.Element: The root XML element representing the object.
        """
        if components_to_not_include is None:
            cpe_platforms = self.get_not_used_cpe_platforms(self.profiles)
            components_to_not_include = {"cpe_platforms": cpe_platforms}

        root = self._create_benchmark_xml_skeleton(env_yaml)

        add_reference_title_elements(root, env_yaml)

        self._add_cpe_xml(
            root, components_to_not_include.get("cpe_platforms", set()), product_cpes
        )

        self._add_version_xml(root)

        contributors_file = os.path.join(os.path.dirname(__file__), "../Contributors.xml")
        add_benchmark_metadata(root, contributors_file)

        self._add_profiles_xml(root, components_to_not_include)
        self._add_values_xml(root, components_to_not_include)
        self._add_groups_xml(root, components_to_not_include, env_yaml)
        self._add_rules_xml(root, components_to_not_include.get("rules", set()),  env_yaml,)

        if hasattr(ET, "indent"):
            ET.indent(root, space="  ", level=0)
        return root

    def to_file(self, file_name, env_yaml=None):
        """
        Serializes the XML representation of the object to a file.

        Args:
            file_name (str): The name of the file to which the XML data will be written.
            env_yaml (dict, optional): An optional parameter that can be used to customize the XML generation.

        Returns:
            None
        """
        root = self.to_xml_element(env_yaml)
        tree = ET.ElementTree(root)
        tree.write(file_name, encoding="utf-8")

    def add_value(self, value):
        """
        Adds a value to the values dictionary if the value is not None.

        Args:
            value (object): The value to be added. It is expected to have an 'id_' attribute.

        Returns:
            None
        """
        if value is None:
            return
        self.values[value.id_] = value

    # The benchmark is also considered a group, so this function signature needs to match
    # Group()'s add_group()
    def add_group(self, group, env_yaml=None, product_cpes=None):
        """
        Adds a group to the groups dictionary.

        Args:
            group (Group): The group object to be added. Must have an 'id_' attribute.
            env_yaml (dict, optional): Additional environment YAML data. Default is None.
            product_cpes (dict, optional): Additional product CPEs data. Default is None.

        Returns:
            None
        """
        if group is None:
            return
        self.groups[group.id_] = group

    def add_rule(self, rule):
        """
        Adds a rule to the rules dictionary.

        Args:
            rule (Rule): The rule to be added. If None, the method returns without adding anything.

        Returns:
            None
        """
        if rule is None:
            return
        self.rules[rule.id_] = rule

    def to_xccdf(self):
        """
        Converts the current object to XCCDF format.

        This method is intended to be extended to generate a valid XCCDF instead of SSG SHORTHAND.

        Returns:
            None

        Raises:
            NotImplementedError: This method is not yet implemented.
        """
        raise NotImplementedError

    def __str__(self):
        return self.id_

    def get_benchmark_xml_for_profiles(self, env_yaml, profiles, rule_and_variables_dict):
        """
        Generates the benchmark XML for the given profiles.

        Args:
            env_yaml (dict): The environment YAML configuration.
            profiles (list): A list of profile objects.
            rule_and_variables_dict (dict): A dictionary containing rules and variables.

        Returns:
            tuple: A tuple containing:
                - profiles_ids (list): A list of profile IDs.
                - xml_element (Element): The XML element representing the benchmark.
        """
        rules, groups, variables = self.get_components_not_included_in_a_profiles(
            profiles, rule_and_variables_dict
        )
        cpe_platforms = self.get_not_used_cpe_platforms(profiles)
        profiles_ids = [profile.id_ for profile in profiles]
        profiles = set(filter(
            lambda id_, profiles_ids=profiles_ids: id_ not in profiles_ids,
            [profile.id_ for profile in self.profiles]
        ))
        components_to_not_include = {
                "rules": rules,
                "groups": groups,
                "variables": variables,
                "profiles": profiles,
                "cpe_platforms": cpe_platforms
            }
        return profiles_ids, self.to_xml_element(
            env_yaml,
            components_to_not_include=components_to_not_include
        )


class Group(XCCDFEntity):
    """
    Represents an XCCDF Group entity, which is a collection of rules, values, and sub-groups
    that can be processed and converted into various formats such as YAML and XML.

    Attributes:
        GENERIC_FILENAME (str): The default filename for the group.
        KEYS (dict): A dictionary of keys and their default values for the group.
        MANDATORY_KEYS (set): A set of keys that are mandatory for the group.
    """

    GENERIC_FILENAME = "group.yml"

    KEYS = dict(
        description=lambda: "",
        warnings=lambda: list(),
        requires=lambda: list(),
        conflicts=lambda: list(),
        values=lambda: dict(),
        groups=lambda: dict(),
        rules=lambda: dict(),
        platform=lambda: "",
        platforms=lambda: set(),
        inherited_platforms=lambda: set(),
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
        """
        Processes the input dictionary and updates it with additional data.

        Args:
            cls (type): The class type that calls this method.
            input_contents (dict): The input dictionary containing initial data.
            env_yaml (dict): The environment YAML data.
            product_cpes (dict, optional): The product CPEs, defaults to None.

        Returns:
            dict: The processed data dictionary with updated rules, groups, values, and platforms.
        """
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

        # parse platform definition and get CPEAL platform
        # if cpe_platform_names not already defined
        if data["platforms"] and not data["cpe_platform_names"]:
            for platform in data["platforms"]:
                cpe_platform = Platform.from_text(platform, product_cpes)
                cpe_platform = add_platform_if_not_defined(cpe_platform, product_cpes)
                data["cpe_platform_names"].add(cpe_platform.id_)
        return data

    def load_entities(self, rules_by_id, values_by_id, groups_by_id):
        """
        Load entities into the current object's rules, values, and groups attributes.

        This method updates the current object's `rules`, `values`, and `groups` attributes with
        the corresponding entities from the provided dictionaries (`rules_by_id`, `values_by_id`,
        `groups_by_id`). If an entity is not present in the current object's attributes, it will
        be added from the provided dictionaries.

        Args:
            rules_by_id (dict): A dictionary containing rule entities indexed by their IDs.
            values_by_id (dict): A dictionary containing value entities indexed by their IDs.
            groups_by_id (dict): A dictionary containing group entities indexed by their IDs.

        Returns:
            None

        Raises:
            KeyError: If a group ID in the current object's `groups` attribute is not found in the
                      `groups_by_id` dictionary, the group will be removed from the current
                      object's `groups` attribute.
        """
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
        """
        Represents the object as a dictionary.

        This method overrides the `represent_as_dict` method from the superclass. It adds the
        `rules`, `groups`, and `values` attributes to the dictionary representation if they are
        present.

        Returns:
            dict: A dictionary representation of the object with sorted keys for
                  `rules`, `groups`, and `values` if they are not empty.
        """
        yaml_contents = super(Group, self).represent_as_dict()

        if self.rules:
            yaml_contents["rules"] = sorted(list(self.rules.keys()))
        if self.groups:
            yaml_contents["groups"] = sorted(list(self.groups.keys()))
        if self.values:
            yaml_contents["values"] = sorted(list(self.values.keys()))

        return yaml_contents

    def _create_group_xml_skeleton(self):
        """
        Creates an XML skeleton for a group element.

        This method constructs an XML element representing a group with the appropriate namespace
        and attributes. It includes sub-elements for the title, description, and warnings.

        Returns:
            xml.etree.ElementTree.Element: The root element of the group XML skeleton.
        """
        group = ET.Element('{%s}Group' % XCCDF12_NS)
        group.set('id', OSCAP_GROUP + self.id_)
        title = ET.SubElement(group, '{%s}title' % XCCDF12_NS)
        title.text = self.title
        add_sub_element(group, 'description', XCCDF12_NS, self.description)
        add_warning_elements(group, self.warnings)
        return group

    def _add_cpe_platforms_xml(self, group):
        """
        Adds CPE platform elements to the given XML group element.

        This method iterates over the list of CPE platform names and creates a new XML element for
        each platform. Each new element is added as a child to the provided group element with the
        appropriate namespace and idref attribute.

        Args:
            group (xml.etree.ElementTree.Element): The XML element to which the CPE platform
                                                   elements will be added.

        Returns:
            None
        """
        for cpe_platform_name in self.cpe_platform_names:
            platform_el = ET.SubElement(group, "{%s}platform" % XCCDF12_NS)
            platform_el.set("idref", "#"+cpe_platform_name)

    def _add_rules_xml(self, group, rules_to_not_include, env_yaml):
        """
        Adds rules to the given XML group in a specific order based on their type and priority.

        The rules are ordered such that package installation/removal rules come first, followed by
        service enablement/disablement rules, and other specific rules. This ensures that the
        remediation order is logical and natural.

        Args:
            group (list): The XML group to which the rules will be added.
            rules_to_not_include (set): A set of rule IDs that should not be included.
            env_yaml (dict): The environment YAML configuration.

        Returns:
            None
        """
        # Rules that install or remove packages affect remediation
        # of other rules.
        # When packages installed/removed rules come first:
        # The Rules are ordered in more logical way, and
        # remediation order is natural, first the package is installed, then configured.
        rules_in_group = list(self.rules.keys())
        regex = (r'(package_.*_(installed|removed))|' +
                 r'(service_.*_(enabled|disabled))|' +
                 r'install_smartcard_packages|' +
                 r'sshd_.*|' +
                 r'sshd_set_keepalive(_0)?|' +
                 r'sshd_set_idle_timeout|' +
                 r'chronyd_specify_remote_server|' +
                 r'zipl_.*_argument(_absent)?$')
        priority_order = ["enable_authselect", "installed", "install_smartcard_packages", "removed",
                          "enabled", "disabled", "sshd_include_crypto_policy",
                          "sshd_set_keepalive_0",
                          "sshd_set_keepalive", "sshd_set_idle_timeout",
                          "chronyd_specify_remote_server",
                          "argument"]
        rules_in_group = reorder_according_to_ordering(rules_in_group, priority_order, regex)

        # Add rules in priority order, first all packages installed, then removed,
        # followed by services enabled, then disabled
        for rule_id in rules_in_group:
            if rule_id in rules_to_not_include:
                continue
            rule = self.rules.get(rule_id)
            if rule is not None:
                group.append(rule.to_xml_element(env_yaml))

    def _add_sub_groups(self, group, components_to_not_include, env_yaml):
        """
        Adds sub-groups to the given group in a specific order based on priority.

        This method ensures that sub-groups are added after any current level group rules.
        It handles the ordering of groups to avoid conflicts between rules, ensuring that certain
        rules are executed before others to maintain system integrity and desired configurations.

        Args:
            group (list): The list to which sub-groups will be appended.
            components_to_not_include (dict): A dictionary containing components that should not be included.
                It should have a key "groups" which is a set of group IDs to be excluded.
            env_yaml (dict): The environment YAML configuration.

        Returns:
            None

        Notes:
            - The priority order ensures that verification rules are run before any other rules.
            - Specific group orders are maintained to avoid conflicts and ensure proper rule execution.
        """
        groups_to_not_include = components_to_not_include.get("groups", set())

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
            if group_id in groups_to_not_include:
                continue
            _group = self.groups[group_id]
            if _group is not None:
                group.append(_group.to_xml_element(env_yaml, components_to_not_include))

    def to_xml_element(self, env_yaml=None,  components_to_not_include=None):
        """
        Converts the current object to an XML element.

        Args:
            env_yaml (dict, optional): Environment YAML data. Defaults to None.
            components_to_not_include (dict, optional): Components to exclude from the XML.
                Defaults to None. The dictionary can contain the following keys:
                - "rules": A set of rule IDs to exclude.
                - "groups": A set of group IDs to exclude.
                - "variables": A set of variable IDs to exclude.

        Returns:
            xml.etree.ElementTree.Element: The XML element representing the current object,
            or None if the object is in the groups_to_not_include set.
        """
        if components_to_not_include is None:
            components_to_not_include = {}

        rules_to_not_include = components_to_not_include.get("rules", set())
        groups_to_not_include = components_to_not_include.get("groups", set())

        if self.id_ in groups_to_not_include:
            return None

        group = self._create_group_xml_skeleton()

        self._add_cpe_platforms_xml(group)

        add_nondata_subelements(
            group, "requires", "idref",
            list(map(lambda x: OSCAP_GROUP + x, self.requires)))
        add_nondata_subelements(
            group, "conflicts", "idref",
            list(map(lambda x: OSCAP_GROUP + x, self.conflicts)))

        variables_to_not_include = components_to_not_include.get("variables", set())
        for value_id, _value in self.values.items():
            if value_id in variables_to_not_include:
                continue
            if _value is not None:
                group.append(_value.to_xml_element())

        self._add_rules_xml(group, rules_to_not_include, env_yaml)
        self._add_sub_groups(group, components_to_not_include, env_yaml)

        return group

    def add_value(self, value):
        """
        Adds a value to the values dictionary if the value is not None.

        Args:
            value: An object with an 'id_' attribute that will be used as the key in the values
                   dictionary.

        Returns:
            None
        """
        if value is None:
            return
        self.values[value.id_] = value

    def add_group(self, group, env_yaml=None, product_cpes=None):
        """
        Adds a group to the current object.

        Args:
            group (str): The group to be added.
            env_yaml (dict, optional): Environment YAML data. Defaults to None.
            product_cpes (list, optional): List of product CPEs. Defaults to None.

        Returns:
            None
        """
        self._add_child(group, self.groups, env_yaml, product_cpes)

    def add_rule(self, rule, env_yaml=None, product_cpes=None):
        """
        Adds a rule to the current object and processes its inherited platforms.

        Args:
            rule (Rule): The rule object to be added.
            env_yaml (dict, optional): Environment-specific YAML data. Defaults to None.
            product_cpes (dict, optional): Product-specific CPEs. Defaults to None.

        Returns:
            None
        """
        self._add_child(rule, self.rules, env_yaml, product_cpes)
        if env_yaml:
            for platform in rule.inherited_platforms:
                cpe_platform = Platform.from_text(platform, product_cpes)
                cpe_platform = add_platform_if_not_defined(cpe_platform, product_cpes)
                rule.inherited_cpe_platform_names.add(cpe_platform.id_)

    def _add_child(self, child, childs, env_yaml=None, product_cpes=None):
        """
        Adds a child object to the given dictionary of children and updates its inherited platforms.

        Args:
            child (object): The child object to be added. If None, the method returns immediately.
            childs (dict): A dictionary where the key is the child's ID and the value is the child object.
            env_yaml (dict, optional): Environment YAML configuration. Default is None.
            product_cpes (optional): Product CPEs configuration. Default is None.

        Returns:
            None
        """
        if child is None:
            return
        child.inherited_platforms.update(self.platforms, self.inherited_platforms)
        childs[child.id_] = child

    def remove_rules_with_ids_not_listed(self, rule_ids_list):
        """
        Remove rules from the current object whose IDs are not listed in the provided rule_ids_list.

        This method updates the `rules` attribute by filtering out rules whose IDs are not in the
        provided list. It also recursively applies the same filtering to all groups within the
        current object.

        Args:
            rule_ids_list (list): A list of rule IDs to retain.

        Returns:
            None
        """
        self.rules = dict(filter(lambda el, ids=rule_ids_list: el[0] in ids, self.rules.items()))
        for group in self.groups.values():
            group.remove_rules_with_ids_not_listed(rule_ids_list)

    def contains_rules(self, rule_ids):
        """
        Check if the specified rule IDs are present in the rules.

        Args:
            rule_ids (list): A list of rule IDs to check for presence.

        Returns:
            bool: True if all specified rule IDs are present, False otherwise.
        """
        return self._contains_required_element("rule", rule_ids, self.rules.keys())

    def contains_variables(self, variable_ids):
        """
        Check if the given variable IDs are present in the values.

        Args:
            variable_ids (list): A list of variable IDs to check for presence.

        Returns:
            bool: True if all the given variable IDs are present in the values, False otherwise.
        """
        return self._contains_required_element("variable", variable_ids, self.values.keys())

    def _contains_required_element(self, element_type, ids, existing_ids):
        """
        Checks if the required element is present in the given IDs or within the groups.

        Args:
            element_type (str): The type of element to check for, either "variable" or "rule".
            ids (list): A list of IDs to check for the presence of the required element.
            existing_ids (list): A list of existing IDs to compare against.

        Returns:
            bool: True if the required element is found in the given IDs or within the groups,
                  False otherwise.
        """
        intersection_of_ids = list(set(ids) & set(existing_ids))
        if len(intersection_of_ids) > 0:
            return True
        results = []
        for g in self.groups.values():
            if element_type == "variable":
                results.append(g.contains_variables(ids))
            if element_type == "rule":
                results.append(g.contains_rules(ids))
        return any(results)

    def get_not_included_components(self, rule_ids_list, variables_ids_list):
        """
        Identify and return the sets of rules, variables, and groups that are not included in the
        provided lists of rule IDs and variable IDs.

        Args:
            rule_ids_list (list): A list of rule IDs to check against.
            variables_ids_list (list): A list of variable IDs to check against.

        Returns:
            tuple: A tuple containing three sets:
            - rules (set): A set of rule IDs that are not in the provided rule_ids_list.
            - groups (set): A set of group IDs that are not included based on the provided lists.
            - variables (set): A set of variable IDs that are not in the provided variables_ids_list.
        """
        rules = set(filter(lambda id_, ids=rule_ids_list: id_ not in ids, self.rules.keys()))
        variables = set(
            filter(lambda id_, ids=variables_ids_list: id_ not in ids, self.values.keys())
        )
        groups = set()

        contains_variables = self.contains_variables(variables_ids_list)
        contains_rules = self.contains_rules(rule_ids_list)
        if not contains_rules and not contains_variables:
            groups.add(self.id_)

        out_sets = dict(rules_set=rules, groups_set=groups, variables_set=variables)

        for sub_group in self.groups.values():
            self._update_not_included_components(
                sub_group, rule_ids_list, variables_ids_list, out_sets
            )
        return rules, groups, variables

    def get_used_cpe_platforms(self, rule_ids_list):
        """
        Get the set of CPE platforms used by the given list of rule IDs.

        This method collects CPE platform names from the specified rules and their inherited
        rules. It also includes CPE platforms from sub-groups of the given rules.

        Args:
            rule_ids_list (list): A list of rule IDs to retrieve CPE platforms for.

        Returns:
            set: A set of CPE platform names used by the specified rules.
        """
        cpe_platforms = set()
        for rule_id in rule_ids_list:
            if rule_id not in self.rules:
                continue
            rule = self.rules[rule_id]
            cpe_platforms.update(rule.cpe_platform_names)
            cpe_platforms.update(rule.inherited_cpe_platform_names)

        cpe_platforms.update(_get_cpe_platforms_of_sub_groups(self, rule_ids_list))
        return cpe_platforms

    def __str__(self):
        return self.id_


def noop_rule_filterfunc(rule):
    return True


def rule_filter_from_def(filterdef):
    """
    Creates a filter function based on the provided filter definition.

    Args:
        filterdef (str or None): A string containing a Python expression that will be used
                                 to filter rules. If None or an empty string is provided,
                                 a no-operation filter function is returned.

    Returns:
        function: A function that takes a rule object and evaluates the filter definition against
                  the rule's attributes. If the filter definition is None or an empty string, a
                  no-operation filter function is returned.

    Note:
        The filter function uses `eval` to evaluate the filter definition. For security reasons,
        only the rule's attributes are exposed to the evaluation context, and Python built-ins
        are not available.
    """
    if filterdef is None or filterdef == "":
        return noop_rule_filterfunc

    def filterfunc(rule):
        # Remove globals for security and only expose
        # variables relevant to the rule
        return eval(filterdef, {"__builtins__": None}, rule.__dict__)
    return filterfunc


class Rule(XCCDFEntity, Templatable):
    """
    Represents an XCCDF Rule entity with various attributes and methods for handling rule data,
    validation, and conversion.

    Attributes:
        KEYS (dict): Default values for various rule attributes.
        MANDATORY_KEYS (set): Set of mandatory keys for a rule.
        GENERIC_FILENAME (str): Default filename for a rule.
        ID_LABEL (str): Label for rule ID.
        PRODUCT_REFERENCES (tuple): Tuple of product-specific reference types.
    """
    KEYS = dict(
        description=lambda: "",
        rationale=lambda: "",
        severity=lambda: "",
        references=lambda: dict(),
        control_references=lambda: dict(),
        components=lambda: list(),
        identifiers=lambda: dict(),
        ocil_clause=lambda: None,
        ocil=lambda: None,
        oval_external_content=lambda: None,
        fixtext=lambda: "",
        checktext=lambda: "",
        vuldiscussion=lambda: "",
        srg_requirement=lambda: "",
        warnings=lambda: list(),
        conflicts=lambda: list(),
        requires=lambda: list(),
        policy_specific_content=lambda: dict(),
        platform=lambda: None,
        platforms=lambda: set(),
        sce_metadata=lambda: dict(),
        inherited_platforms=lambda: set(),
        cpe_platform_names=lambda: set(),
        inherited_cpe_platform_names=lambda: set(),
        bash_conditional=lambda: None,
        fixes=lambda: dict(),
        **XCCDFEntity.KEYS
    )
    KEYS.update(**Templatable.KEYS)

    MANDATORY_KEYS = {
        "title",
        "description",
        "rationale",
        "severity",
    }

    GENERIC_FILENAME = "rule.yml"
    ID_LABEL = "rule_id"

    PRODUCT_REFERENCES = ("stigid", "cis",)

    def __init__(self, id_):
        super(Rule, self).__init__(id_)
        self.sce_metadata = None

    def __deepcopy__(self, memo):
        """
        Create a deep copy of the instance.

        Args:
            memo (dict): A dictionary to keep track of objects already copied to handle recursive
                         objects.

        Returns:
            object: A deep copy of the instance.
        """
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

    @staticmethod
    def _has_platforms_to_convert(rule, product_cpes):
        """
        Determines if there are platforms to convert based on the given rule and product CPEs.

        This function checks if the platform names need to be converted to CPE names. It only
        performs the conversion if an `env_yaml` was specified (indicating that there are product
        CPEs to look up) and if the rule does not already have `cpe_platform_names` specified
        (indicating that the platforms have not been evaluated yet).

        Args:
            rule (Rule): The rule object which may contain platform information.
            product_cpes (list): A list of product CPEs to look up.

        Returns:
            bool: True if there are platforms to convert, False otherwise.
        """
        return product_cpes and not rule.cpe_platform_names

    @staticmethod
    def _convert_platform_names(rule, product_cpes):
        """
        Converts platform names in a given rule to CPEAL platform names.

        This function checks if the rule has platforms that need to be converted based on the
        provided product CPEs. If conversion is needed, it parses the platform definitions and
        converts them to CPEAL platform names.

        Args:
            rule (Rule): The rule object containing platform definitions.
            product_cpes (dict): A dictionary of product CPEs.

        Returns:
            None

        Raises:
            Exception: If there is an error processing the platform definitions.
        """
        if not Rule._has_platforms_to_convert(rule, product_cpes):
            return
        # parse platform definition and get CPEAL platform
        for platform in rule.platforms:
            try:
                cpe_platform = Platform.from_text(platform, product_cpes)
            except Exception as e:
                msg = "Unable to process platforms in rule '%s': %s" % (
                    rule.id_, str(e))
                raise Exception(msg)
            cpe_platform = add_platform_if_not_defined(
                cpe_platform, product_cpes)
            rule.cpe_platform_names.add(cpe_platform.id_)

    @classmethod
    def from_yaml(cls, yaml_file, env_yaml=None, product_cpes=None, sce_metadata=None):
        """
        Creates a Rule object from a YAML file.

        Args:
            yaml_file (str): Path to the YAML file containing the rule definition.
            env_yaml (dict, optional): Environment-specific YAML data. Defaults to None.
            product_cpes (list, optional): List of product CPEs. Defaults to None.
            sce_metadata (dict, optional): SCE metadata dictionary. Defaults to None.

        Returns:
            Rule: An instance of the Rule class populated with data from the YAML file.

        Notes:
            - Converts platforms from list to set.
            - Splits references from comma-separated strings to lists.
            - Ensures rule.platform is included in rule.platforms.
            - Loads policy-specific content if not already defined.
            - Adds SCE metadata if available.
            - Validates identifiers and references.
        """
        rule = super(Rule, cls).from_yaml(yaml_file, env_yaml, product_cpes)

        # platforms are read as list from the yaml file
        # we need them to convert to set again
        rule.platforms = set(rule.platforms)

        # references are represented as a comma separated string
        # we need to split the string to form an actual list
        for ref_type, val in rule.references.items():
            if isinstance(val, str):
                rule.references[ref_type] = val.split(",")

        # rule.platforms.update(set(rule.inherited_platforms))

        check_warnings(rule)

        # ensure that content of rule.platform is in rule.platforms as
        # well
        if rule.platform is not None:
            rule.platforms.add(rule.platform)

        cls._convert_platform_names(rule, product_cpes)

        # Only load policy specific content if rule doesn't have it defined yet
        if not rule.policy_specific_content:
            rule.load_policy_specific_content(yaml_file, env_yaml)

        if sce_metadata and rule.id_ in sce_metadata:
            rule.sce_metadata = sce_metadata[rule.id_]
            rule.sce_metadata["relative_path"] = os.path.join(
                env_yaml["product"], "checks/sce", rule.sce_metadata['filename'])

        rule.validate_identifiers(yaml_file)
        rule.validate_references(yaml_file)
        return rule

    def _verify_disa_cci_format(self):
        """
        Verify that the DISA CCI format is correct.

        This method checks if the CCI IDs in the 'disa' reference follow the expected format
        'CCI-XXXXXX', where 'X' is a digit. If any CCI ID does not match this format, a ValueError
        is raised.

        Returns:
            None

        Raises:
            ValueError: If any CCI ID is in the wrong format.
        """
        cci_id = self.references.get("disa", None)
        if not cci_id:
            return
        cci_ex = re.compile(r'^CCI-[0-9]{6}$')
        for cci in cci_id:
            if not cci_ex.match(cci):
                raise ValueError("CCI '{}' is in the wrong format! "
                                 "Format should be similar to: "
                                 "CCI-XXXXXX".format(cci))
        self.references["disa"] = cci_id

    def normalize(self, product):
        """
        Normalize the given product by making references and identifiers product-specific and
        applying product-specific templates.

        Args:
            product (str): The product to be normalized.

        Returns:
            None

        Raises:
            RuntimeError: If an error occurs during normalization, an exception is raised with a
                          message indicating the rule and the error message.
        """
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
        """
        Adds STIG references to the object's references.

        This method looks up STIG references based on the STIG IDs present in the object's
        references. If any matching references are found, they are added to the object's
        references under the key "stigref".

        Args:
            stig_references (dict): A dictionary mapping STIG IDs to their corresponding
                                    references.

        Returns:
            None
        """
        stig_id = self.references.get("stigid", None)
        if not stig_id:
            return

        references = []
        for id in stig_id:
            reference = stig_references.get(id, None)
            if not reference:
                continue
            references.append(reference)

        if references:
            self.references["stigref"] = references

    def _get_product_only_references(self):
        """
        Retrieves a dictionary of product-specific references from the rule's references.

        This method filters the references to include only those that are specific to a product.
        A reference is considered product-specific if it matches a product reference exactly or
        if it starts with the product reference followed by an "@" symbol.

        Returns:
            dict: A dictionary where the keys are product-specific reference identifiers and the
                  values are the corresponding reference values.
        """
        product_references = dict()

        for ref in Rule.PRODUCT_REFERENCES:
            start = "{0}@".format(ref)
            for gref, gval in self.references.items():
                if ref == gref or gref.startswith(start):
                    product_references[gref] = gval
        return product_references

    def find_policy_specific_content(self, rule_root):
        """
        Finds and returns a set of policy-specific YAML files within a given rule directory.

        Args:
            rule_root (str): The root directory of the rule to search for policy-specific content.

        Returns:
            set: A set of file paths to the policy-specific YAML files found within the rule
                 directory.
        """
        policy_specific_dir = os.path.join(rule_root, "policy")
        policy_directories = glob.glob(os.path.join(policy_specific_dir, "*"))
        filenames = set()
        for pdir in policy_directories:
            policy_files = glob.glob(os.path.join(pdir, "*.yml"))
            filenames.update(set(policy_files))
        return filenames

    def triage_policy_specific_content(self, product_name, filenames):
        """
        Organizes filenames by policy based on the product name and specific criteria.

        Args:
            product_name (str): The name of the product.
            filenames (list): A list of filenames to be triaged.

        Returns:
            dict: A dictionary where the keys are policy names and the values are filenames that
                  match the criteria for storage.
        """
        product_dot_yml = product_name + ".yml"
        filename_by_policy = dict()
        for fname in filenames:
            policy = os.path.basename(os.path.dirname(fname))
            filename_appropriate_for_storage = (
                fname.endswith(product_dot_yml) and product_name
                or fname.endswith("shared.yml") and policy not in filename_by_policy)
            if (filename_appropriate_for_storage):
                filename_by_policy[policy] = fname
        return filename_by_policy

    def read_policy_specific_content_file(self, env_yaml, filename):
        """
        Reads and processes a policy-specific content file.

        Args:
            env_yaml (dict): The environment variables and macros for YAML expansion.
            filename (str): The path to the policy-specific content file.

        Returns:
            dict: The processed YAML data from the content file.
        """
        yaml_data = open_and_macro_expand(filename, env_yaml)
        return yaml_data

    def read_policy_specific_content(self, env_yaml, files):
        """
        Reads policy-specific content from a list of files and returns a dictionary of keys.

        Args:
            env_yaml (dict): A dictionary containing environment-specific YAML data.
            files (list): A list of file paths to read the policy-specific content from.

        Returns:
            dict: A dictionary where the keys are policy identifiers and the values are the
                  corresponding YAML data.
        """
        keys = dict()
        if env_yaml:
            product = env_yaml["product"]
        else:
            product = ""
        filename_by_policy = self.triage_policy_specific_content(product, files)
        for p, f in filename_by_policy.items():
            yaml_data = self.read_policy_specific_content_file(env_yaml, f)
            keys[p] = yaml_data
        return keys

    def load_policy_specific_content(self, rule_filename, env_yaml):
        """
        Loads policy-specific content for a given rule.

        This method finds and reads policy-specific content files related to the provided rule
        filename and environment YAML. The content is then stored in the instance variable
        `policy_specific_content`.

        Args:
            rule_filename (str): The filename of the rule for which to load policy-specific
                                 content.
            env_yaml (dict): The environment YAML data.

        Returns:
            None
        """
        rule_root = os.path.dirname(rule_filename)
        policy_specific_content_files = self.find_policy_specific_content(rule_root)
        policy_specific_content = dict()
        if policy_specific_content_files:
            policy_specific_content = self.read_policy_specific_content(
                env_yaml, policy_specific_content_files)
        self.policy_specific_content = policy_specific_content

    def get_template_context(self, env_yaml):
        """
        Generates the template context for the given environment YAML.

        This method overrides the parent class's get_template_context method to include additional
        context specific to this class.

        Args:
            env_yaml (dict): The environment YAML data.

        Returns:
            dict: The template context with additional identifiers if available.
        """
        ctx = super(Rule, self).get_template_context(env_yaml)
        if self.identifiers:
            ctx["cce_identifiers"] = self.identifiers
        return ctx

    def make_refs_and_identifiers_product_specific(self, product):
        """
        Adjusts the rule's references and identifiers to be product-specific.

        This method modifies the rule's references and identifiers by appending a product-specific
        suffix to them. It ensures that general references do not contain product-specific
        identifiers and raises an error if such identifiers are found.

        Args:
            product (str): The product identifier to be appended to references and identifiers.

        Returns:
            None

        Raises:
            ValueError: If an unexpected reference identifier without a product qualifier is
                        found, or if there is an error processing the references or identifiers.
        """
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
                new_items = make_items_product_specific(
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

    def validate_identifiers(self, yaml_file):
        """
        Validates the identifiers in the given YAML file.

        Args:
            yaml_file (str): The path to the YAML file being validated.

        Returns:
            None

        Raises:
            ValueError: If the identifiers section is empty, if any identifier or value is not a
                        string, if any identifier value is empty, if a CCE identifier format is
                        invalid, or if a CCE identifier value is not a valid checksum.
        """
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
        """
        Validates the references section of a YAML file.

        Args:
            yaml_file (str): The path to the YAML file being validated.

        Returns:
            None

        Raises:
            ValueError: If the references section is empty.
            ValueError: If any reference type is not a string.
            ValueError: If any reference value is empty.
            ValueError: If any reference contains leading or trailing whitespace.
        """
        if self.references is None:
            raise ValueError("Empty references section in file %s" % yaml_file)

        for ref_type, ref_val in self.references.items():
            if not isinstance(ref_type, str):
                raise ValueError("References must be strings: %s in file %s"
                                 % (ref_type, yaml_file))
            if len(ref_val) == 0:
                raise ValueError("References must not be empty: %s in file %s"
                                 % (ref_type, yaml_file))

        for ref_type, ref_val in self.references.items():
            for ref in ref_val:
                if ref.strip() != ref:
                    msg = (
                        "Comma-separated '{ref_type}' reference "
                        "in {yaml_file} contains whitespace."
                        .format(ref_type=ref_type, yaml_file=yaml_file))
                    raise ValueError(msg)

    def add_fixes(self, fixes):
        """
        Adds a list of fixes to the current instance.

        Args:
            fixes (list): A list of fixes to be added.

        Returns:
            None
        """
        self.fixes = fixes

    def _add_fixes_elements(self, rule_el):
        """
        Adds fix elements to the given rule element.

        This method iterates over the fixes associated with the rule and creates corresponding XML
        elements under the provided rule element. Each fix element is configured with attributes
        and text content based on the fix type and its configuration.

        Args:
            rule_el (xml.etree.ElementTree.Element): The XML element representing the rule
                to which the fix elements will be added.

        Returns:
            None

        Raises:
            KeyError: If a required key is missing in the fix configuration.
        """
        for fix_type, fix in self.fixes.items():
            fix_el = ET.SubElement(rule_el, "{%s}fix" % XCCDF12_NS)
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

    def _add_ident_elements(self, rule):
        """
        Adds identifier elements to the given rule element.

        This method iterates over the identifiers in the `self.identifiers` dictionary, checks if
        the identifier type is valid, and then creates an XML sub-element for each identifier.
        The sub-element is added to the provided `rule` element.

        Args:
            rule (xml.etree.ElementTree.Element): The XML element to which the identifier elements
                                                  will be added.

        Returns:
            None

        Raises:
            ValueError: If an identifier type is not found in the `SSG_IDENT_URIS` dictionary.
        """
        for ident_type, ident_val in self.identifiers.items():
            if ident_type not in SSG_IDENT_URIS:
                msg = "Invalid identifier type '%s' in rule '%s'" % (ident_type, self.id_)
                raise ValueError(msg)
            ident = ET.SubElement(rule, '{%s}ident' % XCCDF12_NS)
            ident.set("system", SSG_IDENT_URIS[ident_type])
            ident.text = ident_val

    def add_control_reference(self, ref_type, ref_value):
        """
        Adds a control reference to the rule.

        Args:
            ref_type (str): The type of the control reference.
            ref_value (str): The value of the control reference.

        Returns:
            None

        Raises:
            ValueError: If the rule already contains the specified reference type and value.
        """
        if ref_type in self.control_references:
            if ref_value in self.control_references[ref_type]:
                msg = (
                    "Rule %s already contains a '%s' reference with value '%s'." % (
                        self.id_, ref_type, ref_value))
                raise ValueError(msg)
            self.control_references[ref_type].append(ref_value)
        else:
            self.control_references[ref_type] = [ref_value]

    def merge_control_references(self):
        """
        Merges control references into the main references dictionary.

        This method iterates over the control references and adds them to the main references
        dictionary. If a reference type already exists in the main references, the control
        references of that type are appended to the existing list. If the reference type does not
        exist, it is added to the main references dictionary.

        Returns:
            None
        """
        for ref_type in self.control_references:
            if ref_type in self.references:
                self.references[ref_type].append(self.control_references[ref_type])
            else:
                self.references[ref_type] = self.control_references[ref_type]

    def _get_sce_check_parent_element(self, rule_el):
        """
        Determines and returns the appropriate parent element for SCE checks within a given rule element.

        This function handles the interaction between OVAL and SCE checks, as well as the
        inclusion of OCIL data. If 'complex-check' is specified in the SCE metadata, it creates
        the necessary parent elements to accommodate the checks. If OCIL data is present, an
        additional parent element is added to ensure the correct logical structure.

        Args:
            rule_el (Element): The XML element representing the rule.

        Returns:
            Element: The appropriate parent element for SCE checks.
        """
        if 'complex-check' in self.sce_metadata:
            # Here we have an issue: XCCDF allows EITHER one or more check
            # elements OR a single complex-check. While we have an explicit
            # case handling the OVAL-and-SCE interaction, OCIL entries have
            # (historically) been alongside OVAL content and been in an
            # "OR" manner -- preferring OVAL to SCE. In order to accomplish
            # this, we thus need to add _yet another parent_ when OCIL data
            # is present, and add update ocil_parent accordingly.
            if self.ocil or self.ocil_clause:
                ocil_parent = ET.SubElement(
                    rule_el, "{%s}complex-check" % XCCDF12_NS)
                ocil_parent.set('operator', 'OR')

            check_parent = ET.SubElement(
                ocil_parent, "{%s}complex-check" % XCCDF12_NS)
            check_parent.set('operator', self.sce_metadata['complex-check'])
        else:
            check_parent = rule_el
        return check_parent

    def _add_sce_check_import_element(self, sce_check):
        """
        Adds a 'check-import' element to the given SCE check element.

        This method modifies the 'sce_metadata' dictionary by ensuring that the 'check-import'
        key contains a list of import names. It then iterates over this list and creates a
        'check-import' sub-element for each entry, setting the 'import-name' attribute
        accordingly.

        Args:
            sce_check (xml.etree.ElementTree.Element): The SCE check element to which the
                                                       'check-import' elements will be added.

        Returns:
            None

        Raises:
            KeyError: If 'check-import' is not a key in 'sce_metadata'.
        """
        if isinstance(self.sce_metadata['check-import'], str):
            self.sce_metadata['check-import'] = [self.sce_metadata['check-import']]
        for entry in self.sce_metadata['check-import']:
            check_import = ET.SubElement(
                sce_check, '{%s}check-import' % XCCDF12_NS)
            check_import.set('import-name', entry)
            check_import.text = None

    def _add_sce_check_export_element(self, sce_check):
        """
        Adds 'check-export' elements to the given SCE check element.

        This method processes the 'check-export' metadata from the SCE metadata and adds
        'check-export' sub-elements to the provided SCE check element. If the 'check-export'
        metadata is a string, it is converted to a list containing that string.

        Args:
            sce_check (xml.etree.ElementTree.Element): The SCE check element to which the
            'check-export' elements will be added.

        Returns:
            None

        Raises:
            ValueError: If the 'check-export' metadata entry does not contain an '=' character.
        """
        if isinstance(self.sce_metadata['check-export'], str):
            self.sce_metadata['check-export'] = [self.sce_metadata['check-export']]
        for entry in self.sce_metadata['check-export']:
            export, value = entry.split('=')
            check_export = ET.SubElement(
                sce_check, '{%s}check-export' % XCCDF12_NS)
            check_export.set('value-id', value)
            check_export.set('export-name', export)
            check_export.text = None

    def _add_sce_check_content_ref_element(self, sce_check):
        """
        Adds a 'check-content-ref' element to the given SCE check element.

        This method creates a new 'check-content-ref' sub-element under the provided 'sce_check'
        element and sets its 'href' attribute to the relative path specified in the SCE metadata.

        Args:
            sce_check (xml.etree.ElementTree.Element): The SCE check element to which the
                                                       'check-content-ref' element will be added.

        Returns:
            None
        """
        check_ref = ET.SubElement(
            sce_check, "{%s}check-content-ref" % XCCDF12_NS)
        href = self.sce_metadata['relative_path']
        check_ref.set("href", href)

    def _add_sce_check_element(self, rule_el):
        """
        Adds an SCE check element to the given rule element.

        This method constructs an SCE check element and appends it to the appropriate parent
        element within the rule element. The SCE check element is built based on the SCE metadata
        available in the instance. If the SCE metadata contains 'check-import' or 'check-export'
        keys, corresponding sub-elements are added to the SCE check element.

        Args:
            rule_el (Element): The rule element to which the SCE check element will be added.

        Returns:
            None
        """
        if not self.sce_metadata:
            return
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
        parent_el = self._get_sce_check_parent_element(rule_el)
        sce_check_el = ET.SubElement(parent_el, "{%s}check" % XCCDF12_NS)
        sce_check_el.set("system", SCE_SYSTEM)
        if 'check-import' in self.sce_metadata:
            self._add_sce_check_import_element(sce_check_el)
        if 'check-export' in self.sce_metadata:
            self._add_sce_check_export_element(sce_check_el)
        self._add_sce_check_content_ref_element(sce_check_el)

    def _add_oval_check_element(self, rule_el):
        """
        Adds an OVAL check element to the given rule element.

        This method creates a new 'check' subelement under the provided rule element and sets its
        'system' attribute to the OVAL namespace. It then creates a 'check-content-ref' subelement
        under the 'check' element. If the instance has an external OVAL content reference, it sets
        the 'href' attribute of the 'check-content-ref' element to this reference. Otherwise, it
        sets the 'href' attribute to "oval-unlinked.xml" and the 'name' attribute to the rule's ID.

        Args:
            rule_el (xml.etree.ElementTree.Element): The rule element to which the OVAL check
                                                     element will be added.

        Returns:
            None
        """
        check = ET.SubElement(rule_el, '{%s}check' % XCCDF12_NS)
        check.set("system", oval_namespace)
        check_content_ref = ET.SubElement(
            check, "{%s}check-content-ref" % XCCDF12_NS)
        if self.oval_external_content:
            check_content_ref.set("href", self.oval_external_content)
        else:
            # TODO: This is pretty much a hack, oval ID will be the same as rule ID
            #       and we don't want the developers to have to keep them in sync.
            #       Therefore let's just add an OVAL ref of that ID.
            # TODO  Can we not add the check element if the rule doesn't have an OVAL check?
            #       At the moment, the check elements of rules without OVAL are removed by
            #       the OVALFileLinker class.
            check_content_ref.set("href", "oval-unlinked.xml")
            check_content_ref.set("name", self.id_)

    def _add_ocil_check_element(self, rule_el):
        """
        Adds an OCIL check element to the given rule element if applicable.

        This method creates and appends an OCIL check element to the provided rule element
        (`rule_el`) if the rule has associated OCIL content (`self.ocil` or `self.ocil_clause`)
        and the rule ID is not "security_patches_up_to_date".

        Args:
            rule_el (xml.etree.ElementTree.Element): The XML element representing the rule to
                                                     which the OCIL check element will be added.

        Returns:
            None
        """
        patches_up_to_date = (self.id_ == "security_patches_up_to_date")
        if (self.ocil or self.ocil_clause) and not patches_up_to_date:
            ocil_check = ET.SubElement(rule_el, "{%s}check" % XCCDF12_NS)
            ocil_check.set("system", ocil_cs)
            ocil_check_ref = ET.SubElement(
                ocil_check, "{%s}check-content-ref" % XCCDF12_NS)
            ocil_check_ref.set("href", "ocil-unlinked.xml")
            ocil_check_ref.set("name", self.id_ + "_ocil")

    def to_xml_element(self, env_yaml=None):
        """
        Converts the rule object to an XML element.

        Args:
            env_yaml (dict, optional): A dictionary containing environment-specific YAML data.
                                       If provided, it will be used to fetch reference URIs.
                                       Defaults to None.

        Returns:
            xml.etree.ElementTree.Element: An XML element representing the rule.
        """
        rule = ET.Element('{%s}Rule' % XCCDF12_NS)
        rule.set('selected', 'false')
        rule.set('id', OSCAP_RULE + self.id_)
        rule.set('severity', self.severity)
        add_sub_element(rule, 'title', XCCDF12_NS, self.title)
        add_sub_element(rule, 'description', XCCDF12_NS, self.description)
        add_warning_elements(rule, self.warnings)

        if env_yaml:
            ref_uri_dict = env_yaml['reference_uris']
        else:
            ref_uri_dict = SSG_REF_URIS
        add_reference_elements(rule, self.references, ref_uri_dict)

        add_sub_element(rule, 'rationale', XCCDF12_NS, self.rationale)

        for cpe_platform_name in sorted(self.cpe_platform_names):
            platform_el = ET.SubElement(rule, "{%s}platform" % XCCDF12_NS)
            platform_el.set("idref", "#"+cpe_platform_name)

        add_nondata_subelements(
            rule, "requires", "idref",
            list(map(lambda x: OSCAP_RULE + x, self.requires)))
        add_nondata_subelements(
            rule, "conflicts", "idref",
            list(map(lambda x: OSCAP_RULE + x, self.conflicts)))

        self._add_ident_elements(rule)
        self._add_fixes_elements(rule)

        self._add_sce_check_element(rule)
        self._add_oval_check_element(rule)
        self._add_ocil_check_element(rule)

        return rule

    def to_ocil(self):
        """
        Converts the rule to OCIL format.

        This method generates an OCIL questionnaire, boolean question test action, and boolean
        question for the rule. It ensures that the rule has the necessary OCIL and OCIL clause
        information, and processes the OCIL content to remove HTML and XML tags where necessary.

        Returns:
            tuple: A tuple containing the OCIL questionnaire, boolean question test action, and
                   boolean question elements.

        Raises:
            ValueError: If the rule does not have OCIL or OCIL clause information.
        """
        if not self.ocil and not self.ocil_clause:
            raise ValueError("Rule {0} doesn't have OCIL".format(self.id_))
        # Create <questionnaire> for the rule
        questionnaire = ET.Element("{%s}questionnaire" % ocil_namespace, id=self.id_ + "_ocil")
        title = ET.SubElement(questionnaire, "{%s}title" % ocil_namespace)
        title.text = self.title
        actions = ET.SubElement(questionnaire, "{%s}actions" % ocil_namespace)
        test_action_ref = ET.SubElement(actions, "{%s}test_action_ref" % ocil_namespace)
        test_action_ref.text = self.id_ + "_action"
        # Create <boolean_question_test_action> for the rule
        action = ET.Element(
            "{%s}boolean_question_test_action" % ocil_namespace,
            id=self.id_ + "_action",
            question_ref=self.id_ + "_question")
        when_true = ET.SubElement(action, "{%s}when_true" % ocil_namespace)
        result = ET.SubElement(when_true, "{%s}result" % ocil_namespace)
        result.text = "PASS"
        when_true = ET.SubElement(action, "{%s}when_false" % ocil_namespace)
        result = ET.SubElement(when_true, "{%s}result" % ocil_namespace)
        result.text = "FAIL"
        # Create <boolean_question>
        boolean_question = ET.Element(
            "{%s}boolean_question" % ocil_namespace, id=self.id_ + "_question")
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
            boolean_question, "question_text", ocil_namespace,
            ocil_without_tags)
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
    """
    A class to load and process security content from a directory structure.

    Attributes:
        profiles_dir (str): Directory containing profiles.
        env_yaml (dict): Environment YAML configuration.
        product_cpes (object): Product CPEs.
        benchmark_file (str): Path to the benchmark file.
        group_file (str): Path to the group file.
        loaded_group (object): Loaded group object.
        rule_files (list): List of rule file paths.
        value_files (list): List of value file paths.
        subdirectories (list): List of subdirectory paths.
        all_values (dict): Dictionary of all loaded values.
        all_rules (dict): Dictionary of all loaded rules.
        all_groups (dict): Dictionary of all loaded groups.
        parent_group (object): Parent group object.
    """
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
        """
        Collects and categorizes items from the specified guide directory.

        This method iterates through the items in the given directory and sorts them into
        different categories based on their file extensions or names. The categorized items are
        stored in the instance variables `value_files`, `benchmark_file`, `group_file`,
        `rule_files`, and `subdirectories`.

        Args:
            guide_directory (str): The path to the directory to be scanned.

        Returns:
            None

        Raises:
            ValueError: If multiple benchmark or group files are found in the directory.

        Categorization:
            - Files with extension '.var' are added to `value_files`.
            - The file named 'benchmark.yml' is assigned to `benchmark_file`.
            - The file named 'group.yml' is assigned to `group_file`.
            - Files with extension '.rule' are added to `rule_files`.
            - Directories identified as rule directories are processed and their YAML files are added to `rule_files`.
            - Subdirectories (excluding 'tests') are added to `subdirectories`.
            - Unknown files are skipped with a warning message.
        """
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
        Loads a given benchmark or group from the specified benchmark_file or group_file, in the
        context of guide_directory, profiles_dir and env_yaml.

        Args:
            guide_directory (str): The directory containing the guide files.

        Returns:
            Group or Benchmark: The loaded group or benchmark.

        Raises:
            ValueError: If both a .benchmark file and a .group file are found in the same directory.
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
            self.all_groups[group.id_] = group

        return group

    def _load_group_process_and_recurse(self, guide_directory):
        """
        Loads a benchmark or group from the specified guide directory, processes its values,
        recurses into its subdirectories, and processes its rules.

        Args:
            guide_directory (str): The directory containing the guide to be loaded.

        Returns:
            None
        """
        self.loaded_group = self.load_benchmark_or_group(guide_directory)

        if self.loaded_group:

            if self.parent_group:
                self.parent_group.add_group(
                    self.loaded_group, env_yaml=self.env_yaml, product_cpes=self.product_cpes)

            self._process_values()
            self._recurse_into_subdirs()
            self._process_rules()

    def process_directory_tree(self, start_dir, extra_group_dirs=None):
        """
        Processes the directory tree starting from the given directory.

        This method collects items to load from the start directory, optionally adds extra group
        directories to the list of subdirectories, and then processes and recurses through the
        directory tree.

        Args:
            start_dir (str): The starting directory to process.
            extra_group_dirs (list, optional): A list of additional directories to include in the
                                               processing. Defaults to None.

        Returns:
            None
        """
        self._collect_items_to_load(start_dir)
        if extra_group_dirs:
            self.subdirectories += extra_group_dirs
        self._load_group_process_and_recurse(start_dir)

    def process_directory_trees(self, directories):
        """
        Processes a list of directory trees.

        Args:
            directories (list): A list of directory paths. The first directory in the list is
                                considered the start directory, and the remaining directories are
                                considered extra group directories.

        Returns:
            The result of processing the start directory and extra group directories.
        """
        start_dir = directories[0]
        extra_group_dirs = directories[1:]
        return self.process_directory_tree(start_dir, extra_group_dirs)

    def _recurse_into_subdirs(self):
        """
        Recursively processes subdirectories to load and update values, rules, and groups.

        This method iterates over each subdirectory in `self.subdirectories`, creates a new loader
        instance, sets its parent group to the current loaded group, and processes the directory
        tree of the subdirectory. It then updates the current instance's `all_values`,
        `all_rules`, and `all_groups` with the corresponding attributes from the new loader
        instance.

        Args:
            None

        Returns:
            None
        """
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
        """
        Saves all entities (rules, groups, values, platforms, and cpe_items) to the specified base directory.

        This method creates subdirectories within the base directory for each type of entity and
        saves the entities if they exist. The subdirectories created are:
            - rules
            - groups
            - values
            - platforms
            - cpe_items

        The entities are saved using the `save_entities` method.

        Args:
            base_dir (str): The base directory where the entities will be saved.

        Returns:
            None
        """
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

        destdir = os.path.join(base_dir, "cpe_items")
        mkdir_p(destdir)
        if self.product_cpes.cpes_by_id:
            self.save_entities(self.product_cpes.cpes_by_id.values(), destdir)

    def save_entities(self, entities, destdir):
        """
        Save a list of entities to YAML files in the specified directory.

        Args:
            entities (list): A list of entities to be saved. Each entity must have an 'id_'
                             attribute and a 'dump_yaml' method.
            destdir (str): The destination directory where the YAML files will be saved.

        Returns:
            None
        """
        if not entities:
            return
        for entity in entities:
            basename = entity.id_ + ".yml"
            dest_filename = os.path.join(destdir, basename)
            entity.dump_yaml(dest_filename)


class BuildLoader(DirectoryLoader):
    """
    BuildLoader is a class that extends DirectoryLoader to handle the loading and processing of
    build-related YAML files, including profiles, environment configurations, product CPEs, and
    SCE metadata.

    Attributes:
        sce_metadata (dict): Metadata for SCE, loaded from a JSON file.
        components_dir (str): Absolute path to the components directory.
        rule_to_components (dict): Mapping of rules to their respective components.
    """
    def __init__(
            self, profiles_dir, env_yaml, product_cpes,
            sce_metadata_path=None):
        super(BuildLoader, self).__init__(profiles_dir, env_yaml, product_cpes)

        self.sce_metadata = None
        if sce_metadata_path and os.path.getsize(sce_metadata_path):
            self.sce_metadata = json.load(open(sce_metadata_path, 'r'))
        self.components_dir = None
        self.rule_to_components = None

    def load_components(self):
        """
        Loads the components from the specified components directory and maps rules to components.

        This method checks if the "components_root" key is present in the environment YAML. If
        not, it returns None. If the key is present, it constructs the absolute path to the
        components directory using the "product_dir" and "components_root" values from the
        environment YAML. It then loads the components from this directory and creates a
        mapping of rules to components.

        Returns:
            None
        """
        if "components_root" not in self.env_yaml:
            return None
        product_dir = self.env_yaml["product_dir"]
        components_root = self.env_yaml["components_root"]
        self.components_dir = os.path.abspath(
            os.path.join(product_dir, components_root))
        components = ssg.components.load(self.components_dir)
        self.rule_to_components = ssg.components.rule_component_mapping(
            components)

    def _process_values(self):
        """
        Processes the YAML files specified in `self.value_files` and loads their contents into
        `self.all_values` and `self.loaded_group`.

        For each YAML file in `self.value_files`, this method:
        1. Parses the YAML file into a `Value` object using `Value.from_yaml`.
        2. Adds the `Value` object to `self.all_values` using its `id_` as the key.
        3. Adds the `Value` object to `self.loaded_group`.

        Returns:
            None

        Raises:
            Any exceptions raised by `Value.from_yaml` if the YAML file cannot be parsed.
        """
        for value_yaml in self.value_files:
            value = Value.from_yaml(value_yaml, self.env_yaml)
            self.all_values[value.id_] = value
            self.loaded_group.add_value(value)

    def _process_rule(self, rule):
        """
        Processes a given rule by performing several checks and operations.

        Args:
            rule (Rule): The rule object to be processed.

        Raises:
            ValueError: If the rule is not mapped to any component and `self.rule_to_components`
                        is not None.

        Returns:
            bool: Always returns True after processing the rule.
        """
        if self.rule_to_components is not None and rule.id_ not in self.rule_to_components:
            raise ValueError(
                "The rule '%s' isn't mapped to any component! Insert the "
                "rule ID to at least one file in '%s'." %
                (rule.id_, self.components_dir))
        self.all_rules[rule.id_] = rule
        self.loaded_group.add_rule(
            rule, env_yaml=self.env_yaml, product_cpes=self.product_cpes)
        rule.normalize(self.env_yaml["product"])
        if self.rule_to_components is not None:
            rule.components = self.rule_to_components[rule.id_]
        return True

    def _process_rules(self):
        """
        Processes each rule file in `self.rule_files`.

        For each rule file, it attempts to create a `Rule` object from the YAML file.
        If the rule is marked as "documentation-incomplete" and the build is not in debug mode,
        it skips processing that rule.

        If the rule is successfully created and processed, it continues to the next rule.

        Returns:
            None

        Raises:
            DocumentationNotComplete: Raised when a rule is "documentation-incomplete" and the
                                      build is not in debug mode.
        """
        for rule_yaml in self.rule_files:
            try:
                rule = Rule.from_yaml(
                    rule_yaml, self.env_yaml, self.product_cpes, self.sce_metadata)
            except DocumentationNotComplete:
                # Happens on non-debug build when a rule is "documentation-incomplete"
                continue
            if not self._process_rule(rule):
                continue

    def _get_new_loader(self):
        """
        Creates and returns a new instance of BuildLoader with preloaded metadata.

        This method initializes a BuildLoader object with the provided profiles directory,
        environment YAML, and product CPEs. It also sets the SCE metadata, rule-to-components
        mapping, and components directory to avoid redundant parsing.

        Returns:
            BuildLoader: A new instance of BuildLoader with preloaded metadata.
        """
        loader = BuildLoader(
            self.profiles_dir, self.env_yaml, self.product_cpes)
        # Do it this way so we only have to parse the SCE metadata once.
        loader.sce_metadata = self.sce_metadata
        # Do it this way so we only have to parse the component metadata once.
        loader.rule_to_components = self.rule_to_components
        loader.components_dir = self.components_dir
        return loader

    def export_group_to_file(self, filename):
        """
        Exports the loaded group to a specified file.

        Args:
            filename (str): The name of the file to which the group will be exported.

        Returns:
            bool: True if the export was successful, False otherwise.
        """
        return self.loaded_group.to_file(filename)


class LinearLoader(object):
    """
    LinearLoader is responsible for loading and managing various security content entities such as
    rules, profiles, groups, values, platforms, fixes, and CPE items from a specified directory
    structure. It also provides methods to export this content to XML format.

    Attributes:
        resolved_rules_dir (str): Directory path for resolved rules.
        rules (dict): Dictionary to store loaded rules.
        resolved_profiles_dir (str): Directory path for resolved profiles.
        profiles (dict): Dictionary to store loaded profiles.
        resolved_groups_dir (str): Directory path for resolved groups.
        groups (dict): Dictionary to store loaded groups.
        resolved_values_dir (str): Directory path for resolved values.
        values (dict): Dictionary to store loaded values.
        resolved_platforms_dir (str): Directory path for resolved platforms.
        platforms (dict): Dictionary to store loaded platforms.
        fixes_dir (str): Directory path for fixes.
        fixes (dict): Dictionary to store loaded fixes.
        resolved_cpe_items_dir (str): Directory path for resolved CPE items.
        cpe_items (dict): Dictionary to store loaded CPE items.
        benchmark (Benchmark): Loaded benchmark object.
        env_yaml (dict): Environment YAML configuration.
        product_cpes (ProductCPEs): Product CPEs object.
        off_ocil (bool): Flag to indicate if OCIL should be turned off.
    """
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

        self.resolved_cpe_items_dir = os.path.join(resolved_path, "cpe_items")
        self.cpe_items = dict()

        self.benchmark = None
        self.env_yaml = env_yaml
        self.product_cpes = ProductCPEs()
        self.off_ocil = False

    def find_first_groups_ids(self, start_dir):
        """
        Finds the IDs of the first-level groups in the specified directory.

        This method searches for all "group.yml" files located in the immediate subdirectories of
        the given start directory and extracts the names of these subdirectories as group IDs.

        Args:
            start_dir (str): The directory to start searching from.

        Returns:
            list: A list of group IDs (names of subdirectories containing "group.yml").
        """
        group_files = glob.glob(os.path.join(start_dir, "*", "group.yml"))
        group_ids = [fname.split(os.path.sep)[-2] for fname in group_files]
        return group_ids

    def load_entities_by_id(self, filenames, destination, cls):
        """
        Loads entities from a list of YAML files and stores them in a destination dictionary by their ID.

        Args:
            filenames (list of str): List of file paths to YAML files.
            destination (dict): Dictionary to store the loaded entities, keyed by their ID.
            cls (type): Class type that has a `from_yaml` method to create an instance from a YAML file.

        Returns:
            None
        """
        for fname in filenames:
            entity = cls.from_yaml(fname, self.env_yaml, self.product_cpes)
            destination[entity.id_] = entity

    def add_fixes_to_rules(self):
        """
        Adds fixes to the rules in the rules dictionary.

        Iterates over the items in the fixes dictionary and adds the corresponding fixes to the
        rules in the rules dictionary.

        Returns:
            None

        Raises:
            KeyError: If a rule_id in fixes does not exist in rules.
        """
        for rule_id, rule_fixes in self.fixes.items():
            self.rules[rule_id].add_fixes(rule_fixes)

    def load_benchmark(self, directory):
        """
        Loads the benchmark data from the specified directory.

        This method performs the following steps:
        1. Loads the benchmark from a YAML file located in the given directory.
        2. Adds profiles from the resolved profiles directory.
        3. Adds groups to the benchmark based on the first group IDs found in the directory.
        4. Drops rules that are not included in any profile.
        5. Unselects empty groups from the benchmark.

        Args:
            directory (str): The directory from which to load the benchmark data.

        Returns:
            None

        Raises:
            KeyError: If a group ID is not found in the compiled and loaded groups.
        """
        self.benchmark = Benchmark.from_yaml(
            os.path.join(directory, "benchmark.yml"), self.env_yaml, self.product_cpes)

        self.benchmark.add_profiles_from_dir(
            self.resolved_profiles_dir, self.env_yaml, self.product_cpes)

        benchmark_first_groups = self.find_first_groups_ids(directory)
        for gid in benchmark_first_groups:
            try:
                self.benchmark.add_group(self.groups[gid], self.env_yaml, self.product_cpes)
            except KeyError as exc:
                # Add only the groups we have compiled and loaded
                pass
        self.benchmark.drop_rules_not_included_in_a_profile()
        self.benchmark.unselect_empty_groups()

    def get_benchmark_xml_by_profile(self, rule_and_variables_dict):
        """
        Generates benchmark XML for each profile in the benchmark.

        This method iterates over all profiles in the benchmark and generates the corresponding
        benchmark XML for each profile using the provided rule and variables dictionary.

        Args:
            rule_and_variables_dict (dict): A dictionary containing rules and variables
                to be used for generating the benchmark XML.

        Yields:
            tuple: A tuple containing the profile ID (str) and the corresponding benchmark XML (str).

        Raises:
            Exception: If the benchmark is not loaded before calling this method.
        """
        if self.benchmark is None:
            raise Exception(
                "Before generating benchmarks for each profile, you need to load "
                "the initial benchmark using the load_benchmark method."
            )

        for profile in self.benchmark.profiles:
            profiles_ids, benchmark = self.benchmark.get_benchmark_xml_for_profiles(
                self.env_yaml, [profile], rule_and_variables_dict
            )
            yield profiles_ids.pop(), benchmark

    def load_compiled_content(self):
        """
        Loads and compiles various content entities from specified directories into the
        appropriate attributes.

        This method performs the following steps:
        1. Loads CPEs from the directory tree specified by `self.resolved_cpe_items_dir` and
           updates `self.product_cpes`.
        2. Loads compiled remediations from the directory specified by `self.fixes_dir` and
           assigns them to `self.fixes`.
        3. Loads rule entities from YAML files in the directory specified by
           `self.resolved_rules_dir` and updates `self.rules`.
        4. Loads group entities from YAML files in the directory specified by
           `self.resolved_groups_dir` and updates `self.groups`.
        5. Loads value entities from YAML files in the directory specified by
           `self.resolved_values_dir` and updates `self.values`.
        6. Loads platform entities from YAML files in the directory specified by
           `self.resolved_platforms_dir` and updates `self.platforms`.
        7. Assigns the loaded platforms to `self.product_cpes.platforms`.
        8. For each group in `self.groups`, loads associated rules, values, and sub-groups.

        Returns:
            None

        Raises:
            FileNotFoundError: If any of the specified directories or files do not exist.
            ValueError: If there is an issue with the content of the YAML files.
        """
        self.product_cpes.load_cpes_from_directory_tree(self.resolved_cpe_items_dir, self.env_yaml)

        self.fixes = ssg.build_remediations.load_compiled_remediations(self.fixes_dir)

        filenames = glob.glob(os.path.join(self.resolved_rules_dir, "*.yml"))
        self.load_entities_by_id(filenames, self.rules, Rule)

        filenames = glob.glob(os.path.join(self.resolved_groups_dir, "*.yml"))
        self.load_entities_by_id(filenames, self.groups, Group)

        filenames = glob.glob(os.path.join(self.resolved_values_dir, "*.yml"))
        self.load_entities_by_id(filenames, self.values, Value)

        filenames = glob.glob(os.path.join(self.resolved_platforms_dir, "*.yml"))
        self.load_entities_by_id(filenames, self.platforms, Platform)
        self.product_cpes.platforms = self.platforms

        for g in self.groups.values():
            g.load_entities(self.rules, self.values, self.groups)

    def export_benchmark_to_xml(self, rule_and_variables_dict):
        """
        Exports the benchmark data to an XML format.

        Args:
            rule_and_variables_dict (dict): A dictionary containing rules and variables.

        Returns:
            str: The benchmark data in XML format.
        """
        _, benchmark = self.benchmark.get_benchmark_xml_for_profiles(
            self.env_yaml, self.benchmark.profiles, rule_and_variables_dict
        )
        return benchmark

    def get_benchmark_xml(self):
        """
        Converts the benchmark data to an XML element.

        Returns:
            xml.etree.ElementTree.Element: The XML representation of the benchmark data.
        """
        return self.benchmark.to_xml_element(self.env_yaml)

    def export_benchmark_to_file(self, filename):
        """
        Exports the benchmark data to a specified file.

        This method registers the necessary namespaces and then writes the benchmark data to the
        given filename using the environment YAML configuration.

        Args:
            filename (str): The path to the file where the benchmark data will be exported.

        Returns:
            bool: True if the export was successful, False otherwise.
        """
        register_namespaces()
        return self.benchmark.to_file(filename, self.env_yaml)

    def _create_ocil_xml_skeleton(self):
        """
        Creates the skeleton of an OCIL XML document.

        This method initializes the root element of the OCIL document and sets the necessary
        namespaces. It also creates a 'generator' element with sub-elements for product name,
        product version, schema version, and timestamp.

        Returns:
            xml.etree.ElementTree.Element: The root element of the OCIL XML document.
        """
        root = ET.Element('{%s}ocil' % ocil_namespace)
        root.set('xmlns:xsi', xsi_namespace)
        root.set("xmlns:xhtml", xhtml_namespace)
        generator = ET.SubElement(root, "{%s}generator" % ocil_namespace)
        product_name = ET.SubElement(generator, "{%s}product_name" % ocil_namespace)
        product_name.text = "build_shorthand.py from SCAP Security Guide"
        product_version = ET.SubElement(generator, "{%s}product_version" % ocil_namespace)
        product_version.text = "ssg: " + self.env_yaml["ssg_version_str"]
        schema_version = ET.SubElement(generator, "{%s}schema_version" % ocil_namespace)
        schema_version.text = "2.0"
        timestamp_el = ET.SubElement(generator, "{%s}timestamp" % ocil_namespace)
        timestamp_el.text = timestamp
        return root

    @staticmethod
    def _add_ocil_rules(rules, root):
        """
        Adds OCIL rules to the provided XML root element.

        This function creates and appends 'questionnaires', 'test_actions', and 'questions'
        elements to the given XML root element based on the provided rules. Each rule is expected
        to have 'ocil' and 'ocil_clause' attributes, and a 'to_ocil' method that returns a tuple
        containing the questionnaire, action, and boolean question elements.

        Args:
            rules (list): A list of rule objects. Each rule object should have 'ocil' and 'ocil_clause'
                          attributes, and a 'to_ocil' method.
            root (xml.etree.ElementTree.Element): The root XML element to which the OCIL elements will be added.

        Returns:
            None
        """
        questionnaires = ET.SubElement(root, "{%s}questionnaires" % ocil_namespace)
        test_actions = ET.SubElement(root, "{%s}test_actions" % ocil_namespace)
        questions = ET.SubElement(root, "{%s}questions" % ocil_namespace)

        for rule in rules:
            if not rule.ocil and not rule.ocil_clause:
                continue
            questionnaire, action, boolean_question = rule.to_ocil()
            questionnaires.append(questionnaire)
            test_actions.append(action)
            questions.append(boolean_question)

    def _get_rules_from_benchmark(self, benchmark):
        """
        Retrieves a list of rules from the benchmark that are selected in all profiles.

        Args:
            benchmark: An object representing the benchmark, which contains rules and profiles.

        Returns:
            A list of rules that are selected in all profiles of the given benchmark.
        """
        return [self.rules[rule_id] for rule_id in benchmark.get_rules_selected_in_all_profiles()]

    def export_ocil_to_xml(self, benchmark=None):
        """
        Exports OCIL content to an XML format.

        Args:
            benchmark (optional): The benchmark object containing rules to be exported.
                                  If not provided, the instance's benchmark attribute is used.

        Returns:
            xml.etree.ElementTree.Element: The root element of the generated OCIL XML tree.
                                           Returns None if OCIL is turned off or no rules are found.
        """
        if self.off_ocil:
            return None
        root = self._create_ocil_xml_skeleton()

        if benchmark is None:
            benchmark = self.benchmark

        rules = self._get_rules_from_benchmark(benchmark)
        if len(rules) == 0:
            return None
        self._add_ocil_rules(rules, root)

        if hasattr(ET, "indent"):
            ET.indent(root, space=" ", level=0)
        return root

    def export_ocil_to_file(self, filename):
        """
        Exports the OCIL data to an XML file.

        This method converts the OCIL data to an XML format and writes it to the specified file.
        If the conversion to XML results in a None root, the method returns without writing to the file.

        Args:
            filename (str): The path to the file where the XML data will be written.

        Returns:
            None
        """
        root = self.export_ocil_to_xml()
        if root is None:
            return
        tree = ET.ElementTree(root)
        tree.write(filename, encoding="utf-8", xml_declaration=True)


class Platform(XCCDFEntity):
    """
    Represents a platform entity in the XCCDF standard.

    Attributes:
        KEYS (dict): Dictionary of keys with default lambda functions.
        MANDATORY_KEYS (list): List of mandatory keys for the platform.
        prefix (str): Prefix for the platform.
        ns (str): Namespace for the platform.
    """
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
        """
        Creates a platform object from a given text expression and product CPEs.

        Args:
            cls: The class itself.
            expression (str): The text expression to parse.
            product_cpes (ProductCPEs): The product CPEs to use for parsing and resolving CPE items.

        Returns:
            platform (Platform): A platform object with the parsed and enriched CPE information,
                                 or None if product_cpes is empty.
        """
        if not product_cpes:
            return None
        test = product_cpes.algebra.parse(expression, simplify=True)
        id_ = test.as_id()
        platform = cls(id_)
        platform.test = test
        product_cpes.add_resolved_cpe_items_from_platform(platform)
        platform.test.enrich_with_cpe_info(product_cpes)
        platform.name = id_
        platform.original_expression = expression
        platform.xml_content = platform.get_xml()
        platform.update_conditional_from_cpe_items("bash", product_cpes)
        platform.update_conditional_from_cpe_items("ansible", product_cpes)
        return platform

    def get_xml(self):
        """
        Generates an XML string representation of the platform.

        This method creates an XML element for the platform with the appropriate namespace and
        sets its 'id' attribute to the platform's name. If the platform contains only a single CPE
        name, it creates a logical test element with an 'AND' operator and 'false' negate
        attribute to adhere to the CPE specification. The logical test element or the test element
        is then appended to the platform element.

        Returns:
            str: A string representation of the XML for the platform.
        """
        cpe_platform = ET.Element("{%s}platform" % Platform.ns)
        cpe_platform.set('id', self.name)
        # In case the platform contains only single CPE name, fake the logical test
        # we have to adhere to CPE specification
        if isinstance(self.test, CPEALCheckFactRef):
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
        """
        Converts the stored XML content into an XML element.

        Returns:
            xml.etree.ElementTree.Element: The root element of the parsed XML content.
        """
        return ET.fromstring(self.xml_content)

    def get_remediation_conditional(self, language):
        """
        Returns the remediation conditional based on the specified language.

        Args:
            language (str): The remediation language. Supported values are "bash" and "ansible".

        Returns:
            str: The corresponding remediation conditional for the specified language.

        Raises:
            AttributeError: If an invalid remediation language is specified.
        """
        if language == "bash":
            return self.bash_conditional
        elif language == "ansible":
            return self.ansible_conditional
        else:
            raise AttributeError("Invalid remediation language {0} specified.".format(language))

    @classmethod
    def from_yaml(cls, yaml_file, env_yaml=None, product_cpes=None):
        """
        Creates a Platform object from a YAML file.

        Args:
            yaml_file (str): Path to the YAML file.
            env_yaml (dict, optional): Environment YAML data. Defaults to None.
            product_cpes (ProductCPEs, optional): Product CPEs object for restoring the original
                                                  test object. Defaults to None.

        Returns:
            Platform: A Platform object created from the YAML file.
        """
        platform = super(Platform, cls).from_yaml(yaml_file, env_yaml)
        # If we received a product_cpes, we can restore also the original test object
        # it can be later used e.g. for comparison
        if product_cpes:
            platform.test = product_cpes.algebra.parse(platform.original_expression, simplify=True)
            product_cpes.add_resolved_cpe_items_from_platform(platform)
        return platform

    def get_fact_refs(self):
        """
        Retrieve fact references from the test symbols.

        Returns:
            list: A list of symbols from the test object.
        """
        return self.test.get_symbols()

    def update_conditional_from_cpe_items(self, language, product_cpes):
        """
        Updates the conditional statements for the specified language based on CPE items.

        This method enriches the test object with CPE information and then generates the
        appropriate conditional statements for the specified language.

        Args:
            language (str): The language for which to generate the conditional statements.
                            Supported values are "bash" and "ansible".
            product_cpes (list): A list of CPE items to enrich the test object with.

        Returns:
            None

        Raises:
            RuntimeError: If the specified language is not supported.
        """
        self.test.enrich_with_cpe_info(product_cpes)
        if language == "bash":
            self.bash_conditional = self.test.to_bash_conditional()
        elif language == "ansible":
            self.ansible_conditional = self.test.to_ansible_conditional()
        else:
            raise RuntimeError(
                "Platform remediations do not support the {0} language".format(language))

    def __eq__(self, other):
        if not isinstance(other, Platform):
            return False
        else:
            return self.test == other.test


def add_platform_if_not_defined(platform, product_cpes):
    """
    Adds a platform to the product_cpes if it is not already defined.

    Args:
        platform (Platform): The platform to be added.
        product_cpes (ProductCPEs): The product CPEs object containing platforms.

    Returns:
        Platform: The existing platform if it was already defined, otherwise the newly added platform.
    """
    # check if the platform is already in the dictionary. If yes, return the existing one
    for p in product_cpes.platforms.values():
        if platform == p:
            return p
    product_cpes.platforms[platform.id_] = platform
    return platform
