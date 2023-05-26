import argparse
import collections
import os
import re

import ssg.build_yaml
import ssg.components
import ssg.environment
import ssg.rules
import ssg.yaml


def parse_args():
    parser = argparse.ArgumentParser(
        description="Test components data consistency")
    parser.add_argument("--source-dir", help="Path to the root directory")
    parser.add_argument("--build-dir", help="Path to the build directory")
    parser.add_argument("--product", help="Product ID")
    return parser.parse_args()


def get_component_by_template(
        rule, package_to_component, template_to_component):
    template = rule.template
    component = None
    reason = None
    if not template:
        return (component, reason)
    template_name = template["name"]
    template_vars = template["vars"]
    if template_name in template_to_component:
        component = template_to_component[template_name]
        reason = (
            "all rules using template '%s' should be assigned to component "
            "'%s'" % (template_name, component))
    elif template_name in ["package_installed", "package_removed"]:
        package = template_vars["pkgname"]
        component = package_to_component.get(package, package)
        reason = (
            "rule uses template '%s' with 'pkgname' parameter set to '%s' "
            "which is a package that already belongs to component '%s'" %
            (template_name, package, component))
    elif template_name in ["service_enabled", "service_disabled"]:
        if "packagename" in template_vars:
            package = template_vars["packagename"]
        else:
            package = template_vars["servicename"]
        component = package_to_component.get(package, package)
        reason = (
            "rule uses template '%s' checking service '%s' provided by "
            "package '%s' which is a package that already belongs to "
            "component '%s'" % (
                template_name,  template_vars["servicename"],
                package, component))
    return (component, reason)


def test_nonexistent_rules(rules_in_benchmark, rules_with_component):
    nonexistent_rules = rules_with_component - rules_in_benchmark
    if nonexistent_rules:
        print("The following rules aren't part of the benchmark:")
        for rule_id in nonexistent_rules:
            print("- %s" % (rule_id))
        return False
    return True


def test_unmapped_rules(rules_in_benchmark, rules_with_component):
    unmapped_rules = rules_in_benchmark - rules_with_component
    if unmapped_rules:
        print("The following rules aren't part of any component:")
        for x in unmapped_rules:
            print("- " + x)
            return False
    return True


def find_all_rules(base_dir):
    for rule_dir in ssg.rules.find_rule_dirs(base_dir):
        rule_id = ssg.rules.get_rule_dir_id(rule_dir)
        yield rule_id


def iterate_over_resolved_rules(built_rules_dir):
    for file_name in os.listdir(built_rules_dir):
        file_path = os.path.join(built_rules_dir, file_name)
        try:
            rule = ssg.build_yaml.Rule.from_yaml(file_path)
        except ssg.yaml.DocumentationNotComplete:
            pass
        yield rule


def test_templates(
        rule, package_to_component, rule_components, template_to_component):
    result = True
    candidate, reason = get_component_by_template(
        rule, package_to_component, template_to_component)
    if candidate and candidate not in rule_components:
        result = False
        print(
            "Rule '%s' should be assigned to component '%s', because %s." %
            (rule.id_, candidate, reason))
    return result


def test_package_platform(rule, package_to_component, rule_components):
    match = re.match(r"package\[([\w\-_]+)\]", rule.platform)
    if not match:
        return True
    result = True
    for package in match.groups():
        component = package_to_component.get(package, package)
        if component not in rule_components:
            print(
                "Rule '%s' should be assigned to component '%s', "
                "because it uses the package['%s'] platform." %
                (rule.id_, component, package))
            result = False
    return result


def test_platform(rule, package_to_component, rule_components):
    platform = rule.platform
    if platform is None:
        return True
    if "package" in platform:
        return test_package_platform(
            rule, package_to_component, rule_components)
    elif platform == "grub2" and "grub2" not in rule_components:
        print(
            "Rule '%s' should be assigned to component 'grub2', "
            "because it uses the 'grub2' platform." %
            (rule.id_))
        return False
    elif platform == "sssd-ldap" and "sssd" not in rule_components:
        print(
            "Rule '%s' should be assigned to component 'sssd', "
            "because it uses the 'sssd-ldap' platform." %
            (rule.id_))
        return False
    return True


def test_group(rule, rule_components, rule_groups, group_to_components):
    result = True
    for g in rule_groups:
        components = group_to_components.get(g, [])
        for c in components:
            if c not in rule_components:
                print(
                    "Rule '%s' should be in component '%s' because it's a "
                    "member of '%s' group." % (rule.id_, c, g))
                result = False
    return result


def get_rule_to_groups(groups_dir):
    rule_to_groups = collections.defaultdict(list)
    for file_name in os.listdir(groups_dir):
        group_file_path = os.path.join(groups_dir, file_name)
        group = ssg.build_yaml.Group.from_yaml(group_file_path)
        for rule in group.rules:
            rule_to_groups[rule].append(group.id_)
    return rule_to_groups


def main():
    result = 0
    args = parse_args()
    components_dir = os.path.join(args.source_dir, "components")
    components = ssg.components.load(components_dir)
    rule_to_components = ssg.components.rule_components_mapping(components)
    rules_with_component = set(rule_to_components.keys())
    linux_os_guide_dir = os.path.join(args.source_dir, "linux_os", "guide")
    rules_in_benchmark = set(find_all_rules(linux_os_guide_dir))
    if not test_nonexistent_rules(rules_in_benchmark, rules_with_component):
        result = 1
    if not test_unmapped_rules(rules_in_benchmark, rules_with_component):
        result = 1
    package_to_component = ssg.components.package_component_mapping(
        components)
    template_to_component = ssg.components.template_component_mapping(
        components)
    group_to_components = ssg.components.group_components_mapping(components)
    product_dir = os.path.join(args.build_dir, args.product)
    groups_dir = os.path.join(product_dir, "groups")
    rule_to_groups = get_rule_to_groups(groups_dir)
    rules_dir = os.path.join(product_dir, "rules")
    for rule in iterate_over_resolved_rules(rules_dir):
        rule_components = [c.name for c in rule_to_components[rule.id_]]
        if not test_templates(
                rule, package_to_component, rule_components,
                template_to_component):
            result = 1
        if not test_platform(rule, package_to_component, rule_components):
            result = 1
        rule_groups = rule_to_groups[rule.id_]
        if not test_group(
                rule, rule_components, rule_groups, group_to_components):
            result = 1
    exit(result)


if __name__ == "__main__":
    main()
