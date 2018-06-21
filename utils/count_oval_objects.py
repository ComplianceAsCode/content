#!/usr/bin/env python2

'''
count_oval_objects.py

Shows OVAL objects used by XCCDF rules.

Author: Jan Cerny <jcerny@redhat.com>
'''

import argparse
import sys
import os.path
import ssg


def parse_args():
    parser = argparse.ArgumentParser(description="Show OVAL objects used by XCCDF rules.")
    parser.add_argument("xccdf_file", help="Path to the XCCDF file to parse")
    return parser.parse_args()


def main():
    stats = {}
    global xccdf_dir

    args = parse_args()
    xccdf_file_name = args.xccdf_file
    xccdf_root = ssg.utils_count.load_xml(xccdf_file_name)

    oval_files = dict()
    xccdf_dir = os.path.dirname(xccdf_file_name)

    for rule in xccdf_root.findall(".//Rule"):
        rule_id = rule.attrib['id']
        oval_refs = []
        for ref in rule.findall(".//check-content-ref"):

            # Skip remotely referenced OVAL checks since they won't have the
            # 'name' attribute set (just 'href' would be set in that case)
            try:
                oval_name = ref.attrib['name']
            except KeyError:
                if 'href' in ref.attrib:
                    print("\nInfo: Skipping remotely referenced OVAL:")
                    continue
                else:
                    print("\nError: Invalid OVAL check detected! Exiting..")
                    sys.exit(1)

            oval_file = ref.attrib['href']
            oval_refs.append((oval_name, oval_file))
        if oval_refs:
            objects = ssg.utils_count.find_oval_objects(oval_refs, oval_files, xccdf_dir)
            print(rule_id + ": " + ", ".join(objects))
            for o in objects:
                stats[o] = stats.get(o, 0) + 1
        else:
            print(rule_id + ":")
    ssg.utils_count.print_stats(stats)


if __name__ == "__main__":
    main()
