#!/usr/bin/python3

import argparse
import os
import re
import xml.etree.ElementTree as ET

import ssg.ansible
from ssg.constants import (
    ansible_system,
    bash_system,
    datastream_namespace,
    OSCAP_PROFILE,
    OSCAP_RULE,
    XCCDF12_NS,
)


DEFAULT_SELECTOR = "__DEFAULT"
HASH_ROW = "#" * 79
LANGUAGE_TO_SYSTEM = {"ansible": ansible_system, "bash": bash_system}
LANGUAGE_TO_TARGET = {"ansible": "playbook", "bash": "script"}
LANGUAGE_TO_EXTENSION = {"ansible": "yml", "bash": "sh"}
ANSIBLE_VAR_PATTERN = re.compile(
    "- name: XCCDF Value [^ ]+ # promote to variable\n  set_fact:\n"
    "    ([^:]+): (.+)\n  tags:\n    - always\n")


def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--data-stream", required=True,
        help="Path of a SCAP source data stream file"
    )
    parser.add_argument(
        "--output-dir", required=True,
        help="Path of the output directory to save generated files"
    )
    parser.add_argument(
        "--product", required=True,
        help="Product ID, eg. 'rhel9'"
    )
    parser.add_argument(
        "--language", required=True, choices=["bash", "ansible"],
        help="Remediation language, either 'bash' or 'ansible'"
    )
    args = parser.parse_args()
    return args


def extract_ansible_vars(string):
    ansible_vars = {}
    for match in ANSIBLE_VAR_PATTERN.finditer(string):
        variable_name, value = match.groups()
        ansible_vars[variable_name] = value
    return ansible_vars


def indent(string, level):
    out = ""
    for line in string.splitlines():
        out += " " * level + line + "\n"
    return out


def extract_ansible_tasks(string):
    string = ANSIBLE_VAR_PATTERN.sub("\n", string)
    string = indent(string, 4)
    string = ssg.ansible.remove_trailing_whitespace(string)
    return [string]


def comment(text):
    commented_text = ""
    for line in text.split("\n"):
        trimmed_line = line.strip()
        if trimmed_line != "":
            commented_line = "# " + trimmed_line + "\n"
            commented_text += commented_line
    return commented_text


def get_selected_rules(profile):
    selected_rules = set()
    for select in profile.findall("./{%s}select" % XCCDF12_NS):
        if select.get("selected") == "true":
            id_ = select.get("idref")
            if id_.startswith(OSCAP_RULE):
                selected_rules.add(id_)
    return selected_rules


def get_value_refinenements(profile):
    refinements = {}
    for refine_value in profile.findall("./{%s}refine-value" % XCCDF12_NS):
        value_id = refine_value.get("idref")
        selector = refine_value.get("selector")
        refinements[value_id] = selector
    return refinements


def get_remediation(rule, system):
    for fix in rule.findall("./{%s}fix" % XCCDF12_NS):
        if fix.get("system") == system:
            return fix
    return None


def _get_all_itms(benchmark, element_name, callback):
    itms = {}
    el_xpath = ".//{%s}%s" % (XCCDF12_NS, element_name)
    for el in benchmark.findall(el_xpath):
        rule_id = el.get("id")
        itms[rule_id] = callback(el)
    return itms


def get_variable_values(variable):
    values = {}
    for value in variable.findall("./{%s}value" % (XCCDF12_NS)):
        selector = value.get("selector")
        if selector is None:
            selector = DEFAULT_SELECTOR
        if value.text is None:
            values["selector"] = ""
        else:
            values[selector] = value.text
    return values


def get_all_variables(benchmark):
    return _get_all_itms(benchmark, "Value", get_variable_values)


def expand_variables(fix_el, refinements, variables):
    content = fix_el.text[:]
    for sub_el in fix_el.findall("./{%s}sub" % XCCDF12_NS):
        variable_id = sub_el.get("idref")
        values = variables[variable_id]
        selector = refinements.get(variable_id, DEFAULT_SELECTOR)
        if selector == "default":
            return None
        if selector in values:
            value = values[selector]
        else:
            value = list(values.values())[0]
        content += value
        content += sub_el.tail
    return content


