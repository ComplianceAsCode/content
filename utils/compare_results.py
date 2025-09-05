#!/usr/bin/env python3

import argparse
import os
import sys

try:
    import ssg.xml
    from ssg.constants import PREFIX_TO_NS, SSG_REF_URIS, XCCDF12_NS
except ImportError:
    print("The ssg module could not be found.")
    print("Run .pyenv.sh available in the project root directory,"
          " or add it to PYTHONPATH manually.")
    print("$ source .pyenv.sh")
    exit(1)

from xml.etree import ElementTree as ElementTree

# So we don't hard code "xccdf-1.2"
XCCDF12 = list(PREFIX_TO_NS.keys())[list(PREFIX_TO_NS.values()).index(XCCDF12_NS)]


class Status:
    PASS = "pass"
    FAIL = "fail"
    ERROR = "error"
    NOT_CHECKED = "notchecked"
    NOT_SELECTED = "notselected"
    NOT_APPLICABLE = "notapplicable"
    INFORMATION = "informational"

    @classmethod
    def get_wining_status(cls, current_status: str, proposed: str) -> str:
        if current_status == cls.ERROR:
            return current_status
        elif current_status == cls.FAIL:
            return current_status
        elif current_status == cls.NOT_APPLICABLE:
            return current_status
        elif current_status == cls.NOT_SELECTED:
            return current_status
        elif current_status == cls.NOT_CHECKED:
            return current_status
        elif current_status == cls.INFORMATION:
            return current_status
        return proposed


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description='Compare two result ARF files.')
    parser.add_argument('base', help='Path to the first ARF file to compare')
    parser.add_argument('target', help='Path to the second ARF file to compare')
    return parser.parse_args()


def is_file_disa(xml: ElementTree.ElementTree) -> bool:
    return 'DISA' in xml.find(f'.//{XCCDF12}:metadata/dc:creator', PREFIX_TO_NS).text


def is_file_ssg(xml: ElementTree.ElementTree) -> bool:
    return 'SCAP Security Guide Project' in \
           xml.find(f'.//{XCCDF12}:metadata/dc:creator', PREFIX_TO_NS).text


def check_file(path: str) -> bool:
    if not os.path.exists(path):
        sys.stderr.write(f"File not found: {path}")
        exit(1)
    return True


def get_rule_to_stig_dict(xml: ElementTree.ElementTree, is_disa: bool) -> dict:
    rules = dict()
    for group in xml.findall(f'{XCCDF12}:Group', PREFIX_TO_NS):
        for sub_groups in group.findall(f'{XCCDF12}:Group', PREFIX_TO_NS):
            rules.update(get_rule_to_stig_dict(ElementTree.ElementTree(sub_groups), is_disa))
        for rule in group.findall(f'{XCCDF12}:Rule', PREFIX_TO_NS):
            rule_id = rule.attrib['id']
            if is_disa:
                stig_id = rule.find(f'{XCCDF12}:version', PREFIX_TO_NS).text
            else:
                elm = rule.find(f"{XCCDF12}:reference[@href='{SSG_REF_URIS['stigid']}']",
                                PREFIX_TO_NS)
                if elm is not None:
                    stig_id = elm.text
                else:
                    continue
            if stig_id in rules:
                rules[stig_id].append(rule_id)
            else:
                rules[stig_id] = [rule_id]
    return rules


def get_results(xml: ElementTree.ElementTree) -> dict:
    rules = dict()

    results_xml = xml.findall('.//xccdf-1.2:TestResult/xccdf-1.2:rule-result',
                              ssg.constants.PREFIX_TO_NS)
    for result in results_xml:
        idref = result.attrib['idref']
        rules[idref] = result.find('xccdf-1.2:result', ssg.constants.PREFIX_TO_NS).text

    return rules


def file_a_different_type(base_tree: ElementTree.ElementTree,
                          target_tree: ElementTree.ElementTree) \
        -> bool:
    """
    Check if both files are the same type.

    :param base_tree: base tree to check
    :param target_tree: target tree to check
    :return: true if the give trees are not the same type, otherwise return false.
    """
    return is_file_disa(base_tree) != is_file_disa(target_tree) or \
           is_file_ssg(base_tree) != is_file_ssg(target_tree)


def flatten_stig_results(stig_results: dict) -> dict:
    base_stig_flat_results = dict()
    for stig, results in stig_results.items():
        if len(results) == 1:
            base_stig_flat_results[stig] = results[0]
        status = results[0]
        for result in results:
            if result == status:
                continue
            else:
                status = Status.get_wining_status(status, result)
        base_stig_flat_results[stig] = status
    return base_stig_flat_results


def get_results_by_stig(results: dict, stigs: dict) -> dict:
    base_stig_results = dict()
    for base_stig, rules in stigs.items():
        base_stig_results[base_stig] = list()
        for rule in rules:
            base_stig_results[base_stig].append(results.get(rule))
    return base_stig_results


def print_summary(base_stig_flat_results: dict, different_results: dict, missing_in_target: list,
                  same_status: list) -> None:
    print(f'Missing in target: {len(missing_in_target)}')
    for rule in missing_in_target:
        print(f'\t{rule}')
    print(f'Same Status: {len(same_status)}')
    for rule in same_status:
        print(f'\t{rule}\t\t{base_stig_flat_results[rule]}')
    print(f'Different results: {len(different_results)}')
    for rule, value in different_results.items():
        print(f'\t{rule}\t\t{value[0]} - {value[1]}')


def process_stig_results(base_results: dict, target_results: dict,
                         base_tree: ElementTree.ElementTree,
                         target_tree: ElementTree.ElementTree) -> (dict, dict):
    base_stigs = get_rule_to_stig_dict(base_tree, is_file_disa(base_tree))
    target_stigs = get_rule_to_stig_dict(target_tree, is_file_disa(target_tree))
    base_stig_results = get_results_by_stig(base_results, base_stigs)
    target_stig_results = get_results_by_stig(target_results, target_stigs)
    base_stig_flat_results = flatten_stig_results(base_stig_results)
    target_stig_flat_results = flatten_stig_results(target_stig_results)
    return base_stig_flat_results, target_stig_flat_results


def do_compare(base_results: dict, target_results: dict) -> None:
    same_status = list()
    missing_in_target = list()
    different_results = dict()
    for base_result_id, base_result in base_results.items():
        target_result = target_results.get(base_result_id)
        if not target_result:
            missing_in_target.append(base_result_id)
            continue
        if base_result != target_result:
            different_results[base_result_id] = (base_result, target_result)
        else:
            same_status.append(base_result_id)
    print_summary(base_results, different_results, missing_in_target, same_status)


def match_results(base_tree: ElementTree.ElementTree, target_tree: ElementTree.ElementTree):
    diff_type = file_a_different_type(base_tree, target_tree)
    base_results = get_results(base_tree)
    target_results = get_results(target_tree)

    if diff_type:
        base_stig_flat_results, target_stig_flat_results = process_stig_results(base_results,
                                                                                target_results,
                                                                                base_tree,
                                                                                target_tree)

        do_compare(base_stig_flat_results, target_stig_flat_results)
        exit(0)

    do_compare(base_results, target_results)


def main():
    args = parse_args()
    check_file(args.base)
    check_file(args.target)
    base_tree = ssg.xml.open_xml(args.base)
    target_tree = ssg.xml.open_xml(args.target)
    match_results(base_tree, target_tree)


if __name__ == '__main__':
    main()
