from __future__ import annotations

from openpyxl.worksheet.worksheet import Worksheet

# The start row is 2, to avoid importing the header
START_ROW = 2


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
