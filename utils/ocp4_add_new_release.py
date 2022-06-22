###
#    This is a script that ensures that versioned test manifests and new version in the
#    "platforms:" list are added when we switch to a new OCP release.
#
#    Usage:
#       python utils/ocp4_add_new_release.py 4.11
###

#!/usr/bin/env python

import argparse
import logging
import os.path
import sh
import sys
import yaml

logging.basicConfig(level=logging.INFO)

OCP_DIR = "applications/openshift"


def get_previous_version(version):
    major,minor = version.split(".")
    if minor == "0":
        raise ValueError("Refusing to add a .0 version")

    prev_minor = int(minor) - 1
    return ".".join((major, str(prev_minor)))


# this is extremely hacky, but rules are not a valid YAML due to the jinja templates..whatever, this just a helper
# script
def add_platform(rule_dir, version):
    rule_manifest = os.path.join(rule_dir, "rule.yml")
    previous_version = get_previous_version(version)

    new_content = ""
    with open(rule_manifest) as inrule:
        orig = inrule.readlines()
        if "platforms:\n" not in orig:
            return

        pidx = orig.index("platforms:\n")
        platforms = orig[pidx+1]

        if previous_version not in platforms:
            logging.warn("%s has per-platform test results but couldn't find %s in platforms", rule_manifest, previous_version)
            return
        if version in platforms:
            logging.info("%s already in platforms for %s", version, rule_manifest)
            return

        orig[pidx+1] = orig[pidx+1].rstrip("\n") + " or " + version + "\n"
        new_content = orig

    logging.info("Adding %s to %s", version, rule_manifest)
    with open(rule_manifest, "w") as outrule:
        outrule.writelines(new_content)


def add_versioned_test_files(version, content_dir):
    prev_test_manifest = get_previous_version(version) + ".yml"

    manifests = sh.find(content_dir, "-name", prev_test_manifest).rstrip().split("\n")
    for m in manifests:
        test_basedir = os.path.dirname(m)
        cur_manifest = version + ".yml"
        new_version_path = os.path.join(test_basedir, cur_manifest)
        logging.info("Copying %s to %s", m, new_version_path)
        sh.cp(m, new_version_path)

        rule_dir = test_basedir[:-len("/tests/ocp4")]
        add_platform(rule_dir, version)


def main():
    parser = argparse.ArgumentParser(
        description='Adds the needed stuff for a new OCP release')
    parser.add_argument('VERSION',
                        type=str,
                        help='The version to add')
    parser.add_argument('--content-dir',
                        dest='content_dir',
                        type=str,
                        default=".",
                        help='The content dir')
    args = parser.parse_args()

    ocp_content_dir = os.path.join(args.content_dir, OCP_DIR)
    add_versioned_test_files(args.VERSION, ocp_content_dir)

if __name__ == '__main__':
    rv = main()
    sys.exit(rv)
