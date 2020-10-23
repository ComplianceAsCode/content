from __future__ import absolute_import
from __future__ import print_function

import sys
import os
import os.path
import re
import codecs
from collections import defaultdict, namedtuple, OrderedDict

import ssg.yaml
from . import build_yaml
from . import rules
from . import utils

from . import constants
from .jinja import process_file_with_macros as jinja_process_file

from .xml import ElementTree

REMEDIATION_TO_EXT_MAP = {
    'anaconda': '.anaconda',
    'ansible': '.yml',
    'bash': '.sh',
    'puppet': '.pp',
    'ignition': '.yml',
    'kubernetes': '.yml'
}

PKG_MANAGER_TO_PACKAGE_CHECK_COMMAND = {
    'apt_get': 'dpkg-query -s {0} &>/dev/null',
    'dnf': 'rpm --quiet -q {0}',
    'yum': 'rpm --quiet -q {0}',
    'zypper': 'rpm --quiet -q {0}',
}

FILE_GENERATED_HASH_COMMENT = '# THIS FILE IS GENERATED'

REMEDIATION_CONFIG_KEYS = ['complexity', 'disruption', 'platform', 'reboot',
                           'strategy']
REMEDIATION_ELM_KEYS = ['complexity', 'disruption', 'reboot', 'strategy']


def get_available_functions(build_dir):
    """Parse the content of "$CMAKE_BINARY_DIR/bash-remediation-functions.xml"
    XML file to obtain the list of currently known SCAP Security Guide internal
    remediation functions"""

    # If location of /shared directory is known
    if build_dir is None or not os.path.isdir(build_dir):
        sys.stderr.write("Expected '%s' to be the build directory. It doesn't "
                         "exist or is not a directory." % (build_dir))
        sys.exit(1)

    # Construct the final path of XML file with remediation functions
    xmlfilepath = \
        os.path.join(build_dir, "bash-remediation-functions.xml")

    if not os.path.isfile(xmlfilepath):
        sys.stderr.write("Expected '%s' to contain the remediation functions. "
                         "The file was not found!\n" % (xmlfilepath))
        sys.exit(1)

    remediation_functions = []
    with codecs.open(xmlfilepath, "r", encoding="utf-8") as xmlfile:
        filestring = xmlfile.read()
        # This regex looks implementation dependent but we can rely on the element attributes
        # being present. Beware, DOTALL means we go through the whole file at once.
        # We can't rely on ElementTree sorting XML attrs in any way since Python 3.7.
        remediation_functions = re.findall(
            r'<Value[^>]+id=\"function_(\S+)\"',
            filestring, re.DOTALL
        )

    return remediation_functions


def get_fixgroup_for_type(fixcontent, remediation_type):
    """
    For a given remediation type, return a new subelement of that type.

    Exits if passed an unknown remediation type.
    """
    if remediation_type == 'anaconda':
        return ElementTree.SubElement(
            fixcontent, "fix-group", id="anaconda",
            system="urn:redhat:anaconda:pre",
            xmlns="http://checklists.nist.gov/xccdf/1.1")

    elif remediation_type == 'ansible':
        return ElementTree.SubElement(
            fixcontent, "fix-group", id="ansible",
            system="urn:xccdf:fix:script:ansible",
            xmlns="http://checklists.nist.gov/xccdf/1.1")

    elif remediation_type == 'bash':
        return ElementTree.SubElement(
            fixcontent, "fix-group", id="bash",
            system="urn:xccdf:fix:script:sh",
            xmlns="http://checklists.nist.gov/xccdf/1.1")

    elif remediation_type == 'puppet':
        return ElementTree.SubElement(
            fixcontent, "fix-group", id="puppet",
            system="urn:xccdf:fix:script:puppet",
            xmlns="http://checklists.nist.gov/xccdf/1.1")

    elif remediation_type == 'ignition':
        return ElementTree.SubElement(
            fixcontent, "fix-group", id="ignition",
            system="urn:xccdf:fix:script:ignition",
            xmlns="http://checklists.nist.gov/xccdf/1.1")

    elif remediation_type == 'kubernetes':
        return ElementTree.SubElement(
            fixcontent, "fix-group", id="kubernetes",
            system="urn:xccdf:fix:script:kubernetes",
            xmlns="http://checklists.nist.gov/xccdf/1.1")

    sys.stderr.write("ERROR: Unknown remediation type '%s'!\n"
                     % (remediation_type))
    sys.exit(1)


