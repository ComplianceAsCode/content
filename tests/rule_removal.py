#!/usr/bin/env python3

import argparse
import pathlib
import sys
import xml.etree.ElementTree as ET
from ssg.constants import XCCDF12_NS
from typing import Generator


SSG_ROOT = pathlib.Path(__file__).resolve().parent.parent.absolute()
BUILT_ROOT = SSG_ROOT.joinpath('build')

NS = {'xccdf-1.2': XCCDF12_NS}


def _create_arg_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser()
    parser.add_argument('--old-release-dir', required=True,
                        help='Path to built content from last release')
    parser.add_argument('--build-root', default=str(BUILT_ROOT),
                        help=f'Path to the current build root. Defaults to {BUILT_ROOT}')
    parser.add_argument('--product', help='Product to check')
    return parser


def _get_rules(root: ET.Element) -> Generator[str, None, None]:
    for rule in root.findall('.//xccdf-1.2:Rule', namespaces=NS):
        yield rule.get('id', '')


def main() -> int:
    args = _create_arg_parser().parse_args()
    old_build_root = pathlib.Path(args.old_release_dir)
    old_rules_datastream_path = old_build_root / f'ssg-{args.product}-ds.xml'
    old_ds_root = ET.parse(old_rules_datastream_path).getroot()
    old_rules = set(_get_rules(old_ds_root))

    new_build_root = pathlib.Path(args.build_root)
    new_rules_datastream_path = new_build_root / f'ssg-{args.product}-ds.xml'
    new_ds_root = ET.parse(new_rules_datastream_path).getroot()
    new_rules = set(_get_rules(new_ds_root))

    missing = old_rules - new_rules
    if len(missing) != 0:
        for rule in missing:
            print(f'{rule} is missing in new data stream', file=sys.stderr)
        return 1
    return 0


if __name__ == '__main__':
    sys.exit(main())
