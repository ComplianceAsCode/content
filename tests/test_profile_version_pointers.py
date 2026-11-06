#!/usr/bin/env python3

"""
Test Unversioned Profile Version Pointers

The OpenShift products ship a profile in two forms: a pinned one carrying
the benchmark version in its name (ocp4-cis-2-0) and an unversioned one
(ocp4-cis) that users select when they want to stay on the newest content
without editing their ScanSettingBindings on every release.

This is an OpenShift convention, so the check runs only against the products
listed in DEFAULT_PRODUCTS rather than the whole repository. Other
distributions use `extends` for unrelated layering and have not signed up to
this rule.

The unversioned profile is not a copy. It carries no selections of its own,
just `extends: <pinned profile>`, so the two are the same content by
construction. What that construction does not protect is the pointer: when a
new benchmark revision is added, the unversioned profile has to be repointed
at it by hand. Miss that step and users asking for "latest" silently stay on
the previous revision, with nothing in a scan to reveal it -- the unversioned
profile still agrees perfectly with the pinned profile it names, just the
wrong one.

Two checks, both against profile sources rather than the build tree. After
the build, `extends` has already been resolved away, which is precisely why
the mistake is invisible downstream.

  1. An unversioned profile must extend the highest-versioned variant
     available, not merely some variant.

  2. An unversioned profile's declared metadata.version must agree with the
     version of the profile it extends, so the version users are shown is the
     content they actually get.
"""

import argparse
import os
import re
import sys
from collections import defaultdict

try:
    import ssg.yaml
except ImportError:
    print("Could not import ssg. Run from the content repository root, or set "
          "PYTHONPATH to include it.", file=sys.stderr)
    raise

# Products known to follow the unversioned-profile-extends-pinned-revision
# convention. The check is opt-in rather than repository-wide because the
# convention is an OpenShift one: other distributions use `extends` for
# unrelated layering (rhel's ism_o extends e8, stig_gui extends stig), and
# nothing says a future profile name there could not look like a revision
# suffix. Add a product here once its maintainers adopt the convention.
DEFAULT_PRODUCTS = ("ocp4", "rhcos4")

# Suffixes that mark a profile as a pinned variant of its unversioned parent,
# rather than a separate profile that happens to share the prefix. Matching is
# deliberately strict: ocp4-cis-node and ocp4-cis-vm-extension are their own
# profiles, not versions of ocp4-cis, and must not be treated as candidates.
#
# Observed forms: cis-2-0, pci-dss-4-0, bsi-2022, moderate-rev-4, stig-v2r6.
VERSION_SUFFIX_PATTERNS = (
    re.compile(r"^\d+(-\d+)*$"),      # 2-0, 1-9, 3-2, 2022
    re.compile(r"^rev-\d+$"),         # rev-4
    re.compile(r"^v\d+r\d+$", re.I),  # v2r6
)


def is_version_suffix(suffix):
    """Report whether suffix names a benchmark revision."""
    return any(p.match(suffix) for p in VERSION_SUFFIX_PATTERNS)


def version_sort_key(version):
    """
    Order declared versions within a single profile family.

    Formats vary by benchmark -- "2.0.0", "V2R6", "Revision 4", "2022" -- but
    are consistent inside a family, so comparing the integers in order is
    enough to rank them: V2R6 > V2R3, 2.0.0 > 1.9.0, Revision 4 > Revision 3.
    Lexical comparison is not enough; it would rank "V2R10" below "V2R6".
    """
    return tuple(int(n) for n in re.findall(r"\d+", str(version or "")))


def load_profiles(product_dir):
    """
    Return {profile_name: {"extends": ..., "version": ..., "path": ...}} for
    one product's profile sources.
    """
    profiles_dir = os.path.join(product_dir, "profiles")
    if not os.path.isdir(profiles_dir):
        return {}

    profiles = {}
    for basename in sorted(os.listdir(profiles_dir)):
        if not basename.endswith(".profile"):
            continue
        path = os.path.join(profiles_dir, basename)
        try:
            parsed = ssg.yaml.open_raw(path) or {}
        except ssg.yaml.DocumentationNotComplete:
            # Profiles marked documentation_complete: false are not shipped, so
            # their pointers are not yet anyone's problem.
            continue
        except Exception as exc:  # noqa: BLE001 - surfaced as a test failure
            raise RuntimeError("could not parse {0}: {1}".format(path, exc))
        metadata = parsed.get("metadata") or {}
        profiles[basename[: -len(".profile")]] = {
            "extends": parsed.get("extends"),
            "version": metadata.get("version"),
            "path": path,
        }
    return profiles


def find_versioned_variants(profiles):
    """
    Group pinned variants under the unversioned profile they belong to.

    Only names that are an existing profile plus a version suffix are grouped,
    so ocp4-cis-node-2-0 lands under ocp4-cis-node and never under ocp4-cis.
    """
    variants = defaultdict(list)
    for name in profiles:
        for base in profiles:
            if base == name or not name.startswith(base + "-"):
                continue
            if is_version_suffix(name[len(base) + 1:]):
                variants[base].append(name)
    return variants


def check_product(product, product_dir):
    """Return a list of human-readable failures for one product."""
    profiles = load_profiles(product_dir)
    failures = []

    for base, pinned in sorted(find_versioned_variants(profiles).items()):
        extends = profiles[base]["extends"]

        # A profile with its own content that merely has versioned relatives
        # is out of scope; this check is about the pointer indirection.
        if extends not in pinned:
            continue

        newest = max(pinned, key=lambda n: version_sort_key(profiles[n]["version"]))
        if version_sort_key(profiles[extends]["version"]) < version_sort_key(
            profiles[newest]["version"]
        ):
            failures.append(
                "{0}: {1} extends {2} (version {3}) but {4} (version {5}) is newer. "
                "Users selecting {1} expect the latest revision.".format(
                    product, base, extends, profiles[extends]["version"],
                    newest, profiles[newest]["version"],
                )
            )

        base_version = profiles[base]["version"]
        extended_version = profiles[extends]["version"]
        if base_version != extended_version:
            failures.append(
                "{0}: {1} declares version {2} but extends {3}, which is version {4}. "
                "The version shown to users does not match the content they get.".format(
                    product, base, base_version, extends, extended_version,
                )
            )

    return failures


def main():
    parser = argparse.ArgumentParser(
        description="Check that unversioned profiles point at the newest "
                    "pinned revision and declare its version.",
    )
    parser.add_argument(
        "products_dir",
        help="path to the products directory of the content repository",
    )
    parser.add_argument(
        "--product", action="append", dest="products", metavar="PRODUCT",
        default=None,
        help="product to check; repeatable. Defaults to {0}.".format(
            ", ".join(DEFAULT_PRODUCTS)),
    )
    args = parser.parse_args()

    products = args.products or list(DEFAULT_PRODUCTS)

    missing = [
        p for p in products
        if not os.path.isdir(os.path.join(args.products_dir, p))
    ]
    if missing:
        print("No such product(s) under {0}: {1}".format(
            args.products_dir, ", ".join(missing)), file=sys.stderr)
        return 2

    failures = []
    for product in products:
        failures.extend(
            check_product(product, os.path.join(args.products_dir, product))
        )

    if failures:
        print("Unversioned profiles are out of step with their pinned variants:\n")
        for failure in failures:
            print("  - {0}".format(failure))
        print(
            "\nWhen a new benchmark revision is added, repoint the unversioned "
            "profile's 'extends' at it and update its metadata.version to match."
        )
        return 1

    print("All unversioned profiles extend their newest pinned variant.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
