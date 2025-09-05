"""
Utils functions consumed by SSG
"""

from __future__ import absolute_import
from __future__ import print_function

import multiprocessing
import errno
import os
import re
from collections import namedtuple
import hashlib

from .constants import (FULL_NAME_TO_PRODUCT_MAPPING,
                        MAKEFILE_ID_TO_PRODUCT_MAP,
                        MULTI_PLATFORM_LIST,
                        )


class SSGError(RuntimeError):
    pass


PRODUCT_NAME_PARSER = re.compile(r"([a-zA-Z\-]+)([0-9]+)")


class VersionSpecifierSet(set):
    """
    A set-like collection that only accepts VersionSpecifier objects.

    This class extends the built-in set and ensures that all elements are instances of the
    VersionSpecifier class. It provides additional properties to generate titles, CPE IDs, and
    OVAL IDs from the contained VersionSpecifier objects.

    Attributes:
        title (str): A string representation of the set, joining the titles of the contained
                     VersionSpecifier objects with ' and '.
        cpe_id (str): A string representation of the set, joining the CPE IDs of the contained
                      VersionSpecifier objects with ':'.
        oval_id (str): A string representation of the set, joining the OVAL IDs of the contained
                       VersionSpecifier objects with '_'.
    """
    def __init__(self, s=()):
        for el in s:
            if not isinstance(el, VersionSpecifier):
                raise ValueError('VersionSpecifierSet can only work with VersionSpecifier objects,'
                                 ' invalid object: {0}'.format(repr(el)))
        super(VersionSpecifierSet, self).__init__(s)

    @property
    def title(self):
        return ' and '.join([ver_spec.title for ver_spec in sorted(self)])

    @property
    def cpe_id(self):
        return ':'.join([ver_spec.cpe_id for ver_spec in sorted(self)])

    @property
    def oval_id(self):
        return '_'.join([ver_spec.oval_id for ver_spec in sorted(self)])


class VersionSpecifier:
    """
    A class to represent a version specifier with properties and methods to manipulate and
    retrieve version information.

    Attributes:
        op (str): The operation associated with the version specifier.
        _evr_ver_dict (dict): A dictionary containing epoch, version, and release information.
    """
    def __init__(self, op, evr_ver_dict):
        self._evr_ver_dict = evr_ver_dict
        self.op = op

    def __str__(self):
        return '{0} {1}'.format(self.op, self.ver)

    def __repr__(self):
        return '<VersionSpecifier({0},{1})>'.format(self.op, self.ver)

    def __hash__(self):
        return hash(self.op + self.ver)

    def __eq__(self, other):
        return self.op+self.ver == other.op+other.ver

    def __lt__(self, other):
        return self.op+self.ver < other.op+other.ver

    @property
    def evr_op(self):
        return comparison_to_oval(self.op)

    @property
    def ver(self):
        return VersionSpecifier.evr_dict_to_str(self._evr_ver_dict)

    @property
    def evr_ver(self):
        return VersionSpecifier.evr_dict_to_str(self._evr_ver_dict, True)

    @property
    def ev_ver(self):
        return VersionSpecifier.evr_dict_to_str(self._evr_ver_dict, True).split("-")[0]

    @property
    def title(self):
        return '{0} {1}'.format(comparison_to_oval(self.op), self.ver)

    @property
    def cpe_id(self):
        return '{0}:{1}'.format(escape_comparison(self.op), self.ver)

    @property
    def oval_id(self):
        return '{0}_{1}'.format(escape_comparison(self.op), escape_id(self.ver))

    @staticmethod
    def evr_dict_to_str(evr, fully_formed_evr_string=False):
        """
        Convert an EVR (Epoch-Version-Release) dictionary to a string representation.

        Args:
            evr (dict): A dictionary containing 'epoch', 'version', and 'release' keys.
                        'epoch' and 'release' can be None.
            fully_formed_evr_string (bool): If True, ensures that the returned string includes '0'
                                            for missing 'epoch' and '-0' for missing 'release'.

        Returns:
            str: The string representation of the EVR dictionary.
        """
        res = ''
        if evr['epoch'] is not None:
            res += evr['epoch'] + ':'
        elif fully_formed_evr_string:
            res += '0:'
        res += evr['version']
        if evr['release'] is not None:
            res += '-' + evr['release']
        elif fully_formed_evr_string:
            res += '-0'
        return res


