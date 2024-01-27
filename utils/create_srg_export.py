#!/usr/bin/python3

import argparse
import csv
import datetime
import json
import pathlib
import os
import re
import sys

import yaml
from typing import TextIO
import xml.etree.ElementTree as ET

from utils.srg_export import html, md, xlsx
from utils.srg_export.data import HEADERS, get_iacontrol_mapping

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
SRG_PATH = os.path.join(SSG_ROOT, 'shared', 'references', 'disa-os-srg-v2r7.xml')
NS = {'scap': ssg.constants.datastream_namespace,
      'xccdf-1.2': ssg.constants.XCCDF12_NS,
      'xccdf-1.1': ssg.constants.XCCDF11_NS}


def get_iacontrol(srg_str: str) -> str:
    srgs = srg_str.split(',')
    result = list()
    for srg in srgs:
        mapping = get_iacontrol_mapping(srg)
        if mapping is None:
            continue
        if srg in mapping:
            result.append(mapping[srg])
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
        data = {
            ssg.controls.Status.INHERENTLY_MET: DisaStatus.INHERENTLY_MET,
            ssg.controls.Status.DOES_NOT_MEET: DisaStatus.DOES_NOT_MEET,
            ssg.controls.Status.NOT_APPLICABLE: DisaStatus.NOT_APPLICABLE,
            ssg.controls.Status.AUTOMATED: DisaStatus.AUTOMATED,
            ssg.controls.Status.MANUAL: DisaStatus.AUTOMATED
        }
        return data.get(source, source)

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
    parser.add_argument("--prefer-controls", action="store_true",
                        help="When creating rows prefer checks and fixes from controls over rules",
                        default=False)
    parser.add_argument("-f", "--out-format", type=str, choices=("csv", "xlsx", "html", "md"),
                        action="store", help="The format the output should take. Defaults to csv",
                        default="csv")
    return parser.parse_args()


def get_policy_specific_content(key: str, rule_object: ssg.build_yaml.Rule) -> str:
    psc = rule_object.policy_specific_content
    if not psc:
        return ""
    stig = psc.get('stig')
    if not stig:
        return ""
    return stig.get(key, "")


def use_rule_content(control: ssg.controls.Control, prefer_controls: bool) -> bool:
    if control.fixtext is not None and control.check is not None and prefer_controls:
        return False
    return True


def handle_control(product: str, control: ssg.controls.Control, env_yaml: ssg.environment,
                   rule_json: dict, srgs: dict, used_rules: list, root_path: str,
                   prefer_controls: bool) -> list:
    if len(control.selections) > 0 and use_rule_content(control, prefer_controls):
        rows = list()
        for selection in control.selections:
            if selection not in used_rules and selection in control.selected:
                rule_object = handle_rule_yaml(product, rule_json[selection]['dir'], env_yaml)
                row = create_base_row(control, srgs, rule_object)
                if control.levels is not None:
                    row['Severity'] = ssg.build_stig.get_severity(control.levels[0])
                requirement = get_policy_specific_content('srg_requirement', rule_object)
                row['Requirement'] = handle_variables(requirement,
                                                      control.variables, root_path,
                                                      product)
                rationale = get_policy_specific_content('vuldiscussion', rule_object)
                row['Vul Discussion'] = handle_variables(rationale, control.variables,
                                                         root_path, product)
                checktext = get_policy_specific_content('checktext', rule_object)
                row['Check'] = handle_variables(checktext, control.variables, root_path, product)
                fixtext = get_policy_specific_content('fixtext', rule_object)
                row['Fix'] = handle_variables(fixtext, control.variables, root_path,
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
    xlsx.handle_dict(results, output, f'{product} SRG Mapping')
    return output


def handle_html_output(output: str, product: str, results: list) -> str:
    for row in results:
        row['IA Control'] = get_iacontrol(row['SRGID'])
    output = output.replace('.csv', '.html')
    html.handle_dict(results, output, f'{product} SRG Mapping')
    return output


def handle_md_output(output: str, product: str, results: list) -> str:
    output = output.replace('.csv', '.md')
    for row in results:
        row['IA Control'] = get_iacontrol(row['SRGID'])
    md.handle_dict(results, output, f'{product} SRG Mapping')
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


def get_env_yaml(root: str, product_path: str, build_config_yaml: str) -> dict:
    product_dir = os.path.join(root, "products", product_path)
    product_yaml_path = os.path.join(product_dir, "product.yml")
    env_yaml = ssg.environment.open_environment(
            build_config_yaml, product_yaml_path, os.path.join(root, "product_properties"))
    return env_yaml


def rows_match(old: dict, new: dict) -> bool:
    must_match = ['Requirement', 'Fix', 'Check']
    for k in must_match:
        if old[k] != new[k]:
            return False
    return True


def merge_rows(old: dict, new: dict) -> None:
    old["SRGID"] = old["SRGID"] + "," + new["SRGID"]


def extend_results(results: list, rows: list, prefer_controls: bool) -> None:
    # We always extend with rows that are generated based on rule selection
    # We also only attempt to merge the new row if we prefer control-based
    # policy data over rule-based
    if len(rows) > 1 or not prefer_controls:
        results.extend(rows)
        return

    if len(rows) == 0:
        return

    # If we only have one row, possibly with check and fix from the control
    # file and not rules, let's find a row with the same requirement, fix
    # and check and if they match, merge
    new_row = rows[0]
    for r in results:
        if rows_match(r, new_row):
            merge_rows(r, new_row)
            return

    # We didn't find any match, so we just add the row as new
    results.extend(rows)


def main() -> None:
    args = parse_args()
    check_paths(args.control, args.json)
    check_product_value_path(args.root, args.product)

    srgs = ssg.build_stig.parse_srgs(args.manual)
    product_dir = os.path.join(args.root, "products", args.product)
    env_yaml = get_env_yaml(
            args.root, args.product, args.build_config_yaml)
    policy = get_policy(args, env_yaml)
    rule_json = get_rule_json(args.json)

    used_rules = list()
    results = list()
    for control in policy.controls:
        rows = handle_control(args.product, control, env_yaml, rule_json, srgs, used_rules,
                              args.root, args.prefer_controls)
        extend_results(results, rows, args.prefer_controls)

    handle_output(args.output, results, args.out_format, args.product)


if __name__ == '__main__':
    main()
