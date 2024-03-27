#!/usr/bin/python3

from __future__ import print_function

import argparse
import json
import os
import re
from pathlib import Path
import sys
import xml.etree.ElementTree as ET
import yaml

import ssg.build_yaml
import ssg.controls
import ssg.environment
import ssg.rules
from ssg.utils import mkdir_p
import ssg.yaml


SSG_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
BUILD_OUTPUT = os.path.join(SSG_ROOT, "build", "stig_control.yml")
RULES_JSON = os.path.join(SSG_ROOT, "build", "rule_dirs.json")
BUILD_CONFIG = os.path.join(SSG_ROOT, "build", "build_config.yml")


def check_output(output: str) -> None:
    pat = re.compile(r'.*\/?[a-z_0-9]+\.yml')
    if not pat.match(output):
        sys.stderr.write('Output must only contain lowercase letters, underscores, and numbers.'
                         ' The file must also end with .yml\n')
        exit(1)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("-r", "--root", type=str, action="store", default=SSG_ROOT,
                        help="Path to SSG root directory (defaults to %s)" % SSG_ROOT)
    parser.add_argument("-o", "--output", type=str, action="store", default=BUILD_OUTPUT,
                        help=f"File to write yaml output to (defaults to {BUILD_OUTPUT}). "
                             f"Must end in '.yml' and only contain "
                             f"lowercase letters, underscores, and numbers.")
    parser.add_argument("-p", "--product", type=str, action="store", required=True,
                        help="What product to get STIGs for")
    parser.add_argument("-m", "--manual", type=str, action="store", required=True,
                        help="Path to XML XCCDF manual file to use as the source of the STIGs")
    parser.add_argument("-g", "--srg-control", type=str, action="store", default=None,
                        help="Path to the SRG control file relevant to the STIG")
    parser.add_argument("-j", "--json", type=str, action="store", default=RULES_JSON,
                        help=f"Path to the rules_dir.json (defaults to {RULES_JSON})")
    parser.add_argument("-c", "--build-config-yaml", default=BUILD_CONFIG,
                        help="YAML file with information about the build configuration")
    parser.add_argument("-ref", "--reference", type=str, default="stigid",
                        help="Reference system to check for, defaults to stigid")
    parser.add_argument('-s', '--split', action='store_true',
                        help='Splits the each ID into its own file.')

    args = parser.parse_args()
    check_output(args.output)
    return args


def handle_rule_yaml(args, rule_id, rule_dir, guide_dir, env_yaml):
    rule_obj = {'id': rule_id, 'dir': rule_dir, 'guide': guide_dir}
    rule_file = ssg.rules.get_rule_dir_yaml(rule_dir)

    rule_yaml = ssg.build_yaml.Rule.from_yaml(rule_file, env_yaml=env_yaml)
    rule_yaml.normalize(args.product)
    rule_obj['references'] = rule_yaml.references
    return rule_obj


def get_platform_rules(args):
    rules_json_file = open(args.json, 'r')
    rules_json = json.load(rules_json_file)
    platform_rules = list()
    for rule in rules_json.values():
        if args.product in rule['products']:
            platform_rules.append(rule)
    if not rules_json_file.closed:
        rules_json_file.close()
    return platform_rules


def map_rule_id_to_ref(rule_id, refs, known_rules):
    for ref in refs:
        if ref in known_rules:
            known_rules[ref].append(rule_id)
        else:
            known_rules[ref] = [rule_id]


def get_implemented_stigs(args, env_yaml):
    platform_rules = get_platform_rules(args)

    known_rules = dict()
    for rule in platform_rules:
        try:
            rule_obj = handle_rule_yaml(args, rule['id'],
                                        rule['dir'], rule['guide'], env_yaml)
        except ssg.yaml.DocumentationNotComplete:
            sys.stderr.write('Rule %s throw DocumentationNotComplete' % rule['id'])
            # Happens on non-debug build when a rule is "documentation-incomplete"
            continue

        refs = rule_obj['references'].get(args.reference, [])
        map_rule_id_to_ref(rule['id'], refs, known_rules)
    return known_rules