def map_name(version):
    """
    Maps SSG Makefile internal product name to official product name.

    This function takes a version string and maps it to an official product name based on
    predefined mappings. It handles multi-platform versions by trimming the "multi_platform_"
    prefix and recursively mapping the trimmed version.

    Args:
        version (str): The version string to be mapped.

    Returns:
        str: The official product name corresponding to the given version.

    Raises:
        RuntimeError: If the version is invalid or cannot be mapped to any known product.
    """
    if version.startswith("multi_platform_"):
        trimmed_version = version[len("multi_platform_"):]
        if trimmed_version not in MULTI_PLATFORM_LIST:
            raise RuntimeError(
                "%s is an invalid product version. If it's multi_platform the "
                "suffix has to be from (%s)."
                % (version, ", ".join(MULTI_PLATFORM_LIST))
            )
        return map_name(trimmed_version)

    # By sorting in reversed order, keys which are a longer version of other keys are
    # visited first (e.g., rhosp vs. rhel)
    for key in sorted(MAKEFILE_ID_TO_PRODUCT_MAP, reverse=True):
        if version.startswith(key):
            return MAKEFILE_ID_TO_PRODUCT_MAP[key]

    raise RuntimeError("Can't map version '%s' to any known product!"
                       % (version))


def product_to_name(prod):
    """
    Converts a product identifier into a full product name.

    This function takes a product identifier and attempts to match it with a full product name
    from the `FULL_NAME_TO_PRODUCT_MAPPING` dictionary. If the product identifier is found in
    the dictionary, the corresponding full product name is returned. If the product identifier
    is in the `MULTI_PLATFORM_LIST` or is 'all', a string prefixed with "multi_platform_" is
    returned. If the product identifier is not recognized, a RuntimeError is raised.

    Args:
        prod (str): The product identifier to convert.

    Returns:
        str: The full product name corresponding to the given product identifier.

    Raises:
        RuntimeError: If the product identifier is not recognized.
    """
    for name, prod_type in FULL_NAME_TO_PRODUCT_MAPPING.items():
        if prod == prod_type:
            return name
    if prod in MULTI_PLATFORM_LIST or prod == 'all':
        return "multi_platform_" + prod
    raise RuntimeError("Unknown product name: %s" % prod)


def name_to_platform(names):
    """
    Converts one or more full names to a string containing one or more <platform> elements.

    Args:
        names (str or list of str): A single name as a string or a list of names.

    Returns:
        str: A string containing one or more <platform> elements.
    """
    if isinstance(names, str):
        return "<platform>%s</platform>" % names
    return "\n".join(map(name_to_platform, names))


def product_to_platform(prods):
    """
    Converts one or more product ids into a string with one or more <platform> elements.

    Args:
        prods (str or list of str): A single product id as a string or a list of product ids.

    Returns:
        str: A string containing one or more <platform> elements.
    """
    if isinstance(prods, str):
        return name_to_platform(product_to_name(prods))
    return "\n".join(map(product_to_platform, prods))


def parse_name(product):
    """
    Parses a given product string and returns a namedtuple containing the name and version.

    Args:
        product (str): The product string to parse, e.g., "rhel9".

    Returns:
        namedtuple: A namedtuple with 'name' and 'version' attributes, e.g., ("rhel", "9").

    Example:
        >>> parse_name("rhel9")
        product(name='rhel', version='9')
    """
    prod_tuple = namedtuple('product', ['name', 'version'])

    _product = product
    _product_version = None
    match = PRODUCT_NAME_PARSER.match(product)

    if match:
        _product = match.group(1)
        _product_version = match.group(2)

    return prod_tuple(_product, _product_version)


def parse_platform(platform):
    """
    Parses a comma-separated string of platforms and returns a set of trimmed platform names.

    Args:
        platform (str): A comma-separated string of platform names.

    Returns:
        set: A set of platform names with leading and trailing whitespace removed.
    """
    return set(map(lambda x: x.strip(), platform.split(',')))


def get_fixed_product_version(product, product_version):
    """
    Adjusts the product version format for specific products.

    Some product versions have a dot in between the numbers while the product ID doesn't have the
    dot, but the full product name does. This function ensures the correct format for the product
    version.

    Args:
        product (str): The name of the product (e.g., "ubuntu", "macos").
        product_version (str): The version of the product as a string.

    Returns:
        str: The adjusted product version with the correct format.
    """
    if product == "ubuntu" or product == "macos":
        product_version = product_version[:2] + "." + product_version[2:]
    return product_version


