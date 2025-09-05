#!/usr/bin/python3

import argparse
import os

import ssg.build_ovals


def main():
    parser = argparse.ArgumentParser(
        description="Convert shorthand OVAL file to a valid full OVAL.")
    parser.add_argument("input", help="Input shorthand OVAL file")
    parser.add_argument("output", help="Output OVAL file")
    args = parser.parse_args()
    env_yaml = {"rule_id": os.path.basename(args.input)}
    ssg.build_ovals.expand_shorthand(args.input, args.output, env_yaml)


if __name__ == "__main__":
    main()
