#!/usr/bin/env python3

"""CLI for building a component definition for a product using a policy for control responses."""

import argparse
import logging
import os
import sys
from typing import Any, Dict

import ssg.environment

from utils.oscal import SSG_ROOT, VENDOR_ROOT, RULES_JSON, BUILD_CONFIG, LOGGER_NAME
from utils.oscal.control_selector import PolicyControlSelector
from utils.oscal.cd_generator import ComponentDefinitionGenerator


logger = logging.getLogger(LOGGER_NAME)

LOG_FILE = os.path.join(SSG_ROOT, "build", "build_cd_for_product.log")


def _parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Create a component definition for a product."
    )
    parser.add_argument("-o", "--output", help="Path to write the cd to", required=True)
    parser.add_argument(
        "-r",
        "--root",
        help=f"Root of the SSG project. Defaults to {SSG_ROOT}",
        default=SSG_ROOT,
    )
    parser.add_argument(
        "-v",
        "--vendor-dir",
        help="Path to the vendor directory with third party OSCAL artifacts",
        default=VENDOR_ROOT,
    )
    parser.add_argument(
        "-p",
        "--profile",
        help="Main profile href, or name of the profile model in the trestle workspace",
        required=True,
    )
    parser.add_argument(
        "-pr",
        "--product",
        help="Product to build cd with",
        required=True,
    )
    parser.add_argument(
        "-c",
        "--control",
        help="Control to use as the source for control responses. \
        To optionally filter by level, use the format <control_id>:<level>.",
        required=True,
    )
    parser.add_argument(
        "-j",
        "--json",
        type=str,
        action="store",
        default=RULES_JSON,
        help=f"Path to the rules_dir.json (defaults to {RULES_JSON})",
    )
    parser.add_argument(
        "-b",
        "--build-config-yaml",
        default=BUILD_CONFIG,
        help="YAML file with information about the build configuration",
    )
    parser.add_argument(
        "--component-definition-type",
        choices=["service", "validation"],
        default="service",
        help="Type of component definition to create",
    )
    return parser.parse_args()


def configure_logger(log_file=None, log_level=logging.INFO):
    """Configure the logger."""
    logger.setLevel(log_level)

    log_format_file = "%(asctime)s - %(name)s - %(levelname)s - %(message)s"
    formatter_file = logging.Formatter(log_format_file)

    log_format_console = "%(levelname)s - %(message)s"
    formatter_console = logging.Formatter(log_format_console)

    if log_file:
        file_handler = logging.FileHandler(log_file)
        file_handler.setLevel(log_level)
        file_handler.setFormatter(formatter_file)
        logger.addHandler(file_handler)

    console_handler = logging.StreamHandler(sys.stdout)
    console_handler.setLevel(log_level)
    console_handler.setFormatter(formatter_console)
    logger.addHandler(console_handler)


def get_env_yaml(ssg_root: str, build_config_yaml: str, product: str) -> Dict[str, Any]:
    """Get the environment yaml."""
    product_yaml_path = ssg.products.product_yaml_path(ssg_root, product)
    env_yaml = ssg.environment.open_environment(
        build_config_yaml,
        product_yaml_path,
        os.path.join(ssg_root, "product_properties"),
    )
    return env_yaml


def main():
    """Main function."""
    args = _parse_args()
    configure_logger(LOG_FILE, log_level=logging.INFO)

    filter_by_level = None
    if ":" in args.control:
        args.control, filter_by_level = args.control.split(":")

    env_yaml = get_env_yaml(args.root, args.build_config_yaml, args.product)

    control_selector = PolicyControlSelector(
        args.control,
        args.root,
        env_yaml,
        filter_by_level,
    )

    cd_generator = ComponentDefinitionGenerator(
        args.root,
        args.json,
        env_yaml,
        args.vendor_dir,
        args.profile,
        control_selector,
    )

    try:
        cd_generator.create_cd(args.output, args.component_definition_type)
    except ValueError as e:
        logger.error(f"Invalid value: {e}", exc_info=True)
        sys.exit(2)
    except FileNotFoundError as e:
        logger.error(f"File not found: {e}", exc_info=True)
        sys.exit(3)
    except Exception as e:
        logger.error(f"An unexpected error occurred: {e}", exc_info=True)
        sys.exit(1)


if __name__ == "__main__":
    main()