def is_applicable_for_product(platform, product):
    """
    Determines if a remediation script is applicable for a given product based on the platform specifier.

    The function checks if the platform is either a general multi-platform specifier or matches
    the specific product name and version.

    Args:
        platform (str): The platform specifier of the remediation script.
        product (str): The product name and version.

    Returns:
        bool: True if the remediation script is applicable for the product, False otherwise.
    """
    # If the platform is None, platform must not exist in the config, so return False.
    if not platform:
        return False

    product, product_version = parse_name(product)

    # Define general platforms
    multi_platforms = ['multi_platform_all',
                       'multi_platform_' + product]

    # First test if platform isn't for 'multi_platform_all' or 'multi_platform_' + product
    for _platform in multi_platforms:
        if _platform in platform and product in MULTI_PLATFORM_LIST:
            return True

    product_name = ""
    # Get official name for product
    if product_version is not None:
        product_name = map_name(product) + ' ' + get_fixed_product_version(
            product, product_version
        )
    else:
        product_name = map_name(product)

    # Test if this is for the concrete product version
    for _name_part in platform.split(','):
        if product_name == _name_part.strip():
            return True

    # Remediation script isn't neither a multi platform one, nor isn't
    # applicable for this product => return False to indicate that
    return False


def is_applicable(platform, product):
    """
    Check if a platform is applicable for the given product.

    This function determines whether a specified platform or a list of platforms is applicable
    for a given product. It handles cases where the platform is specified as 'all' or
    'multi_platform_all', as well as cases where the platform is a comma-separated list of
    products.

    Args:
        platform (str): The platform or list of platforms to check.
        product (str): The product to check applicability for.

    Returns:
        bool: True if the product is applicable for the platform or list of platforms, False otherwise.
    """
    if platform == 'all' or platform == 'multi_platform_all':
        return True

    if is_applicable_for_product(platform, product):
        return True

    if 'osp7' in product and 'osp7' in platform:
        return True

    return product in platform.split(',')


def required_key(_dict, _key):
    """
    Returns the value associated with the specified key in the given dictionary.

    Parameters:
        _dict (dict): The dictionary to search for the key.
        _key: The key to look for in the dictionary.

    Returns:
        The value associated with the specified key in the dictionary.

    Raises:
        ValueError: If the key is not found in the dictionary, an exception is raised with a
                    message indicating that the key is required but was not found.
    """
    if _key in _dict:
        return _dict[_key]

    raise ValueError("%s is required but was not found in:\n%s" %
                     (_key, repr(_dict)))


def get_cpu_count():
    """
    Returns the most likely estimate of the number of CPUs in the machine for threading purposes,
    gracefully handling errors and possible exceptions.

    Returns:
        int: The number of CPUs available. If the number of CPUs cannot be determined, returns 2
             as a default value.
    """
    try:
        return max(1, multiprocessing.cpu_count())

    except NotImplementedError:
        return 2


def merge_dicts(left, right):
    """
    Merges two dictionaries, keeping left and right as passed.

    If there are any common keys between left and right, the value from right is used.

    Args:
        left (dict): The first dictionary.
        right (dict): The second dictionary.

    Returns:
        dict: The merged dictionary containing keys and values from both left and right dictionaries.
    """
    result = left.copy()
    result.update(right)
    return result


def subset_dict(dictionary, keys):
    """
    Restricts a dictionary to only include specified keys.

    This function creates a new dictionary that contains only the key-value pairs from the
    original dictionary where the key is present in the provided list of keys. Neither the
    original dictionary nor the list of keys is modified.

    Args:
        dictionary (dict): The original dictionary from which to create the subset.
        keys (iterable): An iterable of keys that should be included in the subset.

    Returns:
        dict: A new dictionary containing only the key-value pairs where the key is in the
              provided list of keys.
    """
    result = dictionary.copy()
    for original_key in dictionary:
        if original_key not in keys:
            del result[original_key]

    return result


def read_file_list(path):
    """
    Reads the given file path and returns the contents as a list.

    Args:
        path (str): The path to the file to be read.

    Returns:
        list: A list containing the contents of the file, split by lines or other delimiters as
              defined by `split_string_content`.

    Raises:
        FileNotFoundError: If the file at the given path does not exist.
        IOError: If an I/O error occurs while reading the file.
    """
    with open(path, 'r') as f:
        return split_string_content(f.read())


