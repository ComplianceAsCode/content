#!/usr/bin/python3

from __future__ import print_function

import argparse
import glob
import os.path
import sys

import ssg.products
import ssg.yaml

from tests.common import stability


IGNORED_PROPERTIES = (
    "product_dir",
)


def describe_modification(intro, changeset):
    if not changeset:
        return ""

    msg = intro
    for what, (initial, final) in changeset.items():
        msg += " - {what} from '{initial}' -> '{final}'\n".format(
                what=what, initial=initial, final=final)
    return msg


def describe_change(difference, name):
    msg = ""

    msg += stability.describe_changeset(
        "Following properties were added to the {name} product:\n".format(name=name),
        difference.added,
    )
    msg += stability.describe_changeset(
        "Following properties were removed from the {name} product:\n".format(name=name),
        difference.removed,
    )
    msg += describe_modification(
        "Following properties got different values in the {name} product:\n".format(name=name),
        difference.modified,
    )
    return msg.rstrip()


def compare_dictionaries(reference, sample):
    reference_keys = set(reference.keys())
    sample_keys = set(sample.keys())

    result = stability.Difference()
    result.added = list(sample_keys.difference(reference_keys))
    result.removed = list(reference_keys.difference(sample_keys))
    for key, value in reference.items():
        if sample.get(key, value) != value:
            result.modified[key] = (value, sample[key])
    for item in IGNORED_PROPERTIES:
        result.remove_item_from_comparison(item)
    return result


def get_references_filenames(ref_root):
    return glob.glob(os.path.join(ref_root, "*.yml"))


def corresponding_product_built(build_dir, product_id):
    return os.path.isdir(os.path.join(build_dir, product_id))


def get_matching_compiled_product_filename(build_dir, product_id):
    ref_path_components = reference_fname.split(os.path.sep)
    matching_filename = os.path.join(build_dir, product_id, "product.yml")
    if os.path.isfile(matching_filename):
        return matching_filename


def get_reference_vs_built_difference(ref_product, built_product):
    ref_dict = dict()
    ref_dict.update(ref_product)
    built_dict = dict()
    built_dict.update(built_product)
    difference = compare_dictionaries(ref_dict, built_dict)
    return difference


def inform_and_append_fix_based_on_reference_compiled_product(ref, build_root):
    ref_product = ssg.products.Product(ref)
    product_id = ref_product["product"]
    if not corresponding_product_built(build_root, product_id):
        return True

    compiled_path = os.path.join(build_root, product_id, "product.yml")
    compiled_product = ssg.products.Product(compiled_path)
    difference = get_reference_vs_built_difference(ref_product, compiled_product)
    all_ok = difference.empty
    return all_ok


def compare_compiled_products_with_reference_data(test_data_root, build_root):
    reference_files = get_references_filenames(test_data_root)
    if not reference_files:
        raise RuntimeError("Unable to find any reference compiled products in {test_root}"
                           .format(test_root=test_data_root))
    all_ok = True
    for ref in reference_files:
        all_ok &= inform_and_append_fix_based_on_reference_compiled_product(
                ref, build_root)

    if not all_ok:
        products_dir = os.path.join(os.path.dirname(__file__), "..", "products")
        msg = (
            "If changes to mentioned products are intentional, "
            "execute this script with PYTHONPATH set to the project root "
            "to regenerate reference products: \n"
            "{script_name} --update-reference-data {build_root} {test_data_root}\n"
            "If those changes are unwanted, take a look at product properties "
            "that likely cause these changes."
            .format(script_name=__file__, build_root=os.path.normpath(products_dir),
                    test_data_root=test_data_root))
        print(msg, file=sys.stderr)
    return all_ok


def write_product_without_keys(product, path, exclude_keys=frozenset()):
    product_data = dict()
    product_data.update(product)
    for key in exclude_keys:
        product_data.pop(key, None)
    with open(path, "w") as f:
        ssg.yaml.ordered_dump(product_data, f)


def update_reference_data(test_data_root, products_dir):
    properties_dir = os.path.join(products_dir, os.path.pardir, "product_properties")
    product_yamls = glob.glob(os.path.join(products_dir, "*", "product.yml"))
    for fname in product_yamls:
        product = ssg.products.Product(fname)
        product.read_properties_from_directory(properties_dir)
        out_fname = os.path.join(test_data_root, product["product"] + ".yml")
        write_product_without_keys(product, out_fname, IGNORED_PROPERTIES)
    print("Updated test data of {num_products} products".format(num_products=len(product_yamls)))


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument(
            "build_root", help="A directory that contains product-named subdirectories "
            "with product.yml files. Typically the build root, or products source root "
            "if the script is executed in the update mode")
    parser.add_argument("test_data_root", help="Root of reference data containing "
                        "reference files named <product>.yml")
    parser.add_argument(
        "--update-reference-data", action="store_true", default=False,
        help="If supplied with this option, "
        "and the build root is the product root, update all of the test data")
    args = parser.parse_args()

    if args.update_reference_data:
        update_reference_data(args.test_data_root, args.build_root)
        sys.exit(0)

    all_ok = compare_compiled_products_with_reference_data(args.test_data_root, args.build_root)
    return_code = int(not all_ok)
    sys.exit(return_code)


if __name__ == "__main__":
    main()
