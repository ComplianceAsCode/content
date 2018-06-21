#!/usr/bin/python3

import os
import argparse

import pathlib


SSG_DIR = pathlib.PurePath(__file__).parents[1]


def safe_listdir(path):
    try:
        return os.listdir(path)
    except:
        return []


def print_shadows(resource, language, product):
    source_paths = [
        # shared templated checks
        pathlib.Path("build") / product / resource / "shared" / language,
        # shared checks
        pathlib.Path("shared") / resource / language,
        # product templated checks
        pathlib.Path("build") / product / resource / language,
        # product checks
        pathlib.Path(product) / resource / language,
    ]

    source_files = [
        set(safe_listdir(SSG_DIR / path)) for path in source_paths
    ]

    all_source_files = set.union(*source_files)

    for source_file in all_source_files:
        i = 0
        while i < len(source_paths):
            if source_file in source_files[i]:
                break
            i += 1

        assert(i < len(source_paths))

        shadows = set()
        j = i + 1
        while j < len(source_paths):
            if source_file in source_files[j]:
                shadows.add(j)
            j += 1

        if shadows:
            msg = str((source_paths[i] / source_file).relative_to(SSG_DIR))

            for shadow in shadows:
                msg += " <- " + str((source_paths[shadow] / source_file).relative_to(SSG_DIR))

            print(msg)


def parse_args():
    p = argparse.ArgumentParser(
        description="Looks through both source files and built files of the "
        "product and finds shadowed files. Outputs them in the format of "
        "shadowing. For example if D ends up being used and C, B and A are "
        "shadowed it will output A <- B <- C <- D."
    )
    p.add_argument("--product", default="rhel7",
                   help="Which product we should examine for shadowed checks "
                   "and fixes.")

    return p.parse_args()


def main():
    args = parse_args()

    check_languages = ["oval"]
    fix_languages = ["bash", "ansible", "anaconda", "puppet"]

    for product in [args.product]:
        for check_lang in check_languages:
            print("%s %s check shadows" % (product, check_lang))
            print_shadows("checks", check_lang, product)
            print()

        print()

        for fix_lang in fix_languages:
            print("%s %s fix shadows" % (product, fix_lang))
            print_shadows("fixes", fix_lang, product)
            print()


if __name__ == "__main__":
    main()