def split_string_content(content):
    """
    Splits the input string content by newline characters and returns the result as a list of strings.

    Args:
        content (str): The string content to be split.

    Returns:
        list: A list of strings, each representing a line from the input content.
              The last element will be removed if it is an empty string.
    """
    file_contents = content.split("\n")
    if file_contents[-1] == '':
        file_contents = file_contents[:-1]
    return file_contents


def write_list_file(path, contents):
    """
    Writes the given contents to the specified file path.

    Args:
        path (str): The file path where the contents will be written.
        contents (list of str): A list of strings to be written to the file.

    Returns:
        None
    """
    _contents = "\n".join(contents) + "\n"
    _f = open(path, 'w')
    _f.write(_contents)
    _f.flush()
    _f.close()


# Taken from https://stackoverflow.com/a/600612/592892
def mkdir_p(path):
    """
    Create a directory and all intermediate-level directories if they do not exist.

    Args:
        path (str): The directory path to create.

    Returns:
        bool: True if the directory was created, False if it already exists.

    Raises:
        OSError: If the directory cannot be created and it does not already exist.
    """
    if os.path.isdir(path):
        return False
    # Python >=3.4.1
    # os.makedirs(path, exist_ok=True)
    try:
        os.makedirs(path)
        return True
    except OSError as exc:  # Python >2.5
        if exc.errno == errno.EEXIST and os.path.isdir(path):
            return False
        else:
            raise


def escape_regex(text):
    """
    Escapes special characters in a given text to make it safe for use in regular expressions.

    This function mimics the behavior of re.escape() in Python 3.7, which escapes a reasonable set
    of characters.
    Specifically, it escapes the following characters: #, $, &, *, +, ., ^, `, |, ~, :, (, ), and -.
    Note that the characters '!', '"', '%', "'", ',', '/', ':', ';', '<', '=', '>', '@', and "`"
    are not escaped.

    Args:
        text (str): The input string containing characters to be escaped.

    Returns:
        str: A new string with special characters escaped.
    """
    # We could use re.escape(), but it escapes too many characters, including plain white space.
    # In python 3.7 the set of characters escaped by re.escape is reasonable, so lets mimic it.
    # See https://docs.python.org/3/library/re.html#re.sub
    # '!', '"', '%', "'", ',', '/', ':', ';', '<', '=', '>', '@', and "`" are not escaped.
    return re.sub(r"([#$&*+.^`|~:()\[\]-])", r"\\\1", text)


def escape_id(text):
    """
    Converts a given text into a string that is more readable and compatible with OSCAP/XCCDF/OVAL
    entity IDs by replacing non-word characters with underscores and stripping leading/trailing
    underscores.

    Args:
        text (str): The input string to be converted.

    Returns:
        str: The converted string with non-word characters replaced by underscores and
             leading/trailing underscores removed.
    """
    # Make a string used as an Id for OSCAP/XCCDF/OVAL entities more readable
    # and compatible with:
    # OVAL: r'oval:[A-Za-z0-9_\-\.]+:ste:[1-9][0-9]*'
    return re.sub(r"[^\w]+", "_", text).strip("_")


def escape_yaml_key(text):
    """
    Escapes uppercase letters and caret symbols in a YAML key by prefixing them with a caret
    and converts the entire key to lowercase.

    This function is used to handle the limitation of OVAL's name argument of the field type,
    which requires avoiding uppercase letters for keys. The probe would escape them with the
    '^' symbol.

    Example:
        myCamelCase^Key -> my^camel^case^^^key

    Args:
        text (str): The YAML key to be escaped.

    Returns:
        str: The escaped and lowercased YAML key.
    """
    return re.sub(r'([A-Z^])', '^\\1', text).lower()


def _map_comparison_op(op, table):
    """
    Maps a comparison operator to its corresponding function or value from a given table.

    Args:
        op (str): The comparison operator to be mapped.
        table (dict): A dictionary where keys are comparison operators and values are the
                      corresponding functions or values.

    Returns:
        The function or value corresponding to the given comparison operator.

    Raises:
        KeyError: If the given comparison operator is not found in the table.
    """
    if op not in table:
        raise KeyError("Invalid comparison operator: %s (expected one of: %s)",
                       op, ', '.join(table.keys()))
    return table[op]


