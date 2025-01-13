"""
Common functions for processing YAML in SSG
"""

from __future__ import absolute_import
from __future__ import print_function

import codecs
import re
import sys
import yaml

from collections import OrderedDict

from .jinja import (
    load_macros,
    load_macros_from_content_dir,
    process_file,
)

try:
    from yaml import CSafeLoader as yaml_SafeLoader
except ImportError:
    from yaml import SafeLoader as yaml_SafeLoader

try:
    from yaml import CLoader as yaml_Loader
except ImportError:
    from yaml import Loader as yaml_Loader

try:
    from yaml import CDumper as yaml_Dumper
except ImportError:
    from yaml import Dumper as yaml_Dumper

def _bool_constructor(self, node):
    """
    Construct a boolean value from a YAML node.

    Args:
        self: The instance of the class calling this method.
        node: The YAML node to be converted into a boolean value.

    Returns:
        The scalar value of the node, typically a boolean.
    """
    return self.construct_scalar(node)


def _unicode_constructor(self, node):
    """
    Constructs a Unicode string from a YAML node.

    This method takes a YAML node, extracts its scalar value, and converts it to a Unicode string.

    Args:
        node (yaml.Node): The YAML node to be converted.

    Returns:
        str: The Unicode string representation of the node's scalar value.
    """
    string_like = self.construct_scalar(node)
    return str(string_like)


# Don't follow python bool case
yaml_SafeLoader.add_constructor(u'tag:yaml.org,2002:bool', _bool_constructor)
# Python2-relevant - become able to resolve "unicode strings"
yaml_SafeLoader.add_constructor(u'tag:yaml.org,2002:python/unicode', _unicode_constructor)


class DocumentationNotComplete(Exception):
    pass


def _save_rename(result, stem, prefix):
    """
    Renames a key (represented by the stem argument) in the result dictionary by prefixing it with a given prefix.

    Args:
        result (dict): The dictionary where the renamed key-value pair will be stored.
        stem (str): The original key that will be renamed.
        prefix (str): The prefix to be added to the original key.

    Returns:
        None
    """
    result["{0}_{1}".format(prefix, stem)] = stem


def _get_yaml_contents_without_documentation_complete(parsed_yaml, substitutions_dict):
    """
    Processes the given parsed YAML content by handling the 'documentation_complete' key.

    If the YAML content is a dictionary, it checks the value of the 'documentation_complete' key.
    If 'documentation_complete' is "false" and the build type is not "Debug", it raises a
    DocumentationNotComplete exception. The 'documentation_complete' key is then removed from the
    dictionary.

    If the YAML content is empty or a list, it is returned as is.

    Args:
        parsed_yaml (dict or list): The parsed YAML content.
        substitutions_dict (dict): A dictionary containing substitution values, including the
                                   'cmake_build_type'.

    Returns:
        dict or list: The processed YAML content with the 'documentation_complete' key removed if
                      applicable.

    Raises:
        DocumentationNotComplete: If 'documentation_complete' is "false" and the build type is not
                                  "Debug".
    """
    if isinstance(parsed_yaml, dict):
        documentation_incomplete_content_and_not_debug_build = (
            parsed_yaml.pop("documentation_complete", "true") == "false"
            and substitutions_dict.get("cmake_build_type") != "Debug")
        if documentation_incomplete_content_and_not_debug_build:
            raise DocumentationNotComplete("documentation not complete and not a debug build")
    return parsed_yaml


def _open_yaml(stream, original_file=None, substitutions_dict={}):
    """
    Open given file-like object and parse it as YAML.

    Args:
        stream (file-like object): The file-like object containing YAML content.
        original_file (str, optional): The path to the original file for better error handling.
                                       Defaults to None.
        substitutions_dict (dict, optional): A dictionary of substitutions to apply to the YAML
                                             content. Defaults to {}.

    Returns:
        dict: The parsed YAML content with substitutions applied.

    Raises:
        DocumentationNotComplete: If the YAML content contains the key "documentation_complete"
                                  set to "false".
        Exception: For any other exceptions, including tab indentation errors in the file.
    """
    try:
        yaml_contents = yaml.load(stream, Loader=yaml_SafeLoader)

        return _get_yaml_contents_without_documentation_complete(yaml_contents, substitutions_dict)
    except DocumentationNotComplete as e:
        raise e
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


def open_and_expand(yaml_file, substitutions_dict=None):
    """
    Process the given YAML file as a template, using the provided substitutions dictionary to
    perform variable expansion. After expanding the template, process the result as YAML content.

    Args:
        yaml_file (str): The path to the YAML file to be processed.
        substitutions_dict (dict, optional): A dictionary containing key-value pairs for template
            substitution. Defaults to an empty dictionary if not provided.

    Returns:
        dict: The processed YAML content as a dictionary.

    Raises:
        yaml.scanner.ScannerError: If there is an error in scanning the YAML content, typically
            due to incorrect indentation after template expansion.

    See also:
        _open_yaml: Function to open and parse the YAML content.
    """
    if substitutions_dict is None:
        substitutions_dict = dict()

    expanded_template = process_file(yaml_file, substitutions_dict)
    try:
        yaml_contents = _open_yaml(expanded_template, yaml_file, substitutions_dict)
    except yaml.scanner.ScannerError as e:
        print("A Jinja template expansion can mess up the indentation.")
        print("Please, check if the contents below are correctly expanded:")
        print("Source yaml: {}".format(yaml_file))
        print("Expanded yaml:\n{}".format(expanded_template))
        sys.exit(1)

    return yaml_contents


