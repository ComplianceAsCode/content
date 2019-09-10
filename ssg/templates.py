from __future__ import print_function

import os
import sys
import re

import ssg.build_yaml

languages = ["anaconda", "ansible", "bash", "oval", "puppet"]

lang_to_ext_map = {
    "anaconda": ".anaconda",
    "ansible": ".yml",
    "bash": ".sh",
    "oval": ".xml",
    "puppet": ".pp"
}

# Callback functions for processing template parameters and/or validating them


def package_installed(data, lang):
    if "evr" in data:
        evr = data["evr"]
        if evr and not re.match(r'\d:\d[\d\w+.]*-\d[\d\w+.]*', evr, 0):
            raise RuntimeError(
                "ERROR: input violation: evr key should be in "
                "epoch:version-release format, but package {0} has set "
                "evr to {1}".format(data["pkgname"], evr))
    return data

templates = {
    "accounts_password": None,
    "auditd_lineinfile": None,
    "audit_rules_dac_modification": None,
    "audit_rules_file_deletion_events": None,
    "audit_rules_login_events": None,
    "audit_rules_path_syscall": None,
    "audit_rules_privileged_commands": None,
    "audit_rules_unsuccessful_file_modification": None,
    "audit_rules_unsuccessful_file_modification_o_creat": None,
    "audit_rules_unsuccessful_file_modification_o_trunc_write": None,
    "audit_rules_unsuccessful_file_modification_rule_order": None,
    "audit_rules_usergroup_modification": None,
    "file_groupowner": None,
    "file_owner": None,
    "file_permissions": None,
    "file_regex_permissions": None,
    "grub2_bootloader_argument": None,
    "kernel_module_disabled": None,
    "mount": None,
    "mount_option": None,
    "mount_option_remote_filesystems": None,
    "mount_option_removable_partitions": None,
    "mount_option_var": None,
    "ocp_service_runtime_config": None,
    "package_installed": package_installed,
    "package_removed": None,
    "permissions": None,
    "sebool": None,
    "sebool_var": None,
    "service_disabled": None,
    "service_enabled": None,
    "sshd_lineinfile": None,
    "sysctl": None,
    "sysctl_ipv6": None,
    "sysctl_runtime": None,
    "sysctl_runtime_var": None,
    "sysctl_static": None,
    "sysctl_static_var": None,
    "sysctl_var": None,
    "timer_enabled": None,
}


class Builder(object):
    """
    Class for building all templated content for a given product.

    To generate content from templates, pass the env_yaml, path to the
    directory with resolved rule YAMLs, path to the directory that contains
    templates, path to the output directory for checks and a path to the
    output directory for remediations into the constructor. Then, call the
    method build() to perform a build.
    """
    def __init__(
            self, env_yaml, resolved_rules_dir, templates_dir,
            remediations_dir, checks_dir):
        self.env_yaml = env_yaml
        self.resolved_rules_dir = resolved_rules_dir
        self.templates_dir = templates_dir
        self.remediations_dir = remediations_dir
        self.checks_dir = checks_dir
        self.output_dirs = dict()
        for lang in languages:
            if lang == "oval":
                # OVAL checks need to be put to a different directory because
                # they are processed differently than remediations later in the
                # build process
                output_dir = self.checks_dir
            else:
                output_dir = self.remediations_dir
            dir_ = os.path.join(output_dir, lang)
            self.output_dirs[lang] = dir_

    def preprocess_data(self, template, lang, raw_parameters):
        """
        Processes template data using a callback before the data will be
        substituted into the Jinja template.
        """
        template_func = templates[template]
        if template_func is not None:
            parameters = template_func(raw_parameters, lang)
        else:
            parameters = raw_parameters
        # TODO: Remove this right after the variables in templates are renamed
        # to lowercase
        parameters = {k.upper(): v for k, v in parameters.items()}
        return parameters

    def build_lang(self, rule, template_name, lang):
        """
        Builds templated content for a given rule for a given language.
        Writes the output to the correct build directories.
        """
        template_file_name = "template_{0}_{1}".format(
            lang.upper(), template_name)
        template_file_path = os.path.join(
            self.templates_dir, template_file_name)
        if not os.path.exists(template_file_path):
            return
        ext = lang_to_ext_map[lang]
        output_file_name = rule.id_ + ext
        output_filepath = os.path.join(
            self.output_dirs[lang], output_file_name)

        try:
            template_vars = rule.template["vars"]
        except KeyError:
            raise ValueError(
                "Rule {0} does not contain mandatory 'vars:' key under "
                "'template:' key.".format(rule.id_))
        template_parameters = self.preprocess_data(
            template_name, lang, template_vars)
        jinja_dict = ssg.utils.merge_dicts(self.env_yaml, template_parameters)
        filled_template = ssg.jinja.process_file_with_macros(
            template_file_path, jinja_dict)
        with open(output_filepath, "w") as f:
            f.write(filled_template)

    def get_langs_to_generate(self, rule):
        """
        For a given rule returns list of languages that should be generated
        from templates. This is controlled by "template_backends" in rule.yml.
        """
        if "backends" in rule.template:
            backends = rule.template["backends"]
            for lang in backends:
                if lang not in languages:
                    raise RuntimeError(
                        "Rule {0} wants to generate unknown language '{1}"
                        "from a template.".format(rule.id_, lang)
                    )
            langs_to_generate = []
            for lang in languages:
                backend = backends.get(lang, "on")
                if backend == "on":
                    langs_to_generate.append(lang)
            return langs_to_generate
        else:
            return languages

    def build_rule(self, rule):
        """
        Builds templated content for a given rule for all languages, writing
        the output to the correct build directories.
        """
        if rule.template is None:
            # rule is not templated, skipping
            return
        try:
            template_name = rule.template["name"]
        except KeyError:
            raise ValueError(
                "Rule {0} is missing template name under template key".format(
                    rule.id_))
        if template_name not in templates:
            raise ValueError(
                "Rule {0} uses template {1} which does not exist.".format(
                    rule.id_, template_name))
        langs_to_generate = self.get_langs_to_generate(rule)
        for lang in langs_to_generate:
            self.build_lang(rule, template_name, lang)

    def build(self):
        """
        Builds all templated content for all languages, writing
        the output to the correct build directories.
        """

        for dir_ in self.output_dirs.values():
            if not os.path.exists(dir_):
                os.makedirs(dir_)

        for rule_file in os.listdir(self.resolved_rules_dir):
            rule_path = os.path.join(self.resolved_rules_dir, rule_file)
            rule = ssg.build_yaml.Rule.from_yaml(rule_path, self.env_yaml)
            self.build_rule(rule)
