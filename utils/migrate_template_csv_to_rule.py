import argparse
import csv
import os
import pprint

from ssg.constants import product_directories


def packages_installed_csv_to_dict(csv_line):
    package_installed = {}

    pkgname = csv_line[0]
    rule_id = f"package_{pkgname}_installed"

    if len(csv_line) == 2:
        evr = csv_line[1]
    else:
        evr = ""

    package_installed["PKGNAME"] = pkgname
    package_installed["EVR"] = evr
    return rule_id, package_installed

class ProductCSVData(object):
    TEMPLATE_TO_CSV_FORMAT_MAP = {
            "packages_installed": packages_installed_csv_to_dict
            }

    def __init__(self, product, ssg_root):
        self.product = product
        self.ssg_root = ssg_root  # Needed?

        self.csv_dir = os.path.join(ssg_root, product, "templates/csv")
        self.csv_files = self._identify_csv_files(self.csv_dir)

        self.csv_data = self._load_csv_files(self.csv_files)

    def _identify_csv_files(self, csv_dir):
        try:
            # get all CSV files
            product_csvs = [csv_filename for csv_filename in os.listdir(csv_dir)
                            if csv_filename.endswith(".csv")]
        except FileNotFoundError as not_found:
            product_csvs = []
            # double check that exception is on templates/csv directory
            if not_found.filename != csv_dir:
                raise not_found
        return product_csvs

    def _load_csv_files(self, csv_files):
        csv_data = {}
        for csv_filename in csv_files:
            template_name = csv_filename.replace(".csv", "")

            # Only load CSV for which we know the format
            if template_name not in self.TEMPLATE_TO_CSV_FORMAT_MAP:
                continue

            with open(os.path.join(self.csv_dir, csv_filename), "r") as csv_f:
                csv_data[template_name] = self._load_csv(template_name, csv_f)
        return csv_data

    def _load_csv(self, template_name, csv_f):
        template_data = {}
        template_csv_parser = self.TEMPLATE_TO_CSV_FORMAT_MAP[template_name]

        for line in csv.reader(csv_f):
            # Skip all comment lines
            if len(line) >= 1 and line[0].startswith('#'):
                continue

            rule_id, line_data_dict = template_csv_parser(line)
            template_data[rule_id] = line_data_dict
        return template_data


def parse_args():
    p = argparse.ArgumentParser()
    p.add_argument("ssg_root", help="Path to root of ssg git directory")

    return p.parse_args()


def main():
    args = parse_args()

    show_data = {}
    templated_content = {}

    # Load all product's CSV data
    for product_name in product_directories:
        product = ProductCSVData(product_name, args.ssg_root)
        templated_content[product_name] = product.csv_data
        show_data[product_name] = product.csv_data

    # Ilustrate DataStructure
    pprint.pprint(show_data)

    # Normalize loaded CSV Data

    # Walk through benchmark and add data into rule.yml


if __name__ == "__main__":
    main()
