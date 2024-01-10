import os
from typing import Optional

import ssg.products

from trestle.common.const import TRESTLE_GENERIC_NS
from trestle.core.generators import generate_sample_model
from trestle.oscal.common import Property

SSG_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
VENDOR_ROOT = os.path.join(SSG_ROOT, "shared", "references", "oscal")
RULES_JSON = os.path.join(SSG_ROOT, "build", "rule_dirs.json")
BUILD_CONFIG = os.path.join(SSG_ROOT, "build", "build_config.yml")
TRESTLE_CD_NS = f"{TRESTLE_GENERIC_NS}/cd"
LOGGER_NAME = "oscal"


def get_benchmark_root(root: str, product: str) -> str:
    """Get the benchmark root."""
    product_yaml_path = ssg.products.product_yaml_path(root, product)
    product_yaml = ssg.products.load_product_yaml(product_yaml_path)
    product_dir = product_yaml.get("product_dir")
    benchmark_root = os.path.join(product_dir, product_yaml.get("benchmark_root"))
    return benchmark_root


def add_prop(name: str, value: str, remarks: Optional[str] = None) -> Property:
    """Add a property to a set of rule properties."""
    prop = generate_sample_model(Property)
    prop.name = name
    prop.value = value
    if remarks:
        prop.remarks = remarks
    prop.ns = TRESTLE_CD_NS  # type: ignore
    return prop
