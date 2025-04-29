#!/usr/bin/env python3

import argparse
import logging
import os
import pathlib
import sys
from typing import TypeVar, Generator, Set, Dict
import multiprocessing

import ssg.constants
import ssg.environment
import ssg.jinja
import ssg.utils
import ssg.yaml
import ssg.templates

SSG_ROOT = str(pathlib.Path(__file__).resolve().parent.parent.absolute())
JOB_COUNT = multiprocessing.cpu_count()
T = TypeVar("T")
TESTS_CONFIG_NAME = "test_config.yml"


def _create_arg_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="Converts built content tests to be rendered.")
    parser.add_argument("--build-config-yaml", required=True, type=str,
                        help="YAML file with information about the build configuration. "
                             "e.g.: ~/scap-security-guide/build/build_config.yml")
    parser.add_argument("--product-yaml", required=True, type=str,
                        help="YAML file with information about the product we are building. "
                             "e.g.: ~/scap-security-guide/rhel10/product.yml")
    parser.add_argument("--output", required=True, type=str,
                        help="Output path"
                             "e.g.:  ~/scap-security-guide/build/rhel10/tests")
    parser.add_argument("--resolved-rules-dir", required=True, type=str,
                        help="Directory with <rule-id>.yml resolved rule YAMLs "
                             "e.g.: ~/scap-security-guide/build/rhel10/rules")
    parser.add_argument("--log-level", action="store", type=str, default="ERROR",
                        choices=["ERROR", "WARNING", "INFO", "DEBUG", "TRACE"],
                        help="What level to log at. Defaults to ERROR.")
    parser.add_argument("--root", default=SSG_ROOT,
                        help=f"Path to the project. Defaults to {SSG_ROOT}")
    parser.add_argument("--jobs", "-j", type=int, default=JOB_COUNT,
                        help=f"Number of cores to use. Defaults to {JOB_COUNT} on this system.")
    return parser


def _write_path(file_contents: str, output_path: os.PathLike) -> None:
    with open(output_path, "w") as file:
        file.write(file_contents)
        file.write("\n")


def _is_test_file(filename: str) -> bool:
    return filename.endswith(('.pass.sh', '.fail.sh', '.notapplicable.sh'))


def _get_deny_templated_scenarios(test_config_path: pathlib.Path) -> Set[str]:
    if test_config_path.exists():
        test_config = ssg.yaml.open_raw(str(test_config_path.absolute()))
        deny_templated_scenarios = test_config.get('deny_templated_scenarios', set())
        return deny_templated_scenarios
    return set()


def _process_shared_file(env_yaml: dict, file: pathlib.Path, shared_output_path: pathlib.Path) \
        -> None:
    file_contents = ssg.jinja.process_file_with_macros(str(file.absolute()), env_yaml)
    shared_script_path = shared_output_path / file.name
    _write_path(file_contents, shared_script_path)


def _copy_and_process_shared(env_yaml: dict, output_path: pathlib.Path, root_path: pathlib.Path) \
        -> None:
    tests_shared_root = root_path / "tests" / "shared"
    shared_output_path = output_path / "shared"
    shared_output_path.mkdir(parents=True, exist_ok=True)
    for file in tests_shared_root.iterdir():  # type: pathlib.Path
        # We only support one level deep, this avoids recursive functions
        if file.is_dir():
            for sub_file in file.iterdir():
                shared_output_path_sub = shared_output_path / file.name
                shared_output_path_sub.mkdir(parents=True, exist_ok=True)
                _process_shared_file(env_yaml, sub_file, shared_output_path_sub)
        else:
            _process_shared_file(env_yaml, file, shared_output_path)


def _get_platform_from_file_contents(file_contents: str) -> str:
    # Some tests don't have an explict platform assume always applicable
    platform = "multi_platform_all"
    for line in file_contents.split("\n"):
        if line.startswith('# platform'):
            platform_parts = line.split('=')
            if len(platform_parts) == 2:
                platform = platform_parts[1]
                break
    return platform.strip()


def _process_local_tests(product: str, env_yaml: dict, rule_output_path: pathlib.Path,
                         rule_tests_root: pathlib.Path) -> None:
    logger = logging.getLogger()
    for test in rule_tests_root.iterdir():  # type: pathlib.Path
        if test.is_dir():
            logger.warning("Skipping directory %s in rule %s", test.name,
                           rule_output_path.name)
            continue
        if not _is_test_file(test.name):
            file_contents = ssg.jinja.process_file_with_macros(str(test.absolute()),
                                                               env_yaml)
            output_file = rule_output_path / test.name
            rule_output_path.mkdir(parents=True, exist_ok=True)
            _write_path(file_contents, output_file)
        file_contents = test.read_text()
        platform = _get_platform_from_file_contents(file_contents)
        if ssg.utils.is_applicable_for_product(platform, product):
            content = ssg.jinja.process_file_with_macros(str(test.absolute()), env_yaml)
            rule_output_path.mkdir(parents=True, exist_ok=True)
            _write_path(content, rule_output_path / test.name)


