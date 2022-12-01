#!/usr/bin/python3

import argparse
import datetime
import json
import os
import re
import sys
import xml.etree.ElementTree as ET

import ssg.build_yaml
import ssg.constants
import ssg.rules
import ssg.yaml
import ssg.build_yaml
import ssg.environment

SSG_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
SSG_BUILD_ROOT = os.path.join(SSG_ROOT, "build")
RULES_JSON = os.path.join(SSG_BUILD_ROOT, "rule_dirs.json")
BUILD_CONFIG = os.path.join(SSG_BUILD_ROOT, "build_config.yml")
NS = {'scap': ssg.constants.datastream_namespace,
      'xccdf-1.2': ssg.constants.XCCDF12_NS}
PROFILE = 'stig'


def get_profile(product, profile_name):
    ds_root = ET.parse(os.path.join(SSG_ROOT, 'build', 'ssg-{product}-ds.xml'
                                    .format(product=product))).getroot()
    profiles = ds_root.findall(
        './/{{{scap}}}component/{{{xccdf}}}Benchmark/{{{xccdf}}}Profile'.format(
            scap=NS["scap"], xccdf=NS["xccdf-1.2"])
    )

    profile_name_fqdn = "xccdf_org.ssgproject.content_profile_{profile_name}".format(
        profile_name=profile_name)

    for profile in profiles:
        if profile.attrib['id'] == profile_name_fqdn:
            return profile


get_profile.__annotations__ = {'product': str, 'profile_name': str, 'return': ET.Element}


def filter_out_implemented_rules(known_rules, ns, root):
    needed_rules = known_rules.copy()
    groups = root.findall('.//scap:component/xccdf-1.2:Benchmark/xccdf-1.2:Group', ns)
    for group in groups:
        for stig in group.findall('xccdf-1.2:Rule', ns):
            stig_id = stig.find('xccdf-1.2:version', ns).text
            check = stig.find('xccdf-1.2:check', ns)
            if stig_id in known_rules.keys() and len(check) > 0:
                del needed_rules[stig_id]
    return needed_rules


filter_out_implemented_rules.__annotations__ = {'known_rules': dict, 'ns': dict,
                                                'root': ET.Element, 'return': dict}


def handle_rule_yaml(product, rule_id, rule_dir, guide_dir, env_yaml):
    rule_obj = {'id': rule_id, 'dir': rule_dir, 'guide': guide_dir}
    rule_file = ssg.rules.get_rule_dir_yaml(rule_dir)

    rule_yaml = ssg.build_yaml.Rule.from_yaml(rule_file, env_yaml=env_yaml)
    rule_yaml.normalize(product)
    rule_obj['references'] = rule_yaml.references
    return rule_obj


handle_rule_yaml.__annotations__ = {'product': str, 'rule_id': str, 'rule_dir': str,
                                    'guide_dir': str, 'env_yaml': dict, 'return': dict}


def get_platform_rules(product, json_path, resolved_rules_dir, build_root):
    platform_rules = list()
    if resolved_rules_dir:
        rules_path = os.path.join(build_root, product, 'rules')
        for file in os.listdir(rules_path):
            if not file.endswith('.yml'):
                continue
            rule_id = file.replace('.yml', '')
            rule = dict()
            rule_yaml = ssg.yaml.open_raw(os.path.join(rules_path, file))
            rule['id'] = rule_id
            rule['references'] = dict()
            rule['references'] = rule_yaml['references']
            platform_rules.append(rule)
    else:
        rules_json_file = open(json_path, 'r')
        rules_json = json.load(rules_json_file)
        for rule in rules_json.values():
            if product in rule['products']:
                platform_rules.append(rule)
        if not rules_json_file.closed:
            rules_json_file.close()
    return platform_rules


get_platform_rules.__annotations__ = {'product': str, 'json_path': str, 'resolved_rules_dir': bool,
                                      'build_root': str, 'return': list}


def get_implemented_stigs(product, root_path, build_config_yaml_path,
                          reference_str, json_path, resolved_rules_dir,
                          build_root):
    platform_rules = get_platform_rules(product, json_path, resolved_rules_dir, build_root)

    product_dir = os.path.join(root_path, "products", product)
    product_yaml_path = os.path.join(product_dir, "product.yml")
    env_yaml = ssg.environment.open_environment(build_config_yaml_path, str(product_yaml_path))

    known_rules = dict()
    for rule in platform_rules:
        if resolved_rules_dir:
            rule_obj = rule
        else:
            try:
                rule_obj = handle_rule_yaml(product, rule['id'],
                                            rule['dir'], rule['guide'], env_yaml)
            except ssg.yaml.DocumentationNotComplete:
                sys.stderr.write('Rule %s throw DocumentationNotComplete' % rule['id'])
                # Happens on non-debug build when a rule is "documentation-incomplete"
                continue

        if reference_str in rule_obj['references'].keys():
            ref = rule_obj['references'][reference_str]
            if ref in known_rules:
                known_rules[ref].append(rule['id'])
            else:
                known_rules[ref] = [rule['id']]
    return known_rules


