import os
import tempfile

import ssg.build_ovals

PROJECT_ROOT = os.path.join(os.path.dirname(__file__), "..", "..", "..", )
DATADIR = os.path.abspath(
    os.path.join(os.path.dirname(__file__), "test_build_ovals_data"))
PRODUCT_YAML = os.path.join(DATADIR, "product.yml")
SHARED_OVALS = os.path.join(DATADIR, "shared_ovals")
BUILD_OVALS_DIR = tempfile.mkdtemp()

shared_oval_1_def_id = "tmux_conf_readable_by_others"
benchmark_oval_1_def_id = "selinux_state"


def test_build_ovals():
    env_yaml = {
        "product": "rhel9",
        "target_oval_version_str": "5.11",
    }
    oval_builder = ssg.build_ovals.OVALBuilder(
        env_yaml, PRODUCT_YAML, [SHARED_OVALS], BUILD_OVALS_DIR)
    oval_document = oval_builder.get_oval_document_from_shorthands(include_benchmark=False)
    assert shared_oval_1_def_id in oval_document.definitions
    assert benchmark_oval_1_def_id not in oval_document.definitions


def test_build_ovals_include_benchmark():
    env_yaml = {
        "benchmark_root": "./guide",
        "product": "rhel9",
        "target_oval_version_str": "5.11",
    }
    oval_builder = ssg.build_ovals.OVALBuilder(
        env_yaml, PRODUCT_YAML, [SHARED_OVALS], BUILD_OVALS_DIR)
    oval_document = oval_builder.get_oval_document_from_shorthands(include_benchmark=True)
    assert shared_oval_1_def_id in oval_document.definitions
    assert benchmark_oval_1_def_id in oval_document.definitions
