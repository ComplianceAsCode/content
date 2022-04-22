#!/usr/bin/env python3

import argparse
import csv
import datetime
import json
import pathlib
import os
import re
import sys
from typing.io import TextIO
import xml.etree.ElementTree as ET

import ssg.build_yaml
import ssg.constants
import ssg.controls
import ssg.environment
import ssg.rules
import ssg.yaml

SSG_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
RULES_JSON = os.path.join(SSG_ROOT, "build", "rule_dirs.json")
BUILD_CONFIG = os.path.join(SSG_ROOT, "build", "build_config.yml")
OUTPUT = os.path.join(SSG_ROOT, 'build', f'{datetime.datetime.now().strftime("%s")}.csv')
SRG_PATH = os.path.join(SSG_ROOT, 'shared', 'references', 'disa-os-srg-v2r1.xml')
NS = {'scap': ssg.constants.datastream_namespace,
      'xccdf-1.2': ssg.constants.XCCDF12_NS,
      'xccdf-1.1': ssg.constants.XCCDF11_NS}
SEVERITY = {'low': 'CAT III', 'medium': 'CAT II', 'high': 'CAT I'}


class DisaStatus:
    """
    Convert control status to a string for the spreadsheet
    """
    PENDING = "pending"
    PLANNED = "planned"
    NOT_APPLICABLE = "Not Applicable"
    INHERENTLY_MET = "Applicable - Inherently Met"
    DOCUMENTATION = "documentation"
    PARTIAL = "Applicable - Configurable"
    SUPPORTED = "supported"
    AUTOMATED = "Applicable - Configurable"

    @staticmethod
    def from_string(source: str) -> str:
        if source == ssg.controls.Status.INHERENTLY_MET:
            return DisaStatus.INHERENTLY_MET
        return source


def html_plain_text(source: str) -> str:
    if source is None:
        return ""
    # Quick and dirty way to clean up HTML fields.
    # Add line breaks
    result = source.replace("<br />", "\n")
    # Remove all other tags
    result = re.sub(r"(?s)<.*?>", " ", result)
    return result


def get_description_root(srg: ET.Element) -> ET.Element:
    # DISA adds escaped XML to the description field
    # This method unescapes that XML and parses it
    description_xml = "<root>"
    description_xml += srg.find('xccdf-1.1:description', NS).text.replace('&lt;', '<') \
        .replace('&gt;', '>').replace(' & ', '')
    description_xml += "</root>"
    description_root = ET.ElementTree(ET.fromstring(description_xml)).getroot()
    return description_root


def get_srg_dict(xml_path: str) -> dict:
    if not pathlib.Path(xml_path).exists():
        sys.stderr.write("XML for SRG was not found\n")
        exit(1)
    root = ET.parse(xml_path).getroot()
    srgs = dict()
    for group in root.findall('xccdf-1.1:Group', NS):
        for srg in group.findall('xccdf-1.1:Rule', NS):
            srg_id = srg.find('xccdf-1.1:version', NS).text
            srgs[srg_id] = dict()
            srgs[srg_id]['severity'] = SEVERITY[srg.get('severity')]
            srgs[srg_id]['title'] = srg.find('xccdf-1.1:title', NS).text
            description_root = get_description_root(srg)
            srgs[srg_id]['vuln_discussion'] = \
                html_plain_text(description_root.find('VulnDiscussion').text)
            srgs[srg_id]['cci'] = \
                srg.find("xccdf-1.1:ident[@system='http://cyber.mil/cci']", NS).text
            srgs[srg_id]['fix'] = srg.find('xccdf-1.1:fix', NS).text
            srgs[srg_id]['check'] = \
                html_plain_text(srg.find('xccdf-1.1:check/xccdf-1.1:check-content', NS).text)
            srgs[srg_id]['ia_controls'] = description_root.find('IAControls').text
    return srgs


