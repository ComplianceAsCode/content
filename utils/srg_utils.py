from __future__ import annotations

import json
import os
import re
from pathlib import Path

import yaml

from ssg.rule_yaml import find_section_lines, get_yaml_contents
from ssg.utils import mkdir_p, read_file_list
from ssg.yaml import yaml_Loader
from openpyxl.worksheet.worksheet import Worksheet

# The start row is 2, to avoid importing the header
START_ROW = 2

SEVERITY = {'CAT III': 'low', 'CAT II': 'medium', 'CAT I': 'high'}

class Row:
    row_id = 0
    IA_Control = ""
    CCI = ""
    SRGID = ""
    STIGID = ""
    SRG_Requirement = ""
    Requirement = ""
    SRG_VulDiscussion = ""
    Vul_Discussion = ""
    Status = ""
    SRG_Check = ""
    Check = ""
    SRG_Fix = ""
    Fix = ""
    Severity = ""
    Mitigation = ""
    Artifact_Description = ""
    Status_Justification = ""

    @staticmethod
    def from_row(sheet: Worksheet, row_number: int, full_name: str, changed_name: str) -> Row:
        self = Row()
        self.row_id = row_number
        self.IA_Control = sheet[f'A{row_number}'].value
        self.CCI = sheet[f'B{row_number}'].value
        self.SRGID = sheet[f'C{row_number}'].value
        self.STIGID = sheet[f'D{row_number}'].value
        self.SRG_Requirement = sheet[f'E{row_number}'].value
        if sheet[f'F{row_number}'].value:
            self.Requirement = sheet[f'F{row_number}'].value.replace(full_name, changed_name)
        self.SRG_VulDiscussion = sheet[f'G{row_number}'].value
        if sheet[f'H{row_number}'].value:
            self.Vul_Discussion = sheet[f'H{row_number}'].value.replace(full_name, changed_name)
        self.Status = sheet[f'I{row_number}'].value
        self.SRG_Check = sheet[f'J{row_number}'].value
        if sheet[f'K{row_number}'].value:
            self.Check = sheet[f'K{row_number}'].value.replace(full_name, changed_name)
        self.SRG_Fix = sheet[f'L{row_number}'].value
        if sheet[f'M{row_number}'].value:
            self.Fix = sheet[f'M{row_number}'].value.replace(full_name, changed_name)
        self.Severity = sheet[f'N{row_number}'].value
        self.Mitigation = sheet[f'O{row_number}'].value
        self.Artifact_Description = sheet[f'P{row_number}'].value
        self.Artifact_Description = sheet[f'Q{row_number}'].value
        return self

    def __str__(self) -> str:
        return f'<Row {self.row_id}>'


def get_full_name(root_dir: str, product: str) -> str:
    product_yml_path = os.path.join(root_dir, 'products', product, 'product.yml')
    with open(product_yml_path, 'r') as f:
        data = yaml.load(f, Loader=yaml_Loader)
        return data['full_name']


def get_stigid_set(sheet: Worksheet, end_row: int) -> set[str]:
    result = set()
    for i in range(START_ROW, end_row):
        cci_raw = sheet[f'D{i}'].value

        if cci_raw is None or cci_raw == "":
            continue
        result.add(cci_raw)
    return result


def get_cce_dict_to_row_dict(sheet: Worksheet, full_name: str, changed_name: str,
                             end_row: int) -> dict:
    result = dict()
    for i in range(START_ROW, end_row):
        cci_raw = sheet[f'D{i}'].value
        if cci_raw is None or cci_raw == "":
            continue
        cci = cci_raw.strip().replace('\n', '')
        result[cci] = Row.from_row(sheet, i, full_name, changed_name)

    return result


def get_cce_dict(data: dict, product: str) -> dict:
    results = dict()
    for rule_id in data.keys():
        rule = data[rule_id]
        cce_key = f'cce@{product}' in rule['identifiers']
        if product in rule['products'] and cce_key:
            results[rule['identifiers'][f'cce@{product}']] = rule_id

    return results