def escape_comparison(op):
    """
    Maps a comparison operator to its corresponding string representation.

    Args:
        op (str): The comparison operator to be mapped.
                  Expected values are '==', '!=', '>', '<', '>=', '<='.

    Returns:
        str: The string representation of the comparison operator.
             Possible return values are 'eq', 'ne', 'gt', 'le', 'gt_or_eq', 'le_or_eq'.

    Raises:
        KeyError: If the provided operator is not in the mapping dictionary.
    """
    return _map_comparison_op(op, {
        '==': 'eq',       '!=': 'ne',
        '>': 'gt',        '<': 'le',
        '>=': 'gt_or_eq', '<=': 'le_or_eq',
    })


def comparison_to_oval(op):
    """
    Converts a comparison operator to its corresponding OVAL string representation.

    Args:
        op (str): The comparison operator to convert.
                  Expected values are '==', '!=', '>', '<', '>=', '<='.

    Returns:
        str: The OVAL string representation of the comparison operator.

    Raises:
        KeyError: If the provided operator is not one of the expected values.
    """
    return _map_comparison_op(op, {
        '==': 'equals',                '!=': 'not equal',
        '>': 'greater than',           '<': 'less than',
        '>=': 'greater than or equal', '<=': 'less than or equal',
    })


def sha256(text):
    """
    Generate a SHA-256 hash for the given text.

    Args:
        text (str): The input text to be hashed.

    Returns:
        str: The SHA-256 hash of the input text as a hexadecimal string.
    """
    return hashlib.sha256(text.encode('utf-8')).hexdigest()


def banner_regexify(banner_text):
    """
    Converts a banner text into a regex pattern.

    This function escapes special regex characters in the input text and then performs the
    following transformations:
    - Replaces newline characters ("\n") with a placeholder string "BFLMPSVZ".
    - Replaces spaces with a regex pattern that matches one or more whitespace characters or
      newline characters.
    - Replaces the placeholder string "BFLMPSVZ" with a regex pattern that matches one or more
      newline characters or escaped newline sequences.

    Args:
        banner_text (str): The banner text to be converted into a regex pattern.

    Returns:
        str: The resulting regex pattern.
    """
    return escape_regex(banner_text) \
        .replace("\n", "BFLMPSVZ") \
        .replace(" ", "[\\s\\n]+") \
        .replace("BFLMPSVZ", "(?:[\\n]+|(?:\\\\n)+)")


def banner_anchor_wrap(banner_text):
    """
    Wraps the given banner text with '^' at the beginning and '$' at the end.

    Args:
        banner_text (str): The text to be wrapped.

    Returns:
        str: The banner text wrapped with '^' at the beginning and '$' at the end.
    """
    return "^" + banner_text + "$"


def parse_template_boolean_value(data, parameter, default_value):
    """
    Parses a boolean value from a template parameter.

    Args:
        data (dict): The dictionary containing the template data.
        parameter (str): The key for the parameter to parse.
        default_value (bool): The default value to return if the parameter is not found or is None.

    Returns:
        bool: The parsed boolean value.

    Raises:
        ValueError: If the parameter value is not "true" or "false".
    """
    value = data.get(parameter)
    if not value:
        return default_value
    if value == "true":
        return True
    elif value == "false":
        return False
    else:
        raise ValueError(
            "Template parameter {} used in rule {} cannot accept the "
            "value {}".format(parameter, data["_rule_id"], value))


def check_conflict_regex_directory(data):
    """
    Validate that either all paths are directories or the 'file_regex' key exists.

    This function checks the following conditions:
    1. If the 'is_directory' key is present in the data dictionary, it ensures that all file paths
       in the 'filepath' list are either directories or files. Mixing directories and files is not
       allowed.
    2. If the 'file_regex' key is present in the data dictionary, it ensures that all file paths
       in the 'filepath' list are directories.

    Args:
        data (dict): A dictionary containing the following keys:
            - 'filepath' (list): A list of file paths to be validated.
            - 'is_directory' (bool, optional): A flag indicating whether the paths are directories.
            - 'file_regex' (str, optional): A regular expression pattern for file matching.
            - '_rule_id' (str): An identifier for the rule being validated.

    Raises:
        ValueError: If the file paths are a mix of directories and files, or if the 'file_regex' key
                    is used but the file paths are not directories.
    """
    for f in data["filepath"]:
        if "is_directory" in data and data["is_directory"] != f.endswith("/"):
            raise ValueError(
                "If passing a list of filepaths, all of them need to be "
                "either directories or files. Mixing is not possible. "
                "Please fix rules '{0}' filepath '{1}'".format(data["_rule_id"], f))

        data["is_directory"] = f.endswith("/")

        if "file_regex" in data and not data["is_directory"]:
            raise ValueError(
                "Used 'file_regex' key in rule '{0}' but filepath '{1}' does not "
                "specify a directory. Append '/' to the filepath or remove the "
                "'file_regex' key.".format(data["_rule_id"], f))


