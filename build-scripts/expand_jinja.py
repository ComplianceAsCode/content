from __future__ import print_function

import os
import sys
import argparse

import ssg.jinja


SUBS_DICT = ssg.jinja.load_macros()


def expand_jinja(filepath):
    return ssg.jinja.process_file(filepath, SUBS_DICT)


def _get_output_filepath(outdir, filepath):
    out_filepath = None

    if filepath.endswith(".jinja"):
        out_filepath = filepath.split(".jinja")[0]
        filepath = out_filepath

    if outdir:
        filename = os.path.basename(filepath)
        out_filepath = os.path.join(outdir, filename)

    if not out_filepath:
        raise RuntimeError(
            "Don't know where to save expansion of '{0}', as "
            "the output directory has not been supplied, and "
            "the file doesn't end with '.jinja'."
            .format(filepath)
        )
    return out_filepath


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("filename", nargs="+")
    parser.add_argument("--outdir")

    args = parser.parse_args()

    for filepath in args.filename:
        try:
            out_filepath = _get_output_filepath(args.outdir, filepath)
        except RuntimeError as exc:
            print(str(exc), file=sys.stderr)
            sys.exit(1)

        expanded_contents = expand_jinja(filepath)
        with open(out_filepath, "w") as f:
            f.write(expanded_contents)
        print(out_filepath)
