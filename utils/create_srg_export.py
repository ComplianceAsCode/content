#!/usr/bin/python3

import argparse
import csv
import datetime
import json
import pathlib
import os
import re
import sys
import string

import yaml
from typing.io import TextIO
import xml.etree.ElementTree as ET

import convert_srg_export_to_xlsx
import convert_srg_export_to_html
import convert_srg_export_to_md

try:
    import ssg.build_stig
    import ssg.build_yaml
    import ssg.constants
    import ssg.controls
    import ssg.environment
    import ssg.rules
    import ssg.yaml
except (ModuleNotFoundError, ImportError):
    sys.stderr.write("Unable to load ssg python modules.\n")
    sys.stderr.write("Hint: run source ./.pyenv.sh\n")
    exit(3)

SSG_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
RULES_JSON = os.path.join(SSG_ROOT, "build", "rule_dirs.json")
BUILD_CONFIG = os.path.join(SSG_ROOT, "build", "build_config.yml")
OUTPUT = os.path.join(SSG_ROOT, 'build',
                      f'{datetime.datetime.now().strftime("%s")}_stig_export.csv')
SRG_PATH = os.path.join(SSG_ROOT, 'shared', 'references', 'disa-os-srg-v2r3.xml')
NS = {'scap': ssg.constants.datastream_namespace,
      'xccdf-1.2': ssg.constants.XCCDF12_NS,
      'xccdf-1.1': ssg.constants.XCCDF11_NS}

HEADERS = [
    'IA Control', 'CCI', 'SRGID', 'STIGID', 'SRG Requirement', 'Requirement',
    'SRG VulDiscussion', 'Vul Discussion', 'Status', 'SRG Check', 'Check', 'SRG Fix',
    'Fix', 'Severity', 'Mitigation', 'Artifact Description', 'Status Justification'
    ]

COLUMNS = string.ascii_uppercase[:17]  # A-Q uppercase letters

COLUMN_MAPPINGS = dict(zip(COLUMNS, HEADERS))

