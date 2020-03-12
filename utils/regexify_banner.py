#!/usr/bin/env python
import argparse
import ssg.utils


def parse_args():
    p = argparse.ArgumentParser()
    p.add_argument("--output", help="Path to output regexified banner")
    p.add_argument("input", help="Path to file with banner to regexify")

    return p.parse_args()


def main():

    args = parse_args()
    with open(args.input, "r") as file_in:
        # rstrip is used to remove newline at the end of file
        banner_text = file_in.read().rstrip()

    banner_regex = ssg.utils.banner_regexify(banner_text)
    banner_regex = ssg.utils.banner_anchor_wrap(banner_regex)

    if args.output:
        with open(args.output, "w") as file_out:
            file_out.write(banner_regex)
    else:
        print(banner_regex)


if __name__ == "__main__":
    main()