def is_supported_filename(remediation_type, filename):
    """
    Checks if filename has a supported extension for remediation_type.

    Exits when remediation_type is of an unknown type.
    """
    if remediation_type in REMEDIATION_TO_EXT_MAP:
        return filename.endswith(REMEDIATION_TO_EXT_MAP[remediation_type])

    sys.stderr.write("ERROR: Unknown remediation type '%s'!\n"
                     % (remediation_type))
    sys.exit(1)


def get_populate_replacement(remediation_type, text):
    """
    Return varname, fixtextcontribution
    """

    if remediation_type == 'bash':
        # Extract variable name
        varname = re.search(r'\npopulate (\S+)\n',
                            text, re.DOTALL).group(1)
        # Define fix text part to contribute to main fix text
        fixtextcontribution = '\n%s="' % varname
        return (varname, fixtextcontribution)

    sys.stderr.write("ERROR: Unknown remediation type '%s'!\n"
                     % (remediation_type))
    sys.exit(1)


def split_remediation_content_and_metadata(fix_file):
    remediation_contents = []
    config = defaultdict(lambda: None)

    # Assignment automatically escapes shell characters for XML
    for line in fix_file.splitlines():
        if line.startswith(FILE_GENERATED_HASH_COMMENT):
            continue

        if line.startswith('#') and line.count('=') == 1:
            (key, value) = line.strip('#').split('=')
            if key.strip() in REMEDIATION_CONFIG_KEYS:
                config[key.strip()] = value.strip()
                continue

        # If our parsed line wasn't a config item, add it to the
        # returned file contents. This includes when the line
        # begins with a '#' and contains an equals sign, but
        # the "key" isn't one of the known keys from
        # REMEDIATION_CONFIG_KEYS.
        remediation_contents.append(line)

    contents = "\n".join(remediation_contents)
    remediation = namedtuple('remediation', ['contents', 'config'])
    return remediation(contents=contents, config=config)


def parse_from_file_with_jinja(file_path, env_yaml):
    """
    Parses a remediation from a file. As remediations contain jinja macros,
    we need a env_yaml context to process these. In practice, no remediations
    use jinja in the configuration, so for extracting only the configuration,
    env_yaml can be an abritrary product.yml dictionary.

    If the logic of configuration parsing changes significantly, please also
    update ssg.fixes.parse_platform(...).
    """

    fix_file = jinja_process_file(file_path, env_yaml)
    return split_remediation_content_and_metadata(fix_file)


def parse_from_file_without_jinja(file_path):
    """
    Parses a remediation from a file. Doesn't process the Jinja macros.
    This function is useful in build phases in which all the Jinja macros
    are already resolved.
    """
    with open(file_path, "r") as f:
        f_str = f.read()
        return split_remediation_content_and_metadata(f_str)


class Remediation(object):
    def __init__(self, file_path, remediation_type):
        self.file_path = file_path
        self.local_env_yaml = dict()

        self.metadata = defaultdict(lambda: None)

        self.remediation_type = remediation_type
        self.associated_rule = None

    def load_rule_from(self, rule_path):
        self.associated_rule = build_yaml.Rule.from_yaml(rule_path)
        self.expand_env_yaml_from_rule()

    def expand_env_yaml_from_rule(self):
        if not self.associated_rule:
            return

        self.local_env_yaml["rule_title"] = self.associated_rule.title
        self.local_env_yaml["rule_id"] = self.associated_rule.id_

    def parse_from_file_with_jinja(self, env_yaml):
        return parse_from_file_with_jinja(self.file_path, env_yaml)


