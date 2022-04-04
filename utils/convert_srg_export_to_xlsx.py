#!/usr/bin/env python3

import argparse
import csv
import datetime
import os
import openpyxl
from openpyxl.styles import Alignment, Font


SSG_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
RULES_JSON = os.path.join(SSG_ROOT, "build", "rule_dirs.json")
BUILD_CONFIG = os.path.join(SSG_ROOT, "build", "build_config.yml")
OUTPUT = os.path.join(SSG_ROOT, 'build',
                      f'{datetime.datetime.now().strftime("%s")}_stig_export.xlsx')


def setup_sheet(sheet: openpyxl.worksheet.worksheet.Worksheet) -> None:
    sheet.column_dimensions['A'].width = 17
    sheet.column_dimensions['B'].width = 17
    sheet.column_dimensions['C'].width = 17
    sheet.column_dimensions['E'].width = 4 * sheet.column_dimensions['A'].width
    sheet.column_dimensions['F'].width = 4 * sheet.column_dimensions['A'].width
    sheet.column_dimensions['G'].width = 4 * sheet.column_dimensions['A'].width
    sheet.column_dimensions['H'].width = 4 * sheet.column_dimensions['A'].width
    sheet.column_dimensions['I'].width = 1.5 * sheet.column_dimensions['A'].width
    sheet.column_dimensions['K'].width = 4 * sheet.column_dimensions['A'].width
    sheet.column_dimensions['J'].width = 4 * sheet.column_dimensions['A'].width
    sheet.column_dimensions['M'].width = 4 * sheet.column_dimensions['A'].width
    sheet.column_dimensions['O'].width = 3 * sheet.column_dimensions['A'].width
    sheet.column_dimensions['P'].width = 3 * sheet.column_dimensions['A'].width
    sheet.column_dimensions['Q'].width = 3 * sheet.column_dimensions['A'].width


def setup_headers(sheet: openpyxl.worksheet.worksheet.Worksheet) -> None:
    sheet['A1'] = 'IA Control'
    sheet['B1'] = 'CCI'
    sheet['C1'] = 'SRGID'
    sheet['D1'] = 'STIGID'
    sheet['E1'] = 'SRG Requirement'
    sheet['F1'] = 'Requirement'
    sheet['G1'] = 'SRG VulDiscussion'
    sheet['H1'] = 'Vul Discussion'
    sheet['I1'] = 'Status'
    sheet['J1'] = 'SRG Check'
    sheet['K1'] = 'Check'
    sheet['L1'] = 'SRG Fix'
    sheet['M1'] = 'Fix'
    sheet['N1'] = 'Severity'
    sheet['O1'] = 'Mitigation'
    sheet['P1'] = 'Artifact Description'
    sheet['Q1'] = 'Status Justification'
    for cell in list(sheet.iter_rows(max_row=1))[0]:
        cell.font = Font(bold=True, name='Calibri')


def format_cells(sheet: openpyxl.worksheet.worksheet.Worksheet):
    for row in sheet.iter_rows():
        for cell in row:
            cell.alignment = cell.alignment = Alignment(wrap_text=True, vertical='top')


def setup_row(sheet: openpyxl.worksheet.worksheet.Worksheet, row: dict, row_num: int) -> None:
    sheet[f'A{row_num}'] = row['IA Control']
    sheet[f'B{row_num}'] = row['CCI']
    sheet[f'C{row_num}'] = row['SRGID']
    sheet[f'D{row_num}'] = row['STIGID']
    sheet[f'E{row_num}'] = row['SRG Requirement']
    sheet[f'F{row_num}'] = row['Requirement']
    sheet[f'G{row_num}'] = row['SRG VulDiscussion']
    sheet[f'H{row_num}'] = row['Vul Discussion']
    sheet[f'I{row_num}'] = row['Status']
    sheet[f'J{row_num}'] = row['SRG Check']
    sheet[f'K{row_num}'] = row['Check']
    sheet[f'L{row_num}'] = row['SRG Fix']
    sheet[f'M{row_num}'] = row['Fix']
    sheet[f'N{row_num}'] = row['Severity']
    sheet[f'O{row_num}'] = row['Mitigation']
    sheet[f'P{row_num}'] = row['Artifact Description']
    sheet[f'Q{row_num}'] = row['Status Justification']
    sheet.row_dimensions[row_num].height = 42

    # freeze header row represented by A1
    # A2 is required because it freezes everything before it
    # in this case we only want A1 row to be frozen
    sheet.freeze_panes = "A2"


def handle_dict(data: list, output_path: str) -> None:
    """
    Given a dict with the fields for the srg export, create a formatted XLSX file
    """
    xlsx = openpyxl.Workbook()
    sheet = xlsx.active
    sheet.name = f'Sheet0'
    setup_headers(sheet)
    setup_sheet(sheet)
    row_num = 2
    for row in data:
        setup_row(sheet, row, row_num)
        row_num += 1
    format_cells(sheet)
    xlsx.save(output_path)
