#!/usr/bin/python3

import argparse
import sys
import logging
import os

import ssg.build_ovals
import ssg.environment
from ssg.oval_object_model import (
    ExceptionDuplicateObjectReferenceInTest,
    ExceptionDuplicateOVALEntity,
    ExceptionEmptyNote,
    ExceptionMissingObjectReferenceInTest,
)

MASSAGE_FORMAT = "%(levelname)s: %(message)s"
EXPECTED_ERRORS = (
    ExceptionDuplicateObjectReferenceInTest,
    ExceptionDuplicateOVALEntity,
    ExceptionEmptyNote,
    ExceptionMissingObjectReferenceInTest,
    ValueError,
)


def parse_args():
    p = argparse.ArgumentParser()
    p.add_argument(
        "--build-config-yaml",
        required=True,
        dest="build_config_yaml",
        help="YAML file with information about the build configuration. "
        "e.g.: ~/scap-security-guide/build/build_config.yml",
    )
    p.add_argument(
        "--product-yaml",
        required=True,
        dest="product_yaml",
        help="YAML file with information about the product we are building. "
        "e.g.: ~/scap-security-guide/rhel7/product.yml",
    )
    p.add_argument(
        "--build-ovals-dir",
        dest="build_ovals_dir",
        help="Directory to store intermediate built OVAL files.",
    )
    p.add_argument("--output", type=argparse.FileType("wb"), required=True)
    p.add_argument(
        "--include-benchmark",
        action="store_true",
        help="Include OVAL checks from rule directories in the benchmark "
        "directory tree which is specified by product.yml "
        "in the `benchmark_root` key.",
    )
    p.add_argument(
        "ovaldirs",
        metavar="OVAL_DIR",
        nargs="+",
        help="Shared directory(ies) from which we will collect OVAL "
        "definitions to combine. Order matters, latter directories override "
        "former. If --include-benchmark is provided, these will be "
        "overwritten by OVALs in the rule directory (which in turn preference "
        "oval/{{{ product }}}.xml over oval/shared.xml for a given rule.",
    )
    p.add_argument(
        "--log",
        action="store",
        default="WARNING",
        choices=["DEBUG", "INFO", "WARNING", "ERROR", "CRITICAL"],
        help="write debug information to the log up to the LOG_LEVEL.",
    )

    return p.parse_args()


def setup_logging(log_level_str):
    numeric_level = getattr(logging, log_level_str.upper(), None)
    if not isinstance(numeric_level, int):
        raise ValueError("Invalid log level: {}".format(log_level_str))
    logging.basicConfig(format=MASSAGE_FORMAT, level=numeric_level)


def main():
    args = parse_args()
    setup_logging(args.log)

    env_yaml = ssg.environment.open_environment(
        args.build_config_yaml, args.product_yaml
    )

    oval_builder = ssg.build_ovals.OVALBuilder(
        env_yaml, args.product_yaml, args.ovaldirs, args.build_ovals_dir
    )
    oval_builder.product_name = "Script {}".format(os.path.basename(__file__))

    try:
        oval_document = oval_builder.get_oval_document_from_shorthands(
            args.include_benchmark
        )
        oval_document.finalize_affected_platforms(env_yaml)

        oval_document.save_as_xml(args.output)
    except EXPECTED_ERRORS as error:
        logging.critical(error)

    sys.exit(0)


if __name__ == "__main__":
    main()