def process(remediation, env_yaml, fixes, rule_id):
    """
    Process a fix, adding it to fixes iff the file is of a valid extension
    for the remediation type and the fix is valid for the current product.

    Note that platform is a required field in the contents of the fix.
    """
    if not is_supported_filename(remediation.remediation_type, remediation.file_path):
        return

    result = remediation.parse_from_file_with_jinja(env_yaml)
    platforms = result.config['platform']

    if not platforms:
        raise RuntimeError(
            "The '%s' remediation script does not contain the "
            "platform identifier!" % (remediation.file_path))

    for platform in platforms.split(","):
        if platform.strip() != platform:
            msg = (
                "Comma-separated '{platform}' platforms "
                "in '{remediation_file}' contains whitespace."
                .format(platform=platforms, remediation_file=remediation.file_path))
            raise ValueError(msg)

    product = env_yaml["product"]
    if utils.is_applicable_for_product(platforms, product):
        fixes[rule_id] = result

    return result


class BashRemediation(Remediation):
    def __init__(self, file_path):
        super(BashRemediation, self).__init__(file_path, "bash")

    def parse_from_file_with_jinja(self, env_yaml):
        self.local_env_yaml.update(env_yaml)
        result = super(BashRemediation, self).parse_from_file_with_jinja(self.local_env_yaml)

        # Avoid platform wrapping empty fix text
        # Remediations can be empty when a Jinja macro or conditional
        # renders no fix text for a product
        stripped_fix_text = result.contents.strip()
        if stripped_fix_text == "":
            return result

        rule_platforms = set()
        if self.associated_rule:
            # There can be repeated inherited platforms and rule platforms
            rule_platforms.update(self.associated_rule.inherited_platforms)
            rule_platforms.add(self.associated_rule.platform)

        platform_conditionals = []
        for platform in rule_platforms:
            if platform == "machine":
                # Based on check installed_env_is_a_container
                platform_conditionals.append('[ ! -f /.dockerenv ] && [ ! -f /run/.containerenv ]')
            elif platform is not None:
                # Assume any other platform is a Package CPE

                # Some package names are different from the platform names
                if platform in self.local_env_yaml["platform_package_overrides"]:
                    platform = self.local_env_yaml["platform_package_overrides"].get(platform)

                    # Workaround for plaforms that are not Package CPEs
                    # Skip platforms that are not about packages installed
                    # These should be handled in the remediation itself
                    if not platform:
                        continue

                # Adjust package check command according to the pkg_manager
                pkg_manager = self.local_env_yaml["pkg_manager"]
                pkg_check_command = PKG_MANAGER_TO_PACKAGE_CHECK_COMMAND[pkg_manager]
                platform_conditionals.append(pkg_check_command.format(platform))

        if platform_conditionals:
            wrapped_fix_text = ["# Remediation is applicable only in certain platforms"]

            all_conditions = " && ".join(platform_conditionals)
            wrapped_fix_text.append("if {0}; then".format(all_conditions))
            wrapped_fix_text.append("")
            # It is possible to indent the original body of the remediation with textwrap.indent(),
            # however, it is not supported by python2, and there is a risk of breaking remediations
            # For example, remediations with a here-doc block could be affected.
            wrapped_fix_text.append("{0}".format(stripped_fix_text))
            wrapped_fix_text.append("")
            wrapped_fix_text.append("else")
            wrapped_fix_text.append("    >&2 echo 'Remediation is not applicable, nothing was done'")
            wrapped_fix_text.append("fi")

            remediation = namedtuple('remediation', ['contents', 'config'])
            result = remediation(contents="\n".join(wrapped_fix_text), config=result.config)

        return result

