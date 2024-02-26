#!/usr/bin/python3
from __future__ import annotations

import argparse
import os
from typing import cast

from openpyxl.worksheet.worksheet import Worksheet
from openpyxl import load_workbook

from utils.srg_utils import get_full_name, get_stigid_set, get_cce_dict_to_row_dict, \
    get_cce_dict, get_rule_dir_json, fix_changed_text, cleanup_end_of_file, \
    update_severity
from utils.srg_utils.yaml import update_row

SSG_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
RULES_JSON = os.path.join(SSG_ROOT, "build", "rule_dirs.json")


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
                        help="What product id to use.")
    parser.add_argument("-e", '--end-row', type=int, action="store", default=600,
                        help="What row to end on, defaults to 600")
    return parser.parse_args()


def fix_cac_cells(content: str, full_name: str, changed_name: str) -> str:
    if content:
        return content.replace(full_name, changed_name)
    return ""


def get_common_set(changed_sheet: Worksheet, current_sheet: Worksheet, end_row: int):
    changed_set = get_stigid_set(changed_sheet, end_row)
    current_set = get_stigid_set(current_sheet, end_row)
    common_set = current_set - (current_set - changed_set)
    return common_set


def main() -> None:
    args = _parse_args()
    full_name = get_full_name(args.root, args.product)
    changed_wb = load_workbook(args.changed)
    current_wb = load_workbook(args.current)
    current_sheet = cast(Worksheet, current_wb['Sheet'])
    changed_sheet = cast(Worksheet, changed_wb['Sheet'])
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
