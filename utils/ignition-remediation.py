#!/usr/bin/env python3

import errno
import os
import sys
import argparse
import urllib.parse
from string import Template

description = \
"""
Encode a given file to an ignition based remediation or decode an ignition
based file remediation to the resulting file.

Encoding
========
To encode a file, you need to provide a number of attributes. At the minimum,
you need to provide the version of the file that would be applied with
MachineConfigs. Then you also need to provide the path where the file would
be uploaded to using the MC and the file mode. Finally, either provide the
platforms the remediation applies to or provide the rule name. If the rule
name is provided, then the script reads the platforms from existing
remediations. The output is either written to the rule directory if a rule
is provided or to a file.

Examples
--------
    * Encode a remediation based on a "golden file" at /tmp/chrony.conf. The
      remediation will replace the file at /etc/chrony.conf with the mode 0644.
      The resulting MachineConfig would be automatically written to the
      directory where the rule chronyd_no_chronyc_network is stored. The
      platforms that the remediation is applied to would be read from the
      existing bash remediations.

      python3 utils/ignition-remediation.py encode \\
                                            --mode=0644 \\
                                            --infile=/tmp/chrony.conf \\
                                            --target=/etc/chrony.conf \\
                                            --rule=chronyd_no_chronyc_network

    * As above, but print out the resulting remediation to stdout. You could
      substitute stdout for any other file to have the remediation dumped
      there.

      python3 utils/ignition-remediation.py encode \\
                                            --mode=0644 \\
                                            --infile=/tmp/chrony.conf \\
                                            --target=/etc/chrony.conf \\
                                            --rule=chronyd_no_chronyc_network \\
                                            --outfile=stdout

Decoding
========
Either pass in the rule name or an absolute path to the ignition file. When
passing in the rule name, the script expects your current directory is at
the root of the checkout.

Examples
--------
    * Decode a remediation for a given rule:

      python3 utils/ignition-remediation.py decode \\
                                            --rule=chronyd_no_chronyc_network

    * Decode a remediation from a given file:

      python3 utils/ignition-remediation.py decode \\
                                            --infile=/tmp/remediation.yml

"""

mc_template = \
"""# platform = $platforms
apiVersion: machineconfiguration.openshift.io/v1
kind: MachineConfig
spec:
  config:
    ignition:
      version: 2.2.0
    storage:
      files:
      - contents:
          source: data:,$content
        filesystem: root
        mode: $mode
        path: $path
        overwrite: true
"""


def urlencoded_file(filename):
    with open(filename) as f:
        return urllib.parse.quote(''.join(f.readlines()))


def encode(infile, target_path, mode, platforms):
    content = urlencoded_file(infile)
    tmpl = Template(mc_template)
    mc = tmpl.substitute(path=target_path, mode=mode,
                         platforms=platforms, content=content)
    return mc


def encode_outfile(encode_outfile, rule_dir):
    ign_file = None

    if encode_outfile == "stdout":
        ign_file = sys.stdout
    elif encode_outfile is not None:
        ign_file = open(encode_outfile, "w")
    elif rule_dir is not None:
        ign_dir = os.path.join(rule_dir, "ignition")
        ign_path = os.path.join(ign_dir, "shared.yml")
        try:
            ign_file = open(ign_path, "w")
        except OSError as e:
            if e.errno == errno.ENOENT:
                os.mkdir(ign_dir)
                ign_file = open(ign_path, "w")
            else:
                raise

    return ign_file


def write_encoded(fhandle, remediation):
    try:
        fhandle.write(remediation)
    finally:
        fhandle.close()


def required_for_encode(args, param, print_warning=False):
    if getattr(args, param) is None:
        if print_warning:
            print(f"Argument {param} is required when "
                   "encoding a source to an MCO")
        return False
    return True


def check_encode_args(args):
    if required_for_encode(args, "mode", print_warning=True) is False or \
       required_for_encode(args, "infile", print_warning=True) is False or \
       required_for_encode(args, "target_path", print_warning=True) is False:
            print("--mode, --infile and --target-path are "
                  "required when encoding")
            sys.exit(1)

    if required_for_encode(args, "platforms") is False and \
       required_for_encode(args, "rule") is False:
            print("Either platforms is given or the rule name "
                  "must given so that we can deduce the platforms")
            sys.exit(1)


