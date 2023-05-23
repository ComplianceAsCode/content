#!/usr/bin/python3

import argparse
import collections
import csv
import re
import subprocess
import yaml

from pathlib import Path

import ssg.build_yaml
import ssg.environment


def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("--build-config-yaml")
    parser.add_argument("--product-yaml")
    parser.add_argument("--target-dir")
    parser.add_argument("--benchmark-root")
    args = parser.parse_args()
    return args


def get_all_groups(benchmark_root):
    groups = []
    for group_yml in benchmark_root.glob("**/group.yml"):
        groups.append(group_yml.parent.name)
    return sorted(groups)


def get_group_to_components_mapping():
    group_to_components = {}
    with open("utils/group_to_component.csv") as csvfile:
        reader = csv.reader(csvfile)
        for row in reader:
            group = row[0]
            components = set(row[1:])
            group_to_components[group] = components
    return group_to_components


def get_package_to_components_mapping():
    package_to_component = {}
    with open("utils/component_to_package.csv") as csvfile:
        reader = csv.reader(csvfile)
        for row in reader:
            component = row[0]
            packages = set(row)
            for package in packages:
                package_to_component[package] = component
    return package_to_component


def get_component_to_package_mapping():
    component_to_package = {}
    with open("utils/component_to_package.csv") as csvfile:
        reader = csv.reader(csvfile)
        for row in reader:
            component = row[0]
            packages = list(row)
            component_to_package[component] = packages
    return component_to_package


def get_components_by_groups(rule_groups, group_to_components):
    components = set()
    for group in rule_groups:
        components |= group_to_components.get(group, set())
    return components


template_to_component = {
    "accounts_password": "pam",
    "auditd_lineinfile": "audit",
    "audit_rules_dac_modification": "audit",
    "audit_rules_file_deletion_events": "audit",
    "audit_rules_login_events": "audit",
    "audit_rules_path_syscall": "audit",
    "audit_rules_privileged_commands": "audit",
    "audit_rules_syscall_events": "audit",
    "audit_file_contents": "audit",
    "audit_rules_unsuccessful_file_modification": "audit",
    "audit_rules_unsuccessful_file_modification_o_creat": "audit",
    "audit_rules_unsuccessful_file_modification_o_trunc_write": "audit",
    "audit_rules_unsuccessful_file_modification_rule_order": "audit",
    "audit_rules_usergroup_modification": "audit",
    "dconf_ini_file": "dconf",
    "firefox_lockpreference": "firefox",
    "grub2_bootloader_argument": "grub2",
    "grub2_bootloader_argument_absent": "grub2",
    "kernel_build_config": "kernel",
    "kernel_module_disabled": "kernel",
    "mount": "filesystem",
    "mount_option": "filesystem",
    "mount_option_remote_filesystems": "filesystem",
    "mount_option_removable_partitions": "filesystem",
    "pam_options": "pam",
    "sebool": "selinux",
    "sshd_lineinfile": "openssh",
    "sudo_defaults_option": "sudo",
    "sysctl": "kernel"
}


def get_components_by_template(rule, package_to_components):
    template = rule.template
    if not template:
        return set()
    template_name = template["name"]
    template_vars = template["vars"]
    components = []
    if template_name in template_to_component:
        components.append(template_to_component[template_name])
    elif template_name in ["package_installed", "package_removed"]:
        package = template_vars["pkgname"]
        component = package_to_components.get(package, package)
        components.append(component)
    elif template_name in ["service_enabled", "service_disabled"]:
        if "packagename" in template_vars:
            package = template_vars["packagename"]
        else:
            package = template_vars["servicename"]
        component = package_to_components.get(package, package)
        components.append(component)
    elif template_name in ["file_existence", "file_groupowner", "file_owner", "file_permissions"]:
        filepath = template_vars["filepath"]
        if not isinstance(filepath, str):
            return set()
        package = package_provides(filepath)
        if package is None:
            return set()
        component = package_to_components.get(package, package)
        components.append(component)
    return set(components)


