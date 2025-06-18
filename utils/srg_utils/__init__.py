import json
import os
import re
from pathlib import Path

import yaml

from ssg.utils import mkdir_p
from ssg.yaml import yaml_SafeLoader
from ssg.build_stig import SEVERITY
from utils.srg_utils.yaml import replace_yaml_key

def get_full_name(root_dir: str, product: str) -> str:
    product_yml_path = os.path.join(root_dir, 'products', product, 'product.yml')
    with open(product_yml_path, 'r') as f:
        data = yaml.load(f, Loader=yaml_SafeLoader)
        return data['full_name']


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


def fix_changed_text(replacement: str, changed_name: str) -> str:
    no_space_name = changed_name.replace(' ', '')
    return replacement.replace(changed_name, '{{{ full_name }}}')\
        .replace(no_space_name, '{{{ full_name }}}')


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

def get_cac_status(disa: str) -> str:
    return SEVERITY.get(disa, 'Unknown')

def update_severity(changed, current, rule_dir_json):
    if changed.Severity != current.Severity and changed.Severity is not None and \
            current.Severity is not None:
        cac_severity = get_cac_status(changed.Severity)
        replace_yaml_key('severity', cac_severity, rule_dir_json)