def resolve_path(rule, path):
    # If the path to the ingnition file is given, we just use it
    if path is not None:
        return path

    # If path is not given and rule is not given,
    # we don't know what to work with
    if rule is None:
        return None

    # Otherwise we try to guess it based on the rule name
    for root, dirs, files in os.walk('./linux_os'):
        if root.endswith(rule):
            return os.path.join([root, "ignition", "shared.yml"])


def resolve_rule(rule):
    # If the rulename is not given, we can't find the rule path
    if rule is None:
        return None

    # Otherwise we try to guess it based on the rule name
    for root, dirs, files in os.walk('./linux_os'):
        if root.endswith(rule):
            return root
    return None


def rule_platforms(rule_path):
    platforms = ""

    with open(os.path.join(rule_path, "bash", "shared.sh")) as bash_rem:
        for brl in bash_rem.readlines():
            if brl.startswith("# platform = "):
                platforms += brl.split(" = ")[1].strip()
                if "multi_platform_ocp" not in platforms:
                    platforms += ",multi_platform_ocp"
                return platforms

    # ignition rules wouldn't make sense w/o ocp platform
    return "multi_platform_ocp "


def resolve_platforms(rule_path, args_platforms):
    if args_platforms is not None:
        return args_platforms

    return rule_platforms(rule_path)


def decode(filename):
    if filename is None:
        raise IOError("No filename given to decode")

    with open(filename) as f:
        for line in f.readlines():
            # FIXME: what about multiple files?
            if 'source: data:,' in line:
                return decode_data(line)
        raise ValueError("Could not locate the data source in the file")

    raise IOError("Could not open the remediation file")


def decode_data(line):
    return urllib.parse.unquote(line)


def resolve_for_decode(rule, path):
    if path is not None:
        return path

    rule_dir = resolve_rule(rule)
    if rule_dir is None:
        return None
    return os.path.join(rule_dir, "ignition", "shared.yml")


def main():
    parser = argparse.ArgumentParser(
                            description=description,
                            formatter_class=argparse.RawTextHelpFormatter)

    common_opts = parser.add_argument_group('common')
    common_opts.add_argument('--infile', action='store', type=str,
                             help='The file to encode or decode')
    common_opts.add_argument('--rule', action='store', type=str,
                             help="When decoding, used to load the ignition "
                                  "file. When encoding, used to write the "
                                  "ignition file to")

    encode_opts = parser.add_argument_group('encoding')
    encode_opts.add_argument('--target-path', action='store', type=str,
                             help="The path where the file would be applied "
                                  "on the host.")
    encode_opts.add_argument('--outfile', action='store', type=str,
                             help="The path the encoded result will be "
                                  "written to. Optional if --rule is "
                                  "specified")
    encode_opts.add_argument('--mode', action='store', type=str,
                             help='The mode of the file on the host.')
    encode_opts.add_argument('--platforms', action='store', type=str,
                             help="Optional, if not set and rule is set, "
                                  "the script will read plarforms from "
                                  "existing rules")

    parser.add_argument('ACTION', choices=['encode', 'decode'])

    args = parser.parse_args()

    if args.ACTION == 'encode':
        check_encode_args(args)
        rule_path = resolve_rule(args.rule)
        platforms = resolve_platforms(rule_path, args.platforms)
        if platforms is None:
            print("Platforms neither passed through flags nor could "
                  "be detected, fail")
            sys.exit(1)

        remediation = encode(args.infile, args.target_path,
                             args.mode, platforms)

        try:
            outfile_handle = encode_outfile(args.outfile, rule_path)
            write_encoded(outfile_handle, remediation)
        except OSError as e:
            # The rule dir probably couldn't be written to
            print(e)
            print("Please check the rule name or path")
            sys.exit(1)
    elif args.ACTION == 'decode':
        rem_path = resolve_for_decode(args.rule, args.infile)
        try:
            print(decode(rem_path))
        except IOError as e:
            # The rule probably couldn't be loaded
            print(e)
            print("Please check the rule name or path")
            sys.exit(1)
        except ValueError as e:
            # Malformed remediation?
            print(e)
            print("Please check if the remediation is well-formed "
                  "ignition file")
            sys.exit(1)
    else:
        print("Unknown action")
        sys.exit(1)

if __name__ == "__main__":
    main()
