#!/usr/bin/python3

from __future__ import print_function

import argparse
import ssg.build_profile
import ssg.constants
# ssg.xml provides ElementTree which is a wrapper for standard ElementTree
import ssg.xml
import ssg.jinja
import os
import re
import io


def parse_togglable_argument_into_dict(output_dict, dict_key, passed_string):
    on_or_off, path = passed_string.split(":", 1)
    if on_or_off == "ON":
        value = path
    else:
        value = ""
    output_dict[dict_key] = value


def parse_arguments_into_dict(args):
    result = dict()
    parse_togglable_argument_into_dict(
            result, "xccdf_oval_ocil_cpes_path", args.separate_scap_files)
    parse_togglable_argument_into_dict(
            result, "bash_profile_scripts_path", args.profile_bash)
    parse_togglable_argument_into_dict(
            result, "ansible_profile_playbooks_path", args.profile_ansible)
    parse_togglable_argument_into_dict(
            result, "ansible_per_rule_path", args.ansible_per_rule)
    parse_togglable_argument_into_dict(
            result, "kickstarts_path", args.kickstarts)
    parse_togglable_argument_into_dict(
            result, "tailoring_path", args.tailoring)

    result["content_path"] = args.content_path
    result["install_prefix"] = args.install_prefix
    return result


def main():
    p = argparse.ArgumentParser(
        description="Generates man page from profile data")
    p.add_argument("--input_dir", required=True)
    p.add_argument("--output", required=True)
    p.add_argument("--template", required=True)
    p.add_argument("--content-path", required=True)
    p.add_argument("--install-prefix", default="/usr")

    p.add_argument("--separate-scap-files")
    p.add_argument("--profile-bash")
    p.add_argument("--profile-ansible")
    p.add_argument("--ansible-per-rule")
    p.add_argument("--kickstarts")
    p.add_argument("--tailoring")
    args = p.parse_args()

    input_dir = os.path.abspath(args.input_dir)
    all_products = get_all_products(input_dir)
    substitution_dicts = dict(
        products=all_products,
    )
    substitution_dicts.update(parse_arguments_into_dict(args))
    man_page = ssg.jinja.process_file(args.template, substitution_dicts)
    with io.open(args.output, "w", encoding="utf-8") as output_file:
        output_file.write(man_page)


def get_all_products(input_dir):
    all_products = []
    for item in sorted(os.listdir(input_dir)):
        if re.match(r"ssg-\w+-ds.xml", item):
            ds_filepath = os.path.join(input_dir, item)
            all_products.append(get_product_info(ds_filepath))
    return all_products


def get_product_info(ds_filepath):
    tree = ssg.xml.ElementTree.parse(ds_filepath)
    root = tree.getroot()
    benchmark = root.find(".//{%s}Benchmark" % (ssg.constants.XCCDF12_NS))
    benchmark_title = benchmark.find(
        "{%s}title" % (ssg.constants.XCCDF12_NS)).text
    ds_filename = os.path.basename(ds_filepath)
    profiles = get_profiles_info(benchmark)
    product = {
        "title": benchmark_title,
        "ds_filename": ds_filename,
        "profiles": profiles,
    }
    return product


def get_profiles_info(benchmark):
    all_profile_elems = benchmark.findall(
        "./{%s}Profile" % (ssg.constants.XCCDF12_NS))
    profiles_info = []
    for elem in all_profile_elems:
        profile_id = elem.get('id')
        title = elem.find(
                "{%s}title" % (ssg.constants.XCCDF12_NS)
                ).text
        description = elem.find(
                "{%s}description" % (ssg.constants.XCCDF12_NS)
                ).text
        profile = {
            "profile_id": profile_id,
            "title": title,
            "description": description
        }
        profiles_info.append(profile)
    return profiles_info


if __name__ == '__main__':
    main()