class AnsibleRemediation(Remediation):
    def __init__(self, file_path):
        super(AnsibleRemediation, self).__init__(
            file_path, "ansible")

        self.body = None

    def parse_from_file_with_jinja(self, env_yaml):
        self.local_env_yaml.update(env_yaml)
        result = super(AnsibleRemediation, self).parse_from_file_with_jinja(self.local_env_yaml)

        if not self.associated_rule:
            return result

        parsed = ssg.yaml.ordered_load(result.contents)

        self.update(parsed, result.config)

        updated_yaml_text = ssg.yaml.ordered_dump(
            parsed, None, default_flow_style=False)
        result = result._replace(contents=updated_yaml_text)

        self.body = parsed
        self.metadata = result.config

        return result

    def update_tags_from_config(self, to_update, config):
        tags = to_update.get("tags", [])
        if "strategy" in config:
            tags.append("{0}_strategy".format(config["strategy"]))
        if "complexity" in config:
            tags.append("{0}_complexity".format(config["complexity"]))
        if "disruption" in config:
            tags.append("{0}_disruption".format(config["disruption"]))
        if "reboot" in config:
            if config["reboot"] == "true":
                reboot_tag = "reboot_required"
            else:
                reboot_tag = "no_reboot_needed"
            tags.append(reboot_tag)
        to_update["tags"] = sorted(tags)

    def update_tags_from_rule(self, to_update):
        if not self.associated_rule:
            raise RuntimeError("The Ansible snippet has no rule loaded.")

        tags = to_update.get("tags", [])
        tags.insert(0, "{0}_severity".format(self.associated_rule.severity))
        tags.insert(0, self.associated_rule.id_)

        cce_num = self._get_cce()
        if cce_num:
            tags.append("{0}".format(cce_num))

        refs = self.get_references()
        tags.extend(refs)
        to_update["tags"] = sorted(tags)

    def _get_cce(self):
        return self.associated_rule.identifiers.get("cce", None)

    def get_references(self):
        if not self.associated_rule:
            raise RuntimeError("The Ansible snippet has no rule loaded.")

        result = []
        for ref_class, prefix in constants.REF_PREFIX_MAP.items():
            refs = self._get_rule_reference(ref_class)
            result.extend(["{prefix}-{value}".format(prefix=prefix, value=v) for v in refs])
        return result

    def _get_rule_reference(self, ref_class):
        refs = self.associated_rule.references.get(ref_class, "")
        if refs:
            return refs.split(",")
        else:
            return []

    def inject_package_facts_task(self, parsed_snippet):
        """ Injects a package_facts task only if
            the snippet has a task with a when clause with ansible_facts.packages,
            and the snippet doesn't already have a package_facts task
        """
        has_package_facts_task = False
        has_ansible_facts_packages_clause = False

        for p_task in parsed_snippet:
            # We are only interested in the OrderedDicts, which represent Ansible tasks
            if not isinstance(p_task, dict):
                continue

            if "package_facts" in p_task:
                has_package_facts_task = True

            # When clause of the task can be string or a list, lets normalize to list
            task_when = p_task.get("when", "")
            if type(task_when) is str:
                task_when = [task_when]
            for when in task_when:
                if "ansible_facts.packages" in when:
                    has_ansible_facts_packages_clause = True

        if has_ansible_facts_packages_clause and not has_package_facts_task:
            facts_task = OrderedDict({'name': 'Gather the package facts',
                                      'package_facts': {'manager': 'auto'}})
            parsed_snippet.insert(0, facts_task)

    def update_when_from_rule(self, to_update):
        additional_when = []

        # There can be repeated inherited platforms and rule platforms
        rule_platforms = set(self.associated_rule.inherited_platforms)
        rule_platforms.add(self.associated_rule.platform)

        for platform in rule_platforms:
            if platform == "machine":
                additional_when.append('ansible_virtualization_type not in ["docker", "lxc", "openvz", "podman", "container"]')
            elif platform is not None:
                # Assume any other platform is a Package CPE

                # It doesn't make sense to add a conditional on the task that
                # gathers data for the conditional
                if "package_facts" in to_update:
                    continue

                if platform in self.local_env_yaml["platform_package_overrides"]:
                    platform = self.local_env_yaml["platform_package_overrides"].get(platform)

                    # Workaround for plaforms that are not Package CPEs
                    # Skip platforms that are not about packages installed
                    # These should be handled in the remediation itself
                    if not platform:
                        continue

                additional_when.append('"' + platform + '" in ansible_facts.packages')
                # After adding the conditional, we need to make sure package_facts are collected.
                # This is done via inject_package_facts_task()

        to_update.setdefault("when", "")
        new_when = ssg.yaml.update_yaml_list_or_string(to_update["when"], additional_when)
        if not new_when:
            to_update.pop("when")
        else:
            to_update["when"] = new_when

    def update(self, parsed, config):
        # We split the remediation update in three steps

        # 1. Update the when clause
        for p in parsed:
            if not isinstance(p, dict):
                continue
            self.update_when_from_rule(p)

        # 2. Inject any extra task necessary
        self.inject_package_facts_task(parsed)

        # 3. Add tags to all tasks, including the ones we have injected
        for p in parsed:
            if not isinstance(p, dict):
                continue
            self.update_tags_from_config(p, config)
            self.update_tags_from_rule(p)

    @classmethod
    def from_snippet_and_rule(cls, snippet_fname, rule_fname):
        if os.path.isfile(snippet_fname) and os.path.isfile(rule_fname):
            result = cls(snippet_fname)
            try:
                result.load_rule_from(rule_fname)
            except ssg.yaml.DocumentationNotComplete:
                # Happens on non-debug build when a rule is "documentation-incomplete"
                return None
            return result


