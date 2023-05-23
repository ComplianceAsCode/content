from __future__ import print_function

import argparse
import fnmatch
import os.path
import sys

import ssg.yaml

from tests.common import stability


def describe_change(difference, name):
    msg = ""

    msg += stability.describe_changeset(
        "Following selections were added to the {name} profile:\n".format(name=name),
        difference.added,
    )
    msg += stability.describe_changeset(
        "Following selections were removed from the {name} profile:\n".format(name=name),
        difference.removed,
    )
    return msg.rstrip()


def compare_sets(reference, sample):
    reference = set(reference)
    sample = set(sample)

    result = stability.Difference()
    result.added = list(sample.difference(reference))
    result.removed = list(reference.difference(sample))
    return result


def get_references_filenames(ref_root):
    found = []
    for root, dirs, files in os.walk(ref_root):
        for basename in files:
            if fnmatch.fnmatch(basename, "*.profile"):
                filename = os.path.join(root, basename)
                found.append(filename)
    return found


def corresponding_product_built(build_dir, reference_fname):
    ref_path_components = reference_fname.split(os.path.sep)
    product_id = ref_path_components[-2]
    return os.path.isdir(os.path.join(build_dir, product_id))


def get_matching_compiled_profile_filename(build_dir, reference_fname):
    ref_path_components = reference_fname.split(os.path.sep)
    product_id = ref_path_components[-2]
    profile_fname = ref_path_components[-1]
    matching_filename = os.path.join(build_dir, product_id, "profiles", profile_fname)
    if os.path.isfile(matching_filename):
        return matching_filename


def get_selections_key_from_yaml(yaml_fname):
    return ssg.yaml.open_raw(yaml_fname)["selections"]


def get_profile_name_from_reference_filename(fname):
    path_components = fname.split(os.path.sep)
    product_id = path_components[-2]
    profile_id = os.path.splitext(path_components[-1])[0]
    name = "{product_id}'s {profile_id}".format(
        product_id=product_id, profile_id=profile_id)
    return name


def get_reference_vs_built_difference(reference_fname, built_fname):
    ref_selections = get_selections_key_from_yaml(reference_fname)
    built_selections = get_selections_key_from_yaml(built_fname)
    difference = compare_sets(ref_selections, built_selections)
    return difference


def inform_and_append_fix_based_on_reference_compiled_profile(ref, build_root, fix_commands):
    if not corresponding_product_built(build_root, ref):
        return

    compiled_profile = get_matching_compiled_profile_filename(build_root, ref)
    if not compiled_profile:
        msg = ("Unexpectedly unable to find compiled profile corresponding"
               "to the test file {ref}, although the corresponding product has been built. "
               "This indicates that a profile we have tests for is missing."
               .format(ref=ref))
        raise RuntimeError(msg)
    difference = get_reference_vs_built_difference(ref, compiled_profile)
    if not difference.empty:
        comprehensive_profile_name = get_profile_name_from_reference_filename(ref)
        stability.report_comparison(comprehensive_profile_name, difference, describe_change)
        fix_commands.append(
            "cp '{compiled}' '{reference}'"
            .format(compiled=compiled_profile, reference=ref)
        )


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("build_root")
    parser.add_argument("test_data_root")
    args = parser.parse_args()

    reference_files = get_references_filenames(args.test_data_root)
    if not reference_files:
        raise RuntimeError("Unable to find any reference profiles in {test_root}"
                           .format(test_root=args.test_data_root))
    fix_commands = []
    for ref in reference_files:
        inform_and_append_fix_based_on_reference_compiled_profile(
                ref, args.build_root, fix_commands)

    if fix_commands:
        msg = (
            "If changes to mentioned profiles are intentional, "
            "copy those compiled files, so they become the new reference:\n{fixes}\n"
            "Please remember that if you change a profile that is extended by other profiles, "
            "changes propagate to derived profiles. "
            "If those changes are unwanted, you have to supress them "
            "using explicit selections or !unselections in derived profiles."
            .format(fixes="\n".join(fix_commands)))
        print(msg, file=sys.stderr)
    sys.exit(bool(fix_commands))


if __name__ == "__main__":
    main()