srgid_to_iacontrol = {
    'SRG-OS-000001-GPOS-00001': 'AC-2 (1)',
    'SRG-OS-000002-GPOS-00002': 'AC-2 (2)',
    'SRG-OS-000004-GPOS-00004': 'AC-2 (4)',
    'SRG-OS-000021-GPOS-00005': 'AC-7 a',
    'SRG-OS-000023-GPOS-00006': 'AC-8 a',
    'SRG-OS-000024-GPOS-00007': 'AC-8 b',
    'SRG-OS-000027-GPOS-00008': 'AC-10',
    'SRG-OS-000028-GPOS-00009': 'AC-11 b',
    'SRG-OS-000029-GPOS-00010': 'AC-11 a',
    'SRG-OS-000030-GPOS-00011': 'AC-11 a',
    'SRG-OS-000031-GPOS-00012': 'AC-11 (1)',
    'SRG-OS-000032-GPOS-00013': 'AC-17 (1)',
    'SRG-OS-000033-GPOS-00014': 'AC-17 (2)',
    'SRG-OS-000037-GPOS-00015': 'AU-3',
    'SRG-OS-000038-GPOS-00016': 'AU-3',
    'SRG-OS-000039-GPOS-00017': 'AU-3',
    'SRG-OS-000040-GPOS-00018': 'AU-3',
    'SRG-OS-000041-GPOS-00019': 'AU-3',
    'SRG-OS-000042-GPOS-00020': 'AU-3 (1)',
    'SRG-OS-000042-GPOS-00021': 'AU-3 (1)',
    'SRG-OS-000046-GPOS-00022': 'AU-5 a',
    'SRG-OS-000047-GPOS-00023': 'AU-5 b',
    'SRG-OS-000051-GPOS-00024': 'AU-6 (4)',
    'SRG-OS-000054-GPOS-00025': 'AU-7 (1)',
    'SRG-OS-000055-GPOS-00026': 'AU-8 a',
    'SRG-OS-000057-GPOS-00027': 'AU-9',
    'SRG-OS-000058-GPOS-00028': 'AU-9',
    'SRG-OS-000059-GPOS-00029': 'AU-9',
    'SRG-OS-000062-GPOS-00031': 'AU-12 a',
    'SRG-OS-000063-GPOS-00032': 'AU-12 b',
    'SRG-OS-000064-GPOS-00033': 'AU-12 c',
    'SRG-OS-000066-GPOS-00034': 'IA-5 (2) (a)',
    'SRG-OS-000067-GPOS-00035': 'IA-5 (2) (b)',
    'SRG-OS-000068-GPOS-00036': 'IA-5 (2) (c)',
    'SRG-OS-000069-GPOS-00037': 'IA-5 (1) (a)',
    'SRG-OS-000070-GPOS-00038': 'IA-5 (1) (a)',
    'SRG-OS-000071-GPOS-00039': 'IA-5 (1) (a)',
    'SRG-OS-000072-GPOS-00040': 'IA-5 (1) (b)',
    'SRG-OS-000073-GPOS-00041': 'IA-5 (1) (c)',
    'SRG-OS-000074-GPOS-00042': 'IA-5 (1) (c)',
    'SRG-OS-000075-GPOS-00043': 'IA-5 (1) (d)',
    'SRG-OS-000076-GPOS-00044': 'IA-5 (1) (d)',
    'SRG-OS-000077-GPOS-00045': 'IA-5 (1) (e)',
    'SRG-OS-000078-GPOS-00046': 'IA-5 (1) (a)',
    'SRG-OS-000079-GPOS-00047': 'IA-6',
    'SRG-OS-000080-GPOS-00048': 'AC-3',
    'SRG-OS-000095-GPOS-00049': 'CM-7 a',
    'SRG-OS-000096-GPOS-00050': 'CM-7 b',
    'SRG-OS-000104-GPOS-00051': 'IA-2',
    'SRG-OS-000105-GPOS-00052': 'IA-2 (1)',
    'SRG-OS-000106-GPOS-00053': 'IA-2 (2)',
    'SRG-OS-000107-GPOS-00054': 'IA-2 (3)',
    'SRG-OS-000108-GPOS-00055': 'IA-2 (4)',
    'SRG-OS-000109-GPOS-00056': 'IA-2 (5)',
    'SRG-OS-000112-GPOS-00057': 'IA-2 (8)',
    'SRG-OS-000113-GPOS-00058': 'IA-2 (9)',
    'SRG-OS-000114-GPOS-00059': 'IA-3',
    'SRG-OS-000118-GPOS-00060': 'IA-4 e',
    'SRG-OS-000120-GPOS-00061': 'IA-7',
    'SRG-OS-000121-GPOS-00062': 'IA-8',
    'SRG-OS-000122-GPOS-00063': 'AU-7 a',
    'SRG-OS-000123-GPOS-00064': 'AC-2 (2)',
    'SRG-OS-000125-GPOS-00065': 'MA-4 c',
    'SRG-OS-000126-GPOS-00066': 'MA-4 e',
    'SRG-OS-000132-GPOS-00067': 'SC-2',
    'SRG-OS-000134-GPOS-00068': 'SC-3',
    'SRG-OS-000138-GPOS-00069': 'SC-4',
    'SRG-OS-000142-GPOS-00071': 'SC-5 (2)',
    'SRG-OS-000163-GPOS-00072': 'SC-10',
    'SRG-OS-000184-GPOS-00078': 'SC-24',
    'SRG-OS-000185-GPOS-00079': 'SC-28',
    'SRG-OS-000191-GPOS-00080': 'SI-2 (2)',
    'SRG-OS-000205-GPOS-00083': 'SI-11 a',
    'SRG-OS-000206-GPOS-00084': 'SI-11 b',
    'SRG-OS-000228-GPOS-00088': 'AC-8 c 1, AC-8 c 2, AC-8 c 3',
    'SRG-OS-000239-GPOS-00089': 'AC-2 (4)',
    'SRG-OS-000240-GPOS-00090': 'AC-2 (4)',
    'SRG-OS-000241-GPOS-00091': 'AC-2 (4)',
    'SRG-OS-000250-GPOS-00093': 'AC-17 (2)',
    'SRG-OS-000254-GPOS-00095': 'AU-14 (1)',
    'SRG-OS-000255-GPOS-00096': 'AU-3',
    'SRG-OS-000256-GPOS-00097': 'AU-9',
    'SRG-OS-000257-GPOS-00098': 'AU-9',
    'SRG-OS-000258-GPOS-00099': 'AU-9',
    'SRG-OS-000259-GPOS-00100': 'CM-5 (6)',
    'SRG-OS-000266-GPOS-00101': 'IA-5 (1) (a)',
    'SRG-OS-000269-GPOS-00103': 'SC-24',
    'SRG-OS-000274-GPOS-00104': 'AC-2 (4)',
    'SRG-OS-000275-GPOS-00105': 'AC-2 (4)',
    'SRG-OS-000276-GPOS-00106': 'AC-2 (4)',
    'SRG-OS-000277-GPOS-00107': 'AC-2 (4)',
    'SRG-OS-000278-GPOS-00108': 'AU-9 (3)',
    'SRG-OS-000279-GPOS-00109': 'AC-12',
    'SRG-OS-000280-GPOS-00110': 'AC-12 (1)',
    'SRG-OS-000281-GPOS-00111': 'AC-12 (1)',
    'SRG-OS-000297-GPOS-00115': 'AC-17 (1)',
    'SRG-OS-000298-GPOS-00116': 'AC-17 (9)',
    'SRG-OS-000299-GPOS-00117': 'AC-18 (1)',
    'SRG-OS-000300-GPOS-00118': 'AC-18 (1)',
    'SRG-OS-000303-GPOS-00120': 'AC-2 (4)',
    'SRG-OS-000304-GPOS-00121': 'AC-2 (4)',
    'SRG-OS-000312-GPOS-00122': 'AC-3 (4)',
    'SRG-OS-000312-GPOS-00123': 'AC-3 (4)',
    'SRG-OS-000312-GPOS-00124': 'AC-3 (4)',
    'SRG-OS-000324-GPOS-00125': 'AC-6 (10)',
    'SRG-OS-000326-GPOS-00126': 'AC-6 (8)',
    'SRG-OS-000327-GPOS-00127': 'AC-6 (9)',
    'SRG-OS-000329-GPOS-00128': 'AC-7 b',
    'SRG-OS-000337-GPOS-00129': 'AU-12 (3)',
    'SRG-OS-000341-GPOS-00132': 'AU-4',
    'SRG-OS-000342-GPOS-00133': 'AU-4 (1)',
    'SRG-OS-000343-GPOS-00134': 'AU-5 (1)',
    'SRG-OS-000344-GPOS-00135': 'AU-5 (2)',
    'SRG-OS-000348-GPOS-00136': 'AU-7 a',
    'SRG-OS-000349-GPOS-00137': 'AU-7 a',
    'SRG-OS-000350-GPOS-00138': 'AU-7 a',
    'SRG-OS-000351-GPOS-00139': 'AU-7 a',
    'SRG-OS-000352-GPOS-00140': 'AU-7 a',
    'SRG-OS-000353-GPOS-00141': 'AU-7 b',
    'SRG-OS-000354-GPOS-00142': 'AU-7 b',
    'SRG-OS-000355-GPOS-00143': 'AU-8 (1) (a)',
    'SRG-OS-000356-GPOS-00144': 'AU-8 (1) (b)',
    'SRG-OS-000358-GPOS-00145': 'AU-8 b',
    'SRG-OS-000359-GPOS-00146': 'AU-8 b',
    'SRG-OS-000360-GPOS-00147': 'AU-9 (5), CM-6 b',
    'SRG-OS-000362-GPOS-00149': 'CM-11 (2)',
    'SRG-OS-000363-GPOS-00150': 'CM-3 (5)',
    'SRG-OS-000364-GPOS-00151': 'CM-5 (1)',
    'SRG-OS-000365-GPOS-00152': 'CM-5 (1)',
    'SRG-OS-000366-GPOS-00153': 'CM-5 (3)',
    'SRG-OS-000368-GPOS-00154': 'CM-7 (2)',
    'SRG-OS-000370-GPOS-00155': 'CM-7 (5) (b)',
    'SRG-OS-000373-GPOS-00156': 'IA-11',
    'SRG-OS-000373-GPOS-00157': 'IA-11',
    'SRG-OS-000373-GPOS-00158': 'IA-11',
    'SRG-OS-000374-GPOS-00159': 'IA-11',
    'SRG-OS-000375-GPOS-00160': 'IA-2 (11)',
    'SRG-OS-000376-GPOS-00161': 'IA-2 (12)',
    'SRG-OS-000377-GPOS-00162': 'IA-2 (12)',
    'SRG-OS-000378-GPOS-00163': 'IA-3',
    'SRG-OS-000379-GPOS-00164': 'IA-3 (1)',
    'SRG-OS-000380-GPOS-00165': 'IA-5 (1) (f)',
    'SRG-OS-000383-GPOS-00166': 'IA-5 (13)',
    'SRG-OS-000384-GPOS-00167': 'IA-5 (2) (d)',
    'SRG-OS-000392-GPOS-00172': 'MA-4 (1) (a)',
    'SRG-OS-000393-GPOS-00173': 'MA-4 (6)',
    'SRG-OS-000394-GPOS-00174': 'MA-4 (6)',
    'SRG-OS-000395-GPOS-00175': 'MA-4 (7)',
    'SRG-OS-000396-GPOS-00176': 'SC-13',
    'SRG-OS-000403-GPOS-00182': 'SC-23 (5)',
    'SRG-OS-000404-GPOS-00183': 'SC-28 (1)',
    'SRG-OS-000405-GPOS-00184': 'SC-28 (1)',
    'SRG-OS-000420-GPOS-00186': 'SC-5',
    'SRG-OS-000423-GPOS-00187': 'SC-8',
    'SRG-OS-000424-GPOS-00188': 'SC-8 (1)',
    'SRG-OS-000425-GPOS-00189': 'SC-8 (2)',
    'SRG-OS-000426-GPOS-00190': 'SC-8 (2)',
    'SRG-OS-000432-GPOS-00191': 'SI-10 (3)',
    'SRG-OS-000433-GPOS-00192': 'SI-16',
    'SRG-OS-000433-GPOS-00193': 'SI-16',
    'SRG-OS-000437-GPOS-00194': 'SI-2 (6)',
    'SRG-OS-000445-GPOS-00199': 'SI-6 a',
    'SRG-OS-000446-GPOS-00200': 'SI-6 b',
    'SRG-OS-000447-GPOS-00201': 'SI-6 d',
    'SRG-OS-000458-GPOS-00203': 'AU-12 c',
    'SRG-OS-000461-GPOS-00205': 'AU-12 c',
    'SRG-OS-000462-GPOS-00206': 'AU-12 c',
    'SRG-OS-000463-GPOS-00207': 'AU-12 c',
    'SRG-OS-000465-GPOS-00209': 'AU-12 c',
    'SRG-OS-000466-GPOS-00210': 'AU-12 c',
    'SRG-OS-000467-GPOS-00211': 'AU-12 c',
    'SRG-OS-000468-GPOS-00212': 'AU-12 c',
    'SRG-OS-000470-GPOS-00214': 'AU-12 c',
    'SRG-OS-000471-GPOS-00215': 'AU-12 c',
    'SRG-OS-000471-GPOS-00216': 'AU-12 c',
    'SRG-OS-000472-GPOS-00217': 'AU-12 c',
    'SRG-OS-000473-GPOS-00218': 'AU-12 c',
    'SRG-OS-000474-GPOS-00219': 'AU-12 c',
    'SRG-OS-000475-GPOS-00220': 'AU-12 c',
    'SRG-OS-000476-GPOS-00221': 'AU-12 c',
    'SRG-OS-000477-GPOS-00222': 'AU-12 c',
    'SRG-OS-000478-GPOS-00223': 'SC-13',
    'SRG-OS-000479-GPOS-00224': 'AU-4 (1)',
    'SRG-OS-000480-GPOS-00225': 'CM-6 b',
    'SRG-OS-000480-GPOS-00226': 'CM-6 b',
    'SRG-OS-000480-GPOS-00227': 'CM-6 b',
    'SRG-OS-000480-GPOS-00228': 'CM-6 b',
    'SRG-OS-000480-GPOS-00229': 'CM-6 b',
    'SRG-OS-000480-GPOS-00230': 'CM-6 b',
    'SRG-OS-000480-GPOS-00232': 'CM-6 b',
    'SRG-OS-000481-GPOS-000481': 'SC-8'}


