#!/usr/bin/env python3

import json
import os.path
import re
import sys

from collections import defaultdict
from typing import List

import ssg.environment
import ssg.yaml
from utils.find_unused_rules import SSG_ROOT
from ssg.xml import open_xml, PREFIX_TO_NS
from ssg.controls import ControlsManager

PRODUCT = "rhel9"
RHEL9_XML = os.path.join(SSG_ROOT, "shared", "references", "disa-stig-rhel9-v2r1-xccdf-manual.xml")
PRODUCT_YAML = os.path.join(SSG_ROOT, "products", PRODUCT, "product.yml")
BUILD_YAML = os.path.join(SSG_ROOT, "build", "build_config.yml")
REALLY_BAD_SECTION_REGEX = r'^\s+disa:.+$'

def main() -> int:
    rule_dirs_path = os.path.join(SSG_ROOT, "build", "rule_dirs.json")
    env_yaml = ssg.environment.open_environment(BUILD_YAML, PRODUCT_YAML)


    with open(rule_dirs_path, 'r') as json_fp:
        rules = json.load(json_fp)
    root = open_xml(RHEL9_XML).getroot()
    stigid_to_cci = defaultdict(set)
    for rule in root.findall('.//xccdf-1.1:Rule', PREFIX_TO_NS):
        stig_id = rule.find('xccdf-1.1:version', PREFIX_TO_NS).text
        ccis_elems = rule.findall(
            "xccdf-1.1:ident[@system='http://cyber.mil/cci']", PREFIX_TO_NS)
        for cci in ccis_elems:
            stigid_to_cci[stig_id].add(cci.text)
    controls_root = os.path.join(SSG_ROOT, "controls")
    ctrl_manager = ControlsManager(controls_root, env_yaml)
    ctrl_manager.load()
    for stig_id, ccis in stigid_to_cci.items():
        control = ctrl_manager.get_control('stig_rhel9', stig_id)
        if len(control.rules) < 1:
            # print(f"{stig_id} has no rules.", file=sys.stderr)
            continue
        for rule in control.rules:
            if '=' in rule:
                continue
            rule_obj = rules[rule]
            rule_yaml_path = os.path.join(rule_obj['dir'], 'rule.yml')
            with open(rule_yaml_path, 'r') as fp:
                old_content = fp.readlines()
            new_content = list()
            ref_start_line = 0
            for index, line in enumerate(old_content):
                if 'references:' in line:
                    ref_start_line = index
                    new_content.append(line)
                    continue
                if not re.match(REALLY_BAD_SECTION_REGEX, line):
                    new_content.append(line)
                else:
                    new_content.append(f"{' ' * 4}disa: {','.join(ccis)}\n")
            if new_content != old_content:
                validate_file(new_content, rule_yaml_path)
                with open(rule_yaml_path, 'w') as fp:
                    fp.writelines(new_content)
                continue

            new_line = f'{" " * 4}disa: {','.join(ccis)}\n'
            if ref_start_line == 0:
                raise ValueError
            new_content.insert(ref_start_line+2, new_line)
            if new_content != old_content:
                with open(rule_yaml_path, 'w') as fp:
                    fp.writelines(new_content)
                continue
    return 0


def validate_file(lines: List[str], filename: str):
    offenders = list()
    for idx, line in enumerate(lines):
        if re.match(REALLY_BAD_SECTION_REGEX, line):
            offenders.append(str(idx))
        if len(offenders) > 1:
            print(f"Failure on lines {','.join(offenders)} in {filename}", file=sys.stderr)

if __name__ == "__main__":
    raise SystemExit(main())
