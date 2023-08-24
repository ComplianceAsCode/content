#!/usr/bin/python3

import argparse
import pcre2
import xml.etree.ElementTree as ET
from typing import Generator, List

from ssg.constants import PREFIX_TO_NS


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("data_stream")
    return parser.parse_args()


def find_all_patern_match(root: ET.Element, section_xpath: str) -> Generator:
    section = root.find(section_xpath, PREFIX_TO_NS)
    if section is None:
        return
    for child in section:
        for el in child.findall(".//*[@operation='pattern match']"):
            if el.text is not None:
                yield el.text


def extract_all_regexes_from_oval(root: ET.Element) -> list:
    regexes: List[str] = []
    sections_xpaths = ["./oval-def:objects", "./oval-def:states"]
    for section_xpath in sections_xpaths:
        regexes += find_all_patern_match(root, section_xpath)
    return regexes


def extract_all_regexes_from_data_stream(ds_file_path: str) -> set:
    regexes = []
    tree = ET.parse(ds_file_path)
    root = tree.getroot()
    xpath = "./ds:component/oval-def:oval_definitions"
    for oval_definitions in root.findall(xpath, PREFIX_TO_NS):
        regexes += extract_all_regexes_from_oval(oval_definitions)
    return set(regexes)


def check_pcre2_compatibility(regexes: set) -> bool:
    result = True
    for regex in regexes:
        try:
            pcre2.compile(regex)
        except pcre2.exceptions.CompileError as ecp:
            result = False
            print(f"Regular expression {regex} is invalid: {str(ecp)}")
    return result


def main():
    args = parse_args()
    regexes = extract_all_regexes_from_data_stream(args.data_stream)
    if not check_pcre2_compatibility(regexes):
        exit(1)


if __name__ == "__main__":
    main()
