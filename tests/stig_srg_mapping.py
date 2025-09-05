#!/usr/bin/python3

import argparse
import os
import sys
import xml.etree.cElementTree as ET

try:
    import ssg.constants
    import ssg.xccdf
    import ssg.xml
except ImportError:
    print("The ssg module could not be found.", file=sys.stderr)
    print(
        "Run .pyenv.sh available in the project root directory,"
        " or add it to PYTHONPATH manually.",
        file=sys.stderr,
    )
    print("$ source .pyenv.sh", file=sys.stderr)
    exit(2)

SSG_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
BINARY_DIR = os.path.join(SSG_ROOT, "build")
PREFIX = "xccdf_org.ssgproject.content_"
SRG_GPOS_URL = "https://public.cyber.mil/stigs/downloads/?_dl_facet_stigs=operating-systems%2Cgeneral-purpose-os"
SRG_PREFIX = "SRG-OS"


def _parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Ensure that rules with STIG IDs also have SRG references."
    )
    parser.add_argument(
        "-r",
        "--root",
        help=f"Root of the project. Defaults to {SSG_ROOT}",
        default=SSG_ROOT,
    )
    parser.add_argument(
        "-b",
        "--build-root",
        help=f"Path to the root the cmake build directory. Defaults to {BINARY_DIR}.",
        default=BINARY_DIR,
    )
    parser.add_argument(
        "-u",
        "--srg-url",
        help=f"URL for the SRG reference. Defaults to {SRG_GPOS_URL.replace('%', '%%')}.",
        default=SRG_GPOS_URL,
    )
    parser.add_argument(
        "--prefix",
        help=f"Prefix used for the SRG reference. Defaults to {SRG_PREFIX}.",
        default=SRG_PREFIX,
    )
    parser.add_argument("product")
    return parser.parse_args()


def _print_missing(missing):
    if len(missing) != 0:
        for rule in missing:
            content_id = rule.replace(f"{PREFIX}rule_", "")
            print(f"Missing SRG in {content_id}")
        exit(3)


def _get_srg_rules(ref_url, root, srg_prefix):
    srg_rule = set()
    for rule in root.findall(".//xccdf-1.2:Rule", ssg.constants.PREFIX_TO_NS):
        ref = rule.find(
            f".//xccdf-1.2:reference[@href='{ref_url}']", ssg.constants.PREFIX_TO_NS
        )
        if ref is not None and ref.text.startswith(srg_prefix):
            srg_rule.add(rule.attrib.get("id"))
    return srg_rule


def _get_stig_rules(stig_profile):
    stig_rules = set()
    for rule in stig_profile.findall(
        "xccdf-1.2:select[@selected='true']", ssg.constants.PREFIX_TO_NS
    ):
        stig_rules.add(rule.attrib.get("idref"))
    return stig_rules


def _get_stig_profile(root):
    profile_id = f"{PREFIX}profile_stig"
    stig_profile = root.find(
        f".//xccdf-1.2:Profile[@id='{profile_id}']", ssg.constants.PREFIX_TO_NS
    )
    return stig_profile


def _get_root(build_root, product):
    filename = f"ssg-{product}-ds.xml"
    datastream_path = os.path.join(build_root, filename)
    root = ET.parse(datastream_path).getroot()
    if not os.path.exists(datastream_path):
        print(
            f"Product {product} datastream dose not exist. Has it been built?",
            file=sys.stderr,
        )
        exit(1)
    return root


def main():
    ssg.xml.register_namespaces()
    args = _parse_args()

    product = args.product
    build_root = args.build_root
    root = _get_root(build_root, product)
    ref_url = args.srg_url
    srg_prefix = args.prefix

    stig_profile = _get_stig_profile(root)

    stig_rules = _get_stig_rules(stig_profile)
    srg_rules = _get_srg_rules(ref_url, root, srg_prefix)

    missing = stig_rules - srg_rules
    _print_missing(missing)


if __name__ == "__main__":
    main()
