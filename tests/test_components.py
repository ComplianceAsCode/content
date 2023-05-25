import argparse
import os

import ssg.build_yaml
import ssg.components
import ssg.environment
import ssg.rules
import ssg.yaml


def parse_args():
    parser = argparse.ArgumentParser(
        description="Test components data consistency")
    parser.add_argument(
        "--build-config-yaml", help="Path to the build config YAML file")
    parser.add_argument("--product-yaml", help="Path to the product YAML file")
    parser.add_argument("--source-dir", help="Path to the root directory")
    return parser.parse_args()


def get_components_by_template(rule, package_to_components, template_to_component):
    template = rule.template
    if not template:
        return []
    template_name = template["name"]
    template_vars = template["vars"]
    components = []
    if template_name in template_to_component:
        component = template_to_component[template_name]
        reason = (
            "all rules using template '%s' should be assigned to component "
            "'%s'" % (template_name, component))
        components.append((component, reason))
    elif template_name in ["package_installed", "package_removed"]:
        package = template_vars["pkgname"]
        component = package_to_components.get(package, package)
        reason = (
            "rule uses template '%s' with 'pkgname' parameter set to '%s' "
            "which is a package that already belongs to component '%s'" %
            (template_name, package, component))
        components.append((component, reason))
    elif template_name in ["service_enabled", "service_disabled"]:
        if "packagename" in template_vars:
            package = template_vars["packagename"]
        else:
            package = template_vars["servicename"]
        component = package_to_components.get(package, package)
        reason = (
            "rule uses template '%s' checking service '%s' provided by "
            "package '%s' which is a package that already belongs to "
            "component '%s'" % (
                template_name,  template_vars["servicename"],
                package, component))
        components.append((component, reason))
    return components


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


def iterate_over_all_rules(base_dir, env_yaml):
    """
    Generator which yields all rule objects within a given base_dir,
    recursively
    """
    for rule_dir in ssg.rules.find_rule_dirs(base_dir):
        rule_yaml_file_path = ssg.rules.get_rule_dir_yaml(rule_dir)
        try:
            rule = ssg.build_yaml.Rule.from_yaml(rule_yaml_file_path, env_yaml)
        except ssg.yaml.DocumentationNotComplete:
            pass
        yield rule


def test_templates(
        linux_os_guide_dir, env_yaml,
        package_to_components, rules_to_components, template_to_component):
    result = True
    for rule in iterate_over_all_rules(linux_os_guide_dir, env_yaml):
        candidates = get_components_by_template(
            rule, package_to_components, template_to_component)
        rule_components = [c.name for c in rules_to_components[rule.id_]]
        for candidate, reason in candidates:
            if candidate not in rule_components:
                result = False
                print(
                    "Rule '%s' should be assigned to component '%s', "
                    "because %s." % (rule.id_, candidate, reason))
    return result


def main():
    result = 0
    args = parse_args()
    components_dir = os.path.join(args.source_dir, "components")
    components = ssg.components.load(components_dir)
    rule_to_components = ssg.components.rule_components_mapping(components)
    linux_os_guide_dir = os.path.join(args.source_dir, "linux_os", "guide")
    rules_with_component = set(rule_to_components.keys())
    rules_in_benchmark = set(ssg.rules.find_all_rules(linux_os_guide_dir))
    if not test_nonexistent_rules(rules_in_benchmark, rules_with_component):
        result = 1
    if not test_unmapped_rules(rules_in_benchmark, rules_with_component):
        result = 1
    env_yaml = ssg.environment.open_environment(
        args.build_config_yaml, args.product_yaml)
    package_to_component = ssg.components.package_component_mapping(
        components)
    template_to_component = ssg.components.template_component_mapping(
        components)
    if not test_templates(
            linux_os_guide_dir, env_yaml,
            package_to_component, rule_to_components, template_to_component):
        result = 1
    exit(result)


if __name__ == "__main__":
    main()
