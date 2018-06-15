#!/usr/bin/env python2

import os
import os.path
import errno
import re
import sys
from copy import deepcopy
import argparse
import collections


try:
    from xml.etree import cElementTree as ElementTree
except ImportError:
    import cElementTree as ElementTree

import ssg


def parse_args():
    p = argparse.ArgumentParser()
    p.add_argument(
        "--build-config-yaml", required=True, dest="build_config_yaml",
        help="YAML file with information about the build configuration. "
        "e.g.: ~/scap-security-guide/build/build_config.yml"
    )
    p.add_argument(
        "--product-yaml", required=True, dest="product_yaml",
        help="YAML file with information about the product we are building. "
        "e.g.: ~/scap-security-guide/rhel7/product.yml"
    )
    p.add_argument("--oval_config", required=True,
                   help="Location of the oval.config file.")
    p.add_argument("--output", type=argparse.FileType("wb"), required=True)
    p.add_argument("ovaldirs", metavar="OVAL_DIR", nargs="+",
                   help="Directory(ies) from which we will collect "
                   "OVAL definitions to combine. Order matters, latter "
                   "directories override former.")

    args, unknown = p.parse_known_args()
    if unknown:
        sys.stderr.write(
            "Unknown positional arguments " + ",".join(unknown) + ".\n"
        )
        sys.exit(1)

    return args


def main():
    args = parse_args()

    oval_ns = ssg.constants.oval_namespace
    footer = ssg.constants.oval_footer
    env_yaml = ssg.yaml.open_environment(
        args.build_config_yaml, args.product_yaml)

    if os.path.isfile(args.oval_config):
        multi_platform = ssg.build_ovals.parse_conf_file(
            args.oval_config,
            ssg.utils.required_key(env_yaml, "product")
        )
        header = ssg.xml.oval_generated_header(
            "combine-ovals.py",
            ssg.utils.required_key(env_yaml, "target_oval_version_str"),
            ssg.utils.required_key(env_yaml, "ssg_version"))
    else:
        sys.stderr.write("The directory specified does not contain the %s "
                         "file!\n" % (args.oval_config))
        sys.exit(1)

    body = ssg.build_ovals.checks(
        env_yaml,
        ssg.utils.required_key(env_yaml, "target_oval_version_str"),
        args.ovaldirs)

    # parse new file(string) as an ElementTree, so we can reorder elements
    # appropriately
    corrected_tree = ElementTree.fromstring(
        ("%s%s%s" % (header, body, footer)).encode("utf-8"))
    tree = ssg.build_ovals.add_platforms(corrected_tree, multi_platform)
    definitions = ElementTree.Element("{%s}definitions" % oval_ns)
    tests = ElementTree.Element("{%s}tests" % oval_ns)
    objects = ElementTree.Element("{%s}objects" % oval_ns)
    states = ElementTree.Element("{%s}states" % oval_ns)
    variables = ElementTree.Element("{%s}variables" % oval_ns)

    for childnode in tree.findall("./{%s}def-group/*" % oval_ns):
        if childnode.tag is ElementTree.Comment:
            continue
        elif childnode.tag.endswith("definition"):
            ssg.build_ovals.append(definitions, childnode)
        elif childnode.tag.endswith("_test"):
            ssg.build_ovals.append(tests, childnode)
        elif childnode.tag.endswith("_object"):
            ssg.build_ovals.append(objects, childnode)
        elif childnode.tag.endswith("_state"):
            ssg.build_ovals.append(states, childnode)
        elif childnode.tag.endswith("_variable"):
            ssg.build_ovals.append(variables, childnode)
        else:
            sys.stderr.write("Warning: Unknown element '%s'\n"
                             % (childnode.tag))

    root = ElementTree.fromstring(("%s%s" % (header, footer)).encode("utf-8"))
    root.append(definitions)
    root.append(tests)
    root.append(objects)
    root.append(states)
    if list(variables):
        root.append(variables)

    ElementTree.ElementTree(root).write(args.output)

    sys.exit(0)


if __name__ == "__main__":
    main()
