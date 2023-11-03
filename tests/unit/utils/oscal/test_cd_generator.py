import argparse
import os
import pytest
import pathlib
import shutil

from tempfile import TemporaryDirectory

from trestle.common.err import TrestleError
from trestle.core.generators import generate_sample_model
from trestle.common.model_utils import ModelUtils
from trestle.core.commands.init import InitCmd
from trestle.core.models.file_content_type import FileContentType
from trestle.oscal import catalog as cat
from trestle.oscal import profile as prof
from trestle.oscal.component import ImplementedRequirement

from utils.oscal.cd_generator import ComponentDefinitionGenerator

DATADIR = os.path.join(os.path.dirname(__file__), "data")
TEST_ROOT = os.path.abspath(os.path.join(DATADIR, "test_root"))
TEST_BUILD_CONFIG = os.path.join(DATADIR, "build-config.yml")
TEST_RULE_JSON = os.path.join(DATADIR, "rule_dirs.json")


@pytest.fixture(scope="function")
def vendor_dir():
    """Create a temporary trestle directory for testing."""
    with TemporaryDirectory(prefix="temp_vendor") as tmpdir:
        tmp_path = pathlib.Path(tmpdir)
        try:
            args = argparse.Namespace(
                verbose=0,
                trestle_root=tmp_path,
                full=True,
                local=False,
                govdocs=False,
            )
            init = InitCmd()
            init._run(args)
            load_oscal_test_data(tmp_path, 'simplified_nist_catalog', cat.Catalog)
            load_oscal_test_data(tmp_path, 'simplified_nist_profile', prof.Profile)
        except Exception as e:
            raise TrestleError(
                f'Initialization failed for temporary trestle directory: {e}.'
            )
        yield tmpdir


def load_oscal_test_data(trestle_dir, model_name, model_type):
    dst_path = ModelUtils.get_model_path_for_name_and_class(
        trestle_dir, model_name, model_type, FileContentType.JSON  # type: ignore
    )
    dst_path.parent.mkdir(parents=True, exist_ok=True)
    src_path = os.path.join(DATADIR, model_name + '.json')
    shutil.copy2(src_path, dst_path)


@pytest.mark.parametrize(
    "input, response",
    [
        ('AC-1', 'ac-1'),
        ('AC-2(2)', 'ac-2.2'),
        ('ac-1_smt.a', 'ac-1_smt.a'),
        ('AC-200', None),
    ]
)
def test_get_control_profile_id(vendor_dir, input, response):
    "Test get_control_profile_id"
    cd_generator = ComponentDefinitionGenerator(
        product='test_product',
        vendor_dir=vendor_dir,
        build_config_yaml=TEST_BUILD_CONFIG,
        json_path=TEST_RULE_JSON,
        root=TEST_ROOT,
        profile_name_or_href='simplified_nist_profile',
        control="test_policy"
    )
    result_id = cd_generator.get_profile_control_id(input)
    assert result_id == response


section_response = """
Section a: My response is a single statement
Section b: My response is a list of statements

This link for section b.
"""

single_response = """
A single response with no sections
"""


def test_handle_response(vendor_dir):
    """Test handling responses"""
    cd_generator = ComponentDefinitionGenerator(
        product='test_product',
        vendor_dir=vendor_dir,
        build_config_yaml=TEST_BUILD_CONFIG,
        json_path=TEST_RULE_JSON,
        root=TEST_ROOT,
        profile_name_or_href='simplified_nist_profile',
        control="test_policy"
    )

    # test with sections
    implemented_req = generate_sample_model(ImplementedRequirement)
    implemented_req.control_id = 'ac-1'
    cd_generator.handle_response(implemented_req, section_response)

    assert len(implemented_req.statements) == 2
    assert implemented_req.statements[0].description == 'My response is a single statement'
    expected_text = "My response is a list of statements\n\nThis link for section b."
    assert implemented_req.statements[1].description == expected_text

    # test single
    implemented_req = generate_sample_model(ImplementedRequirement)
    implemented_req.control_id = 'ac-1'
    cd_generator.handle_response(implemented_req, single_response)

    assert implemented_req.statements is None
    assert implemented_req.description == 'A single response with no sections'
