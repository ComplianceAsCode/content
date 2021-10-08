#!/usr/bin/env python3

import argparse
import datetime
import json
import os
import sys
import xml.etree.ElementTree as ET

import ssg.constants
import ssg.rules
import ssg.yaml
import ssg.build_yaml
import ssg.environment

SSG_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
RULES_JSON = os.path.join(SSG_ROOT, "build", "rule_dirs.json")
BUILD_CONFIG = os.path.join(SSG_ROOT, "build", "build_config.yml")
NS = {'scap': ssg.constants.datastream_namespace,
      'xccdf-1.2': ssg.constants.XCCDF12_NS}
PROFILE = 'stig'


def get_profile(args) -> ET.Element:
    ds_root = ET.parse(os.path.join(SSG_ROOT, 'build', f'ssg-{args.product}-ds.xml')).getroot()
    for kelem in ds_root:
        if kelem.tag == f'{{{NS["scap"]}}}component':
            for jelem in kelem:
                if jelem.tag == f'{{{NS["xccdf-1.2"]}}}Benchmark':
                    for ielem in jelem:
                        if ielem.tag == f'{{{NS["xccdf-1.2"]}}}Profile':
                            if ielem.attrib['id'].endswith(args.profile):
                                version = ET.SubElement(ielem, 'xccdf-1.2:version',
                                                        attrib={'time': datetime.datetime.utcnow().isoformat()})
                                version.text = '1'
                                return ielem


def get_needed_rules(known_rules, ns, root):
    needed_rules = known_rules.copy()
    for group in root.findall('scap:component', ns)[1][0].findall('xccdf-1.2:Group', ns):
        for stig in group.findall('xccdf-1.2:Rule', ns):
            stig_id = stig.find('xccdf-1.2:version', ns).text
            check = stig.find('xccdf-1.2:check', ns)
            if stig_id in known_rules.keys() and len(check) > 0:
                del needed_rules[stig_id]
    return needed_rules


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


def get_implemented_stigs(args):
    platform_rules = get_platform_rules(args)

    product_dir = os.path.join(args.root, "products", args.product)
    product_yaml_path = os.path.join(product_dir, "product.yml")
    env_yaml = ssg.environment.open_environment(args.build_config_yaml, str(product_yaml_path))

    known_rules = dict()
    for rule in platform_rules:
        try:
            rule_obj = handle_rule_yaml(args, rule['id'],
                                        rule['dir'], rule['guide'], env_yaml)
        except ssg.yaml.DocumentationNotComplete:
            sys.stderr.write('Rule %s throw DocumentationNotComplete' % rule['id'])
            # Happens on non-debug build when a rule is "documentation-incomplete"
            continue

        if args.reference in rule_obj['references'].keys():
            ref = rule_obj['references'][args.reference]
            if ref in known_rules:
                known_rules[ref].append(rule['id'])
            else:
                known_rules[ref] = [rule['id']]
    return known_rules


def create_tailoring(args):
    benchmark_root = ET.parse(args.manual).getroot()
    known_rules = get_implemented_stigs(args)
    need_rules = get_needed_rules(known_rules, NS, benchmark_root)
    profile_root = get_profile(args)
    selections = profile_root.findall('xccdf-1.2:select', NS)
    for selection in selections:
        if selection.attrib['idref'].startswith('xccdf_org.ssgproject.content_group'):
            selection.set('selected', 'true')
            continue
        elif selection.attrib['idref'].startswith('xccdf_org.ssgproject.content_rule_'):
            cac_rule_id = selection.attrib['idref'].replace('xccdf_org.ssgproject.content_rule_', '')
            selection.set('selected',
                          str([cac_rule_id] in list(need_rules.values())).lower())
    tailoring_root = ET.Element('xccdf-1.2:Tailoring')
    tailoring_root.append(profile_root)
    return tailoring_root


def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("-r", "--root", type=str, action="store", default=SSG_ROOT,
                        help=f"Path to SSG root directory (defaults to {SSG_ROOT})")
    parser.add_argument("-p", "--product", type=str, action="store", required=True,
                        help="What product to produce the tailoring file for")
    parser.add_argument("-m", "--manual", type=str, action="store", required=True,
                        help="Path to XML XCCDF manual file to use as the source")
    parser.add_argument("-j", "--json", type=str, action="store", default=RULES_JSON,
                        help="Path to the rules_dir.json (defaults to build/stig_control.json)")
    parser.add_argument("-c", "--build-config-yaml", default=BUILD_CONFIG,
                        help="YAML file with information about the build configuration. ")
    parser.add_argument("-b", "--profile", type=str, default="stig",
                        help="What profile to use. Defaults to stig")
    parser.add_argument("-ref", "--reference", type=str, default="stigid",
                        help="Reference system to check for, defaults to stigid")

    return parser.parse_args()


def main():
    args = parse_args()
    ET.register_namespace('xccdf-1.2', ssg.constants.XCCDF12_NS)
    tailoring_root = create_tailoring(args)
    tree = ET.ElementTree(tailoring_root)
    tree.write(os.path.join(SSG_ROOT, 'build', f'{args.product}_{args.profile}_tailoring.xml'))


if __name__ == '__main__':
    main()
