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
                        MULTI_PLATFORM_MAPPING)


class SSGError(RuntimeError):
    pass


PRODUCT_NAME_PARSER = re.compile(r"([a-zA-Z\-]+)([0-9]+)")


class VersionSpecifierSet(set):
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
    """Maps SSG Makefile internal product name to official product name"""

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


def prodtype_to_name(prod):
    """
    Converts a vaguely-prodtype-like thing into one or more full product names.
    """
    for name, prod_type in FULL_NAME_TO_PRODUCT_MAPPING.items():
        if prod == prod_type:
            return name
    if prod in MULTI_PLATFORM_LIST or prod == 'all':
        return "multi_platform_" + prod
    raise RuntimeError("Unknown product name: %s" % prod)


def name_to_platform(names):
    """
    Converts one or more full names to a string containing one or more
    <platform> elements.
    """
    if isinstance(names, str):
        return "<platform>%s</platform>" % names
    return "\n".join(map(name_to_platform, names))


def prodtype_to_platform(prods):
    """
    Converts one or more prodtypes into a string with one or more <platform>
    elements.
    """
    if isinstance(prods, str):
        return name_to_platform(prodtype_to_name(prods))
    return "\n".join(map(prodtype_to_platform, prods))


def parse_name(product):
    """
    Returns a namedtuple of (name, version) from parsing a given product;
    e.g., "rhel7" -> ("rhel", "7")
    """

    prod_tuple = namedtuple('product', ['name', 'version'])

    _product = product
    _product_version = None
    match = PRODUCT_NAME_PARSER.match(product)

    if match:
        _product = match.group(1)
        _product_version = match.group(2)

    return prod_tuple(_product, _product_version)


