#!/usr/bin/python3

import argparse
import json
import os
import re
import sys

try:
    import ssg.build_profile
    import ssg.controls
    import ssg.environment
    import ssg.products
except (ModuleNotFoundError, ImportError):
    sys.stderr.write("Unable to load ssg python modules.\n")
    sys.stderr.write("Hint: run source ./.pyenv.sh\n")
    exit(6)

SSG_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
RULES_JSON = os.path.join(SSG_ROOT, "build", "rule_dirs.json")
BUILD_CONFIG = os.path.join(SSG_ROOT, "build", "build_config.yml")
CONTROLS_DIR = os.path.join(SSG_ROOT, "controls")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Ensures that Control and rule files are in sync")
    parser.add_argument("-j", "--json", type=str, action="store",
                        default=RULES_JSON, help="File to read "
                        "json output of rule_dir_json from (defaults to "
                        f"{RULES_JSON}")
    parser.add_argument("-c", "--build-config-yaml", default=BUILD_CONFIG,
                        help="YAML file with information about the build configuration. "
                        f"Defaults to {BUILD_CONFIG}")
    parser.add_argument("--controls", default=CONTROLS_DIR,
                        help="Directory that contains control files with policy controls.")
    parser.add_argument("product", type=str, help="Product to check has required references")
    parser.add_argument("control", type=str, help="Control to iterate over")
    parser.add_argument("reference", type=str, help="Required reference system to check for")
    return parser.parse_args()


def check_product(product: str) -> None:
    linux_products, other_products = ssg.products.get_all(SSG_ROOT)
    all_products = linux_products.union(other_products)
    if product not in all_products:
        sys.stderr.write(f"{product} is not a valid product\n")
        exit(2)
    return None


def check_files(json_path: str, controls_dir: str) -> None:
    if not os.path.exists(json_path):
        sys.stderr.write(f"JSON at {json_path} was not found.\n")
        sys.stderr.write("Run  ./utils/rule_dir_json.py to create.")
        exit(3)
    if not os.path.exists(controls_dir):
        sys.stderr.write(f"Controls directory {controls_dir} was not found.\n")
        exit(4)
    if not os.path.isdir(controls_dir):
        sys.stderr.write(f"Given controls directory {controls_dir} is not a directory.\n")
        exit(5)


def get_rule_object(all_rules, args, control_rule, env_yaml) -> ssg.build_yaml.Rule:
    rule_dict = all_rules.get(control_rule)
    rule_path = os.path.join(rule_dict['dir'], 'rule.yml')
    rule_obj = ssg.build_yaml.Rule.from_yaml(rule_path, env_yaml=env_yaml)
    rule_obj.normalize(args.product)
    return rule_obj


def get_controls_env(args):
    product_base = os.path.join(SSG_ROOT, "products", args.product)
    product_yaml = os.path.join(product_base, "product.yml")
    env_yaml = ssg.environment.open_environment(
        args.build_config_yaml, product_yaml, os.path.join(SSG_ROOT, "product_properties"))
    controls_manager = ssg.controls.ControlsManager(args.controls, env_yaml)
    controls_manager.load()
    return controls_manager, env_yaml


def check_stig(reference: str, control_id: str) -> bool:
    return reference == 'stigid' and not re.match(r'(\w){4}-\w{2}-\d{6}', control_id)


def check_cis(reference: str, control_id: str) -> bool:
    return reference == 'cis' and not re.match(r"\d(\.\d+){0,3}", control_id)


def should_rule_be_checked(reference: str, control_id: str) -> bool:
    if check_cis(reference, control_id):
        print(f'Skipping {control_id} as it does not match a CIS id.')
        return False
    if check_stig(reference, control_id):
        print(f'Skipping {control_id} as it does not match a STIG id.')
        return False
    return True


def does_rule_exist(all_rules: dict, control_rule: str) -> bool:
    if all_rules.get(control_rule) is None:
        print(f'{control_rule} was not found in the project.')
        return False
    return True


def check_reference(reference: str, rule_object: ssg.build_yaml.Rule, control_id: str,
                    product: str) -> bool:
    if reference in rule_object.references and control_id \
            not in rule_object.references[reference]:
        print(f"{rule_object.id_} {reference}@{product} "
              f"{rule_object.references[reference]} does not match the control id "
              f"{control_id}")
        return False
    return True


def downgrade_bool(current: bool, target: bool) -> bool:
    if not current or not target:
        return False
    return True


def main():
    args = parse_args()

    check_product(args.product)

    rule_dir_json = open(args.json, 'r')
    all_rules = json.load(rule_dir_json)

    controls_manager, env_yaml = get_controls_env(args)

    ok = True
    for control in controls_manager.get_all_controls(args.control):
        for control_rule in control.selected:
            control_id = str(control.id)
            exists = does_rule_exist(all_rules, control_rule)
            ok = downgrade_bool(ok, exists)
            if should_rule_be_checked(args.reference, control_id):
                rule_object = get_rule_object(all_rules, args, control_rule, env_yaml)
                check_ok = check_reference(args.reference, rule_object, control_id, args.product)
                ok = downgrade_bool(ok, check_ok)

    if not ok:
        exit(1)


if __name__ == '__main__':
    main()