def get_rule_dir_json(path: str) -> dict:
    with open(path, 'r') as f:
        return json.load(f)


def update_row(changed: str, current: str, rule_dir_json: dict, section: str) -> None:
    if changed != current and changed:
        replace_yaml_section(section, changed, rule_dir_json)


def fix_changed_text(replacement: str, changed_name: str) -> str:
    no_space_name = changed_name.replace(' ', '')
    return replacement.replace(changed_name, '{{{ full_name }}}')\
        .replace(no_space_name, '{{{ full_name }}}')


def create_output(rule_dir: str) -> str:
    path_dir_parent = os.path.join(rule_dir, "policy")
    err = mkdir_p(path_dir_parent)
    if err is False:
        raise EnvironmentError(f"Could not create {path_dir_parent}")
    path_dir = os.path.join(path_dir_parent, "stig")
    err = mkdir_p(path_dir)
    if err is False:
        raise EnvironmentError(f"Could not create {path_dir}")
    path = os.path.join(path_dir, 'shared.yml')
    Path(path).touch()
    return path


def get_last_content_index(lines):
    last_content_index = len(lines)
    lines.reverse()
    for line in lines:
        if line == '\n':
            last_content_index -= 1
        else:
            break
    lines.reverse()
    return last_content_index


def cleanup_end_of_file(rule_dir: str) -> None:
    path = create_output(rule_dir)
    with open(path, 'r') as f:
        lines = f.readlines()
    last_content_index = get_last_content_index(lines)
    lines = lines[:last_content_index]

    with open(path, 'w') as f:
        f.writelines(lines)


def update_severity(changed, current, rule_dir_json):
    if changed.Severity != current.Severity and changed.Severity is not None and \
            current.Severity is not None:
        cac_severity = get_cac_status(changed.Severity)
        replace_yaml_key('severity', cac_severity, rule_dir_json)


def write_output(path: str, result: tuple) -> None:
    with open(path, 'w') as f:
        first_time = True
        for line in result:
            if first_time:
                first_time = False
                line = re.sub(r'^\n', '', result[0])
            f.write(line.rstrip())
            f.write('\n')


def replace_yaml_section(section: str, replacement: str, rule_dir: dict) -> None:
    path = create_output(rule_dir['dir'])

    lines = read_file_list(path)
    replacement = replacement.replace('<', '&lt').replace('>', '&gt')
    section_ranges = find_section_lines(lines, section)
    if section_ranges:
        result = lines[:section_ranges[0].start]
        result = (*result, f"{section}: |-")
        result = add_replacement_to_result(replacement, result)
        end_line = section_ranges[0].end
        for line in lines[end_line:]:
            result = [*result, line]
        result = [*result, '\n']
    else:
        result = lines
        result = (*result, f"\n{section}: |-")
        result = add_replacement_to_result(replacement, result)

    write_output(path, result)


def replace_yaml_key(key: str, replacement: str, rule_dir: dict) -> None:
    path_dir = rule_dir['dir']
    path = os.path.join(path_dir, 'rule.yml')
    lines = get_yaml_contents(rule_dir)
    section_ranges = find_section_lines(lines.contents, key)
    replacement_line = f"{key}: {replacement}"
    if section_ranges:
        result = lines.contents[:section_ranges[0].start]
        result = (*result, replacement_line)
        end_line = section_ranges[0].end
        for line in lines.contents[end_line:]:
            result = (*result, line)
    else:
        result = lines.contents
        result = (*result, replacement_line)

    with open(path, 'w') as f:
        for line in result:
            f.write(line.rstrip())
            f.write('\n')


def get_cac_status(disa: str) -> str:
    return SEVERITY.get(disa, 'Unknown')


def add_replacement_to_result(replacement, result):
    for line in replacement.split("\n"):
        if line != "":
            result = (*result, f"    {line}",)
        else:
            result = (*result, "")
    return result
