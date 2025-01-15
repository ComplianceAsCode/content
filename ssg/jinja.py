"""
Common functions for processing Jinja2 in SSG
"""

from __future__ import absolute_import
from __future__ import print_function

import os.path
import sys
import jinja2

try:
    from urllib.parse import quote
except ImportError:
    from urllib import quote

try:
    from shlex import quote as shell_quote
except ImportError:
    from pipes import quote as shell_quote

from .constants import JINJA_MACROS_DIRECTORY
from .utils import (required_key,
                    product_to_name,
                    name_to_platform,
                    product_to_platform,
                    banner_regexify,
                    banner_anchor_wrap,
                    escape_id,
                    escape_regex,
                    escape_yaml_key,
                    sha256
                    )


class MacroError(RuntimeError):
    pass


class AbsolutePathFileSystemLoader(jinja2.BaseLoader):
    """
    AbsolutePathFileSystemLoader is a custom Jinja2 template loader that loads templates from the file system using absolute paths.

    Attributes:
        encoding (str): The encoding used to read the template files. Defaults to 'utf-8'.
    """
    def __init__(self, encoding='utf-8'):
        self.encoding = encoding

    def get_source(self, environment, template):
        """
        Retrieves the source code of a Jinja2 template from the file system.

        Args:
            environment (jinja2.Environment): The Jinja2 environment.
            template (str): The absolute path to the template file.

        Returns:
            tuple: A tuple containing the template contents as a string, the template path, and a
                   function to check if the template file has been updated.

        Raises:
            jinja2.TemplateNotFound: If the template file does not exist or the path is not absolute.
            RuntimeError: If there is an error reading the template file.
        """
        if not os.path.isabs(template):
            raise jinja2.TemplateNotFound(template)

        template_file = jinja2.utils.open_if_exists(template)
        if template_file is None:
            raise jinja2.TemplateNotFound(template)
        try:
            contents = template_file.read().decode(self.encoding)
        except Exception as exc:
            msg = ("Error reading file {template}: {exc}"
                   .format(template=template, exc=str(exc)))
            raise RuntimeError(msg)
        finally:
            template_file.close()

        mtime = os.path.getmtime(template)

        def uptodate():
            try:
                return os.path.getmtime(template) == mtime
            except OSError:
                return False
        return contents, template, uptodate


def _get_jinja_environment(substitutions_dict):
    """
    Initializes and returns a Jinja2 Environment with custom settings and filters.

    This function sets up a Jinja2 Environment with custom block, variable, and comment
    delimiters. It also configures a bytecode cache if specified in the substitutions_dict.
    Additionally, it adds several custom filters to the environment.

    Args:
        substitutions_dict (dict): A dictionary containing configuration options.
            Expected keys include:
            - "jinja2_cache_enabled": A string ("true" or "false") indicating whether bytecode
              caching is enabled.
            - "jinja2_cache_dir": The directory path for storing the bytecode cache
              (required if caching is enabled).

    Returns:
        jinja2.Environment: The configured Jinja2 Environment instance.
    """
    if _get_jinja_environment.env is None:
        bytecode_cache = None
        if substitutions_dict.get("jinja2_cache_enabled") == "true":
            bytecode_cache = jinja2.FileSystemBytecodeCache(
                required_key(substitutions_dict, "jinja2_cache_dir")
            )

        # TODO: Choose better syntax?
        _get_jinja_environment.env = jinja2.Environment(
            block_start_string="{{%",
            block_end_string="%}}",
            variable_start_string="{{{",
            variable_end_string="}}}",
            comment_start_string="{{#",
            comment_end_string="#}}",
            loader=AbsolutePathFileSystemLoader(),
            bytecode_cache=bytecode_cache
        )
        _get_jinja_environment.env.filters['banner_anchor_wrap'] = banner_anchor_wrap
        _get_jinja_environment.env.filters['banner_regexify'] = banner_regexify
        _get_jinja_environment.env.filters['escape_id'] = escape_id
        _get_jinja_environment.env.filters['escape_regex'] = escape_regex
        _get_jinja_environment.env.filters['escape_yaml_key'] = escape_yaml_key
        _get_jinja_environment.env.filters['quote'] = shell_quote
        _get_jinja_environment.env.filters['sha256'] = sha256

    return _get_jinja_environment.env