def get_iacontrol(srg_str: str) -> str:
    srgs = srg_str.split(',')
    result = list()
    for srg in srgs:
        if srg in srgid_to_iacontrol:
            result.append(srgid_to_iacontrol[srg])
    result_set = set(result)
    return ','.join(str(srg) for srg in result_set)


class DisaStatus:
    PENDING = "pending"
    PLANNED = "planned"
    NOT_APPLICABLE = "Not Applicable"
    INHERENTLY_MET = "Applicable - Inherently Met"
    DOCUMENTATION = "documentation"
    PARTIAL = "Applicable - Configurable"
    SUPPORTED = "supported"
    AUTOMATED = "Applicable - Configurable"
    DOES_NOT_MEET = "Applicable - Does Not Meet"

    @staticmethod
    def from_string(source: str) -> str:
        if source == ssg.controls.Status.INHERENTLY_MET:
            return DisaStatus.INHERENTLY_MET
        elif source == ssg.controls.Status.DOES_NOT_MEET:
            return DisaStatus.DOES_NOT_MEET
        elif source == ssg.controls.Status.AUTOMATED or ssg.controls.Status.MANUAL:
            return DisaStatus.AUTOMATED
        return source

    STATUSES = {AUTOMATED, INHERENTLY_MET, DOES_NOT_MEET, NOT_APPLICABLE}


