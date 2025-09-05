#!/usr/bin/env python3

from __future__ import print_function

import argparse
import sys
import ssg.build_profile
import ssg.constants
# ssg.xml provides ElementTree which is a wrapper for standard ElementTree
import ssg.xml
import ssg.jinja
import os
import io


def main():
    p = argparse.ArgumentParser(
        description="Generates man page from profile data")
    p.add_argument("--input_dir", required=True)
    p.add_argument("--output", required=True)
    p.add_argument("--template", required=True)
    args = p.parse_args()
    input_dir = os.path.abspath(args.input_dir)
    all_products = get_all_products(input_dir)
    substitution_dicts = {"products": all_products}
    man_page = ssg.jinja.process_file(args.template, substitution_dicts)
    with io.open(args.output, "w", encoding="utf-8") as output_file:
        output_file.write(man_page)


def get_all_products(input_dir):
    all_products = []
    for item in sorted(os.listdir(input_dir)):
        if item.endswith("-ds.xml"):
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