_get_jinja_environment.env = None


def raise_exception(message):
    raise MacroError(message)


def update_substitutions_dict(filename, substitutions_dict):
    """
    Update the substitutions dictionary with macro definitions from a Jinja2 file.

    This function treats the given filename as a Jinja2 file containing macro definitions.
    It exports definitions that do not start with an underscore (_) into the substitutions_dict,
    which is a dictionary mapping names to macro objects. During the macro compilation process,
    symbols that already exist in substitutions_dict may be used by the new definitions.

    Args:
        filename (str): The path to the Jinja2 file containing macro definitions.
        substitutions_dict (dict): The dictionary to update with new macro definitions.

    Returns:
        None
    """
    template = _get_jinja_environment(substitutions_dict).get_template(filename)
    all_symbols = template.make_module(substitutions_dict).__dict__
    for name, symbol in all_symbols.items():
        if name.startswith("_"):
            continue
        substitutions_dict[name] = symbol


def process_file(filepath, substitutions_dict):
    """
    Process the Jinja file at the given path with the specified substitutions.

    Args:
        filepath (str): The path to the Jinja file to be processed.
        substitutions_dict (dict): A dictionary containing the substitutions to be applied to the template.

    Returns:
        str: The rendered template as a string.

    Note:
        This function does not load the project macros. Use `process_file_with_macros(...)` for that.
    """
    filepath = os.path.abspath(filepath)
    template = _get_jinja_environment(substitutions_dict).get_template(filepath)
    return template.render(substitutions_dict)


def add_python_functions(substitutions_dict):
    """
    Adds predefined Python functions to the provided substitutions dictionary.

    The following functions are added:
    - 'product_to_name': Maps a product identifier to its name.
    - 'name_to_platform': Maps a name to its platform.
    - 'product_to_platform': Maps a product identifier to its platform.
    - 'url_encode': Encodes a URL.
    - 'raise': Raises an exception.
    - 'expand_yaml_path': Expands a YAML path.

    Args:
        substitutions_dict (dict): The dictionary to which the functions will be added.
    """
    substitutions_dict['product_to_name'] = product_to_name
    substitutions_dict['name_to_platform'] = name_to_platform
    substitutions_dict['product_to_platform'] = product_to_platform
    substitutions_dict['url_encode'] = url_encode
    substitutions_dict['raise'] = raise_exception
    substitutions_dict['expand_yaml_path'] = expand_yaml_path


def _load_macros_from_directory(macros_directory, substitutions_dict):
    """
    Helper function to load and update macros from the specified directory.

    Args:
        macros_directory (str): The path to the directory containing macro files.
        substitutions_dict (dict): A dictionary to be augmented with Jinja macros.

    Raises:
        RuntimeError: If there is an error while reading or processing the macro files.
    """
    try:
        for filename in sorted(os.listdir(macros_directory)):
            if filename.endswith(".jinja"):
                macros_file = os.path.join(macros_directory, filename)
                update_substitutions_dict(macros_file, substitutions_dict)
    except Exception as exc:
        msg = ("Error extracting macro definitions from '{1}': {0}"
               .format(str(exc), filename))
        raise RuntimeError(msg)