class AnacondaRemediation(Remediation):
    def __init__(self, file_path):
        super(AnacondaRemediation, self).__init__(
            file_path, "anaconda")


class PuppetRemediation(Remediation):
    def __init__(self, file_path):
        super(PuppetRemediation, self).__init__(
            file_path, "puppet")


class IgnitionRemediation(Remediation):
    def __init__(self, file_path):
        super(IgnitionRemediation, self).__init__(
            file_path, "ignition")


class KubernetesRemediation(Remediation):
    def __init__(self, file_path):
        super(KubernetesRemediation, self).__init__(
              file_path, "kubernetes")


REMEDIATION_TO_CLASS = {
    'anaconda': AnacondaRemediation,
    'ansible': AnsibleRemediation,
    'bash': BashRemediation,
    'puppet': PuppetRemediation,
    'ignition': IgnitionRemediation,
    'kubernetes': KubernetesRemediation,
}


def write_fixes_to_xml(remediation_type, build_dir, output_path, fixes):
    """
    Builds a fix-content XML tree from the contents of fixes
    and writes it to output_path.
    """

    fixcontent = ElementTree.Element("fix-content", system="urn:xccdf:fix:script:sh",
                                     xmlns="http://checklists.nist.gov/xccdf/1.1")
    fixgroup = get_fixgroup_for_type(fixcontent, remediation_type)

    if remediation_type == "bash":
        # (bash_)remediation_functions are really only used for bash
        remediation_functions = get_available_functions(build_dir)
    else:
        remediation_functions = None

    for fix_name in fixes:
        fix_contents, config = fixes[fix_name]

        fix_elm = ElementTree.SubElement(fixgroup, "fix")
        fix_elm.set("rule", fix_name)

        for key in REMEDIATION_ELM_KEYS:
            if config[key]:
                fix_elm.set(key, config[key])

        fix_elm.text = fix_contents + "\n"

        # Expand shell variables and remediation functions
        # into corresponding XCCDF <sub> elements
        expand_xccdf_subs(fix_elm, remediation_type, remediation_functions)

    tree = ElementTree.ElementTree(fixcontent)
    tree.write(output_path)


