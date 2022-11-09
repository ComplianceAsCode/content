#!/usr/bin/python3

import argparse
import difflib
import os.path

import jinja2

from openpyxl import load_workbook

import ssg.jinja
from utils.srg_utils import *

SSG_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
BUILD_ROOT = os.path.join(SSG_ROOT, "build")
OUTPUT_PATH = os.path.join(BUILD_ROOT, "srg_diff.html")
RULES_JSON = os.path.join(BUILD_ROOT, "rule_dirs.json")


def _parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument('--base', '-b', help="The file to compare to, usually the file from the"
                                             " latest build of CaC, in xlsx format.",
                        required=True)
    parser.add_argument('--target', '-t', help="The file with the changes, usually the file "
                                               "modified by external parities, in xlsx format.",
                        required=True)
    parser.add_argument('--changed-name', '-n', type=str, action="store",
                        help="The name that DISA uses for the product. Defaults to RHEL 9",
                        default="RHEL 9")
    parser.add_argument('--product', '-p', type=str, action="store", required=True,
                        help="The product")
    parser.add_argument('--output', '-o', type=str, action="store", default=OUTPUT_PATH,
                        help=f"What file to output the diff to. Defaults to {OUTPUT_PATH}")
    parser.add_argument("-r", "--root", type=str, action="store", default=SSG_ROOT,
                        help=f"Path to SSG root directory (defaults to {SSG_ROOT})")
    parser.add_argument("-e", '--end-row', type=int, action="store", default=600,
                        help="What row to end on, defaults to 600")
    parser.add_argument("-j", "--json", type=str, action="store", default=RULES_JSON,
                        help=f"Path to the rules_dir.json (defaults to {RULES_JSON})")
    return parser.parse_args()


class SrgDiffResult:
    cci = ""
    rule_id = ""
    Requirement = ""
    Vul_Discussion = ""
    Status = ""
    Check = ""
    Fix = ""
    Severity = ""

    def should_display(self):
        return self.Requirement != "" or self.Vul_Discussion != "" or self.Status != "" or \
                self.Check != "" or self.Fix != "" or self.Severity != ""

    def __repr__(self):
        return f'SrgDiffResult({self.cci}, {self.rule_id})'

    def __lt__(self, other):
        return self.cci < other.cci


def word_by_word_diff(original: str, edited: str) -> str:
    if original is None or edited is None:
        return ""
    differ = difflib.HtmlDiff()

    table = differ.make_table(clean_lines(original).split('\n'), edited.split('\n'))

    return table


def clean_lines(lines: str) -> str:
    result = list()
    for line in lines.split('\n'):
        result.append(line.rstrip())
    return '\n'.join(result)


def _get_delta(cac: Row, disa: Row, cce: str, cce_rule_id_dict: dict) -> SrgDiffResult:
    delta = SrgDiffResult()
    delta.cci = cce
    delta.rule_id = cce_rule_id_dict[cce]
    if clean_lines(disa.Requirement) != cac.Requirement:
        delta.Requirement = word_by_word_diff(disa.Requirement, cac.Requirement)
    if clean_lines(disa.Vul_Discussion) != cac.Vul_Discussion:
        delta.Vul_Discussion = word_by_word_diff(disa.Vul_Discussion, cac.Vul_Discussion)
    if clean_lines(disa.Status) != cac.Status:
        delta.Status = word_by_word_diff(disa.Status, cac.Status)
    if clean_lines(disa.Check) != cac.Check:
        delta.Check = word_by_word_diff(disa.Check, cac.Check)
    if clean_lines(disa.Fix) != cac.Fix and cac.Fix is not None and disa.Fix is not None:
        delta.Fix = word_by_word_diff(disa.Fix, cac.Fix)
    if clean_lines(disa.Severity) != cac.Severity:
        disa.Severity = word_by_word_diff(disa.Severity, cac.Severity)
    return delta


def _create_template(root_path: str) -> jinja2.Template:
    loader = ssg.jinja.AbsolutePathFileSystemLoader()
    env = jinja2.Environment(loader=loader)
    path = os.path.join(root_path, 'utils', 'srg_diff.html')
    template = env.get_template(path)
    return template


def get_requirements_with_no_cces(sheet: Worksheet, end_row: int) -> list:
    result = list()
    for i in range(2, end_row):
        requirement = sheet[f'F{i}'].value
        if requirement is None or requirement.strip() == "":
            continue
        cce = sheet[f'D{i}'].value
        if cce is not None and cce.startswith('CCE-') and requirement.strip() != "":
            continue
        status = sheet[f'I{i}'].value
        if status is not None and status.strip() == 'Applicable - Configurable':
            srgs_ids = sheet[f'C{i}'].value
            result.append(f'{requirement.strip()} - {srgs_ids}')
    return result


def get_deltas(cac_cce_dict: dict, cce_rule_id_dict: dict, common_set: set, disa_cce_dict: dict) \
        -> list:
    deltas = list()
    for cce in common_set:
        disa = disa_cce_dict[cce]
        cac = cac_cce_dict[cce]
        delta = _get_delta(cac, disa, cce, cce_rule_id_dict)
        deltas.append(delta)
    return deltas


def get_worksheet(path: str) -> Worksheet:
    wb = load_workbook(path)
    return wb['Sheet']


def get_missing_in(in_set: set, cce_rule_id_dict: dict) -> list:
    result = list()
    for cce in in_set:
        cce = cce.replace('\n', '').strip()
        result.append(f"{cce} - {cce_rule_id_dict[cce]}")
    return result


def main():
    args = _parse_args()
    base_path = args.base
    target_path = args.target
    target_sheet = get_worksheet(base_path)
    base_sheet = get_worksheet(target_path)
    base_set = get_stigid_set(base_sheet, args.end_row)
    target_set = get_stigid_set(target_sheet, args.end_row)
    full_name = get_full_name(args.root, args.product)

    cac_cce_dict = get_cce_dict_to_row_dict(target_sheet, full_name, args.changed_name,
                                            args.end_row)
    disa_cce_dict = get_cce_dict_to_row_dict(base_sheet, full_name, args.changed_name,
                                             args.end_row)

    base_missing_stig_ids = get_requirements_with_no_cces(base_sheet, args.end_row)
    target_missing_stig_ids = get_requirements_with_no_cces(target_sheet, args.end_row)

    common_set = target_set - (target_set - base_set)

    rule_dir_json = get_rule_dir_json(args.json)
    cce_rule_id_dict = get_cce_dict(rule_dir_json, args.product)

    missing_in_base = get_missing_in((target_set - base_set), cce_rule_id_dict)
    missing_in_target = get_missing_in((base_set - target_set), cce_rule_id_dict)

    deltas = get_deltas(cac_cce_dict, cce_rule_id_dict, common_set, disa_cce_dict)

    title = f"{base_path} vs {target_path}"

    template = _create_template(args.root)
    missing_in_base.sort()
    missing_in_target.sort()
    deltas.sort()
    base_missing_stig_ids.sort()
    target_missing_stig_ids.sort()
    output = template.render(missing_in_base=missing_in_base, deltas=deltas,
                             missing_in_target=missing_in_target, title=title,
                             base_missing_stig_ids=base_missing_stig_ids,
                             target_missing_stig_ids=target_missing_stig_ids)

    with open(args.output, 'w') as f:
        f.write(output)

    print(f"Wrote output to {args.output}.")


if __name__ == "__main__":
    main()
