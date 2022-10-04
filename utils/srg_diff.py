import argparse
import difflib
import os.path

import jinja2

from openpyxl import load_workbook

import ssg.jinja
from utils.srg_utils import Row, get_full_name, get_stigid_set, get_cce_dict_to_row_dict

SSG_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))


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
    return parser.parse_args()


class SrgDiffResult:
    cci = ""
    Requirement = ""
    Vul_Discussion = ""
    Status = ""
    Check = ""
    Fix = ""
    Severity = ""


def word_by_word_diff(original: str, edited: str) -> str:
    if original is None or edited is None:
        return ""
    differ = difflib.HtmlDiff()

    table = differ.make_table(original.split('\n'), edited.split('\n'))

    return table


def _get_delta(cac: Row, disa: Row, cce: str) -> SrgDiffResult:
    delta = SrgDiffResult()
    delta.cci = cce
    if disa.Requirement != cac.Requirement:
        delta.Requirement = word_by_word_diff(disa.Requirement, cac.Requirement)
    if disa.Vul_Discussion != cac.Vul_Discussion:
        delta.Vul_Discussion = word_by_word_diff(disa.Vul_Discussion, cac.Vul_Discussion)
    if disa.Status != cac.Status:
        delta.Status = word_by_word_diff(disa.Status, cac.Status)
    if disa.Check != cac.Check:
        delta.Check = word_by_word_diff(disa.Check, cac.Check)
    if disa.Fix != cac.Fix and cac.Fix is not None and disa.Fix is not None:
        delta.Fix = word_by_word_diff(disa.Fix, cac.Fix)
    if disa.Severity != cac.Severity and disa.Severity is not None and cac.Severity is not None:
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

    deltas = list()
    missing_in_disa = list()
    missing_in_cac = list()
    for cci in (cac_set - disa_set):
        missing_in_disa.append(f"{cci} - {cac_cce_dict[cci].Requirement}")

    for cci in (disa_set - cac_set):
        cci = cci.replace('\n', '').strip()
        missing_in_cac.append(f"{cci} - {disa_cce_dict[cci].Requirement}")

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
