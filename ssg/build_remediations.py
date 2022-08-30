from __future__ import absolute_import
from __future__ import print_function

import sys
import os
import os.path
import re
from collections import defaultdict, namedtuple, OrderedDict

import ssg.yaml
import ssg.build_yaml
from . import rules
from . import utils

from . import constants
from .jinja import process_file_with_macros as jinja_process_file

from .xml import ElementTree
from .constants import XCCDF11_NS

REMEDIATION_TO_EXT_MAP = {
    'anaconda': '.anaconda',
    'ansible': '.yml',
    'bash': '.sh',
    'puppet': '.pp',
    'ignition': '.yml',
    'kubernetes': '.yml',
    'blueprint': '.toml'
}


FILE_GENERATED_HASH_COMMENT = '# THIS FILE IS GENERATED'

REMEDIATION_CONFIG_KEYS = ['complexity', 'disruption', 'platform', 'reboot',
                           'strategy']
REMEDIATION_ELM_KEYS = ['complexity', 'disruption', 'reboot', 'strategy']


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

    elif remediation_type == 'blueprint':
        return ElementTree.SubElement(
            fixcontent, "fix-group", id="blueprint",
            system="urn:redhat:osbuild:blueprint",
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

    def associate_rule(self, rule_obj):
        self.associated_rule = rule_obj
        self.expand_env_yaml_from_rule()

    def expand_env_yaml_from_rule(self):
        if not self.associated_rule:
            return

        self.local_env_yaml["rule_title"] = self.associated_rule.title
        self.local_env_yaml["rule_id"] = self.associated_rule.id_
        self.local_env_yaml["cce_identifiers"] = self.associated_rule.identifiers

    def parse_from_file_with_jinja(self, env_yaml, cpe_platforms):
        return parse_from_file_with_jinja(self.file_path, env_yaml)


def process(remediation, env_yaml, cpe_platforms):
    """
    Process a fix, and return the processed fix iff the file is of a valid
    extension for the remediation type and the fix is valid for the current
    product.

    Note that platform is a required field in the contents of the fix.
    """
    if not is_supported_filename(remediation.remediation_type, remediation.file_path):
        return

    result = remediation.parse_from_file_with_jinja(env_yaml, cpe_platforms)
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
        return result

    return None


class BashRemediation(Remediation):
    def __init__(self, file_path):
        super(BashRemediation, self).__init__(file_path, "bash")

    def parse_from_file_with_jinja(self, env_yaml, cpe_platforms):
        self.local_env_yaml.update(env_yaml)
        result = super(BashRemediation, self).parse_from_file_with_jinja(
            self.local_env_yaml, cpe_platforms)

        # Avoid platform wrapping empty fix text
        # Remediations can be empty when a Jinja macro or conditional
        # renders no fix text for a product
        stripped_fix_text = result.contents.strip()
        if stripped_fix_text == "":
            return result

        rule_specific_cpe_platform_names = set()
        inherited_cpe_platform_names = set()
        if self.associated_rule:
            # There can be repeated inherited platforms and rule platforms
            inherited_cpe_platform_names.update(self.associated_rule.inherited_cpe_platform_names)
            if self.associated_rule.cpe_platform_names is not None:
                rule_specific_cpe_platform_names = {
                    p for p in self.associated_rule.cpe_platform_names
                    if p not in inherited_cpe_platform_names}

        inherited_conditionals = [
            cpe_platforms[p].to_bash_conditional()
            for p in inherited_cpe_platform_names]
        rule_specific_conditionals = [
            cpe_platforms[p].to_bash_conditional()
            for p in rule_specific_cpe_platform_names]
        # remove potential "None" from lists
        inherited_conditionals = sorted([
            p for p in inherited_conditionals if p != ''])
        rule_specific_conditionals = sorted([
            p for p in rule_specific_conditionals if p != ''])

        if inherited_conditionals or rule_specific_conditionals:
            wrapped_fix_text = ["# Remediation is applicable only in certain platforms"]

            all_conditions = ""
            if inherited_conditionals:
                all_conditions += " && ".join(inherited_conditionals)
            if rule_specific_conditionals:
                if all_conditions:
                    all_conditions += " && { " + " || ".join(rule_specific_conditionals) + "; }"
                else:
                    all_conditions = " || ".join(rule_specific_conditionals)
            wrapped_fix_text.append("if {0}; then".format(all_conditions))
            wrapped_fix_text.append("")
            # It is possible to indent the original body of the remediation with textwrap.indent(),
            # however, it is not supported by python2, and there is a risk of breaking remediations
            # For example, remediations with a here-doc block could be affected.
            wrapped_fix_text.append("{0}".format(stripped_fix_text))
            wrapped_fix_text.append("")
            wrapped_fix_text.append("else")
            wrapped_fix_text.append(
                "    >&2 echo 'Remediation is not applicable, nothing was done'")
            wrapped_fix_text.append("fi")

            remediation = namedtuple('remediation', ['contents', 'config'])
            result = remediation(contents="\n".join(wrapped_fix_text), config=result.config)

        return result


class AnsibleRemediation(Remediation):
    def __init__(self, file_path):
        super(AnsibleRemediation, self).__init__(
            file_path, "ansible")

        self.body = None

    def parse_from_file_with_jinja(self, env_yaml, cpe_platforms):
        self.local_env_yaml.update(env_yaml)
        result = super(AnsibleRemediation, self).parse_from_file_with_jinja(
            self.local_env_yaml, cpe_platforms)

        if not self.associated_rule:
            return result

        parsed = ssg.yaml.ordered_load(result.contents)

        self.update(parsed, result.config, cpe_platforms)

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

    def update_when_from_rule(self, to_update, cpe_platforms):
        additional_when = []
        rule_specific_cpe_platform_names = set()
        inherited_cpe_platform_names = set()
        if self.associated_rule:
            # There can be repeated inherited platforms and rule platforms
            inherited_cpe_platform_names.update(self.associated_rule.inherited_cpe_platform_names)
            if self.associated_rule.cpe_platform_names is not None:
                rule_specific_cpe_platform_names = {
                    p for p in self.associated_rule.cpe_platform_names
                    if p not in inherited_cpe_platform_names}

        inherited_conditionals = [
            cpe_platforms[p].to_ansible_conditional()
            for p in inherited_cpe_platform_names]
        rule_specific_conditionals = [
            cpe_platforms[p].to_ansible_conditional()
            for p in rule_specific_cpe_platform_names]
        # remove potential "None" from lists
        inherited_conditionals = sorted([
            p for p in inherited_conditionals if p != ''])
        rule_specific_conditionals = sorted([
            p for p in rule_specific_conditionals if p != ''])

        # remove conditionals related to package CPEs if the updated task
        # collects package facts
        if "package_facts" in to_update:
            inherited_conditionals = [
                c for c in inherited_conditionals if "in ansible_facts.packages" not in c]
            rule_specific_conditionals = [
                c for c in rule_specific_conditionals if "in ansible_facts.packages" not in c]

        if inherited_conditionals:
            additional_when = additional_when + inherited_conditionals

        if rule_specific_conditionals:
            additional_when.append(" or ".join(rule_specific_conditionals))

        to_update.setdefault("when", "")
        new_when = ssg.yaml.update_yaml_list_or_string(to_update["when"], additional_when,
                                                       prepend=True)
        if not new_when:
            to_update.pop("when")
        else:
            to_update["when"] = new_when

    def update(self, parsed, config, cpe_platforms):
        # We split the remediation update in three steps

        # 1. Update the when clause
        for p in parsed:
            if not isinstance(p, dict):
                continue
            self.update_when_from_rule(p, cpe_platforms)

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
                rule_obj = ssg.build_yaml.Rule.from_yaml(rule_fname)
                result.associate_rule(rule_obj)
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


class BlueprintRemediation(Remediation):
    """
    This provides class for OSBuild Blueprint remediations
    """
    def __init__(self, file_path):
        super(BlueprintRemediation, self).__init__(
            file_path, "blueprint")


REMEDIATION_TO_CLASS = {
    'anaconda': AnacondaRemediation,
    'ansible': AnsibleRemediation,
    'bash': BashRemediation,
    'puppet': PuppetRemediation,
    'ignition': IgnitionRemediation,
    'kubernetes': KubernetesRemediation,
    'blueprint': BlueprintRemediation,
}


def write_fix_to_file(fix, file_path):
    """
    Writes a single fix to the given file path.
    """
    fix_contents, config = fix
    with open(file_path, "w") as f:
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

    # Two categories of results: those for a product and those that are
    # shared to multiple products. Within common results, there's two types:
    # those shared to multiple versions of the same type (added up front) and
    # those shared across multiple product types (e.g., RHEL and Ubuntu).
    product_results = []
    common_results = []
    for remediation_file in sorted(os.listdir(remediations_dir)):
        file_name, file_ext = os.path.splitext(remediation_file)
        remediation_path = os.path.join(remediations_dir, remediation_file)

        if file_ext == ext and rules.applies_to_product(file_name, product):
            # rules.applies_to_product ensures we only have three entries:
            # 1. shared
            # 2. <product>
            # 3. <product><version>
            #
            # Note that the product variable holds <product><version>.
            if file_name == 'shared':
                # Shared are the lowest priority items, add them to the end
                # of the common results.
                common_results.append(remediation_path)
            elif file_name != product:
                # Here, the filename is a subset of the product, but isn't
                # the full product. Product here is both the product name
                # (e.g., ubuntu) and its version (2004). Filename could be
                # either "ubuntu" or "ubuntu2004" so we want this branch
                # to trigger when it is the former, not the latter. It is
                # the highest priority of common results, so insert it
                # before any shared ones.
                common_results.insert(0, remediation_path)
            else:
                # Finally, this must be product-specific result.
                product_results.append(remediation_path)

    # Combine the two sets in priority order.
    return product_results + common_results


def expand_xccdf_subs(fix, remediation_type):
    """Expand the respective populate keywords of each
    remediation type with an <xccdf:sub> element

    This routine translates any instance of the '`type`-populate' keyword in
    the form of:

            (`type`-populate variable_name)

    where `type` can be either ansible, puppet, anaconda or bash, into

            <sub idref="variable_name"/>

    """

    if fix is not None:
        fix_text = fix.text
    else:
        return
    if remediation_type == "ignition":
        return
    elif remediation_type == "kubernetes":
        return
    elif remediation_type == "blueprint":
        pattern = r'\(blueprint-populate\s*(\S+)\)'
    elif remediation_type == "ansible":

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

    elif remediation_type == "puppet":
        pattern = r'\(puppet-populate\s*(\S+)\)'

    elif remediation_type == "anaconda":
        pattern = r'\(anaconda-populate\s*(\S+)\)'

    elif remediation_type == "bash":
        pattern = r'\(bash-populate\s*(\S+)\)'

    else:
        sys.stderr.write("Unknown remediation type '%s'\n" % (remediation_type))
        sys.exit(1)

    # we will get list what looks like
    # [text, varname, text, varname, ..., text]
    parts = re.split(pattern, fix_text)

    fix.text = parts[0]  # add first "text"
    for index in range(1, len(parts), 2):
        varname = parts[index]
        text_between_vars = parts[index + 1]

        # we cannot combine elements and text easily
        # so text is in ".tail" of element
        xccdfvarsub = ElementTree.SubElement(fix, "{%s}sub" % XCCDF11_NS, idref=varname)
        xccdfvarsub.tail = text_between_vars


def load_compiled_remediations(fixes_dir):
    if not os.path.isdir(fixes_dir):
        raise RuntimeError(
            "Directory with compiled fixes '%s' does not exist" % fixes_dir)
    all_remediations = defaultdict(dict)
    for language in os.listdir(fixes_dir):
        language_dir = os.path.join(fixes_dir, language)
        if not os.path.isdir(language_dir):
            raise RuntimeError(
                "Can't find the '%s' directory with fixes for %s" %
                (language_dir, language))
        for filename in sorted(os.listdir(language_dir)):
            file_path = os.path.join(language_dir, filename)
            rule_id, _ = os.path.splitext(filename)
            remediation = parse_from_file_without_jinja(file_path)
            all_remediations[rule_id][language] = remediation
    return all_remediations
