from __future__ import absolute_import
from __future__ import print_function

import os
import os.path
import json
import sys

from .build_yaml import Rule, DocumentationNotComplete
from .constants import (
    MULTI_PLATFORM_LIST, OSCAP_VALUE, datastream_namespace,
    xlink_namespace, XCCDF12_NS, SCE_SYSTEM
)
from .jinja import process_file_with_macros
from .rule_yaml import parse_prodtype
from .rules import get_rule_dir_id, get_rule_dir_sces, find_rule_dirs_in_paths
from . import utils


def load_sce_and_metadata(file_path, local_env_yaml):
    """
    For the given SCE audit file (file_path) under the specified environment
    (local_env_yaml), parse the file while expanding Jinja macros and read any
    metadata headers the file contains. Note that the last keyword of a
    specified type is the recorded one.

    Returns (audit_content, metadata).
    """

    raw_content = process_file_with_macros(file_path, local_env_yaml)
    return load_sce_and_metadata_parsed(raw_content)


def load_sce_and_metadata_parsed(raw_content):
    metadata = dict()
    sce_content = []

    keywords = ['platform', 'check-import', 'check-export', 'complex-check']
    for line in raw_content.split("\n"):
        found_metadata = False
        for keyword in keywords:
            if not line.startswith('# ' + keyword + ' = '):
                continue

            found_metadata = True

            # Strip off the initial comment marker
            _, value = line[2:].split('=', maxsplit=1)
            metadata[keyword] = value.strip()

        if not found_metadata:
            sce_content.append(line)

    if 'check-export' in metadata:
        # Special case for the variables exposed to the SCE script: prepend
        # the OSCAP_VALUE prefix to reference the variable
        new_variables = []
        for value in metadata['check-export'].split(','):
            k, v = value.split('=', maxsplit=1)
            new_variables.append(k+'='+OSCAP_VALUE+v)
        metadata['check-export'] = new_variables

    if 'platform' in metadata:
        metadata['platform'] = metadata['platform'].split(',')

    return "\n".join(sce_content), metadata


def _check_is_applicable_for_product(metadata, product):
    """
    Validates whether or not the specified check is applicable for this
    product. Different from build_ovals.py in that this operates directly
    on the parsed metadata and doesn't have to deal with matching XML
    elements.
    """

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


def checks(env_yaml, yaml_path, sce_dirs, template_builder, output):
    """
    Walks the build system and builds all SCE checks (and metadata entry)
    into the output directory.
    """
    product = utils.required_key(env_yaml, "product")
    included_checks_count = 0
    reversed_dirs = sce_dirs[::-1]
    already_loaded = dict()
    local_env_yaml = dict()
    local_env_yaml.update(env_yaml)

    # We maintain the same search structure as build_ovals.py even though we
    # don't currently have any content under shared/checks/sce.
    product_dir = os.path.dirname(yaml_path)
    relative_guide_dir = utils.required_key(env_yaml, "benchmark_root")
    guide_dir = os.path.abspath(os.path.join(product_dir, relative_guide_dir))
    additional_content_directories = env_yaml.get("additional_content_directories", [])
    add_content_dirs = [
        os.path.abspath(os.path.join(product_dir, rd))
        for rd in additional_content_directories
    ]

    # First walk all rules under the product. These have higher priority than any
    # out-of-tree SCE checks.
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
        if prodtypes and 'all' not in prodtypes and product not in prodtypes:
            # The prodtype exists, isn't all and doesn't contain this current
            # product, so we're best to skip this rule altogether.
            continue

        local_env_yaml['rule_id'] = rule.id_
        local_env_yaml['rule_title'] = rule.title
        local_env_yaml['products'] = prodtypes  # default is all

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
            if _check_is_loaded(already_loaded, rule_id):
                continue

            with open(os.path.join(output, filename), 'w') as output_file:
                print(sce_content, file=output_file)

            included_checks_count += 1
            already_loaded[rule_id] = metadata

        if rule.template:
            langs = template_builder.get_resolved_langs_to_generate(rule)
            if 'sce-bash' in langs:
                # Here we know the specified rule has a template and this
                # template actually generates (bash) SCE content. We
                # prioritize bespoke SCE content over templated content,
                # however, while we add this to our metadata, we do not
                # bother (yet!) with generating the SCE content. This is done
                # at a later time by build-scripts/build_templated_content.py.
                if _check_is_loaded(already_loaded, rule_id):
                    continue

                # While we don't _write_ it, we still need to parse SCE
                # metadata from the templated content. Render it internally.
                raw_sce_content = template_builder.get_lang_contents_for_templatable(
                    rule, langs['sce-bash']
                )

                ext = '.sh'
                filename = rule_id + ext

                # Load metadata and infer correct file name.
                sce_content, metadata = load_sce_and_metadata_parsed(raw_sce_content)
                metadata['filename'] = filename

                # Skip the check if it isn't applicable for this product.
                if not _check_is_applicable_for_product(metadata, product):
                    continue

                with open(os.path.join(output, filename), 'w') as output_file:
                    print(sce_content, file=output_file)

                # Finally, include it in our loaded content
                included_checks_count += 1
                already_loaded[rule_id] = metadata

    # Finally take any shared SCE checks and build them as well. Note that
    # there's no way for shorthand generation to include them if they do NOT
    # align with a particular rule_id, so it is suggested that the former
    # method be used.
    for sce_dir in reversed_dirs:
        if not os.path.isdir(sce_dir):
            continue

        for filename in sorted(os.listdir(sce_dir)):
            rule_id, _ = os.path.splitext(filename)

            sce_content, metadata = load_sce_and_metadata(filename, env_yaml)
            metadata['filename'] = filename

            if not _check_is_applicable_for_product(metadata, product):
                continue
            if _check_is_loaded(already_loaded, rule_id):
                continue

            with open(os.path.join(output, filename), 'w') as output_file:
                print(sce_content, file=output_file)

            included_checks_count += 1
            already_loaded[rule_id] = metadata

    # Finally, write out our metadata to disk so that we can reference it in
    # later build stages (such as during building shorthand content).
    metadata_path = os.path.join(output, 'metadata.json')
    json.dump(already_loaded, open(metadata_path, 'w'))

    return already_loaded


# Retrieve the SCE checks and return a list of path to each check script.
def collect_sce_checks(datastreamtree):
    checklists = datastreamtree.find(
        ".//{%s}checklists" % datastream_namespace)
    checklists_component_ref = checklists.find(
        "{%s}component-ref" % datastream_namespace)
    # The component ID is the component-ref href without leading '#'
    checklist_component_id = checklists_component_ref.get('{%s}href' % xlink_namespace)[1:]

    checks_xpath = str.format(
        ".//{{{ds_ns}}}component[@id='{cid}']/"
        "{{{xccdf_ns}}}Benchmark//"
        "{{{xccdf_ns}}}Rule/"
        "{{{xccdf_ns}}}check[@system='{sce_sys}']/"
        "{{{xccdf_ns}}}check-content-ref",
        ds_ns=datastream_namespace,
        xccdf_ns=XCCDF12_NS,
        cid=checklist_component_id,
        sce_sys=SCE_SYSTEM
    )

    checks = datastreamtree.findall(checks_xpath)
    # Extract the file paths of the SCE checks
    return [check.get('href') for check in checks]
