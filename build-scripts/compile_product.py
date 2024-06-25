import argparse

import ssg.products


def create_parser():
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--product-yaml", required=True,
        help="YAML file with information about the product we are building. "
        "e.g.: ~/scap-security-guide/products/rhel9/product.yml "
        "needed for autodetection of profile root"
    )
    parser.add_argument(
        "--product-properties",
        help="The directory with additional product properties yamls."
    )
    parser.add_argument(
        "--compiled-product-yaml", required=True,
        help="Where to save the compiled product yaml."
    )
    return parser


def main():
    parser = create_parser()
    args = parser.parse_args()

    product = ssg.products.Product(args.product_yaml)
    if args.product_properties:
        product.read_properties_from_directory(args.product_properties)
    product.write(args.compiled_product_yaml)


if __name__ == "__main__":
    main()
