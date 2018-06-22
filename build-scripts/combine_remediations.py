#!/usr/bin/env python2

import sys
import os
import os.path
import re
import errno
import argparse
import codecs

import ssg

ElementTree = ssg.xml.ElementTree
remediation = ssg.build_remediations

FILE_GENERATED = '# THIS FILE IS GENERATED'


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
    p.add_argument("--remediation_type", required=True,
                   help="language or type of the remediations we are combining."
                   "example: ansible")
    p.add_argument("--build_dir", required=True,
                   help="where is the cmake build directory. pass value of "
                   "$CMAKE_BINARY_DIR.")
    p.add_argument("--output", type=argparse.FileType("wb"), required=True)
    p.add_argument("fixdirs", metavar="FIX_DIR", nargs="+",
                   help="directory(ies) from which we will collect "
                   "remediations to combine.")

    return p.parse_args()


def main():
    args = parse_args()

    env_yaml = ssg.yaml.open_environment(
        args.build_config_yaml, args.product_yaml)

    fixcontent = ElementTree.Element(
        "fix-content", system="urn:xccdf:fix:script:sh",
        xmlns="http://checklists.nist.gov/xccdf/1.1")
    fixgroup = remediation.get_fixgroup_for_type(fixcontent,
                                                 args.remediation_type)
    fixes = dict()

    remediation_functions = remediation.get_available_functions(args.build_dir)

    included_fixes_count = 0
    for fixdir in args.fixdirs:
        if os.path.isdir(fixdir):
            for filename in os.listdir(fixdir):
                if not remediation.is_supported_filename(args.remediation_type, filename):
                    continue

                # Create and populate new fix element based on shell file
                fixname = os.path.splitext(filename)[0]

                mod_file = []
                config = {}

                fix_file_lines = ssg.jinja.process_file(
                    os.path.join(fixdir, filename),
                    env_yaml
                ).splitlines()

                # Assignment automatically escapes shell characters for XML
                for line in fix_file_lines:
                    line += "\n"
                    if line.startswith('#'):
                        try:
                            (key, value) = line.strip('#').split('=')
                            if key.strip() in ['complexity', 'disruption',
                                               'platform', 'reboot',
                                               'strategy']:
                                config[key.strip()] = value.strip()
                            else:
                                if not line.startswith(FILE_GENERATED):
                                    mod_file.append(line)
                        except ValueError:
                            if not line.startswith(FILE_GENERATED):
                                mod_file.append(line)
                    else:
                        mod_file.append(line)

                complexity = None
                disruption = None
                reboot = None
                script_platform = None
                strategy = None

                if 'complexity' in config:
                    complexity = config['complexity']
                if 'disruption' in config:
                    disruption = config['disruption']
                if 'platform' in config:
                    script_platform = config['platform']
                if 'complexity' in config:
                    reboot = config['reboot']
                if 'complexity' in config:
                    strategy = config['strategy']

                if script_platform:
                    product_name, result = remediation.fix_is_applicable_for_product(
                        script_platform, ssg.utils.required_key(env_yaml, "product"))
                    if result:
                        if fixname in fixes:
                            fix = fixes[fixname]
                            for child in list(fix):
                                fix.remove(child)
                        else:
                            fix = ElementTree.SubElement(fixgroup, "fix")
                            fix.set("rule", fixname)
                            if complexity is not None:
                                fix.set("complexity", complexity)
                            if disruption is not None:
                                fix.set("disruption", disruption)
                            if reboot is not None:
                                fix.set("reboot", reboot)
                            if strategy is not None:
                                fix.set("strategy", strategy)
                            fixes[fixname] = fix
                            included_fixes_count += 1

                        fix.text = "".join(mod_file)

                        # Expand shell variables and remediation functions
                        # into corresponding XCCDF <sub> elements
                        remediation.expand_xccdf_subs(
                            fix, args.remediation_type,
                            remediation_functions
                        )
                else:
                    sys.stderr.write("Skipping '%s' remediation script. "
                                     "The platform identifier in the "
                                     "script is missing!\n" % (filename))
    sys.stderr.write("Merged %d %s remediations.\n"
                     % (included_fixes_count, args.remediation_type))
    tree = ElementTree.ElementTree(fixcontent)
    tree.write(args.output)

    sys.exit(0)


if __name__ == "__main__":
    main()