def write_fixes_to_dir(fixes, remediation_type, output_dir):
    """
    Writes fixes as files to output_dir, each fix as a separate file
    """
    try:
        extension = REMEDIATION_TO_EXT_MAP[remediation_type]
    except KeyError:
        raise ValueError("Unknown remediation type %s." % remediation_type)

    if not os.path.exists(output_dir):
        os.makedirs(output_dir)
    for fix_name, fix in fixes.items():
        fix_contents, config = fix
        fix_path = os.path.join(output_dir, fix_name + extension)
        with open(fix_path, "w") as f:
            for k, v in config.items():
                f.write("# %s = %s\n" % (k, v))
            f.write(fix_contents)


def get_rule_dir_remediations(dir_path, remediation_type, product=None):
    """
    Gets a list of remediations of type remediation_type contained in a
    rule directory. If product is None, returns all such remediations.
    If product is not None, returns applicable remediations in order of
    priority:

        {{{ product }}}.ext -> shared.ext

    Only returns remediations which exist.
    """

    if not rules.is_rule_dir(dir_path):
        return []

    remediations_dir = os.path.join(dir_path, remediation_type)
    has_remediations_dir = os.path.isdir(remediations_dir)
    ext = REMEDIATION_TO_EXT_MAP[remediation_type]
    if not has_remediations_dir:
        return []

    results = []
    for remediation_file in os.listdir(remediations_dir):
        file_name, file_ext = os.path.splitext(remediation_file)
        remediation_path = os.path.join(remediations_dir, remediation_file)

        if file_ext == ext and rules.applies_to_product(file_name, product):
            if file_name == 'shared':
                results.append(remediation_path)
            else:
                results.insert(0, remediation_path)

    return results