def print_component_to_rule(component_to_rule):
    for component in sorted(component_to_rule):
        print(f"{component}:")
        rules = sorted(component_to_rule[component])
        for rule in rules:
            print(f"- {rule}")
        print()


def assign_rule_components(rule_id, components, component_to_rule):
    if len(components) != 0:
        for c in components:
            component_to_rule[c].append(rule_id)
    else:
        component_to_rule["operating-system"].append(rule_id)


def package_provides(path):
    p = subprocess.run(
        ["dnf", "repoquery", "--qf", "%{name}", "-f", path],
        capture_output=True)
    try:
        first = p.stdout.decode("utf-8").splitlines()[0]
        return first
    except IndexError:
        return None


def get_components_by_platform(rule, package_to_components):
    platform = rule.platform
    if platform is None:
        return set()
    components = []
    if "package" in platform:
        match = re.match(r"package\[([\w\-_]+)\]", platform)
        if match:
            for package in match.groups():
                component = package_to_components.get(package, package)
                components.append(component)
    elif platform == "grub2":
        components.append("grub2")
    elif platform == "sssd-ldap":
        components.append("sssd")
    return set(components)


def get_components_by_id(rule_id):
    keywords = [
        "kernel", "abrt", "pam", "httpd", "fips", "grub2"
    ]
    components = []
    for k in keywords:
        if k in rule_id:
            components.append(k)
    return set(components)


def get_components(
        rule, rule_groups, group_to_components, package_to_components):
    components = get_components_by_id(rule.id_)
    components |= get_components_by_groups(rule_groups, group_to_components)
    components |= get_components_by_platform(rule, package_to_components)
    components |= get_components_by_template(rule, package_to_components)
    return components


def iterate_over_rules(benchmark_root, env_yaml):
    benchmark_root = Path(benchmark_root).resolve()
    for rule_path in benchmark_root.glob("**/rule.yml"):
        relative_rule_path = rule_path.relative_to(benchmark_root)
        rule_dir = relative_rule_path.parent
        rule_groups = rule_dir.parts[:-1]
        try:
            rule = ssg.build_yaml.Rule.from_yaml(rule_path, env_yaml)
        except ssg.yaml.DocumentationNotComplete:
            pass
        yield rule, rule_groups


def export_components_as_yaml(component_to_rule, target_dir, component_to_group):
    target_path = Path(target_dir).resolve()
    if not target_path.exists():
        target_path.mkdir()
    component_to_package = get_component_to_package_mapping()
    component_to_templates = collections.defaultdict(list)
    for template, component in template_to_component.items():
        component_to_templates[component].append(template)
    for component, rules in component_to_rule.items():
        file_name = target_path / (component + ".yml")
        if component in component_to_package:
            packages = component_to_package[component]
        else:
            packages = [component]
        data = {
            "name": component,
            "packages": sorted(packages),
            "rules": sorted(rules),
        }
        templates = sorted(component_to_templates[component])
        if len(templates) > 0:
            data["templates"] = templates
        groups = sorted(component_to_group[component])
        if len(groups) > 0:
            data["groups"] = groups
        with open(file_name, 'w') as f:
            yaml.dump(data, f)


def get_component_to_group(group_to_components):
    component_to_group = collections.defaultdict(list)
    for group, components in group_to_components.items():
        for c in components:
            component_to_group[c].append(group)
    return component_to_group

def main():
    args = parse_args()
    env_yaml = ssg.environment.open_environment(
        args.build_config_yaml, args.product_yaml)
    group_to_components = get_group_to_components_mapping()
    package_to_components = get_package_to_components_mapping()
    component_to_rule = collections.defaultdict(list)
    benchmark_root = Path(args.benchmark_root).resolve()
    for rule, rule_groups in iterate_over_rules(benchmark_root, env_yaml):
        components = get_components(
            rule, rule_groups, group_to_components, package_to_components)
        assign_rule_components(rule.id_, components, component_to_rule)
    #print_component_to_rule(component_to_rule)
    component_to_group = get_component_to_group(group_to_components)
    export_components_as_yaml(
        component_to_rule, args.target_dir, component_to_group)


if __name__ == "__main__":
    main()
