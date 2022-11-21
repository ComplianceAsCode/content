#!/usr/bin/python3
from __future__ import annotations

import argparse
import os
import re
from pathlib import Path

from openpyxl.worksheet.worksheet import Worksheet
from openpyxl import load_workbook

from ssg.rule_yaml import find_section_lines, get_yaml_contents
from ssg.utils import read_file_list
from utils.srg_utils import get_full_name, get_stigid_set, get_cce_dict_to_row_dict, \
    get_cce_dict, get_rule_dir_json

SSG_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
RULES_JSON = os.path.join(SSG_ROOT, "build", "rule_dirs.json")
SEVERITY = {'CAT III': 'low', 'CAT II': 'medium', 'CAT I': 'high'}


def _parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument('--changed', '-c', help="The file with changes, in xlsx", required=True)
    parser.add_argument('--current', '-b', help="The latest file from CaC, in xlsx", required=True)
    parser.add_argument('--changed-name', '-n', type=str, action="store",
                        help="The name that DISA uses for the product. Defaults to RHEL 9",
                        default="RHEL 9")
    parser.add_argument("-r", "--root", type=str, action="store", default=SSG_ROOT,
                        help=f"Path to SSG root directory (defaults to {SSG_ROOT})")
    parser.add_argument("-j", "--json", type=str, action="store", default=RULES_JSON,
                        help=f"Path to the rules_dir.json (defaults to {RULES_JSON})")
    parser.add_argument("-p", "--product", type=str, action="store", required=True,
                        help="What product product id to use.")
    parser.add_argument("-e", '--end-row', type=int, action="store", default=600,
                        help="What row to end on, defaults to 600")
    return parser.parse_args()


def get_cac_status(disa: str) -> str:
    return SEVERITY.get(disa, 'Unknown')


def create_output(rule_dir: str) -> str:
    path_dir_parent = os.path.join(rule_dir, "policy")
    if not os.path.exists(path_dir_parent):
        os.mkdir(path_dir_parent)
    path_dir = os.path.join(path_dir_parent, "stig")
    if not os.path.exists(path_dir):
        os.mkdir(path_dir)
    path = os.path.join(path_dir, 'shared.yml')
    Path(path).touch()
    return path


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


def add_replacement_to_result(replacement, result):
    for line in replacement.split("\n"):
        if line != "":
            result = (*result, f"    {line}",)
        else:
            result = (*result, "")
    return result


def fix_cac_cells(content: str, full_name: str, changed_name: str) -> str:
    if content:
        return content.replace(full_name, changed_name)
    return ""


def get_common_set(changed_sheet: Worksheet, current_sheet: Worksheet, end_row: int):
    changed_set = get_stigid_set(changed_sheet, end_row)
    current_set = get_stigid_set(current_sheet, end_row)
    common_set = current_set - (current_set - changed_set)
    return common_set


def update_severity(changed, current, rule_dir_json):
    if changed.Severity != current.Severity and changed.Severity is not None and \
            current.Severity is not None:
        cac_severity = get_cac_status(changed.Severity)
        replace_yaml_key('severity', cac_severity, rule_dir_json)


def update_row(changed: str, current: str, rule_dir_json: dict, section: str):
    if changed != current and changed:
        replace_yaml_section(section, changed, rule_dir_json)


def fix_changed_text(replacement: str, changed_name: str):
    no_space_name = changed_name.replace(' ', '')
    return replacement.replace(changed_name, '{{{ full_name }}}')\
        .replace(no_space_name, '{{{ full_name }}}')


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


def main() -> None:
    args = _parse_args()
    full_name = get_full_name(args.root, args.product)
    changed_wb = load_workbook(args.changed)
    current_wb = load_workbook(args.current)
    current_sheet = current_wb['Sheet']
    changed_sheet = changed_wb['Sheet']
    common_set = get_common_set(changed_sheet, current_sheet, args.end_row)

    cac_cce_dict = get_cce_dict_to_row_dict(current_sheet, full_name, args.changed_name,
                                            args.end_row)
    disa_cce_dict = get_cce_dict_to_row_dict(changed_sheet, full_name, args.changed_name,
                                             args.end_row)

    rule_dir_json = get_rule_dir_json(args.json)
    cce_rule_id_dict = get_cce_dict(rule_dir_json, args.product)

    for cce in common_set:
        changed = disa_cce_dict[cce]
        current = cac_cce_dict[cce]
        rule_id = cce_rule_id_dict[cce]
        rule_obj = rule_dir_json[rule_id]

        cleaned_changed_requirement = fix_changed_text(changed.Requirement, args.changed_name)
        update_row(cleaned_changed_requirement, current.Requirement, rule_obj, 'srg_requirement')

        cleaned_changed_vuln_discussion = fix_changed_text(changed.Vul_Discussion,
                                                           args.changed_name)
        update_row(cleaned_changed_vuln_discussion, current.Vul_Discussion, rule_obj,
                   'vuldiscussion')

        cleaned_current_check = fix_cac_cells(current.Check, full_name, args.changed_name)
        cleaned_current_check = fix_changed_text(cleaned_current_check, args.changed_name)
        update_row(cleaned_current_check, changed.Check, rule_obj, 'checktext')

        cleaned_current_fix = fix_cac_cells(current.Fix, full_name, args.changed_name)
        cleaned_changed_fix = fix_changed_text(changed.Fix, args.changed_name)
        update_row(cleaned_changed_fix, cleaned_current_fix, rule_obj, 'fixtext')

        update_severity(changed, current, rule_obj)

        cleanup_end_of_file(rule_obj['dir'])


if __name__ == "__main__":
    main()