def expand_xccdf_subs(fix, remediation_type, remediation_functions):
    """For those remediation scripts utilizing some of the internal SCAP
    Security Guide remediation functions expand the selected shell variables
    and remediation functions calls with <xccdf:sub> element

    This routine translates any instance of the 'populate' function call in
    the form of:

            populate variable_name

    into

            variable_name="<sub idref="variable_name"/>"

    Also transforms any instance of the 'ansible-populate' function call in the
    form of:
            (ansible-populate variable_name)
    into

            <sub idref="variable_name"/>

    Also transforms any instance of some other known remediation function (e.g.
    'replace_or_append' etc.) from the form of:

            function_name "arg1" "arg2" ... "argN"

    into:

            <sub idref="function_function_name"/>
            function_name "arg1" "arg2" ... "argN"
    """

    if remediation_type == "ignition":
        return
    if remediation_type == "kubernetes":
        return
    elif remediation_type == "ansible":
        fix_text = fix.text

        if "(ansible-populate " in fix_text:
            raise RuntimeError(
                "(ansible-populate VAR) has been deprecated. Please use "
                "(xccdf-var VAR) instead. Keep in mind that the latter will "
                "make an ansible variable out of XCCDF Value as opposed to "
                "substituting directly."
            )

        # If you change this string make sure it still matches the pattern
        # defined in OpenSCAP. Otherwise you break variable handling in
        # 'oscap xccdf generate fix' and the variables won't be customizable!
        # https://github.com/OpenSCAP/openscap/blob/1.2.17/src/XCCDF_POLICY/xccdf_policy_remediate.c#L588
        #   const char *pattern =
        #     "- name: XCCDF Value [^ ]+ # promote to variable\n  set_fact:\n"
        #     "    ([^:]+): (.+)\n  tags:\n    - always\n";
        # We use !!str typecast to prevent treating values as different types
        # eg. yes as a bool or 077 as an octal number
        fix_text = re.sub(
            r"- \(xccdf-var\s+(\S+)\)",
            r"- name: XCCDF Value \1 # promote to variable\n"
            r"  set_fact:\n"
            r"    \1: !!str (ansible-populate \1)\n"
            r"  tags:\n"
            r"    - always",
            fix_text
        )

        pattern = r'\(ansible-populate\s*(\S+)\)'

        # we will get list what looks like
        # [text, varname, text, varname, ..., text]
        parts = re.split(pattern, fix_text)

        fix.text = parts[0]  # add first "text"
        for index in range(1, len(parts), 2):
            varname = parts[index]
            text_between_vars = parts[index + 1]

            # we cannot combine elements and text easily
            # so text is in ".tail" of element
            xccdfvarsub = ElementTree.SubElement(fix, "sub", idref=varname)
            xccdfvarsub.tail = text_between_vars
        return

    elif remediation_type == "puppet":
        pattern = r'\(puppet-populate\s*(\S+)\)'

        # we will get list what looks like
        # [text, varname, text, varname, ..., text]
        parts = re.split(pattern, fix.text)

        fix.text = parts[0]  # add first "text"
        for index in range(1, len(parts), 2):
            varname = parts[index]
            text_between_vars = parts[index + 1]

            # we cannot combine elements and text easily
            # so text is in ".tail" of element
            xccdfvarsub = ElementTree.SubElement(fix, "sub", idref=varname)
            xccdfvarsub.tail = text_between_vars
        return

    elif remediation_type == "anaconda":
        pattern = r'\(anaconda-populate\s*(\S+)\)'

        # we will get list what looks like
        # [text, varname, text, varname, ..., text]
        parts = re.split(pattern, fix.text)

        fix.text = parts[0]  # add first "text"
        for index in range(1, len(parts), 2):
            varname = parts[index]
            text_between_vars = parts[index + 1]

            # we cannot combine elements and text easily
            # so text is in ".tail" of element
            xccdfvarsub = ElementTree.SubElement(fix, "sub", idref=varname)
            xccdfvarsub.tail = text_between_vars
        return

    elif remediation_type == "bash":
        # This remediation script doesn't utilize internal remediation functions
        # Skip it without any further processing
        if 'remediation_functions' not in fix.text:
            return

        # This remediation script utilizes some of internal remediation functions
        # Expand shell variables and remediation functions calls with <xccdf:sub>
        # elements
        pattern = r'\n+(\s*(?:' + r'|'.join(remediation_functions) + r')[^\n]*)\n'
        patcomp = re.compile(pattern, re.DOTALL)
        fixparts = re.split(patcomp, fix.text)
        if fixparts[0] is not None:
            # Split the portion of fix.text at the string remediation_functions,
            # and remove preceeding comment whenever it is there.
            # * head        holds part of the fix.text before
            #               remediation_functions string
            # * tail        holds part of the fix.text after the
            #               remediation_functions string
            try:
                rfpattern = r'((?:# Include source function library\.\n)?.*remediation_functions)'
                rfpatcomp = re.compile(rfpattern)
                head, _, tail = re.split(rfpatcomp, fixparts[0], maxsplit=1)
            except ValueError:
                sys.stderr.write("Processing fix.text for: %s rule\n"
                                 % fix.get('rule'))
                sys.stderr.write("Unable to extract part of the fix.text "
                                 "after inclusion of remediation functions."
                                 " Aborting..\n")
                sys.exit(1)
            # If the 'head' is not empty, make it new fix.text.
            # Otherwise use ''
            fix.text = head if head is not None else ''
            fix.text += tail if tail is not None else ''
            # Drop the first element of 'fixparts' since it has been processed
            fixparts.pop(0)
            # Perform sanity check on new 'fixparts' list content (to continue
            # successfully 'fixparts' has to contain even count of elements)
            if len(fixparts) % 2 != 0:
                sys.stderr.write("Error performing XCCDF expansion on "
                                 "remediation script: %s\n"
                                 % fix.get("rule"))
                sys.stderr.write("Invalid count of elements. Exiting!\n")
                sys.exit(1)
            # Process remaining 'fixparts' elements in pairs
            # First pair element is remediation function to be XCCDF expanded
            # Second pair element (if not empty) is the portion of the original
            # fix text to be used in newly added sublement's tail
            for idx in range(0, len(fixparts), 2):
                # We previously removed enclosing newlines when creating
                # fixparts list. Add them back and reuse the above 'pattern'
                fixparts[idx] = "\n%s\n" % fixparts[idx]
                # Sanity check (verify the first field truly contains call of
                # some of the remediation functions)
                if re.match(pattern, fixparts[idx], re.DOTALL) is not None:
                    # This chunk contains call of 'populate' function
                    if "populate" in fixparts[idx]:
                        varname, fixtextcontrib = get_populate_replacement(remediation_type,
                                                                           fixparts[idx])
                        # Define new XCCDF <sub> element for the variable
                        xccdfvarsub = ElementTree.Element("sub", idref=varname)

                        # If this is first sub element,
                        # the textcontribution needs to go to fix text
                        # otherwise, append to last subelement
                        nfixchildren = len(list(fix))
                        if nfixchildren == 0:
                            fix.text += fixtextcontrib
                        else:
                            previouselem = fix[nfixchildren-1]
                            previouselem.tail += fixtextcontrib

                        # If second pair element is not empty, append it as
                        # tail for the subelement (prefixed with closing '"')
                        if fixparts[idx + 1] is not None:
                            xccdfvarsub.tail = '"' + '\n' + fixparts[idx + 1]
                        # Otherwise append just enclosing '"'
                        else:
                            xccdfvarsub.tail = '"' + '\n'
                        # Append the new subelement to the fix element
                        fix.append(xccdfvarsub)
                    # This chunk contains call of other remediation function
                    else:
                        # Extract remediation function name
                        funcname = re.search(r'\n\s*(\S+)(| .*)\n',
                                             fixparts[idx],
                                             re.DOTALL).group(1)
                        # Define new XCCDF <sub> element for the function
                        xccdffuncsub = ElementTree.Element(
                            "sub", idref='function_%s' % funcname)
                        # Append original function call into tail of the
                        # subelement
                        xccdffuncsub.tail = fixparts[idx]
                        # If the second element of the pair is not empty,
                        # append it to the tail of the subelement too
                        if fixparts[idx + 1] is not None:
                            xccdffuncsub.tail += fixparts[idx + 1]
                        # Append the new subelement to the fix element
                        fix.append(xccdffuncsub)
                        # Ensure the newly added <xccdf:sub> element for the
                        # function will be always inserted at newline
                        # If xccdffuncsub is the first <xccdf:sub> element
                        # being added as child of <fix> and fix.text doesn't
                        # end up with newline character, append the newline
                        # to the fix.text
                        if list(fix).index(xccdffuncsub) == 0:
                            if re.search(r'.*\n$', fix.text) is None:
                                fix.text += '\n'
                        # If xccdffuncsub isn't the first child (first
                        # <xccdf:sub> being added), and tail of previous
                        # child doesn't end up with newline, append the newline
                        # to the tail of previous child
                        else:
                            previouselem = fix[list(fix).index(xccdffuncsub) - 1]
                            if re.search(r'.*\n$', previouselem.tail) is None:
                                previouselem.tail += '\n'

        # Perform a sanity check if all known remediation function calls have been
        # properly XCCDF substituted. Exit with failure if some wasn't

        # First concat output form of modified fix text (including text appended
        # to all children of the fix)
        modfix = [fix.text]
        for child in list(fix):
            if child is not None and child.text is not None:
                modfix.append(child.text)
        modfixtext = "".join(modfix)
        # Don't perform sanity check at bash comments because they are not substituted
        modfixtext = re.sub(r'#.*', '', modfixtext)
        for func in remediation_functions:
            # Then efine expected XCCDF sub element form for this function
            funcxccdfsub = "<sub idref=\"function_%s\"" % func
            # Finally perform the sanity check -- if function was properly XCCDF
            # substituted both the original function call and XCCDF <sub> element
            # for that function need to be present in the modified text of the fix
            # Otherwise something went wrong, thus exit with failure
            if func in modfixtext and funcxccdfsub not in modfixtext:
                sys.stderr.write("Error performing XCCDF <sub> substitution "
                                 "for function %s in %s fix. Exiting...\n"
                                 % (func, fix.get("rule")))
                sys.exit(1)
    else:
        sys.stderr.write("Unknown remediation type '%s'\n" % (remediation_type))
        sys.exit(1)
