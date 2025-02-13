#!/usr/bin/python3

import argparse
import pathlib
import shutil

import ssg.environment
import ssg.jinja
import ssg.utils
import ssg.yaml
import ssg.templates
import tests.ssg_test_suite.common
import tests.ssg_test_suite.rule

SSG_ROOT = str(pathlib.Path(__file__).resolve().parent.parent.absolute())

def _create_arg_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="Converts builds content tests to be rendered"
    )
    parser.add_argument(
        "--build-config-yaml", required=True,
        help="YAML file with information about the build configuration. "
             "e.g.: ~/scap-security-guide/build/build_config.yml"
    )
    parser.add_argument(
        "--product-yaml", required=True,
        help="YAML file with information about the product we are building. "
             "e.g.: ~/scap-security-guide/rhel10/product.yml"
    )
    parser.add_argument(
        "--output", required=True,
        help="Output path"
             "e.g.:  ~/scap-security-guide/build/rhel10/tests"
    )
    parser.add_argument(
        "--resolved-rules-dir", required=True,
        help="Directory with <rule-id>.yml resolved rule YAMLs"
             "e.g.: ~/scap-security-guide/build/rhel10/rules"
    )
    parser.add_argument("--root", default=SSG_ROOT,
                        help=f"Path to the project. Defaults to {SSG_ROOT}")
    return parser

def _is_test_file(filename: str) -> bool:
    return (filename.endswith('.pass.sh')
            or filename.endswith('.fail.sh') or
            filename.endswith('.notapplicable.sh'))

def main() -> int:
    args = _create_arg_parser().parse_args()
    env_yaml = ssg.environment.open_environment(
        args.build_config_yaml, args.product_yaml)

    product = ssg.utils.required_key(env_yaml, "product")
    benchmark_cpes =  { env_yaml["cpes"][0][product]["name"], }
    resolved_rules_dir = pathlib.Path(args.resolved_rules_dir)

    for rule_file in resolved_rules_dir.iterdir():  # type: pathlib.Path
        rendered_rule_obj = ssg.yaml.open_raw(str(rule_file))
        rule_path = pathlib.Path(rendered_rule_obj["definition_location"])
        rule_root = rule_path.parent
        rule_id = rule_root.name
        tests_root = rule_root / "tests"
        output_path = pathlib.Path(args.output) / rule_id
        root_path = pathlib.Path(args.root).resolve().absolute()
        templates_root = root_path / "shared" / "templates"
        if tests_root.exists():
            for test in tests_root.iterdir(): # type: pathlib.Path
                if not test.name.endswith(".sh"):
                    continue
                output_path.mkdir(parents=True, exist_ok=True)
                if not _is_test_file(test.name):
                    shutil.copy(test, output_path)
                file_contents = open(str(test.absolute())).read()
                scenario = tests.ssg_test_suite.rule.Scenario(test.name, file_contents)
                if scenario.matches_platform(benchmark_cpes):
                    content = ssg.jinja.process_file_with_macros(str(test.absolute()), env_yaml)
                    with open(output_path / test.name, 'w') as file:
                        file.write(content)
        if rendered_rule_obj["template"] is not None:
            if "name" not in rendered_rule_obj["template"]:
                raise ValueError(f"Invalid template config on rule {rule_id}")
            template_name = rendered_rule_obj["template"]["name"]
            template_root =  templates_root / template_name
            template_tests_root = template_root / "tests"
            if not template_tests_root.exists():
                continue
            if tests_root.exists():
                test_config_path = tests_root/ "test_config.yml"
                deny_templated_scenarios = list()
                if test_config_path.exists():
                    test_config = ssg.yaml.open_raw(str(test_config_path.absolute()))
                    if 'deny_templated_scenarios' in test_config:
                        deny_templated_scenarios = test_config['deny_templated_scenarios']
                for test in tests_root.iterdir():  # type: pathlib.Path
                    if not test.name.endswith(".sh") or test.name in deny_templated_scenarios:
                        print(f'Skipping {test.name} for {rule_id}')
                        continue
                    output_path.mkdir(parents=True, exist_ok=True)
                    template = ssg.templates.Template.load_template(str(templates_root.absolute()), template_name)
                    template_parameters = template.preprocess(rendered_rule_obj["template"]["vars"], "test")
                    env_yaml = env_yaml.copy()
                    jinja_dict = ssg.utils.merge_dicts(env_yaml, template_parameters)
                    file_contents =  ssg.jinja.process_file_with_macros(str(test.absolute()), jinja_dict)
                    scenario = tests.ssg_test_suite.rule.Scenario(test.name, file_contents)
                    if scenario.matches_platform(benchmark_cpes):
                        with open(output_path / test.name, 'w') as file:
                            file.write(file_contents)




    return 0


if __name__ == "__main__":
    raise SystemExit(main())
