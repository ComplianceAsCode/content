"""
Common functions for processing Ansible in SSG
"""

from __future__ import absolute_import
from __future__ import print_function

import re

from .constants import ansible_version_requirement_pre_task_name
from .constants import min_ansible_version


def add_minimum_version(ansible_src):
    """
    Adds minimum ansible version to an Ansible script
    """
    pre_task = (""" - hosts: all
   pre_tasks:
     - name: %s
       assert:
         that: "ansible_version.full is version_compare('%s', '>=')"
         msg: >
           "You must update Ansible to at least version %s to use this role."
          """ % (ansible_version_requirement_pre_task_name,
                 min_ansible_version, min_ansible_version))

    if ' - hosts: all' not in ansible_src:
        return ansible_src

    if 'pre_task' in ansible_src:
        if 'ansible_version.full is version_compare' in ansible_src:
            return ansible_src

        raise ValueError(
            "A pre_task already exists in ansible_src; failing to process: %s" %
            ansible_src)

    return ansible_src.replace(" - hosts: all", pre_task, 1)


def remove_multiple_blank_lines(ansible_src):
    """
    Removes multiple blank lines in an Ansible script
    """
    return re.sub(r'\n\s*\n', '\n\n', ansible_src)


def remove_trailing_whitespace(ansible_src):
    """
    Removes trailing whitespace in an Ansible script
    """
    return re.sub(r'[ \t]+$', '', ansible_src, 0, flags=re.M)


def _strings_to_list(one_or_more_strings):
    """
    Output a list, that either contains one string, or a list of strings.
    In Python, strings can be cast to lists without error, but with unexpected result.
    """
    if isinstance(one_or_more_strings, str):
        return [one_or_more_strings]
    else:
        return list(one_or_more_strings)


def update_yaml_list_or_string(current_contents, new_contents):
    result = []
    if current_contents:
        result += _strings_to_list(current_contents)
    if new_contents:
        result += _strings_to_list(new_contents)
    if not result:
        result = ""
    if len(result) == 1:
        result = result[0]
    return result


class AnsibleRemediation(object):

    def __init__(self, contents, config):
        self.contents = contents
        self.config = config

        self.parsed = yaml.ordered_load(contents)

        self.rule = None

    def update_tags_from_config(self, to_update):
        tags = to_update.get("tags", [])
        if "strategy" in self.config:
            tags.append("{0}_strategy".format(self.config["strategy"]))
        if "complexity" in self.config:
            tags.append("{0}_complexity".format(self.config["complexity"]))
        if "disruption" in self.config:
            tags.append("{0}_disruption".format(self.config["disruption"]))
        if "reboot" in self.config:
            if self.config["reboot"] == "true":
                reboot_tag = "reboot_required"
            else:
                reboot_tag = "no_reboot_needed"
            tags.append(reboot_tag)
        to_update["tags"] = tags

    def update_tags_from_rule(self, platform, to_update):
        if not self.rule:
            raise RuntimeError("The Ansible snippet has no rule loaded.")

        tags = to_update.get("tags", [])
        tags.insert(0, "{0}_severity".format(self.rule.severity))
        tags.insert(0, self.rule.id_)

        cce_num = self._get_cce()
        if cce_num:
            tags.append("CCE-{0}".format(cce_num))

        refs = self.get_references(platform)
        tags.extend(refs)
        to_update["tags"] = tags

    def _get_cce(self):
        return self.rule.identifiers.get("cce", None)

    def get_references(self, platform):
        if not self.rule:
            raise RuntimeError("The Ansible snippet has no rule loaded.")
        # see xccdf-addremediations.xslt <- shared_constants.xslt <- shared_shorthand2xccdf.xslt
        # if you want to know how the map was constructed
        stig_platform_id_map = {
            "rhel6": "RHEL-06",
            "rhel7": "RHEL-07",
            "rhel8": "RHEL-08",
        }
        ref_prefix_map = {
            "nist": "NIST-800-53",
            "cui": "NIST-800-171",
            "pcidss": "PCI-DSS",
            "cjis": "CJIS",
        }

        if platform in stig_platform_id_map:
            stig_platform_id = "DISA-STIG-{id}".format(id=stig_platform_id_map[platform])
            ref_prefix_map["stigid"] = stig_platform_id

        result = []
        for ref_class, prefix in ref_prefix_map.items():
            refs = self._get_rule_reference(ref_class)
            result.extend(["{prefix}-{value}".format(prefix=prefix, value=v) for v in refs])
        return result

    def _get_rule_reference(self, ref_class):
        refs = self.rule.references.get(ref_class, "")
        if refs:
            return refs.split(",")
        else:
            return []

    def update_when_from_rule(self, to_update):
        additional_when = ""
        if self.rule.platform == "machine":
            additional_when = ('ansible_virtualization_role != "guest" '
                               'or ansible_virtualization_type != "docker"')
        to_update.setdefault("when", "")
        new_when = update_yaml_list_or_string(to_update["when"], additional_when)
        if not new_when:
            to_update.pop("when")
        else:
            to_update["when"] = new_when

    def update(self, platform):
        for p in self.parsed:
            if not isinstance(p, dict):
                continue
            self.update_when_from_rule(p)
            self.update_tags_from_config(p)
            self.update_tags_from_rule(platform, p)

    @classmethod
    def from_snippet_and_rule(cls, snippet_fname, rule_fname):
        rule = build_yaml.Rule.from_yaml(rule_fname)
        result = cls.from_snippet(snippet_fname)
        result.rule = rule
        return result

    @classmethod
    def from_snippet(cls, snippet_fname):
        parsed = build_remediations.parse_from_file_without_jinja(snippet_fname)
        result = cls(parsed.contents, parsed.config)
        return result
