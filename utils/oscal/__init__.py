#! /usr/bin/python3

import os

SSG_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
VENDOR_ROOT = os.path.join(SSG_ROOT, "shared", "references", "oscal")
RULES_JSON = os.path.join(SSG_ROOT, "build", "rule_dirs.json")
BUILD_CONFIG = os.path.join(SSG_ROOT, "build", "build_config.yml")
LOGGER_NAME = "oscal"