def html_plain_text(source: str) -> str:
    if source is None:
        return ""
    # Quick and dirty way to clean up HTML fields.
    # Add line breaks
    result = source.replace("<br />", "\n")
    result = result.replace("<br/>", "\n")
    result = result.replace("<tt>", '"')
    result = result.replace("</tt>", '"')
    # Remove all other tags
    result = re.sub(r"(?s)<.*?>", " ", result)

    # only replace this after replacing other tags as < and >
    # would be caught by the generic substitution
    result = result.replace("&gt;", ">")
    result = result.replace("&lt;", "<")
    return result


def get_variable_value(root_path: str, product: str, name: str, selector: str) -> str:
    product_value_full_path = pathlib.Path(root_path).joinpath('build').joinpath(product)\
        .joinpath('values').joinpath(f'{name}.yml').absolute()
    if not product_value_full_path.exists():
        sys.stderr.write(f'Undefined variable {name}\n')
        exit(7)
    with open(product_value_full_path, 'r') as f:
        var_yaml = yaml.load(Loader=yaml.BaseLoader, stream=f)
        if 'options' not in var_yaml:
            sys.stderr.write(f'No options for {name}\n')
            exit(8)
        if not selector and 'default' not in var_yaml['options']:
            sys.stderr.write(f'No default selector for {name}\n')
            exit(10)
        if not selector:
            return str(var_yaml['options']['default'])

        if selector not in var_yaml['options']:
            sys.stderr.write(f'Option {selector} does not exist for {name}\n')
            exit(9)
        else:
            return str(var_yaml['options'][selector])


