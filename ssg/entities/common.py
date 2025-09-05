from __future__ import absolute_import
from __future__ import print_function

import os
import yaml
from collections import defaultdict
from copy import deepcopy

from ..xml import ElementTree as ET, add_xhtml_namespace
from ..constants import xhtml_namespace
from ..yaml import DocumentationNotComplete, open_and_macro_expand
from ..shims import unicode_func

from ..constants import (
    XCCDF_REFINABLE_PROPERTIES,
    XCCDF12_NS,
    OSCAP_VALUE,
)


def add_sub_element(parent, tag, ns, data):
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
    ustr = unicode_func('<{0} xmlns="{3}" xmlns:xhtml="{2}">{1}</{0}>').format(
        tag, namespaced_data, xhtml_namespace, ns)

    try:
        element = ET.fromstring(ustr.encode("utf-8"))
    except Exception:
        msg = ("Error adding subelement to an element '{0}' from string: '{1}'"
               .format(parent.tag, ustr))
        raise RuntimeError(msg)

    # Apart from HTML and XML elements the rule descriptions and similar
    # also contain <xccdf:sub> elements, where we need to add the prefix
    # to create a full reference.
    for x in element.findall(".//{%s}sub" % XCCDF12_NS):
        x.set("idref", OSCAP_VALUE + x.get("idref"))
        x.set("use", "legacy")
    parent.append(element)
    return element


def derive_id_from_file_name(filename):
    return os.path.splitext(filename)[0]


def dump_yaml_preferably_in_original_order(dictionary, file_object):
    try:
        return yaml.dump(dictionary, file_object, indent=4, sort_keys=False)
    except TypeError as exc:
        # Older versions of libyaml don't understand the sort_keys kwarg
        if "sort_keys" not in str(exc):
            raise exc
        return yaml.dump(dictionary, file_object, indent=4)


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


class SelectionHandler(object):
    def __init__(self):
        self.refine_rules = defaultdict(list)
        self.variables = dict()
        self.unselected = []
        self.unselected_groups = []
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