def enum(*args):
    """
    Creates an enumeration with the given arguments.

    Args:
        *args: A variable length argument list of strings representing the names of the
               enumeration members.

    Returns:
        type: A new enumeration type with the given member names as attributes, each assigned a
              unique integer value starting from 0.

    Example:
        >>> Colors = enum('RED', 'GREEN', 'BLUE')
        >>> Colors.RED
        0
        >>> Colors.GREEN
        1
        >>> Colors.BLUE
        2
    """
    enums = dict(zip(args, range(len(args))))
    return type('Enum', (), enums)


def recurse_or_substitute_or_do_nothing(v, string_dict, ignored_keys=frozenset()):
    """
    Recursively applies string formatting to dictionary values, substitutes strings, or returns
    the value unchanged.

    Args:
        v (Any): The value to process. Can be a dictionary, string, or any other type.
        string_dict (dict): A dictionary containing string keys and values to be used for formatting.
        ignored_keys (frozenset, optional): A set of keys to ignore when processing dictionaries.
                                            Defaults to an empty frozenset.

    Returns:
        Any: The processed value. If `v` is a dictionary, returns a dictionary with formatted values.
             If `v` is a string, returns the formatted string. Otherwise, returns `v` unchanged.
    """
    if isinstance(v, dict):
        return apply_formatting_on_dict_values(v, string_dict, ignored_keys)
    elif isinstance(v, str):
        return v.format(**string_dict)
    else:
        return v


def apply_formatting_on_dict_values(source_dict, string_dict, ignored_keys=frozenset()):
    """
    Apply string formatting on dictionary values.

    This function uses Python's built-in string replacement to replace strings marked by {token}
    if "token" is a key in the string_dict parameter. It skips keys in source_dict which are
    listed in the ignored_keys parameter. This function works only for dictionaries whose values
    are dictionaries or strings.

    Args:
        source_dict (dict): The source dictionary whose values need formatting.
        string_dict (dict): A dictionary containing replacement strings for tokens.
        ignored_keys (frozenset, optional): A set of keys to be ignored during formatting.
                                            Defaults to an empty frozenset.

    Returns:
    dict: A new dictionary with formatted values.
   """
    new_dict = {}
    for k, v in source_dict.items():
        if k not in ignored_keys:
            new_dict[k] = recurse_or_substitute_or_do_nothing(
                v, string_dict, ignored_keys)
        else:
            new_dict[k] = v
    return new_dict


def ensure_file_paths_and_file_regexes_are_correctly_defined(data):
    """
    Ensures that the data structure for file paths and file regexes is correctly defined.

    This function is used for the file_owner, file_groupowner, and file_permissions templates.
    It ensures that:
    - The 'filepath' item in the data is a list.
    - The number of items in 'file_regex' matches the number of items in 'filepath'.

    Note:
        - If 'filepath' is a string, it will be converted to a list containing that string.
        - If 'file_regex' is a string, it will be converted to a list with the same length as
          'filepath', with each element being the original 'file_regex' string.
        - If there are multiple regexes for a single filepath, the filepath must be declared
          multiple times.

    Args:
        data (dict): A dictionary containing file path and file regex information.
                     It must contain the keys:
                     - 'filepath': A string or list of strings representing file paths.
                     - 'file_regex' (optional): A string or list of strings representing file regexes.
                     - '_rule_id': A string representing the rule ID.

    Raises:
        ValueError: If the number of items in 'file_regex' does not match the number of items in 'filepath'.
    """
    # this avoids code duplicates
    if isinstance(data["filepath"], str):
        data["filepath"] = [data["filepath"]]

    if "file_regex" in data:
        # we can have a list of filepaths, but only one regex
        # instead of declaring the same regex multiple times
        if isinstance(data["file_regex"], str):
            data["file_regex"] = [data["file_regex"]] * len(data["filepath"])

        # if the length of filepaths and file_regex are not the same, then error.
        # in case we have multiple regexes for just one filepath, than we need
        # to declare that filepath multiple times
        if len(data["filepath"]) != len(data["file_regex"]):
            raise ValueError(
                "You should have one file_path per file_regex. Please check "
                "rule '{0}'".format(data["_rule_id"]))

    check_conflict_regex_directory(data)