def replace_variables(source: str, variables: dict, root_path: str, product: str) -> str:
    result = source
    if source:
        sub_element_regex = r'<sub idref="([a-z0-9_]+)" \/>'
        matches = re.finditer(sub_element_regex, source, re.MULTILINE)
        for match in matches:
            name = match.group(1)
            value = get_variable_value(
                root_path, product, name, variables.get(name))
            result = result.replace(match.group(), value)
    return result


def handle_variables(source: str, variables: dict, root_path: str, product: str) -> str:
    result = replace_variables(source, variables, root_path, product)
    return html_plain_text(result)


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
        sys.stderr.write(f"Could not open file {xml_path} \n")
        exit(1)
    root = ET.parse(xml_path).getroot()
    srgs = dict()
    for group in root.findall('xccdf-1.1:Group', NS):
        for srg in group.findall('xccdf-1.1:Rule', NS):
            srg_id = srg.find('xccdf-1.1:version', NS).text
            srgs[srg_id] = dict()
            srgs[srg_id]['severity'] = ssg.build_stig.get_severity(srg.get('severity'))
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
    parser.add_argument('-o', '--output', type=str,
                        help=f"The path to the output. Defaults to {OUTPUT}",
                        default=OUTPUT)
    parser.add_argument("-r", "--root", type=str, action="store", default=SSG_ROOT,
                        help=f"Path to SSG root directory (defaults to {SSG_ROOT})")
    parser.add_argument("-j", "--json", type=str, action="store", default=RULES_JSON,
                        help=f"Path to the rules_dir.json (defaults to {RULES_JSON})")
    parser.add_argument("-p", "--product", type=str, action="store", required=True,
                        help="What product to get STIGs for")
    parser.add_argument("-b", "--build-config-yaml", default=BUILD_CONFIG,
                        help="YAML file with information about the build configuration.")
    parser.add_argument("-m", "--manual", type=str, action="store",
                        help="Path to XML XCCDF manual file to use as the source of the SRGs",
                        default=SRG_PATH)
    parser.add_argument("-f", "--out-format", type=str, choices=("csv", "xlsx", "html", "md"),
                        action="store", help="The format the output should take. Defaults to csv",
                        default="csv")
    return parser.parse_args()


