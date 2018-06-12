import datetime
import platform
import re
import codecs
import jinja2
import os.path
import yaml

try:
    from yaml import CSafeLoader as yaml_SafeLoader
except ImportError:
    from yaml import SafeLoader as yaml_SafeLoader


def bool_constructor(self, node):
    return self.construct_scalar(node)


# Don't follow python bool case
yaml_SafeLoader.add_constructor(u'tag:yaml.org,2002:bool', bool_constructor)


try:
    from xml.etree import cElementTree as ElementTree
except ImportError:
    import cElementTree as ElementTree


JINJA_MACROS_DEFINITIONS = os.path.join(os.path.dirname(__file__), "macros.jinja")

xml_version = """<?xml version="1.0" encoding="UTF-8"?>"""

datastream_namespace = "http://scap.nist.gov/schema/scap/source/1.2"
ocil_namespace = "http://scap.nist.gov/schema/ocil/2.0"
oval_footer = "</oval_definitions>"
oval_namespace = "http://oval.mitre.org/XMLSchema/oval-definitions-5"
ocil_cs = "http://scap.nist.gov/schema/ocil/2"
xccdf_header = xml_version + "<xccdf>"
xccdf_footer = "</xccdf>"
bash_system = "urn:xccdf:fix:script:sh"
ansible_system = "urn:xccdf:fix:script:ansible"
puppet_system = "urn:xccdf:fix:script:puppet"
anaconda_system = "urn:redhat:anaconda:pre"
cce_uri = "https://nvd.nist.gov/cce/index.cfm"
stig_ns = "http://iase.disa.mil/stigs/Pages/stig-viewing-guidance.aspx"
ssg_version_uri = \
    "https://github.com/OpenSCAP/scap-security-guide/releases/latest"
OSCAP_VENDOR = "org.ssgproject"
OSCAP_DS_STRING = "xccdf_%s.content_benchmark_" % OSCAP_VENDOR
OSCAP_GROUP = "xccdf_%s.content_group_" % OSCAP_VENDOR
OSCAP_GROUP_PCIDSS = "xccdf_%s.content_group_pcidss-req" % OSCAP_VENDOR
OSCAP_GROUP_VAL = "xccdf_%s.content_group_values" % OSCAP_VENDOR
OSCAP_GROUP_NON_PCI = "xccdf_%s.content_group_non-pci-dss" % OSCAP_VENDOR
XCCDF11_NS = "http://checklists.nist.gov/xccdf/1.1"
XCCDF12_NS = "http://checklists.nist.gov/xccdf/1.2"
min_ansible_version = "2.3"
ansible_version_requirement_pre_task_name = \
    "Verify Ansible meets SCAP-Security-Guide version requirements."

oval_header = (
    """
<oval_definitions
    xmlns="{0}"
    xmlns:oval="http://oval.mitre.org/XMLSchema/oval-common-5"
    xmlns:ind="{0}#independent"
    xmlns:unix="{0}#unix"
    xmlns:linux="{0}#linux"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://oval.mitre.org/XMLSchema/oval-common-5 oval-common-schema.xsd
        {0} oval-definitions-schema.xsd
        {0}#independent independent-definitions-schema.xsd
        {0}#unix unix-definitions-schema.xsd
        {0}#linux linux-definitions-schema.xsd">"""
    .format(oval_namespace))


timestamp = datetime.datetime.utcnow().strftime("%Y-%m-%dT%H:%M:%S")


PKG_MANAGER_TO_SYSTEM = {
    "yum": "rpm",
    "zypper": "rpm",
    "dnf": "rpm",
    "apt_get": "dpkg",
}


class SSGError(RuntimeError):
    pass


def oval_generated_header(product_name, schema_version, ssg_version):
    return xml_version + oval_header + \
        """
    <generator>
        <oval:product_name>%s from SCAP Security Guide</oval:product_name>
        <oval:product_version>ssg: %s, python: %s</oval:product_version>
        <oval:schema_version>%s</oval:schema_version>
        <oval:timestamp>%s</oval:timestamp>
    </generator>""" % (product_name, ssg_version, platform.python_version(),
                       schema_version, timestamp)


def get_check_content_ref_if_exists_and_not_remote(check):
    """
    Given an OVAL check element, examine the ``xccdf_ns:check-content-ref``

    If it exists and it isn't remote, pass it as the return value.
    Otherwise, return None.

    ..see-also:: check_content_href_is_remote
    """
    checkcontentref = check.find("./{%s}check-content-ref" % XCCDF11_NS)
    if checkcontentref is None:
        return None
    if check_content_href_is_remote(checkcontentref):
        return None
    else:
        return checkcontentref


def check_content_href_is_remote(check_content_ref):
    """
    Given an OVAL check-content-ref element, examine the 'href' attribute.

    If it starts with 'http://' or 'https://', return True, otherwise return False.

    Raises RuntimeError if the ``href`` element doesn't exist.
    """
    hrefattr = check_content_ref.get("href")
    if hrefattr is None:
        # @href attribute of <check-content-ref> is required by XCCDF standard
        msg = "Invalid OVAL <check-content-ref> detected - missing the 'href' attribute!"
        raise RuntimeError(msg)

    return hrefattr.startswith("http://") or hrefattr.startswith("https://")


def parse_xml_file(filename):
    """
    Given a filename, return the corresponding ElementTree
    """
    with open(filename, 'r') as xml_file:
        filestring = xml_file.read()
        tree = ElementTree.fromstring(filestring)
    return tree