def open_and_macro_expand(yaml_file, substitutions_dict=None):
    """
    Opens a YAML file and expands macros within it using the provided substitutions dictionary.

    This function loads definitions of macros and uses them to expand the template within the YAML
    file. It is similar to open_and_expand, but load definitions of macros

    Args:
        yaml_file (str): The path to the YAML file to be opened and expanded.
        substitutions_dict (dict, optional): A dictionary containing macro definitions and their
                                             corresponding values. If not provided, an empty
                                             dictionary is used.

    Returns:
        dict: The expanded content of the YAML file with macros substituted.
    """
    substitutions_dict = load_macros(substitutions_dict)
    return open_and_expand(yaml_file, substitutions_dict)


def open_and_macro_expand_from_dir(yaml_file, content_dir, substitutions_dict=None):
    """
    Opens a YAML file and expands macros from a specified directory. It is similar to
    open_and_macro_expand but loads macro definitions from a specified directory instead of the
    default directory defined in constants. This is useful in cases where the SSG library is
    consumed by an external project.

    Args:
        yaml_file (str): The path to the YAML file to be opened and expanded.
        content_dir (str): The content dir directory to be used for expansion.
        substitutions_dict (dict, optional): A dictionary of substitutions to be used for macro
                                             expansion. If None, a new dictionary will be created
                                             from the content_dir.

    Returns:
        dict: The expanded content of the YAML file.
    """
    substitutions_dict = load_macros_from_content_dir(content_dir, substitutions_dict)
    return open_and_expand(yaml_file, substitutions_dict)


def open_raw(yaml_file):
    """
    Open the given YAML file and parse its contents without performing any template processing.

    Args:
        yaml_file (str): The path to the YAML file to be opened and parsed.

    Returns:
        dict: The parsed contents of the YAML file.

    See also:
        _open_yaml: The function used to parse the YAML contents.
    """
    with codecs.open(yaml_file, "r", "utf8") as stream:
        yaml_contents = _open_yaml(stream, original_file=yaml_file)
    return yaml_contents


def ordered_load(stream, Loader=yaml_Loader, object_pairs_hook=OrderedDict):
    """
    Load a YAML stream while preserving the order of dictionaries.

    This function is a drop-in replacement for `yaml.load()`, but it ensures that the order of
    dictionaries is preserved by using `OrderedDict`.

    Args:
        stream (str): The YAML stream to load.
        Loader (yaml.Loader, optional): The YAML loader class to use. Defaults to `yaml_Loader`.
        object_pairs_hook (callable, optional): A callable that will be used to construct
                                                ordered mappings. Defaults to `OrderedDict`.

    Returns:
        OrderedDict: The loaded YAML data with preserved order of dictionaries.

    Raises:
        yaml.scanner.ScannerError: If there is an error when trying to load the stream.

    Notes:
        - If there is a `ScannerError`, additional hints will be printed to help diagnose
          common issues such as unquoted colons or other special symbols in the stream.
        - The function will exit the program with status code 1 if a `ScannerError` occurs.
    """
    class OrderedLoader(Loader):
        pass

    def construct_mapping(loader, node):
        """
        Constructs a mapping from a YAML node.

        This function flattens the mapping of the given node and then constructs pairs from the
        node using the loader's `construct_pairs` method. The resulting pairs are then processed
        by the `object_pairs_hook`.

        Args:
            loader: The YAML loader instance.
            node: The YAML node to construct the mapping from.

        Returns:
            The constructed mapping, processed by `object_pairs_hook`.
        """
        loader.flatten_mapping(node)
        return object_pairs_hook(loader.construct_pairs(node))
    OrderedLoader.add_constructor(
        yaml.resolver.BaseResolver.DEFAULT_MAPPING_TAG,
        construct_mapping)

    try:
        yaml_loaded = yaml.load(stream, OrderedLoader)
    except yaml.scanner.ScannerError as e:
        print("Error when trying to load the stream: {}".format(e))
        print("HINT: Ansible tasks names may cause expansion errors if not properly quoted.")
        print("HINT: Check for unquoted colons or other special symbols in the stream:")
        print("{}".format(stream))
        sys.exit(1)
    return yaml_loaded