def get_requirement(control: ssg.controls.Control, rule_obj: ssg.build_yaml.Rule) -> str:
    if rule_obj.srg_requirement != "":
        return rule_obj.srg_requirement
    else:
        return control.title()


def handle_control(product: str, control: ssg.controls.Control, env_yaml: ssg.environment,
                   rule_json: dict, srgs: dict, used_rules: list, root_path: str) -> list:
    if len(control.selections) > 0:
        rows = list()
        for selection in control.selections:
            if selection not in used_rules and selection in control.selected:
                rule_object = handle_rule_yaml(product, rule_json[selection]['dir'], env_yaml)
                row = create_base_row(control, srgs, rule_object)
                if control.levels is not None:
                    row['Severity'] = ssg.build_stig.get_severity(control.levels[0])
                row['Requirement'] = handle_variables(get_requirement(control.title, rule_object),
                                                      control.variables, root_path,
                                                      product)
                row['Vul Discussion'] = handle_variables(rule_object.rationale, control.variables,
                                                         root_path, product)
                ocil_var = handle_variables(rule_object.ocil, control.variables, root_path,
                                            product)
                ocil_clause_var = handle_variables(rule_object.ocil_clause, control.variables,
                                                   root_path, product)
                row['Check'] = f'{ocil_var}\n\n' \
                               f'If {ocil_clause_var}, then this is a finding.'
                row['Fix'] = handle_variables(rule_object.fixtext, control.variables, root_path,
                                              product)
                row['STIGID'] = rule_object.identifiers.get('cce', "")
                if control.status is not None:
                    row['Status'] = DisaStatus.from_string(control.status)
                else:
                    row['Status'] = DisaStatus.AUTOMATED
                used_rules.append(selection)
                rows.append(row)
        return rows

    else:
        return [no_selections_row(control, srgs)]


def no_selections_row(control, srgs):
    row = create_base_row(control, srgs, ssg.build_yaml.Rule('null'))
    row['Requirement'] = control.title
    row['Status'] = DisaStatus.from_string(control.status)
    row['Fix'] = control.fixtext
    row['Check'] = control.check
    row['Vul Discussion'] = html_plain_text(control.rationale)
    row["STIGID"] = ""
    return row


def create_base_row(item: ssg.controls.Control, srgs: dict,
                    rule_object: ssg.build_yaml.Rule) -> dict:
    row = dict()
    srg_id = item.id
    if srg_id not in srgs:
        print(f"Unable to find SRG {srg_id}. Id in the control must be a valid SRGID.")
        exit(4)
    srg = srgs[srg_id]

    row['SRGID'] = rule_object.references.get('srg', srg_id)
    row['CCI'] = rule_object.references.get('disa', srg['cci'])
    row['SRG Requirement'] = srg['title']
    row['SRG VulDiscussion'] = html_plain_text(srg['vuln_discussion'])
    row['SRG Check'] = html_plain_text(srg['check'])
    row['SRG Fix'] = srg['fix']
    row['Severity'] = ssg.build_stig.get_severity(srg.get('severity'))
    row['IA Control'] = get_iacontrol(row['SRGID'])
    row['Mitigation'] = item.mitigation
    row['Artifact Description'] = item.artifact_description
    row['Status Justification'] = item.status_justification
    return row