get_implemented_stigs.__annotations__ = {'product': str, 'root_path': str,
                                         'build_config_yaml_path': str, 'reference_str': str,
                                         'json_path': str, 'resolved_rules_dir': bool,
                                         'build_root': str, 'return': dict}


def setup_tailoring_profile(profile_id, profile_root):
    tailoring_profile = ET.Element('xccdf-1.2:Profile')
    if profile_id:
        tailoring_profile.set('id', '{oscap}{profile_id}'
                              .format(oscap=ssg.constants.OSCAP_PROFILE, profile_id=profile_id))
    else:
        tailoring_profile.set('id', '{id}_delta_tailoring'.format(id=profile_root.attrib["id"]))
    tailoring_profile.append(profile_root.find('xccdf-1.2:title', NS))
    tailoring_profile.append(profile_root.find('xccdf-1.2:description', NS))
    tailoring_profile.set('extends', profile_root.get('id'))
    return tailoring_profile


setup_tailoring_profile.__annotations__ = {'profile_id': str, 'profile_root': ET.Element}


def create_tailoring(args):
    benchmark_root = ET.parse(args.manual).getroot()
    known_rules = get_implemented_stigs(args.product, args.root, args.build_config_yaml,
                                        args.reference, args.json, args.resolved_rules_dir,
                                        args.build_root)
    needed_rules = filter_out_implemented_rules(known_rules, NS, benchmark_root)
    profile_root = get_profile(args.product, args.profile)
    selections = profile_root.findall('xccdf-1.2:select', NS)
    tailoring_profile = setup_tailoring_profile(args.profile_id, profile_root)
    for selection in selections:
        if selection.attrib['idref'].startswith(ssg.constants.OSCAP_RULE):
            cac_rule_id = selection.attrib['idref'].replace(ssg.constants.OSCAP_RULE, '')
            desired_value = str([cac_rule_id] in list(needed_rules.values())).lower()
            if not selection.get('selected') == desired_value:
                selection.set('selected', desired_value)
                tailoring_profile.append(selection)
                if not args.quiet:
                    print('Set rule "{cac_rule_id}" selection state to {desired_value}'
                          .format(cac_rule_id=cac_rule_id, desired_value=desired_value))

    tailoring_root = ET.Element('xccdf-1.2:Tailoring')
    version = ET.SubElement(tailoring_root, 'xccdf-1.2:version',
                            attrib={'time': datetime.datetime.utcnow().isoformat()})
    version.text = '1'
    tailoring_root.set('id', args.tailoring_id)
    tailoring_root.append(tailoring_profile)
    return tailoring_root


create_tailoring.__annotations__ = {'args': argparse.Namespace, 'return': ET.Element}


def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("-r", "--root", type=str, action="store", default=SSG_ROOT,
                        help="Path to SSG root directory (defaults to {ssg_root})"
                        .format(ssg_root=SSG_ROOT))
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
    parser.add_argument("-o", "--output", type=str,
                        help="Defaults build/PRODUCT_PROFILE_tailoring.xml")
    parser.add_argument("--profile-id", type=str,
                        help="Id of the created profile. Defaults to PROFILE_delta")
    parser.add_argument("--tailoring-id", type=str,
                        default='xccdf_content-disa-delta_tailoring_default',
                        help="Id of the created tailoring file. "
                             "Defaults to xccdf_content-disa-delta_tailoring_default")
    parser.add_argument("-q", "--quiet", action='store_true',
                        help="The script will not produce any output.")
    parser.add_argument("--resolved-rules-dir", action='store_true',
                        help="The script will not use rules_dir.json, "
                             "but instead uses the data from the build.")
    parser.add_argument('-B', '--build-root', type=str, default=SSG_BUILD_ROOT,
                        help="The root of the CMake working directory, "
                             "defaults to {ssg_build_root}".format(ssg_build_root=SSG_BUILD_ROOT))
    parser.add_argument("-d", "--dry-run", action="store_true",
                        help="If set the script will not output.")
    return parser.parse_args()


parse_args.__annotations__ = {'return': argparse.Namespace}


def main():
    args = parse_args()
    ET.register_namespace('xccdf-1.2', ssg.constants.XCCDF12_NS)
    tailoring_root = create_tailoring(args)
    tree = ET.ElementTree(tailoring_root)
    manual_version = re.search(r'(v[0-9]+r[0-9]+)', args.manual)
    if manual_version is None:
        sys.stderr.write("Unable to find version from file name.\n")
        sys.stderr.write("The string v[NUM]r[NUM] must be in the filename.\n")
        exit(1)

    if args.dry_run:
        return 0

    if args.output:
        out = os.path.join(args.output)
    else:
        out = os.path.join(SSG_ROOT, 'build',
                           '{product}_{profile}_{manual_version}_delta_tailoring.xml'
                           .format(product=args.product, profile=args.profile,
                                   manual_version=manual_version.group(0)))
    tree.write(out)
    if not args.quiet:
        print("Wrote tailoring file to {out}.".format(out=out))


if __name__ == '__main__':
    main()
