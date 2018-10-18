#!/usr/bin/env python2

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
    all_profiles = get_all_profiles(input_dir)
    substitution_dicts = {"profiles": all_profiles}
    man_page = ssg.jinja.process_file(args.template, substitution_dicts)
    with io.open(args.output, "w", encoding="utf-8") as output_file:
        output_file.write(man_page)


def get_all_profiles(input_dir):
    all_profiles = ""
    for item in sorted(os.listdir(input_dir)):
        if item.endswith("-ds.xml"):
            all_profiles += get_profiles_in_ds(os.path.join(input_dir, item))
    return all_profiles


def get_profiles_in_ds(ds_filepath):
    profiles_in_ds = ""
    tree = ssg.xml.ElementTree.parse(ds_filepath)
    root = tree.getroot()
    benchmark = root.find(".//{%s}Benchmark" % (ssg.constants.XCCDF12_NS))
    benchmark_title = benchmark.find(
        "{%s}title" % (ssg.constants.XCCDF12_NS)).text
    profiles_in_ds += u".SH\nProfiles in %s\n\n" % (benchmark_title)
    ds_filename = os.path.basename(ds_filepath)
    profiles_in_ds += u"Source Datastream: \\fI %s\\fR\n\n" % (ds_filename)
    profiles_in_ds += u"The %s is broken into 'profiles', groupings of security settings " \
        "that correlate to a known policy. Available profiles are:\n\n" % (
            benchmark_title)
    profiles = get_profiles_info(benchmark)
    for profile_id, title, description in profiles:
        profiles_in_ds += u".B %s\n\n.RS\nProfile ID: \\fI%s\\fR\n\n%s\n.RE\n\n\n" % (
                title, profile_id, description)
    return profiles_in_ds


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
        profiles_info.append((profile_id, title, description))
    return profiles_info


if __name__ == '__main__':
    main()