def cce_is_valid(cceid):
    """
    IF CCE ID IS IN VALID FORM (either 'CCE-XXXX-X' or 'CCE-XXXXX-X'
    where each X is a digit, and the final X is a check-digit)
    based on Requirement A17:

    http://people.redhat.com/swells/nist-scap-validation/scap-val-requirements-1.2.html
    """
    match = re.match(r'^CCE-\d{4,5}-\d$', cceid)
    return match is not None


def map_elements_to_their_ids(tree, xpath_expr):
    """
    Given an ElementTree and an XPath expression,
    iterate through matching elements and create 1:1 id->element mapping.

    Raises AssertionError if a matching element doesn't have the ``id`` attribute.

    Returns mapping as a dictionary
    """
    aggregated = {}
    for element in tree.findall(xpath_expr):
        element_id = element.get("id")
        assert element_id is not None
        aggregated[element_id] = element
    return aggregated


class AbsolutePathFileSystemLoader(jinja2.BaseLoader):
    """Loads templates from the file system. This loader insists on absolute
    paths and fails if a relative path is provided.

    >>> loader = AbsolutePathFileSystemLoader()

    Per default the template encoding is ``'utf-8'`` which can be changed
    by setting the `encoding` parameter to something else.
    """

    def __init__(self, encoding='utf-8'):
        self.encoding = encoding

    def get_source(self, environment, template):
        if not os.path.isabs(template):
            raise jinja2.TemplateNotFound(template)

        f = jinja2.utils.open_if_exists(template)
        if f is None:
            raise jinja2.TemplateNotFound(template)
        try:
            contents = f.read().decode(self.encoding)
        finally:
            f.close()

        mtime = os.path.getmtime(template)

        def uptodate():
            try:
                return os.path.getmtime(template) == mtime
            except OSError:
                return False
        return contents, template, uptodate


def get_jinja_environment(substitutions_dict):
    if get_jinja_environment.env is None:
        bytecode_cache = None
        if required_yaml_key(substitutions_dict, "jinja2_cache_enabled") == "true":
            bytecode_cache = jinja2.FileSystemBytecodeCache(
                required_yaml_key(substitutions_dict, "jinja2_cache_dir")
            )

        # TODO: Choose better syntax?
        get_jinja_environment.env = jinja2.Environment(
            block_start_string="{{%",
            block_end_string="%}}",
            variable_start_string="{{{",
            variable_end_string="}}}",
            comment_start_string="{{#",
            comment_end_string="#}}",
            loader=AbsolutePathFileSystemLoader(),
            bytecode_cache=bytecode_cache
        )

    return get_jinja_environment.env


get_jinja_environment.env = None


def process_file_with_jinja(filepath, substitutions_dict):
    template = get_jinja_environment(substitutions_dict).get_template(filepath)
    return template.render(substitutions_dict)


def _open_yaml(stream):
    """
    Open given file-like object and parse it as YAML
    Return None if it contains "documentation_complete" key set to "false".
    """
    yaml_contents = yaml.load(stream, Loader=yaml_SafeLoader)

    if yaml_contents.pop("documentation_complete", "true") == "false":
        return None

    return yaml_contents


def open_and_expand_yaml(yaml_file, substitutions_dict=None):
    """
    Process the file as a template, using substitutions_dict to perform expansion.
    Then, process the expansion result as a YAML content.

    See also: _open_yaml
    """
    if substitutions_dict is None:
        substitutions_dict = dict()

    expanded_template = process_file_with_jinja(yaml_file, substitutions_dict)
    yaml_contents = _open_yaml(expanded_template)
    return yaml_contents


def _extract_substitutions_dict_from_template(filename, substitutions_dict):
    template = get_jinja_environment(substitutions_dict).get_template(filename)
    all_symbols = template.make_module().__dict__
    symbols_to_export = dict()
    for name, symbol in all_symbols.items():
        if name.startswith("_"):
            continue
        symbols_to_export[name] = symbol
    return symbols_to_export


def rename_items(original_dict, renames):
    renamed_macros = dict()
    for rename_from, rename_to in renames.items():
        if rename_from in original_dict:
            renamed_macros[rename_to] = original_dict[rename_from]
    return renamed_macros


def get_implied_properties(existing_properties):
    result = dict()
    if ("pkg_manager" in existing_properties
            and "pkg_system" not in existing_properties):
        result["pkg_system"] = PKG_MANAGER_TO_SYSTEM[existing_properties["pkg_manager"]]
    return result


def _save_rename(result, stem, prefix):
    result["{0}_{1}".format(prefix, stem)] = stem


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
        _save_rename(result, "complete_ocil_entry_socket_and_service_disabled", init_system)

    return result


def open_and_macro_expand_yaml(yaml_file, substitutions_dict=None):
    """
    Do the same as open_and_expand_yaml, but load definitions of macros
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
    special_macros = rename_items(macro_definitions, mapping)
    substitutions_dict.update(macro_definitions)
    substitutions_dict.update(special_macros)
    return open_and_expand_yaml(yaml_file, substitutions_dict)


def open_yaml(yaml_file):
    """
    Open given file-like object and parse it as YAML
    without performing any kind of template processing

    See also: _open_yaml
    """
    with codecs.open(yaml_file, "r", "utf8") as stream:
        yaml_contents = _open_yaml(stream)
    return yaml_contents


def open_environment_yamls(build_config_yaml, product_yaml):
    contents = open_yaml(build_config_yaml)
    contents.update(open_yaml(product_yaml))
    contents.update(get_implied_properties(contents))
    return contents


def required_yaml_key(yaml_contents, key):
    if key in yaml_contents:
        return yaml_contents[key]

    raise ValueError("%s is required but was not found in:\n%s" %
                     (key, repr(yaml_contents)))
