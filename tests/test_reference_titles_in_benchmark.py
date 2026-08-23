#!/usr/bin/python3

import argparse
import xml.etree.ElementTree as ET
import yaml

from ssg.constants import datastream_namespace, XCCDF12_NS


def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("datastream", help="SCAP source data stream")
    parser.add_argument("product_yaml", help="Resolved product YAML")
    return parser.parse_args()


def get_references_in_benchmark(ds_path):
    references = {}
    root = ET.parse(ds_path).getroot()
    benchmark_xpath = "./{%s}component/{%s}Benchmark" % (datastream_namespace, XCCDF12_NS)
    benchmark_el = root.find(benchmark_xpath)
    reference_xpath = "{%s}reference" % XCCDF12_NS
    for reference_el in benchmark_el.findall(reference_xpath):
        href = reference_el.get("href")
        title = reference_el.text
        references[title] = href
    return references


def get_references_in_product_yaml(product_yaml_path):
    with open(product_yaml_path) as product_yaml_fd:
        product_yaml = yaml.safe_load(product_yaml_fd)
    product_yaml_references = product_yaml["reference_uris"]
    return product_yaml_references


def main():
    args = parse_args()
    references_in_benchmark = get_references_in_benchmark(args.datastream)
    references_in_product_yaml = get_references_in_product_yaml(args.product_yaml)
    assert references_in_benchmark == references_in_product_yaml


if __name__ == "__main__":
    main()
