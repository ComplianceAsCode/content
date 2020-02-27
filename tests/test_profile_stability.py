from __future__ import print_function

import argparse
import fnmatch
import os.path
import sys

import ssg.yaml


class Difference(object):
    def __init__(self):
        self.added = []
        self.removed = []

    @property
    def empty(self):
        return not (self.added or self.removed)


def describe_changeset(intro, changeset):
    if not changeset:
        return ""

    msg = intro
    for rid in changeset:
        msg += " - {rid}\n".format(rid=rid)
    return msg


def describe_change(difference, name):
    msg = ""

    msg += describe_changeset(
        "Following selections were added to the {name} profile:\n".format(name=name),
        difference.added,
    )
    msg += describe_changeset(
        "Following selections were removed from the {name} profile:\n".format(name=name),
        difference.removed,
    )
    return msg.rstrip()


def compare_sets(reference, sample):
    reference = set(reference)
    sample = set(sample)

    result = Difference()
    result.added = list(sample.difference(reference))
    result.removed = list(reference.difference(sample))
    return result


def report_comparison(name, result):
    msg = ""
    if not result.empty:
        msg = describe_change(result, name)
    print(msg, file=sys.stderr)


def get_references(ref_root):
    found = []
    for root, dirs, files in os.walk(ref_root):
        for basename in files:
            if fnmatch.fnmatch(basename, "*.profile"):
                filename = os.path.join(root, basename)
                found.append(filename)
    return found


def get_matching_sample(build_dir, reference_fname):
    ref_path_components = reference_fname.split(os.path.sep)
    product_id = ref_path_components[-2]
    profile_fname = ref_path_components[-1]
    matching_filename = os.path.join(build_dir, product_id, "profiles", profile_fname)
    if os.path.isfile(matching_filename):
        return matching_filename


def get_selections(yaml_fname):
    return ssg.yaml.open_raw(yaml_fname)["selections"]


def get_profile_name_from_reference_filename(fname):
    path_components = fname.split(os.path.sep)
    product_id = path_components[-2]
    profile_id = os.path.splitext(path_components[-1])[0]
    name = "{product_id}'s {profile_id}".format(
        product_id=product_id, profile_id=profile_id)
    return name


def compare_reference_and_sample_selections(reference_fname, sample_fname):
    ref_selections = get_selections(reference_fname)
    sample_selections = get_selections(sample_fname)
    difference = compare_sets(ref_selections, sample_selections)
    selections_are_equal = difference.empty
    if not selections_are_equal:
        comprehensive_profile_name = get_profile_name_from_reference_filename(reference_fname)
        report_comparison(comprehensive_profile_name, difference)
    return selections_are_equal


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("build_root")
    parser.add_argument("test_data_root")
    args = parser.parse_args()

    reference_files = get_references(args.test_data_root)
    if not reference_files:
        raise RuntimeError("Unable to find any reference profiles in {test_root}"
                           .format(test_root=args.test_data_root))
    no_changes = True
    for ref in reference_files:
        sample = get_matching_sample(args.build_root, ref)
        if not sample:
            msg = ("Unexpectedly unable to find compiled profile corresponding"
                   "to the test file {ref}. "
                   "This indicates that a profile we have tests for hasn't been built."
                   .format(ref=ref))
            raise RuntimeError(msg)
        changed = compare_reference_and_sample_selections(ref, sample)
        no_changes = no_changes and changed

    if not no_changes:
        msg = (
            "If changes to mentioned profiles are intentional, "
            "edit the appropriate files in '{test_root}' directory."
            .format(test_root=args.test_data_root))
        print(msg, file=sys.stderr)
    sys.exit(not no_changes)


if __name__ == "__main__":
    main()
