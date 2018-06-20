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

    p.add_argument('--language', metavar="LANG", default=None,
                   help="Scripts of which language should we generate? "
                   "Default: all.")
    p.add_argument("-i", "--input", action="store", required=True,
                   help="input directory")
    p.add_argument("-o", "--output", action="store", required=True,
                   help="output directory")
    p.add_argument("-s", "--shared", metavar="PATH", required=True,
                   help="Full absolute path to SSG shared directory")

    return p.parse_args()


if __name__ == "__main__":
    args = parse_args()

    builder = ssg.build_templates.Builder()
    if args.language is not None:
        builder.set_langs([args.language])

    builder.set_input_dir(args.input)
    builder.output_dir = args.output
    builder.ssg_shared = args.shared

    func = getattr(builder, args.cmd)
    func()
