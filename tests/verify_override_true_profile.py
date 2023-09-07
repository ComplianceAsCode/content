#!/usr/bin/python

import argparse
import lxml.etree as ET
from sys import stderr


TITLES_PATH = "//*[local-name()=\"Profile\"]/*[local-name()=\"title\"][not(@override=\"true\")]"
DESCRIPTION_PATH = "//*[local-name()=\"Profile\"]/*[local-name()=\"description\"][not(@override=\"true\")]"

def _parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("datastream", help="Path to the datastream to test")
    return parser.parse_args()

def _get_matching_elements_count(root, xpath_query):
    elements = root.xpath(xpath_query)
    return len(elements)

def main():
    args = _parse_args()
    datastream = args.datastream
    status = 0
    with open(datastream, 'r') as ds_fp:
        root = ET.parse(ds_fp)
        if _get_matching_elements_count(root, TITLES_PATH) != 0:
            print("Datastream %s found profile title without an override." % datastream, file=stderr)
            status = 1
        if _get_matching_elements_count(root, DESCRIPTION_PATH) != 0:
            print("Datastream %s found profile title without an override." % datastream, file=stderr)
            status += 1
    exit(status)




if __name__ == "__main__":
    main()
