#!/usr/bin/env python3
import argparse
import pathlib
import sys
import collections
from xml.etree import ElementTree as ET

import ssg.controls
import ssg.environment
import ssg.constants
import ssg.yaml

SSG_ROOT = pathlib.Path(__file__).parent.parent.resolve().absolute()
BUILD_CONFIG = SSG_ROOT / "build" / "build_config.yml"
RULES_JSON = SSG_ROOT / "build" / "rule_dirs"

def _create_arg_parser() -> argparse.ArgumentParser :
    parser = argparse.ArgumentParser(description="Check a given products control profile for correct CCIs")
    parser.add_argument("-p", "--product", required=True, type=str, action="store",
                        help="Product to Check")
    parser.add_argument("-r", "--root", default=SSG_ROOT, type=str, action="store",
                        help=f"Path to the root of the content project. Defaults to {SSG_ROOT}")
    parser.add_argument("-m", "--manual",  required=True, type=str,
                        action="store",
                        help="Path to the released DISA XML product for the given product.")
    parser.add_argument("-g", "--stig-control", type=str, action="store", default=None,
                        help="Path to the SRG control file relevant to the STIG", required=True)
    parser.add_argument("-c", "--build-config-yaml", default=BUILD_CONFIG, type=str,
                        help="YAML file with information about the build configuration")
    parser.add_argument("-s", "--skip", type=str,
                        help="Comma-separated list of STIG IDs to skip")
    return parser

def _get_disa_ccis(disa_xml_path):
    disa_tree = ET.parse(disa_xml_path)
    rules = disa_tree.findall(".//{%s}Rule" % ssg.constants.XCCDF11_NS)
    disa_stig_to_cci = collections.defaultdict(set)
    for rule in rules:
        idents = rule.findall(
            ".//{%s}ident[@system='http://cyber.mil/cci']" % ssg.constants.XCCDF11_NS)
        stig_id = rule.find(".//{%s}version" % ssg.constants.XCCDF11_NS).text
        for ident in idents:
            disa_stig_to_cci[stig_id].add(ident.text)
    return disa_stig_to_cci

def _check_rule(control, disa_stig_to_cci, rule, rule_path):
    rule_yaml = ssg.yaml.open_raw(rule_path)
    disa_refs = set(rule_yaml.get('references', dict()).get('disa', []))
    if len(disa_refs - disa_stig_to_cci.get(control.id, set())) != 0:
        print(f"{control.id} - {rule}")
        return True
    return False


def main() -> int:
    args = _create_arg_parser().parse_args()
    root = pathlib.Path(args.root)
    disa_xml_path = pathlib.Path(args.manual)
    build_config = pathlib.Path(args.build_config_yaml)
    product_properties_path = root / "product_properties"
    product_yaml_path = root / "products" / args.product / "product.yml"
    if not product_yaml_path.exists():
        print(f"Invalid product {args.product}", file=sys.stderr)
    controls_root = root / "controls"
    if not disa_xml_path.exists():
        print(f"Failed to open DISA XML at {disa_xml_path.absolute()}", file=sys.stderr)
        return 1
    if not build_config.exists():
        print("Did not find build config. Is the project built?", file=sys.stderr)
        return 5
    env_yaml = ssg.environment.open_environment(
        build_config.as_posix(), product_yaml_path.as_posix(), product_properties_path.as_posix())
    control_manager = ssg.controls.ControlsManager(controls_root.as_posix(), env_yaml)
    control_manager.load()
    if args.stig_control not in control_manager.policies:
        print("Invalid control/policy id.", file=sys.stderr)
        return 6
    controls = control_manager.get_all_controls(args.stig_control)
    disa_stig_to_cci = _get_disa_ccis(disa_xml_path)
    ids_to_skip = args.skip.split(",")
    failed = False
    for control in controls:
        for rule in control.rules:
            if "=" in rule or control.id in ids_to_skip:
                continue
            rule_path = root / "build" / args.product /  "rules" / f"{rule}.yml"
            if not rule_path.exists():
                print(f"Unable to find rule file {rule_path.as_posix()}.", file=sys.stderr)
                print("Is the product built?", file=sys.stderr)
                return 4
            temp_failed = _check_rule(control, disa_stig_to_cci, rule, rule_path)
            if temp_failed:
                failed = True
    if failed:
        print("Some rules appear to have mismatched CCIs.", file=sys.stderr)
        return 3
    return 0




if __name__ == "__main__":
    raise SystemExit(main())