def check_files(args):
    if not os.path.exists(args.json):
        sys.stderr.write('Unable to find %s\n' % args.json)
        sys.stderr.write('Hint: run ./utils/rule_dir_json.py\n')
        exit(-1)

    if not os.path.exists(args.build_config_yaml):
        sys.stderr.write('Unable to find %s\n' % args.build_config_yaml)
        sys.stderr.write('Hint: build the project,\n')
        exit(-1)


def get_extra_srgs(rule, ns) -> list:
    pattern = re.compile(r'SRG-[A-Z]{2,}-\d{5,}-[A-Z]{3,}-\d{5,}')

    description = rule.find('checklist:description', ns).text
    return pattern.findall(description)


def get_rules_for_control(stig_id, known_rules, srgs, srg_controls):
    # Add any known rule with the same STIG ID reference
    rule_set = set()
    if stig_id in known_rules.keys():
        rule_set.update(known_rules.get(stig_id))

    # Let's also add any rule selected in the SRG control file
    if srg_controls:
        for srg in srgs:
            rule_set.update(srg_controls.get_control(srg).rules)

    return sorted(list(rule_set))


def get_controls(known_rules, ns, root, srg_controls=None) -> list:
    controls = list()
    for group in root.findall('checklist:Group', ns):
        # There is always at least one SRG associated
        srgs = [group.find('checklist:title', ns).text]

        for stig in group.findall('checklist:Rule', ns):
            stig_id = stig.find('checklist:version', ns).text
            # Add any other SRG associated mentioned in description
            srgs += get_extra_srgs(stig, ns)
            control = dict()
            control['id'] = stig_id
            control['levels'] = [stig.attrib['severity']]
            control['title'] = stig.find('checklist:title', ns).text
            control['rules'] = get_rules_for_control(stig_id, known_rules, srgs, srg_controls)
            if len(control['rules']) > 0:
                control['status'] = 'automated'
            else:
                control['status'] = 'pending'

            controls.append(control)
    return controls


def get_disa_stig_version(root, ns):
    version = root.find('checklist:version', ns).text
    release_string = root.find('checklist:plain-text[@id="release-info"]', ns).text
    release = re.match(r'Release: (\d+) Benchmark', release_string)
    return f"V{version}R{release.group(1)}"


def main():
    args = parse_args()
    check_files(args)

    product_dir = os.path.join(args.root, "products", args.product)
    product_yaml_path = os.path.join(product_dir, "product.yml")
    env_yaml = ssg.environment.open_environment(
        args.build_config_yaml, product_yaml_path, os.path.join(args.root, "product_properties"))

    ns = {'checklist': 'http://checklists.nist.gov/xccdf/1.1'}
    known_rules = get_implemented_stigs(args, env_yaml)
    tree = ET.parse(args.manual)
    root = tree.getroot()
    output = dict()
    output['policy'] = root.find('checklist:title', ns).text
    output['title'] = root.find('checklist:title', ns).text
    output['id'] = 'stig_%s' % args.product
    output['version'] = get_disa_stig_version(root, ns)
    output['source'] = 'https://public.cyber.mil/stigs/downloads/'
    output['reference_type'] = "stigid"
    output['product'] = args.product
    output['levels'] = list()
    for level in ['high', 'medium', 'low']:
        output['levels'].append({'id': level})

    srg_controls = None
    if args.srg_control:
        srg_controls = ssg.controls.Policy(args.srg_control, env_yaml)
        srg_controls.load()
    controls = get_controls(known_rules, ns, root, srg_controls)

    if args.split:
        with open(args.output, 'w') as f:
            f.write(yaml.dump(output, sort_keys=False))
        print(f'Wrote main control file to {args.output}')
        output_path = Path(args.output)
        output_dir_name = output_path.stem
        output_root = output_path.parent
        output_dir = os.path.join(output_root, output_dir_name)
        mkdir_p(output_dir)
        for control in controls:
            out = dict()
            out['controls'] = [control, ]
            filename = f"{control['id']}.yml"
            output_filename = os.path.join(output_dir, filename)
            with open(output_filename, 'w') as f:
                f.write(yaml.dump(out, sort_keys=False))
        print(f'Wrote SRG files to {output_dir}')
        exit(0)
    else:
        output['controls'] = controls
        with open(args.output, 'w') as f:
            f.write(yaml.dump(output, sort_keys=False))
        print(f'Wrote all SRGs out to {args.output}')


if __name__ == "__main__":
    main()