def ansible_vars_to_string(variables):
    var_strings = []
    indent = 4 * " "
    for k, v in variables.items():
        var_string = "%s%s: %s\n" % (indent, k, v)
        var_strings.append(var_string)
    return "".join(var_strings)


def ansible_tasks_to_string(tasks):
    # tasks need to be separated by 2 empty lines
    tasks_str = "\n\n".join(tasks)
    tasks_str = ssg.ansible.remove_too_many_blank_lines(tasks_str)
    return tasks_str


class ScriptGenerator:
    def __init__(self, language, product_id, ds_file_path, output_dir):
        self.language = language
        self.product_id = product_id
        self.ds_file_path = ds_file_path
        self.output_dir = output_dir
        self.get_benchmark_data()

    def generate_remediation_scripts(self):
        profile_xpath = "./{%s}component/{%s}Benchmark/{%s}Profile" % (
            datastream_namespace, XCCDF12_NS, XCCDF12_NS)
        for profile in self.ds.findall(profile_xpath):
            self.generate_profile_remediation_script(profile)

    def get_benchmark_data(self):
        self.ds = ET.parse(self.ds_file_path)
        self.ds_file_name = os.path.basename(self.ds_file_path)
        benchmark_xpath = "./{%s}component/{%s}Benchmark" % (
            datastream_namespace, XCCDF12_NS)
        benchmark = self.ds.find(benchmark_xpath)
        self.benchmark_id = benchmark.get("id")
        self.benchmark_version = benchmark.find(
            "./{%s}version" % XCCDF12_NS).text
        self.load_all_remediations(benchmark)
        self.variables = get_all_variables(benchmark)

    def load_all_remediations(self, benchmark):
        self.remediations = {}
        rule_xpath = ".//{%s}Rule" % (XCCDF12_NS)
        for rule_el in benchmark.findall(rule_xpath):
            rule_id = rule_el.get("id")
            system = LANGUAGE_TO_SYSTEM[self.language]
            remediation = get_remediation(rule_el, system)
            self.remediations[rule_id] = remediation

    def generate_profile_remediation_script(self, profile_el):
        if self.language == "ansible":
            output = self.create_output_ansible(profile_el)
        elif self.language == "bash":
            output = self.create_output_bash(profile_el)
        file_path = self.get_output_file_path(profile_el)
        with open(file_path, "wb") as f:
            f.write(output.encode("utf-8"))

    def get_output_file_path(self, profile_el):
        short_profile_id = profile_el.get("id").replace(OSCAP_PROFILE, "")
        file_name = "%s-%s-%s.%s" % (
            self.product_id, LANGUAGE_TO_TARGET[self.language],
            short_profile_id, LANGUAGE_TO_EXTENSION[self.language])
        file_path = os.path.join(self.output_dir, file_name)
        return file_path

    def create_output_ansible(self, profile_el):
        ansible_vars, ansible_tasks = self.collect_ansible_vars_and_tasks(
            profile_el)
        header = self.create_header(profile_el)
        profile_id = profile_el.get("id")
        vars_str = ansible_vars_to_string(ansible_vars)
        tasks_str = ansible_tasks_to_string(ansible_tasks)
        output = (
            "%s\n"
            "- name: Ansible Playbook for %s\n"
            "  hosts: all\n"
            "  vars:\n"
            "%s"
            "  tasks:\n"
            "%s"
            % (header, profile_id, vars_str, tasks_str))
        return output

    def collect_ansible_vars_and_tasks(self, profile_el):
        selected_rules = get_selected_rules(profile_el)
        refinements = get_value_refinenements(profile_el)
        all_vars = {}
        all_tasks = []
        for rule_id, fix_el in self.remediations.items():
            if rule_id not in selected_rules:
                continue
            rule_vars, rule_tasks = self.generate_ansible_rule_remediation(
                fix_el, refinements)
            all_vars.update(rule_vars)
            all_tasks.extend(rule_tasks)
        return (all_vars, all_tasks)

    def create_output_bash(self, profile):
        output = []
        selected_rules = get_selected_rules(profile)
        refinements = get_value_refinenements(profile)
        header = self.create_header(profile)
        output.append(header)
        total = len(selected_rules)
        current = 1
        for rule_id, fix_el in self.remediations.items():
            if rule_id not in selected_rules:
                continue
            rule_remediation = self.generate_bash_rule_remediation(
                rule_id, fix_el, current, total, refinements)
            output.append(rule_remediation)
            current += 1
        return "".join(output)

    def create_header(self, profile):
        if self.language == "ansible":
            shebang_with_newline = "---\n"
            remediation_type = "Ansible Playbook"
            how_to_apply = (
                "# $ ansible-playbook -i \"localhost,\""
                " -c local playbook.yml\n"
                "# $ ansible-playbook -i \"192.168.1.155,\" playbook.yml\n"
                "# $ ansible-playbook -i inventory.ini playbook.yml\n"
            )
        elif self.language == "bash":
            shebang_with_newline = "#!/usr/bin/env bash\n"
            remediation_type = "Bash Remediation Script"
            how_to_apply = "# $ sudo ./remediation-script.sh\n"
        profile_title = profile.find("./{%s}title" % XCCDF12_NS).text
        description = profile.find("./{%s}description" % XCCDF12_NS).text
        commented_profile_description = comment(description)
        xccdf_version_name = "1.2"
        profile_id = profile.get("id")
        fix_header = (
            "%s"
            "%s\n"
            "#\n"
            "# %s for %s\n"
            "#\n"
            "# Profile Description:\n"
            "%s"
            "#\n"
            "# Profile ID:  %s\n"
            "# Benchmark ID:  %s\n"
            "# Benchmark Version:  %s\n"
            "# XCCDF Version:  %s\n"
            "#\n"
            "# This file can be generated by OpenSCAP using:\n"
            "# $ oscap xccdf generate fix --profile %s --fix-type %s %s\n"
            "#\n"
            "# This %s is generated from an XCCDF profile without"
            " preliminary evaluation.\n"
            "# It attempts to fix every selected rule, even if the system is"
            " already compliant.\n"
            "#\n"
            "# How to apply this %s:\n"
            "%s"
            "#\n"
            "%s\n\n" % (
                shebang_with_newline, HASH_ROW, remediation_type,
                profile_title, commented_profile_description, profile_id,
                self.benchmark_id, self.benchmark_version, xccdf_version_name,
                profile_id, self.language, self.ds_file_name,
                remediation_type, remediation_type, how_to_apply, HASH_ROW))
        return fix_header

    def generate_bash_rule_remediation(
            self, rule_id, fix_el, current, total, refinements):
        output = []
        header = (
            "%s\n"
            "# BEGIN fix (%s / %s) for '%s'\n"
            "%s\n" % (HASH_ROW, current, total, rule_id, HASH_ROW))
        output.append(header)
        begin_msg = "(>&2 echo \"Remediating rule %s/%s: '%s'\")\n" % (
            current, total, rule_id)
        output.append(begin_msg)
        expanded_remediation = None
        if fix_el is not None:
            expanded_remediation = expand_variables(
                fix_el, refinements, self.variables)
        if expanded_remediation is not None:
            output.append(expanded_remediation)
        else:
            warning = (
                "(>&2 echo \"FIX FOR THIS RULE '%s' IS MISSING!\")\n" %
                (rule_id))
            output.append(warning)
        end_msg = "\n# END fix for '%s'\n\n" % (rule_id)
        output.append(end_msg)
        return "".join(output)

    def generate_ansible_rule_remediation(self, fix_el, refinements):
        rule_vars = {}
        tasks = []
        expanded_remediation = None
        if fix_el is not None:
            expanded_remediation = expand_variables(
                fix_el, refinements, self.variables)
        if expanded_remediation is not None:
            rule_vars = extract_ansible_vars(expanded_remediation)
            tasks = extract_ansible_tasks(expanded_remediation)
        return rule_vars, tasks


def main():
    args = parse_args()
    if not os.path.exists(args.output_dir):
        os.mkdir(args.output_dir)
    sg = ScriptGenerator(
        args.language, args.product, args.data_stream, args.output_dir)
    sg.generate_remediation_scripts()


if __name__ == "__main__":
    main()