def ordered_dump(data, stream=None, Dumper=yaml_Dumper, **kwds):
    """
    Serializes a Python object into a YAML stream, preserving the order of dictionaries.

    This function is a drop-in replacement for `yaml.dump()`, but it ensures that the order of
    dictionaries is preserved. It also includes custom representers for dictionaries and strings,
    and applies specific formatting fixes for YAML output.

    Args:
        data (Any): The Python object to serialize.
        stream (Optional[IO]): The stream to write the YAML output to. If None, the YAML string is
                               returned.
        Dumper (yaml.Dumper): The YAML dumper class to use. Defaults to `yaml_Dumper`.
        **kwds: Additional keyword arguments to pass to `yaml.dump()`.

    Returns:
        Optional[str]: The YAML string if `stream` is None, otherwise None.
    """
    class OrderedDumper(Dumper):
        """
        OrderedDumper is a custom YAML Dumper class that ensures the correct indentation of tags
        when dumping YAML data. It inherits from the base Dumper class and overrides the
        increase_indent method to fix tag indentations.
        """
        # fix tag indentations
        def increase_indent(self, flow=False, indentless=False):
            """
            Increases the indentation level for the YAML dumper.

            Args:
                flow (bool): Indicates if the flow style is used. Defaults to False.
                indentless (bool): Indicates if the indentation should be suppressed.
                                   Defaults to False.

            Returns:
                The result of the superclass's increase_indent method with the given flow and
                False for indentless.
            """
            return super(OrderedDumper, self).increase_indent(flow, False)

    def _dict_representer(dumper, data):
        """
        Custom YAML representer for Python dictionaries.

        This function is used to define how Python dictionaries should be represented when
        converting to YAML format. It uses the default mapping tag from the YAML resolver.

        Args:
            dumper (yaml.Dumper): The YAML dumper instance.
            data (dict): The Python dictionary to represent.

        Returns:
            yaml.Node: The YAML node representing the dictionary.
        """
        return dumper.represent_mapping(
            yaml.resolver.BaseResolver.DEFAULT_MAPPING_TAG,
            data.items())

    def _str_representer(dumper, data):
        """
        Custom YAML representer for strings.

        This function is used to represent strings in YAML format. If the string contains a
        newline character, it will be represented as a block scalar (using the '|' style).
        Otherwise, it will be represented as a plain scalar.

        Args:
            dumper (yaml.Dumper): The YAML dumper instance.
            data (str): The string data to be represented.

        Returns:
            yaml.Node: The YAML node representing the string.
        """
        if '\n' in data:
            return dumper.represent_scalar(u'tag:yaml.org,2002:str', data,
                                           style='|')
        else:
            return dumper.represent_str(data)

    OrderedDumper.add_representer(OrderedDict, _dict_representer)
    OrderedDumper.add_representer(str, _str_representer)

    # Fix formatting by adding a space in between tasks
    unformatted_yaml = yaml.dump(data, None, OrderedDumper, **kwds)
    formatted_yaml = re.sub(r"[\n]+([\s]*)- name", r"\n\n\1- name", unformatted_yaml)

    # Fix CDumper issue where it adds yaml document ending '...'
    # in some templated ansible remediations
    formatted_yaml = re.sub(r"\n\s*\.\.\.\s*", r"\n", formatted_yaml)

    if stream is not None:
        return stream.write(formatted_yaml)
    else:
        return formatted_yaml


def _strings_to_list(one_or_more_strings):
    """
    Convert a string or an iterable of strings into a list of strings.

    Args:
        one_or_more_strings (str or iterable): A single string or an iterable of strings.

    Returns:
        list: A list containing the input string or the elements of the input iterable.

    Examples:
        >>> _strings_to_list("hello")
        ['hello']
        >>> _strings_to_list(["hello", "world"])
        ['hello', 'world']
    """
    if isinstance(one_or_more_strings, str):
        return [one_or_more_strings]
    else:
        return list(one_or_more_strings)


def update_yaml_list_or_string(current_contents, new_contents, prepend=False):
    """
    Update a YAML list or string by combining current and new contents.

    This function takes the current contents and new contents, both of which can be either
    a string or a list of strings, and combines them into a single list or string. If the
    `prepend` flag is set to True, the new contents are added before the current contents.
    Otherwise, the new contents are appended to the current contents.

    Args:
        current_contents (str or list of str): The existing contents to be updated.
        new_contents (str or list of str): The new contents to be added.
        prepend (bool): If True, new contents are added before current contents. Defaults to False.

    Returns:
        str or list of str: The updated contents. If the result is a single item, it is returned
                            as a string. If the result is empty, an empty string is returned.
    """
    result = []
    if current_contents:
        result += _strings_to_list(current_contents)
    if new_contents:
        if prepend:
            result = _strings_to_list(new_contents) + result
        else:
            result += _strings_to_list(new_contents)
    if not result:
        result = ""
    if len(result) == 1:
        result = result[0]
    return result


def convert_string_to_bool(string):
    """
    Converts a string representation of a boolean to its corresponding boolean value.

    Args:
        string (str): The string to convert. Expected values are "true" or "false"
                      (case insensitive).

    Returns:
        bool: True if the string is "true" (case insensitive), False if the string is "false"
              (case insensitive).

    Raises:
        ValueError: If the string is not "true" or "false" (case insensitive).
    """
    lower = string.lower()
    if lower == "true":
        return True
    elif lower == "false":
        return False
    else:
        raise ValueError(
                    "Invalid value %s while expecting boolean string" % string)
