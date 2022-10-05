import argparse
import difflib
import os.path

import jinja2

from openpyxl import load_workbook

import ssg.jinja
from utils.srg_utils import *

SSG_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
RULES_JSON = os.path.join(SSG_ROOT, "build", "rule_dirs.json")


def _parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument('--disa', '-d', help="The file submitted to DISA, in xlsx format",
                        required=True)
    parser.add_argument('--cac', '-c', help="The latest file from CaC, in xlsx format",
                        required=True)
    parser.add_argument('--changed-name', '-n', type=str, action="store",
                        help="The name that DISA uses for the product. Defaults to RHEL 9",
                        default="RHEL 9")
    parser.add_argument('--product', '-p', type=str, action="store", required=True,
                        help="The product")
    parser.add_argument('--output', '-o', type=str, action="store",
                        help="What file to output the diff to")
    parser.add_argument("-r", "--root", type=str, action="store", default=SSG_ROOT,
                        help=f"Path to SSG root directory (defaults to {SSG_ROOT})")
    parser.add_argument("-e", '--end-row', type=int, action="store", default=600,
                        help="What row to end on, defaults to 600")
    parser.add_argument("-j", "--json", type=str, action="store", default=RULES_JSON,
                        help=f"Path to the rules_dir.json (defaults to {RULES_JSON})")
    return parser.parse_args()


class SrgDiffResult:
    cci = ""
    Requirement = ""
    Vul_Discussion = ""
    Status = ""
    Check = ""
    Fix = ""
    Severity = ""

    def should_display(self):
        return self.Requirement != "" or self.Vul_Discussion != "" or self.Status != "" or \
                self.Check != "" or self.Fix != "" or self.Severity != ""


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


def _get_delta(cac: Row, disa: Row, cce: str) -> SrgDiffResult:
    delta = SrgDiffResult()
    delta.cci = cce
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


def main():
    args = _parse_args()
    disa_path = args.disa
    cac_path = args.cac
    disa_wb = load_workbook(disa_path)
    cac_wb = load_workbook(cac_path)
    disa_set = get_stigid_set(disa_wb['Sheet'], args.end_row)
    cac_sheet = cac_wb['Sheet']
    disa_sheet = disa_wb['Sheet']
    cac_set = get_stigid_set(cac_sheet, args.end_row)
    full_name = get_full_name(args.root, args.product)

    cac_cce_dict = get_cce_dict_to_row_dict(cac_sheet, full_name, args.changed_name, args.end_row)
    disa_cce_dict = get_cce_dict_to_row_dict(disa_sheet, full_name, args.changed_name,
                                             args.end_row)
    common_set = cac_set - (cac_set - disa_set)

    rule_dir_json = get_rule_dir_json(args.json)
    cce_rule_id_dict = get_cce_dict(rule_dir_json, args.product)

    deltas = list()
    missing_in_disa = list()
    missing_in_cac = list()
    for cci in (cac_set - disa_set):
        cci = cci.replace('\n', '').strip()
        missing_in_disa.append(f"{cci} - {cce_rule_id_dict[cci]}")

    for cci in (disa_set - cac_set):
        cci = cci.replace('\n', '').strip()
        missing_in_cac.append(f"{cci} - {cce_rule_id_dict[cci]}")

    for cce in common_set:
        disa = disa_cce_dict[cce]
        cac = cac_cce_dict[cce]
        delta = _get_delta(cac, disa, cce)
        deltas.append(delta)

    title = f"{disa_path} vs {cac_path}"

    template = _create_template(args.root)
    output = template.render(missing_in_disa=missing_in_disa, deltas=deltas,
                             missing_in_cac=missing_in_cac, title=title)
    with open(args.output, 'w') as f:
        f.write(output)

    print(f"Wrote output to {args.output}.")


if __name__ == "__main__":
    main()
