from __future__ import absolute_import
from __future__ import print_function

import multiprocessing
import errno
import os
import re
from collections import namedtuple

from .constants import (FULL_NAME_TO_PRODUCT_MAPPING,
                        MAKEFILE_ID_TO_PRODUCT_MAP,
                        MULTI_PLATFORM_LIST,
                        MULTI_PLATFORM_MAPPING)


class SSGError(RuntimeError):
    pass


PRODUCT_NAME_PARSER = re.compile(r"([a-zA-Z\-]+)([0-9]+)")


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


def banner_regexify(banner_text):
    return escape_regex(banner_text) \
        .replace("\n", "BFLMPSVZ") \
        .replace(" ", "[\\s\\n]+") \
        .replace("BFLMPSVZ", "(?:[\\n]+|(?:\\\\n)+)")


def banner_anchor_wrap(banner_text):
    return "^" + banner_text + "$"
