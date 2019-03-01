from __future__ import absolute_import
from __future__ import print_function

import codecs
import yaml
import sys
import re

from collections import OrderedDict

from .jinja import extract_substitutions_dict_from_template, process_file
from .constants import (PKG_MANAGER_TO_SYSTEM,
                        PKG_MANAGER_TO_CONFIG_FILE,
                        JINJA_MACROS_BASE_DEFINITIONS,
                        JINJA_MACROS_HIGHLEVEL_DEFINITIONS)
from .constants import DEFAULT_UID_MIN

try:
    from yaml import CSafeLoader as yaml_SafeLoader
except ImportError:
    from yaml import SafeLoader as yaml_SafeLoader


def _bool_constructor(self, node):
    return self.construct_scalar(node)


# Don't follow python bool case
yaml_SafeLoader.add_constructor(u'tag:yaml.org,2002:bool', _bool_constructor)


def _save_rename(result, stem, prefix):
    result["{0}_{1}".format(prefix, stem)] = stem


def _open_yaml(stream, original_file=None, substitutions_dict={}):
    """
    Open given file-like object and parse it as YAML.

    Optionally, pass the path to the original_file for better error handling
    when the file contents are passed.

    Return None if it contains "documentation_complete" key set to "false".
    """
    try:
        yaml_contents = yaml.load(stream, Loader=yaml_SafeLoader)

        if yaml_contents.pop("documentation_complete", "true") == "false" and \
                substitutions_dict.get("cmake_build_type") != "Debug":
            return None

        return yaml_contents
    except Exception as e:
        count = 0
        _file = original_file
        if not _file:
            _file = stream
        with open(_file, "r") as e_file:
            lines = e_file.readlines()
            for line in lines:
                count = count + 1
                if re.match(r"^\s*\t+\s*", line):
                    print("Exception while handling file: %s" % _file, file=sys.stderr)
                    print("TabIndentationError: Line %s contains tabs instead of spaces:" % (count), file=sys.stderr)
                    print("%s\n\n" % repr(line.strip("\n")), file=sys.stderr)
                    sys.exit(1)

        print("Exception while handling file: %s" % _file, file=sys.stderr)
        raise e


def _get_implied_properties(existing_properties):
    result = dict()
    if "pkg_manager" in existing_properties:
        pkg_manager = existing_properties["pkg_manager"]
        if "pkg_system" not in existing_properties:
            result["pkg_system"] = PKG_MANAGER_TO_SYSTEM[pkg_manager]
        if "pkg_manager_config_file" not in existing_properties:
            if pkg_manager in PKG_MANAGER_TO_CONFIG_FILE:
                result["pkg_manager_config_file"] = PKG_MANAGER_TO_CONFIG_FILE[pkg_manager]

    if "uid_min" not in existing_properties:
        result["uid_min"] = DEFAULT_UID_MIN

    if "auid" not in existing_properties:
        result["auid"] = existing_properties.get("uid_min", DEFAULT_UID_MIN)

    return result


def open_and_expand(yaml_file, substitutions_dict=None):
    """
    Process the file as a template, using substitutions_dict to perform
    expansion. Then, process the expansion result as a YAML content.

    See also: _open_yaml
    """
    if substitutions_dict is None:
        substitutions_dict = dict()

    expanded_template = process_file(yaml_file, substitutions_dict)
    yaml_contents = _open_yaml(expanded_template, yaml_file, substitutions_dict)
    return yaml_contents


def open_and_macro_expand(yaml_file, substitutions_dict=None):
    """
    Do the same as open_and_expand, but load definitions of macros
    so they can be expanded in the template.
    """
    if substitutions_dict is None:
        substitutions_dict = dict()

    try:
        macro_definitions = extract_substitutions_dict_from_template(
            JINJA_MACROS_BASE_DEFINITIONS, substitutions_dict)
        macro_definitions.update(extract_substitutions_dict_from_template(
            JINJA_MACROS_HIGHLEVEL_DEFINITIONS, substitutions_dict))
    except Exception as exc:
        msg = ("Error extracting macro definitions: {0}"
               .format(str(exc)))
        raise RuntimeError(msg)
    substitutions_dict.update(macro_definitions)
    return open_and_expand(yaml_file, substitutions_dict)


def open_raw(yaml_file):
    """
    Open given file-like object and parse it as YAML
    without performing any kind of template processing

    See also: _open_yaml
    """
    with codecs.open(yaml_file, "r", "utf8") as stream:
        yaml_contents = _open_yaml(stream, original_file=yaml_file)
    return yaml_contents


def open_environment(build_config_yaml, product_yaml):
    contents = open_raw(build_config_yaml)
    contents.update(open_raw(product_yaml))
    contents.update(_get_implied_properties(contents))
    return contents


def ordered_load(stream, Loader=yaml.Loader, object_pairs_hook=OrderedDict):
    """
    Drop-in replacement for yaml.load(), but preserves order of dictionaries
    """
    class OrderedLoader(Loader):
        pass

    def construct_mapping(loader, node):
        loader.flatten_mapping(node)
        return object_pairs_hook(loader.construct_pairs(node))
    OrderedLoader.add_constructor(
        yaml.resolver.BaseResolver.DEFAULT_MAPPING_TAG,
        construct_mapping)
    return yaml.load(stream, OrderedLoader)


def ordered_dump(data, stream=None, Dumper=yaml.Dumper, **kwds):
    """
    Drop-in replacement for yaml.dump(), but preserves order of dictionaries
    """
    class OrderedDumper(Dumper):
        pass

    def _dict_representer(dumper, data):
        return dumper.represent_mapping(
            yaml.resolver.BaseResolver.DEFAULT_MAPPING_TAG,
            data.items())
    OrderedDumper.add_representer(OrderedDict, _dict_representer)
    return yaml.dump(data, stream, OrderedDumper, **kwds)
