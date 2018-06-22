#!/usr/bin/env python2

from __future__ import print_function

import os
import sys
import argparse
import ssg


def parse_args():
    p = argparse.ArgumentParser()

    sp = p.add_subparsers(help="actions")

    make_sp = sp.add_parser('build', help="Build remediations")
    make_sp.set_defaults(cmd="build")

    input_sp = sp.add_parser('list-inputs', help="Generate input list")
    input_sp.set_defaults(cmd="list_inputs")

    output_sp = sp.add_parser('list-outputs', help="Generate output list")
    output_sp.set_defaults(cmd="list_outputs")

    p.add_argument('--languages', metavar="LANGS", required=True, type=str,
                   nargs='+', help="List of languages to generate")
    p.add_argument("--input", required=True, type=str, nargs='+',
                   help="List of input directories")
    p.add_argument("--output", required=True, type=str, nargs='+',
                   help="List of output directories")
    p.add_argument("--shared", metavar="PATH", required=True,
                   help="Full absolute path to SSG shared directory")

    args = p.parse_args()
    if len(args.input) != len(args.output):
        print("Error: number of inputs and number of outputs must match!",
              file=sys.stderr)
        sys.exit(1)

    return args


if __name__ == "__main__":
    args = parse_args()

    for index in range(0, len(args.input)):
        builder = ssg.build_templates.Builder()
        builder.set_langs(args.languages)

        builder.set_input_dir(args.input[index])
        builder.output_dir = args.output[index]
        builder.ssg_shared = args.shared

        func = getattr(builder, args.cmd)
        func()