def _get_test_dir_config(rule_path: pathlib.Path) -> Dict:
    test_config = dict()
    rule_root = rule_path.parent
    tests_dir = rule_root / "tests"
    test_config_path = tests_dir / TESTS_CONFIG_NAME
    if test_config_path.exists():
        test_config = ssg.yaml.open_raw(test_config_path)
    return test_config


def _process_templated_tests(env_yaml: Dict, rendered_rule_obj: Dict, templates_root: pathlib.Path,
                             rule_output_path: pathlib.Path):
    logger = logging.getLogger()
    rule_path = pathlib.Path(rendered_rule_obj['definition_location'])
    product = rule_output_path.parent.parent.name
    rule_id = rule_path.parent.name
    if "name" not in rendered_rule_obj["template"]:
        raise ValueError(f"Invalid template config on rule {rule_id}")
    template_name = rendered_rule_obj["template"]["name"]
    template_root = templates_root / template_name
    template_tests_root = template_root / "tests"

    if not template_tests_root.exists():
        logger.debug("Template %s doesn't have tests. Skipping for rule %s.",
                     template_name, rule_id)
        return
    test_config = _get_test_dir_config(rule_path)
    all_templated_tests = set(x.name for x in template_tests_root.iterdir())
    templated_tests = ssg.utils.select_templated_tests(test_config, all_templated_tests)
    for test_name in templated_tests:  # type: str
        test = template_tests_root / test_name
        if not test.name.endswith(".sh"):
            logger.warning("Skipping %s for %s as it isn't a test scenario",
                           test.name, rule_id)
            continue
        template = ssg.templates.Template.load_template(str(templates_root.absolute()),
                                                        template_name)
        rendered_rule_obj["template"]["vars"]["_rule_id"] = rule_id
        template_parameters = template.preprocess(rendered_rule_obj["template"]["vars"], "test")
        env_yaml = env_yaml.copy()
        jinja_dict = ssg.utils.merge_dicts(env_yaml, template_parameters)
        file_contents = ssg.jinja.process_file_with_macros(str(test.absolute()), jinja_dict)
        platform = _get_platform_from_file_contents(file_contents)
        if ssg.utils.is_applicable_for_product(platform, product):
            rule_output_path.mkdir(parents=True, exist_ok=True)
            test_output_path = rule_output_path / test.name
            _write_path(file_contents, test_output_path)
            logger.debug("Wrote scenario %s for rule %s", test.name, rule_id)
        else:
            logger.warning("Skipping scenario %s for rule %s as it not applicable to %s",
                           test.name, rule_id, product)


def _process_rules(env_yaml: Dict, output_path: pathlib.Path,
                   templates_root: pathlib.Path, product_rules: list,
                   resolved_root: pathlib.Path) -> None:
    product = resolved_root.parent.name
    for rule_id in product_rules:
        rule_file = resolved_root / f'{rule_id}.yml'

        rendered_rule_obj = ssg.yaml.open_raw(str(rule_file))
        rule_path = pathlib.Path(rendered_rule_obj["definition_location"])
        rule_root = rule_path.parent

        rule_tests_root = rule_root / "tests"
        rule_output_path = output_path / rule_id
        if rendered_rule_obj["template"] is not None:
            _process_templated_tests(env_yaml, rendered_rule_obj, templates_root, rule_output_path)
        if rule_tests_root.exists():
            _process_local_tests(product, env_yaml, rule_output_path, rule_tests_root)


def _get_rules_in_profile(built_profiles_root) -> Generator[str, None, None]:
    for profile_file in built_profiles_root.iterdir():  # type: pathlib.Path
        if not profile_file.name.endswith(".profile"):
            continue
        profile_data = ssg.yaml.open_raw(str(profile_file.absolute()))
        for selection in profile_data["selections"]:
            if "=" not in selection:
                yield selection


def main() -> int:
    args = _create_arg_parser().parse_args()
    logging.basicConfig(level=logging.getLevelName(args.log_level))
    env_yaml = ssg.environment.open_environment(args.build_config_yaml, args.product_yaml,
                                                os.path.join(args.root, "product_properties"))

    root_path = pathlib.Path(args.root).resolve()
    output_path = pathlib.Path(args.output).resolve()
    resolved_rules_dir = pathlib.Path(args.resolved_rules_dir)
    if not resolved_rules_dir.exists() or not resolved_rules_dir.is_dir():
        logging.error("Unable to find product at %s", str(resolved_rules_dir))
        logging.error("Is the product built?")
        return 1

    output_path.mkdir(parents=True, exist_ok=True)
    _copy_and_process_shared(env_yaml, output_path, root_path)

    built_profiles_root = resolved_rules_dir.parent / "profiles"
    rules_in_profiles = list(set(_get_rules_in_profile(built_profiles_root)))

    templates_root = root_path / "shared" / "templates"
    processes = list()
    for chunk in range(args.jobs):
        process_args = (env_yaml, output_path, templates_root,
                        rules_in_profiles[chunk::args.jobs], resolved_rules_dir)
        process = multiprocessing.Process(target=_process_rules, args=process_args)
        processes.append(process)
        process.start()
    for process in processes:
        process.join()
    # Write a file for CMake
    # So we don't have a dependency on a folder
    done_file = output_path / ".test_done"
    done_file.touch()
    return 0


if __name__ == "__main__":
    sys.exit(main())