def setup_csv_writer(csv_file: TextIO) -> csv.DictWriter:
    csv_writer = csv.DictWriter(csv_file, HEADERS)
    csv_writer.writeheader()
    return csv_writer


def get_rule_json(json_path: str) -> dict:
    with open(json_path, 'r') as json_file:
        rule_json = json.load(json_file)
    return rule_json


def check_paths(control_path: str, rule_json_path: str) -> None:
    control_full_path = pathlib.Path(control_path).absolute()
    if not control_full_path.exists():
        sys.stderr.write(f"Unable to find control file {control_full_path}\n")
        exit(5)
    rule_json_full_path = pathlib.Path(rule_json_path).absolute()
    if not rule_json_full_path.exists():
        sys.stderr.write(f"Unable to find rule_dirs.json file {rule_json_full_path}\n")
        sys.stderr.write("Hint: run ./utils/rule_dir_json.py\n")
        exit(2)


def check_product_value_path(root_path: str, product: str) -> None:
    product_value_full_path = pathlib.Path(root_path).joinpath('build')\
        .joinpath(product).joinpath('values').absolute()
    if not pathlib.Path.exists(product_value_full_path):
        sys.stderr.write(f"Unable to find values directory for"
                         f" {product} in {product_value_full_path}\n")
        sys.stderr.write(f"Have you built {product}\n")
        exit(6)


def get_policy(args, env_yaml) -> ssg.controls.Policy:
    policy = ssg.controls.Policy(args.control, env_yaml=env_yaml)
    policy.load()
    return policy


def handle_csv_output(output: str, results: list) -> str:
    with open(output, 'w') as csv_file:
        csv_writer = setup_csv_writer(csv_file)
        for row in results:
            csv_writer.writerow(row)
        return output


def handle_xlsx_output(output: str, product: str, results: list) -> str:
    output = output.replace('.csv', '.xlsx')
    for row in results:
        row['IA Control'] = get_iacontrol(row['SRGID'])
    convert_srg_export_to_xlsx.handle_dict(results, output, f'{product} SRG Mapping')
    return output


def handle_html_output(output: str, product: str, results: list) -> str:
    for row in results:
        row['IA Control'] = get_iacontrol(row['SRGID'])
    output = output.replace('.csv', '.html')
    convert_srg_export_to_html.handle_dict(results, output, f'{product} SRG Mapping')
    return output


def handle_md_output(output: str, product: str, results: list) -> str:
    output = output.replace('.csv', '.md')
    for row in results:
        row['IA Control'] = get_iacontrol(row['SRGID'])
    convert_srg_export_to_md.handle_dict(results, output, f'{product} SRG Mapping')
    return output


def handle_output(output: str, results: list, format_type: str, product: str) -> None:
    if format_type == 'csv':
        output = handle_csv_output(output, results)
    elif format_type == 'xlsx':
        output = handle_xlsx_output(output, product, results)
    elif format_type == 'md':
        output = handle_md_output(output, product, results)
    elif format_type == 'html':
        output = handle_html_output(output, product, results)

    print(f'Wrote output to {output}')


def get_env_yaml(root: str, product: str, build_config_yaml: str) -> dict:
    product_dir = os.path.join(root, "products", product)
    product_yaml_path = os.path.join(product_dir, "product.yml")
    env_yaml = ssg.environment.open_environment(build_config_yaml, str(product_yaml_path))
    return env_yaml


def main() -> None:
    args = parse_args()
    check_paths(args.control, args.json)
    check_product_value_path(args.root, args.product)

    srgs = ssg.build_stig.parse_srgs(args.manual)
    product_dir = os.path.join(args.root, "products", args.product)
    product_yaml_path = os.path.join(product_dir, "product.yml")
    env_yaml = ssg.environment.open_environment(args.build_config_yaml, str(product_yaml_path))
    policy = get_policy(args, env_yaml)
    rule_json = get_rule_json(args.json)

    used_rules = list()
    results = list()
    for control in policy.controls:
        rows = handle_control(args.product, control, env_yaml, rule_json, srgs, used_rules,
                              args.root)
        results.extend(rows)

    handle_output(args.output, results, args.out_format, args.product)


if __name__ == '__main__':
    main()
