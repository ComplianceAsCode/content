import os
import re
from pathlib import Path

from ssg.rule_yaml import find_section_lines, get_yaml_contents
from ssg.utils import read_file_list, mkdir_p


def add_replacement_to_result(replacement, result):
    for line in replacement.split("\n"):
        if line != "":
            result = (*result, f"    {line}",)
        else:
            result = (*result, "")
    return result


def replace_yaml_section(section: str, replacement: str, rule_dir: dict) -> None:
    path = create_output(rule_dir['dir'])

    lines = read_file_list(path)
    replacement = replacement.replace('<', '&lt;').replace('>', '&gt;')
    replacement = re.sub(r'Satisfies: SRG-OS.+', '', replacement)
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


def update_row(changed: str, current: str, rule_dir_json: dict, section: str) -> None:
    if changed != current and changed:
        replace_yaml_section(section, changed, rule_dir_json)


def create_output(rule_dir: str) -> str:
    path_dir_parent = os.path.join(rule_dir, "policy")
    mkdir_p(path_dir_parent)
    path_dir = os.path.join(path_dir_parent, "stig")
    mkdir_p(path_dir)
    path = os.path.join(path_dir, 'shared.yml')
    Path(path).touch()
    return path


def write_output(path: str, result: tuple) -> None:
    with open(path, 'w') as f:
        first_time = True
        for line in result:
            if first_time:
                first_time = False
                line = re.sub(r'^\n', '', result[0])
            f.write(line.rstrip())
            f.write('\n')
