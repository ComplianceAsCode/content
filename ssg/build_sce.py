from __future__ import absolute_import
from __future__ import print_function

import os
import os.path
import json


from .build_yaml import Rule, DocumentationNotComplete
from .constants import MULTI_PLATFORM_LIST
from .jinja import process_file_with_macros
from .rule_yaml import parse_prodtype
from .rules import get_rule_dir_id, get_rule_dir_sces, find_rule_dirs_in_paths
from . import utils

def load_sce_and_metadata(file_path, local_env_yaml):
    raw_content = process_file_with_macros(file_path, local_env_yaml)

    metadata = dict()
    sce_content = []

    for line in raw_content.split("\n"):
        if line.startswith('##ssg##'):
            key, value = line[7:].split('=', maxsplit=1)
            values = value.strip()
            if ',' in values:
                values.split(',')
            metadata[key.strip()] = values
        else:
            sce_content.append(line)

    return "\n".join(sce_content), metadata

def _check_is_applicable_for_product(metadata, product):
    if 'platform' not in metadata:
        return True

    product, product_version = utils.parse_name(product)

    multi_product = 'multi_platform_{0}'.format(product)
    if product in ['macos', 'ubuntu']:
        product_version = product_version[:2] + "." + product_version[2:]

    return ('multi_platform_all' in metadata['platform'] or
            (multi_product in metadata['platform'] and
             product in MULTI_PLATFORM_LIST) or
            (product in metadata['platform'] and
             product_version in metadata['platform']))


def _check_is_loaded(already_loaded, filename):
    # Right now this check doesn't look at metadata or anything
    # else. Eventually we might add versions to the entry or
    # something.
    return filename in already_loaded


def checks(env_yaml, yaml_path, sce_dirs, output):
    product = utils.required_key(env_yaml, "product")
    included_checks_count = 0
    reversed_dirs = sce_dirs[::-1]
    already_loaded = dict()
    local_env_yaml = dict()
    local_env_yaml.update(env_yaml)

    product_dir = os.path.dirname(yaml_path)
    relative_guide_dir = utils.required_key(env_yaml, "benchmark_root")
    guide_dir = os.path.abspath(os.path.join(product_dir, relative_guide_dir))
    additional_content_directories = env_yaml.get("additional_content_directories", [])
    add_content_dirs = [
        os.path.abspath(os.path.join(product_dir, rd))
        for rd in additional_content_directories
    ]

    for _dir_path in find_rule_dirs_in_paths([guide_dir] + add_content_dirs):
        rule_id = get_rule_dir_id(_dir_path)

        rule_path = os.path.join(_dir_path, "rule.yml")
        try:
            rule = Rule.from_yaml(rule_path, env_yaml)
        except DocumentationNotComplete:
            # Happens on non-debug builds when a rule isn't yet completed. We
            # don't want to build the SCE check for this rule yet so skip it
            # and move on.
            continue
        prodtypes = parse_prodtype(rule.prodtype)

        local_env_yaml['rule_id'] = rule.id_
        local_env_yaml['rule_title'] = rule.title
        local_env_yaml['products'] = prodtypes # default is all

        for _path in get_rule_dir_sces(_dir_path, product):
            # To be compatible with later checks, use the rule_id (i.e., the
            # value of _dir) to recreate the expected filename if this OVAL
            # was in a rule directory. However, note that unlike
            # build_oval.checks(...), we have to get this script's extension
            # first.
            _, ext = os.path.splitext(_path)
            filename = "{0}{1}".format(rule_id, ext)

            sce_content, metadata = load_sce_and_metadata(_path, local_env_yaml)
            metadata['filename'] = filename

            if not _check_is_applicable_for_product(metadata, product):
                continue
            if _check_is_loaded(already_loaded, filename):
                continue

            output_file = open(os.path.join(output, filename), 'w')
            print(sce_content, file=output_file)

            included_checks_count += 1
            already_loaded[rule_id] = metadata

    for sce_dir in reversed_dirs:
        if not os.path.isdir(sce_dir):
            continue

        for filename in sorted(os.listdir(sce_dir)):
            rule_id, _ = os.path.splitext(filename)

            sce_content, metadata = load_sce_and_metadata(filename, env_yaml)
            metadata['filename'] = filename

            if not _check_is_applicable_for_product(metadata, product):
                continue
            if _check_is_loaded(already_loaded, filename):
                continue

            output_file = open(os.path.join(output, filename), 'w')
            print(sce_content, file=output_file)

            included_checks_count += 1
            already_loaded[rule_id] = metadata

    # n.b.: Templated SCE checks don't yet exist.
    templates_metadata = os.path.join(output, 'templates_metadata.json')
    if os.path.exists(templates_metadata):
        templates = json.load(open(templates_metadata, 'r'))
        templates.update(already_loaded)
        already_loaded = templates
    metadata_path = os.path.join(output, 'metadata.json')
    json.dump(already_loaded, open(metadata_path, 'w'))

    return already_loaded
