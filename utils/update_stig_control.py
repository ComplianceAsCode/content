import argparse
import os
from typing import List, Dict

import ssg.controls
import ssg.environment
import ssg.build_stig
from utils.import_srg_spreadsheet import (write_yaml_section_replacement, get_cac_status,
                                          replace_yaml_key_file)
import ssg.yaml

SSG_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
BUILD_CONFIG = os.path.join(SSG_ROOT, "build", "build_config.yml")


def _parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("-r", "--root", type=str, action="store", default=SSG_ROOT,
                        help="Path to SSG root directory (defaults to %s)" % SSG_ROOT)
    parser.add_argument("-c", "--control", type=str, action="store",
                        help="Path to control to update.", required=True)
    parser.add_argument("-m", "--manual", type=str, action="store", required=True,
                        help="Path to XML XCCDF manual file to use as the source of the STIGs")
    parser.add_argument("-p", "--product", type=str, action="store", required=True,
                        help="What product to use for the update.")
    parser.add_argument("-bc", "--build-config-yaml", default=BUILD_CONFIG,
                        help="YAML file with information about the build configuration")
    parser.add_argument("--dry-run", action="store_true", default=False)
    return parser.parse_args()


def _get_env_yaml(root: str, product_name: str, build_config_yaml: str) -> dict:
    product_dir = os.path.join(root, "products", product_name)
    product_yaml_path = os.path.join(product_dir, "product.yml")
    env_yaml = ssg.environment.open_environment(
            build_config_yaml, product_yaml_path, os.path.join(root, "product_properties"))
    return env_yaml


def _get_controls(control: str, env_yaml: dict, ssg_root: str) -> List[ssg.controls.Control]:
    controls_root = os.path.join(ssg_root, 'controls')
    control_manager = ssg.controls.ControlsManager(controls_root, env_yaml)
    control_manager.load()
    controls = control_manager.get_all_controls(control)
    return controls


def _clean_up_tite(product: dict, title: str) -> str:
    return title.replace(product['full_name'], 'The operating system')


def _clean_up_title_write(title: str) -> str:
    return title.replace('The operating system', '{{{ full_name }}}')


def _update_row(dry_run: bool, path: str, section: str, replacement: str) -> None:
    if dry_run is True:
        return
    write_yaml_section_replacement(path, replacement, section)


def main() -> int:
    args = _parse_args()
    env_yaml = _get_env_yaml(args.root, args.product, args.build_config_yaml)
    ssg_controls = _get_controls(args.control, env_yaml, args.root)
    srg_controls = ssg.build_stig.parse_srgs(args.manual)
    for ssg_control in ssg_controls:
        srg_control = srg_controls.get(ssg_control.id)
        if srg_control is None:
            continue
        srg_path = os.path.join(args.root, 'controls', args.control, '{}.yml'.format(ssg_control.id))
        if _clean_up_tite(env_yaml, ssg_control.title) != srg_control["title"]:
            _update_row(args.dry_run, srg_path, 'title', _clean_up_title_write(srg_control['title']))
        if get_cac_status(srg_control["severity"]) != ssg_control.levels[0]:
            with open(srg_path, 'r') as f:
                target_line = f'            - {ssg_control.levels[0]}\n'
                new_line = f'            - {get_cac_status(srg_control["severity"])}\n'
                new_content = ''.join(f.readlines()).replace(target_line, new_line)
            with open(srg_path, 'w') as f:
                f.write(new_content)

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