def handle_rule_yaml(product: str, rule_dir: str, env_yaml: dict) -> ssg.build_yaml.Rule:
    rule_file = ssg.rules.get_rule_dir_yaml(rule_dir)

    rule_yaml = ssg.build_yaml.Rule.from_yaml(rule_file, env_yaml=env_yaml)
    rule_yaml.normalize(product)

    return rule_yaml


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument('-c', '--control', type=str, action="store", required=True,
                        help="The control file to parse")
    parser.add_argument('-o', '--output', type=str, help="The path to the output",
                        default=OUTPUT)
    parser.add_argument("-r", "--root", type=str, action="store", default=SSG_ROOT,
                        help=f"Path to SSG root directory (defaults to {SSG_ROOT})")
    parser.add_argument("-j", "--json", type=str, action="store", default=RULES_JSON,
                        help=f"Path to the rules_dir.json (defaults to {RULES_JSON})")
    parser.add_argument("-p", "--product", type=str, action="store", required=True,
                        help="What product to get STIGs for")
    parser.add_argument("-b", "--build-config-yaml", default=BUILD_CONFIG,
                        help="YAML file with information about the build configuration. ")
    parser.add_argument("-m", "--manual", type=str, action="store",
                        help="Path to XML XCCDF manual file to use as the source of the SRGs",
                        default=SRG_PATH)
    return parser.parse_args()


def handle_control(product: str, control: ssg.controls.Control, csv_writer: csv.DictWriter,
                   env_yaml: ssg.environment, rule_json: dict, srgs: dict) -> None:
    if control.selections:
        for rule in control.selections:
            row = create_base_row(control, srgs)
            rule_object = handle_rule_yaml(product, rule_json[rule]['dir'], env_yaml)
            row['Requirement'] = html_plain_text(rule_object.description)
            row['Vul Discussion'] = html_plain_text(rule_object.rationale)
            row['Check'] = html_plain_text(rule_object.ocil)
            row['Fix'] = html_plain_text(rule_object.fix)
            # If then control has rule by definition the status is "Applicable - Configurable"
            row['Status'] = DisaStatus.AUTOMATED
            csv_writer.writerow(row)
    else:
        row = create_base_row(control, srgs)
        row['Mitigation'] = control.mitigation
        row['Artifact Description'] = control.artifact_description
        row['Status Justification'] = control.status_justification
        row['Status'] = DisaStatus.from_string(control.status)
        csv_writer.writerow(row)


def create_base_row(item: ssg.controls.Control, srgs: dict) -> dict:
    row = dict()
    srg_id = item.id
    if srg_id not in srgs:
        print(f"Unable to find SRG {srg_id}. Id in the control must be an srg.")
        exit(1)
    srg = srgs[srg_id]
    row['SRGID'] = srg_id
    row['CCI'] = srg['cci']
    row['SRG Requirement'] = srg['title']
    row['SRG VulDiscussion'] = srg['vuln_discussion']
    row['SRG Check'] = srg['check']
    row['SRG Fix'] = srg['fix']
    row['Severity'] = srg['severity']
    row['IA Control'] = srg['ia_controls']
    return row


def setup_csv_writer(csv_file: TextIO) -> csv.DictWriter:
    headers = ['IA Control', 'CCI', 'SRGID', 'SRG Requirement', 'Requirement',
               'SRG VulDiscussion', 'Vul Discussion', 'Status', 'SRG Check', 'Check', 'SRG Fix',
               'Fix', 'Severity', 'Mitigation', 'Artifact Description', 'Status Justification']
    csv_writer = csv.DictWriter(csv_file, headers)
    csv_writer.writeheader()
    return csv_writer


def get_rule_json(json_path: str) -> dict:
    with open(json_path, 'r') as json_file:
        rule_json = json.load(json_file)
    return rule_json


def main() -> None:
    args = parse_args()

    control_full_path = pathlib.Path(args.control).absolute()
    if not pathlib.Path.exists(control_full_path):
        sys.stderr.write(f"Unable to find control file {control_full_path}\n")
        exit(1)
    srgs = get_srg_dict(args.manual)
    control = ssg.controls.Policy(args.control)
    control.load()
    rule_json = get_rule_json(args.json)

    full_output = pathlib.Path(args.output)
    with open(full_output, 'w') as csv_file:
        csv_writer = setup_csv_writer(csv_file)

        product_dir = os.path.join(args.root, "products", args.product)
        product_yaml_path = os.path.join(product_dir, "product.yml")
        env_yaml = ssg.environment.open_environment(args.build_config_yaml, str(product_yaml_path))

        for control in control.controls:
            handle_control(args.product, control, csv_writer, env_yaml, rule_json, srgs)
        print(f"File written to {full_output}")


if __name__ == '__main__':
    main()
