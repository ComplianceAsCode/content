import os
import pytest
import tempfile
import xml.etree.ElementTree as ET

import ssg.build_ovals

PROJECT_ROOT = os.path.join(os.path.dirname(__file__), "..", "..", "..", )
DATADIR = os.path.abspath(
    os.path.join(os.path.dirname(__file__), "test_build_ovals_data"))
PRODUCT_YAML = os.path.join(DATADIR, "product.yml")
SHARED_OVALS = os.path.join(DATADIR, "shared_ovals")
BUILD_OVALS_DIR = tempfile.mkdtemp()

shared_oval_1_def_tag = '<definition class="compliance" ' \
    'id="tmux_conf_readable_by_others" version="1">'
benchmark_oval_1_def_tag = '<definition class="compliance" ' \
    'id="selinux_state" version="1">'


def test_build_ovals():
    env_yaml = {
        "product": "rhel9",
        "target_oval_version_str": "5.11",
    }
    obuilder = ssg.build_ovals.OVALBuilder(
        env_yaml, PRODUCT_YAML, [SHARED_OVALS], BUILD_OVALS_DIR)
    shorthand = obuilder.build_shorthand(include_benchmark=False)
    assert shared_oval_1_def_tag in shorthand
    assert benchmark_oval_1_def_tag not in shorthand


def test_build_ovals_include_benchmark():
    env_yaml = {
        "benchmark_root": "./guide",
        "product": "rhel9",
        "target_oval_version_str": "5.11",
    }
    obuilder = ssg.build_ovals.OVALBuilder(
        env_yaml, PRODUCT_YAML, [SHARED_OVALS], BUILD_OVALS_DIR)
    shorthand = obuilder.build_shorthand(include_benchmark=True)
    assert shared_oval_1_def_tag in shorthand
    assert benchmark_oval_1_def_tag in shorthand
