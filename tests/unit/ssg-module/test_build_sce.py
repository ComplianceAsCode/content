import json
import os
import pytest
import tempfile

import ssg.build_sce
import ssg.environment
import ssg.products
import ssg.templates


PROJECT_ROOT = os.path.join(os.path.dirname(__file__), "..", "..", "..", )
DATADIR = os.path.abspath(os.path.join(os.path.dirname(__file__), "test_build_sce_data"))
TEST_OUTPUT_DIR = tempfile.mkdtemp()


@pytest.fixture
def scebuilder():
    build_config_yaml_path = os.path.join(
        PROJECT_ROOT, "build", "build_config.yml")
    product_yaml_path = os.path.join(DATADIR, "product.yml")
    env_yaml = ssg.environment.open_environment(
        build_config_yaml_path, product_yaml_path)
    product_yaml = ssg.products.Product(product_yaml_path)
    templates_dir = os.path.join(DATADIR, "templates")
    template_builder = ssg.templates.Builder(
        env_yaml, '', templates_dir,
        '', '', '', None)
    b = ssg.build_sce.SCEBuilder(
        env_yaml, product_yaml, template_builder, TEST_OUTPUT_DIR)
    return b


def test_scebuilder(scebuilder):
    scebuilder.build()

    # Verify that a static SCE check is built
    assert "selinux_state.sh" in os.listdir(TEST_OUTPUT_DIR)
    with open(os.path.join(TEST_OUTPUT_DIR, "selinux_state.sh")) as f:
        contents = f.read()
        assert "$(getenforce) == \"Enforcing\"" in contents

    # Verify that a templated SCE check for a templated rule is built
    assert "package_rsyslog_installed.sh" in os.listdir(TEST_OUTPUT_DIR)
    with open(os.path.join(TEST_OUTPUT_DIR, "package_rsyslog_installed.sh")) as f:
        contents = f.read()
        assert "rpm -q rsyslog" in contents

    # Verify metadata JSON contents
    with open(os.path.join(TEST_OUTPUT_DIR, "metadata.json")) as f:
        metadata = json.load(f)
        assert "selinux_state" in metadata
        assert "package_rsyslog_installed" in metadata
