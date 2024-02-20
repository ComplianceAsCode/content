#!/usr/bin/python3

import argparse
import os

import ssg.build_yaml
import ssg.controls
import ssg.environment
import ssg.products
import ssg.build_stig
from utils.srg_utils import get_rule_dir_json, update_row, fix_changed_text

SSG_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
RULES_JSON = os.path.join(SSG_ROOT, "build", "rule_dirs.json")
BUILD_CONFIG = os.path.join(SSG_ROOT, "build", "build_config.yml")


def _parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Import a DISA STIG XML file to the policy specific content files.")
    parser.add_argument("input", action="store",
                        help="The path to the STIG XML file.")
    parser.add_argument("-r", "--root", type=str, action="store", default=SSG_ROOT,
                        help=f"Path to SSG root directory (defaults to {SSG_ROOT})")
    parser.add_argument("-c", "--control", required=True,
                        help="Name of the policy to use.")
    parser.add_argument("-j", "--json", type=str, action="store", default=RULES_JSON,
                        help=f"Path to the rules_dir.json (defaults to {RULES_JSON})")
    parser.add_argument("-p", "--product", type=str, action="store", required=True,
                        help="What product product id to use.")
    parser.add_argument("-b", "--build-config-yaml", default=BUILD_CONFIG,
                        help="YAML file with information about the build configuration. "
                        f"Defaults to {BUILD_CONFIG}")
    parser.add_argument('--changed-name', '-n', type=str, action="store",
                        help="The name that DISA uses for the product. Defaults to RHEL 9",
                        default="RHEL 9")
    return parser.parse_args()


def _get_env_yaml(ssg_root: str, product: str, build_config_yaml: str) -> dict:
    product_dir = os.path.join(ssg_root, "products", product)
    product_yaml_path = os.path.join(product_dir, "product.yml")
    env_yaml = ssg.environment.open_environment(
        build_config_yaml, product_yaml_path, os.path.join(ssg_root, "product_properties"))
    return env_yaml


def _get_controls(control_name, ssg_root, env_yaml):
    control_manager = ssg.controls.ControlsManager(os.path.join(ssg_root, "controls"), env_yaml)
    control_manager.load()
    controls = control_manager.get_all_controls_dict(control_name)
    return controls


def main() -> int:
    args = _parse_args()
    ssg_root = args.root
    product = args.product
    control_name = args.control
    stig_filename = args.input
    build_config_yaml = args.build_config_yaml
    changed_name = args.changed_name
    env_yaml = _get_env_yaml(ssg_root, product, build_config_yaml)
    controls = _get_controls(control_name, ssg_root, env_yaml)
    rule_dir_json = get_rule_dir_json(args.json)
    srgs = ssg.build_stig.parse_srgs(stig_filename)

    for stig_id, stig_rule in srgs.items():
        control = controls[stig_id]
        if control is None or control.rules is None or len(control.rules) != 1:
            print(f"Warning: Unable to update {stig_id} since it doesn't have exactly one "
                  f"rule.")
            continue

        rule_id = control.rules[0]
        rule_obj = rule_dir_json[rule_id]
        rule_path = os.path.join(rule_obj["dir"], "rule.yml")
        rule = ssg.build_yaml.Rule.from_yaml(rule_path, env_yaml)
        rule.load_policy_specific_content(rule_path, env_yaml)
        rule_obj = rule_dir_json[rule_id]

        stig_srg_requirement = stig_rule['title']
        rule_srg_requirement = rule.policy_specific_content.get('srg_requirement')
        if rule_srg_requirement != stig_srg_requirement:
            changed_fixtext = fix_changed_text(stig_srg_requirement, changed_name)
            update_row(changed_fixtext, stig_srg_requirement, rule_obj, 'srg_requirement')

        stig_fix_text = stig_rule['fixtext']
        rule_fixtext = rule.policy_specific_content.get('fixtext')
        if rule_fixtext != stig_fix_text:
            changed_fixtext = fix_changed_text(stig_fix_text, changed_name)
            update_row(changed_fixtext, rule_fixtext, rule_obj, 'fixtext')

        stig_checktext = stig_rule['check']
        rule_checktext = rule.policy_specific_content.get('checkfix')
        if rule.checktext != stig_checktext:
            changed_checktext = fix_changed_text(stig_checktext, changed_name)
            update_row(changed_checktext, rule_checktext, rule_obj, 'checktext')

        stig_vuln_discussion = stig_rule['vuln_discussion']
        rule_vuln_discussion = rule.policy_specific_content.get('vuldiscussion')
        if stig_vuln_discussion != rule_vuln_discussion:
            changed_vuln_discussion = fix_changed_text(stig_vuln_discussion, changed_name)
            update_row(changed_vuln_discussion, rule_vuln_discussion, rule_obj,
                       'vuln_discussion')

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
