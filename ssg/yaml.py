from __future__ import absolute_import
from __future__ import print_function

import codecs
import yaml
import sys

from .jinja import _extract_substitutions_dict_from_template
from .jinja import _rename_items
from .jinja import process_file
from .constants import (PKG_MANAGER_TO_SYSTEM,
                        JINJA_MACROS_BASE_DEFINITIONS, JINJA_MACROS_HIGHLEVEL_DEFINITIONS)
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


def _open_yaml(stream, original_file=None):
    """
    Open given file-like object and parse it as YAML.

    Optionally, pass the path to the original_file for better error handling
    when the file contents are passed.

    Return None if it contains "documentation_complete" key set to "false".
    """
    try:
        yaml_contents = yaml.load(stream, Loader=yaml_SafeLoader)

        if yaml_contents.pop("documentation_complete", "true") == "false":
            return None

        return yaml_contents
    except Exception as e:
        _file = original_file
        if not _file:
            _file = stream
        print("Exception while handling file: %s" % _file, file=sys.stderr)
        raise e


def _get_implied_properties(existing_properties):
    result = dict()
    if ("pkg_manager" in existing_properties and
            "pkg_system" not in existing_properties):
        pkg_manager = existing_properties["pkg_manager"]
        result["pkg_system"] = PKG_MANAGER_TO_SYSTEM[pkg_manager]

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
    yaml_contents = _open_yaml(expanded_template, original_file=yaml_file)
    return yaml_contents


def open_and_macro_expand(yaml_file, substitutions_dict=None):
    """
    Do the same as open_and_expand, but load definitions of macros
    so they can be expanded in the template.
    """
    if substitutions_dict is None:
        substitutions_dict = dict()

    try:
        macro_definitions = _extract_substitutions_dict_from_template(
            JINJA_MACROS_BASE_DEFINITIONS, substitutions_dict)
        macro_definitions.update(_extract_substitutions_dict_from_template(
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