def _load_macros(macros_directory, substitutions_dict=None):
    """
    Load macros from a specified directory and add them to a substitutions dictionary.

    This function checks if the given macros directory exists, adds Python functions to the
    substitutions dictionary, and then loads macros from the directory into the dictionary.

    Args:
        macros_directory (str): The path to the directory containing macro files.
        substitutions_dict (dict, optional): A dictionary to store the loaded macros.
                                             If None, a new dictionary is created.

    Returns:
        dict: The updated substitutions dictionary containing the loaded macros.

    Raises:
        RuntimeError: If the specified macros directory does not exist.
    """
    if substitutions_dict is None:
        substitutions_dict = dict()

    add_python_functions(substitutions_dict)

    if not os.path.isdir(macros_directory):
        msg = (f"The directory '{macros_directory}' does not exist.")
        raise RuntimeError(msg)

    _load_macros_from_directory(macros_directory, substitutions_dict)

    return substitutions_dict


def load_macros(substitutions_dict=None):
    """
    Augments the provided substitutions_dict with project Jinja macros found in the in
    JINJA_MACROS_DIRECTORY from constants.py.

    Args:
        substitutions_dict (dict, optional): A dictionary to be augmented with Jinja macros.
                                             Defaults to None.

    Returns:
        dict: The updated substitutions_dict containing the Jinja macros.
    """
    return _load_macros(JINJA_MACROS_DIRECTORY, substitutions_dict)


def load_macros_from_content_dir(content_dir, substitutions_dict=None):
    """
    Augments the provided substitutions_dict with project Jinja macros found in a specified
    content directory.

    Args:
        content_dir (str): The base directory containing the 'shared/macros' subdirectory.
        substitutions_dict (dict, optional): A dictionary to be augmented with Jinja macros.
                                             Defaults to None.

    Returns:
        dict: The updated substitutions_dict containing the Jinja macros.
    """
    jinja_macros_directory = os.path.join(content_dir, 'shared', 'macros')
    return _load_macros(jinja_macros_directory, substitutions_dict)


def process_file_with_macros(filepath, substitutions_dict):
    """
    Process a file with Jinja macros.

    This function processes the file located at the given `filepath` using Jinja macros and the
    specified `substitutions_dict`. The `substitutions_dict` is first processed to load any
    macros, and then it is used to substitute values in the file. The function ensures that the
    key 'indent' is not present in the `substitutions_dict`.

    Args:
        filepath (str): The path to the file to be processed.
        substitutions_dict (dict): A dictionary containing the substitutions to be applied to the file.

    Returns:
        str: The processed file content as a string.

    Raises:
        AssertionError: If the key 'indent' is present in `substitutions_dict`.

    See also:
        process_file: A function that processes a file with the given substitutions.
    """
    substitutions_dict = load_macros(substitutions_dict)
    assert 'indent' not in substitutions_dict
    return process_file(filepath, substitutions_dict)


def url_encode(source):
    """
    Encodes a given string into a URL-safe format.

    Args:
        source (str): The string to be URL-encoded.

    Returns:
        str: The URL-encoded string.
    """
    return quote(source)


def expand_yaml_path(path, parameter):
    """
    Expands a dot-separated YAML path into a formatted YAML string.

    Args:
        path (str): The dot-separated path to be expanded.
        parameter (str): An additional parameter to be appended at the end of the path.

    Returns:
        str: A formatted YAML string representing the expanded path.
    """
    out = ""
    i = 0
    for x in path.split("."):
        i += 1
        if i != len(path.split(".")):
            out += i * "  " + x + ":\n"
        elif parameter != "":
            out += i * "  " + x + ":\n"
            i += 1
            out += i * "  " + parameter
        else:
            out += i * "  " + x
    return out


def render_template(data, template_path, output_path, loader):
    """
    Renders a template with the given data and writes the output to a file.

    Args:
        data (dict): The data to be used in the template rendering.
        template_path (str): The path to the template file.
        output_path (str): The path where the rendered output will be written.
        loader (jinja2.BaseLoader): The Jinja2 loader to use for loading templates.

    Returns:
        None
    """
    env = _get_jinja_environment(dict())
    env.loader = loader
    result = process_file(template_path, data)
    with open(output_path, "wb") as f:
        f.write(result.encode('utf8', 'replace'))
