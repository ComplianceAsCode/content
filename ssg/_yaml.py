import codecs
import yaml

from ssg._jinja import _extract_substitutions_dict_from_template
from ssg._jinja import _rename_items
from ssg._jinja import process_file
from ssg._constants import PKG_MANAGER_TO_SYSTEM, JINJA_MACROS_DEFINITIONS

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


def _open_yaml(stream):
    """
    Open given file-like object and parse it as YAML
    Return None if it contains "documentation_complete" key set to "false".
    """
    yaml_contents = yaml.load(stream, Loader=yaml_SafeLoader)

    if yaml_contents.pop("documentation_complete", "true") == "false":
        return None

    return yaml_contents


def _identify_special_macro_mapping(existing_properties):
    result = dict()

    pkg_manager = existing_properties.get("pkg_manager")
    if pkg_manager is not None:
        _save_rename(result, "describe_package_install", pkg_manager)
        _save_rename(result, "describe_package_remove", pkg_manager)

    pkg_system = existing_properties.get("pkg_system")
    if pkg_system is not None:
        _save_rename(result, "ocil_package", pkg_system)
        _save_rename(result, "complete_ocil_entry_package", pkg_system)

    init_system = existing_properties.get("init_system")
    if init_system is not None:
        _save_rename(result, "describe_service_enable", init_system)
        _save_rename(result, "describe_service_disable", init_system)
        _save_rename(result, "ocil_service_enabled", init_system)
        _save_rename(result, "ocil_service_disabled", init_system)
        _save_rename(result, "describe_socket_enable", init_system)
        _save_rename(result, "describe_socket_disable", init_system)
        _save_rename(result, "complete_ocil_entry_socket_and_service_disabled",
                     init_system)

    return result


def _get_implied_properties(existing_properties):
    result = dict()
    if ("pkg_manager" in existing_properties and
            "pkg_system" not in existing_properties):
        pkg_manager = existing_properties["pkg_manager"]
        result["pkg_system"] = PKG_MANAGER_TO_SYSTEM[pkg_manager]
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
    yaml_contents = _open_yaml(expanded_template)
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
            JINJA_MACROS_DEFINITIONS, substitutions_dict)
    except Exception as exc:
        msg = ("Error extracting macro definitions from {0}: {1}"
               .format(JINJA_MACROS_DEFINITIONS, str(exc)))
        raise RuntimeError(msg)
    mapping = _identify_special_macro_mapping(substitutions_dict)
    special_macros = _rename_items(macro_definitions, mapping)
    substitutions_dict.update(macro_definitions)
    substitutions_dict.update(special_macros)
    return open_and_expand(yaml_file, substitutions_dict)


def open_raw(yaml_file):
    """
    Open given file-like object and parse it as YAML
    without performing any kind of template processing

    See also: _open_yaml
    """
    with codecs.open(yaml_file, "r", "utf8") as stream:
        yaml_contents = _open_yaml(stream)
    return yaml_contents


def open_environment(build_config_yaml, product_yaml):
    contents = open_raw(build_config_yaml)
    contents.update(open_raw(product_yaml))
    contents.update(_get_implied_properties(contents))
    return contents