def is_applicable_for_product(platform, product):
    """Based on the platform dict specifier of the remediation script to
    determine if this remediation script is applicable for this product.
    Return 'True' if so, 'False' otherwise"""

    # If the platform is None, platform must not exist in the config, so exit with False.
    if not platform:
        return False

    product, product_version = parse_name(product)

    # Define general platforms
    multi_platforms = ['multi_platform_all',
                       'multi_platform_' + product]

    # First test if platform isn't for 'multi_platform_all' or
    # 'multi_platform_' + product
    for _platform in multi_platforms:
        if _platform in platform and product in MULTI_PLATFORM_LIST:
            return True

    product_name = ""
    # Get official name for product
    if product_version is not None:
        if product == "ubuntu" or product == "macos":
            product_version = product_version[:2] + "." + product_version[2:]
        product_name = map_name(product) + ' ' + product_version
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
    Function to check if a platform is applicable for the product.
    Handles when a platform is really a list of products, i.e., a
    prodtype field from a rule.yml.

    Returns true iff product is applicable for the platform or list
    of products
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
    Returns the value of _key if it is in _dict; otherwise, raise an
    exception stating that it was not found but is required.
    """

    if _key in _dict:
        return _dict[_key]

    raise ValueError("%s is required but was not found in:\n%s" %
                     (_key, repr(_dict)))


def get_cpu_count():
    """
    Returns the most likely estimate of the number of CPUs in the machine
    for threading purposes, gracefully handling errors and possible
    exceptions.
    """

    try:
        return max(1, multiprocessing.cpu_count())

    except NotImplementedError:
        # 2 CPUs is the most probable
        return 2


def merge_dicts(left, right):
    """
    Merges two dictionaries, keeing left and right as passed. If there are any
    common keys between left and right, the value from right is use.

    Returns the merger of the left and right dictionaries
    """
    result = left.copy()
    result.update(right)
    return result


def subset_dict(dictionary, keys):
    """
    Restricts dictionary to only have keys from keys. Does not modify either
    dictionary or keys, returning the result instead.
    """

    result = dictionary.copy()
    for original_key in dictionary:
        if original_key not in keys:
            del result[original_key]

    return result


def read_file_list(path):
    """
    Reads the given file path and returns the contents as a list.
    """

    with open(path, 'r') as f:
        return split_string_content(f.read())


def split_string_content(content):
    """
    Split the string content and returns as a list.
    """

    file_contents = content.split("\n")
    if file_contents[-1] == '':
        file_contents = file_contents[:-1]
    return file_contents


def write_list_file(path, contents):
    """
    Writes the given contents to path.
    """

    _contents = "\n".join(contents) + "\n"
    _f = open(path, 'w')
    _f.write(_contents)
    _f.flush()
    _f.close()


# Taken from https://stackoverflow.com/a/600612/592892
def mkdir_p(path):
    try:
        os.makedirs(path)
    except OSError as exc:  # Python >2.5
        if exc.errno == errno.EEXIST and os.path.isdir(path):
            pass
        else:
            raise


def escape_regex(text):
    # We could use re.escape(), but it escapes too many characters, including plain white space.
    # In python 3.7 the set of charaters escaped by re.escape is reasonable, so lets mimic it.
    # See https://docs.python.org/3/library/re.html#re.sub
    # '!', '"', '%', "'", ',', '/', ':', ';', '<', '=', '>', '@', and "`" are not escaped.
    return re.sub(r"([#$&*+-.^`|~:()])", r"\\\1", text)


def escape_id(text):
    # Make a string used as an Id for OSCAP/XCCDF/OVAL entities more readable
    # and compatible with:
    # OVAL: r'oval:[A-Za-z0-9_\-\.]+:ste:[1-9][0-9]*'
    return re.sub(r"[^\w]+", "_", text).strip("_")


def escape_yaml_key(text):
    # Due to the limitation of OVAL's name argument of the filed type
    # we have to avoid using uppercase letters for keys. The probe would escape
    # them with '^' symbol.
    # myCamelCase^Key -> my^camel^case^^^key
    return re.sub(r'([A-Z^])', '^\\1', text).lower()


def _map_comparison_op(op, table):
    if op not in table:
        raise KeyError("Invalid comparison operator: %s (expected one of: %s)",
                       op, ', '.join(table.keys()))
    return table[op]


def escape_comparison(op):
    return _map_comparison_op(op, {
        '==': 'eq',       '!=': 'ne',
        '>': 'gt',        '<': 'le',
        '>=': 'gt_or_eq', '<=': 'le_or_eq',
    })


def comparison_to_oval(op):
    return _map_comparison_op(op, {
        '==': 'equals',                '!=': 'not equal',
        '>': 'greater than',           '<': 'less than',
        '>=': 'greater than or equal', '<=': 'less than or equal',
    })


def sha256(text):
    return hashlib.sha256(text.encode('utf-8')).hexdigest()


def banner_regexify(banner_text):
    return escape_regex(banner_text) \
        .replace("\n", "BFLMPSVZ") \
        .replace(" ", "[\\s\\n]+") \
        .replace("BFLMPSVZ", "(?:[\\n]+|(?:\\\\n)+)")


def banner_anchor_wrap(banner_text):
    return "^" + banner_text + "$"


def parse_template_boolean_value(data, parameter, default_value):
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
    Validate that either all path are directories OR file_regex exists.

    Throws ValueError.
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
    enums = dict(zip(args, range(len(args))))
    return type('Enum', (), enums)


def recurse_or_substitute_or_do_nothing(
        v, string_dict, ignored_keys=frozenset()):
    if isinstance(v, dict):
        return apply_formatting_on_dict_values(v, string_dict, ignored_keys)
    elif isinstance(v, str):
        return v.format(**string_dict)
    else:
        return v


def apply_formatting_on_dict_values(source_dict, string_dict, ignored_keys=frozenset()):
    """
    Uses Python built-in string replacement.
    It replaces strings marked by {token} if "token" is a key in the string_dict parameter.
    It skips keys in source_dict which are listed in ignored_keys parameter.
    This works only for dictionaries whose values are dicts or strings
    """
    new_dict = {}
    for k, v in source_dict.items():
        if k not in ignored_keys:
            new_dict[k] = recurse_or_substitute_or_do_nothing(
                v, string_dict, ignored_keys)
        else:
            new_dict[k] = v
    return new_dict
