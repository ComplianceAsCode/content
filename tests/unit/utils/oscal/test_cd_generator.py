import argparse
import os
import pytest
import pathlib
import shutil

from tempfile import TemporaryDirectory

from trestle.common.const import IMPLEMENTATION_STATUS, REPLACE_ME
from trestle.common.err import TrestleError
from trestle.core.generators import generate_sample_model
from trestle.common.model_utils import ModelUtils
from trestle.core.commands.init import InitCmd
from trestle.core.models.file_content_type import FileContentType
from trestle.oscal import catalog as cat
from trestle.oscal import profile as prof
from trestle.oscal.component import ComponentDefinition
from trestle.oscal.component import ImplementedRequirement

from ssg.controls import Control, Status

from utils.oscal.cd_generator import (
    ComponentDefinitionGenerator,
    OscalStatus,
    OSCALProfileHelper,
)


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
            load_oscal_test_data(tmp_path, "simplified_nist_catalog", cat.Catalog)
            load_oscal_test_data(tmp_path, "simplified_nist_profile", prof.Profile)
        except Exception as e:
            raise TrestleError(
                f"Initialization failed for temporary trestle directory: {e}."
            )
        yield tmpdir


def load_oscal_test_data(trestle_dir, model_name, model_type):
    dst_path = ModelUtils.get_model_path_for_name_and_class(
        trestle_dir, model_name, model_type, FileContentType.JSON  # type: ignore
    )
    dst_path.parent.mkdir(parents=True, exist_ok=True)
    src_path = os.path.join(DATADIR, model_name + ".json")
    shutil.copy2(src_path, dst_path)


@pytest.mark.parametrize(
    "input, response",
    [
        ("AC-1", "ac-1"),
        ("AC-2(2)", "ac-2.2"),
        ("ac-1_smt.a", "ac-1_smt.a"),
        ("AC-200", None),
    ],
)
def test_oscal_profile_helper(vendor_dir, input, response):
    "Test the OSCALProfileHelper class validate method."
    trestle_root = pathlib.Path(vendor_dir)
    oscal_profile_helper = OSCALProfileHelper(trestle_root=trestle_root)
    profile_path = f"{vendor_dir}/profiles/simplified_nist_profile/profile.json"
    oscal_profile_helper.load(profile_path=profile_path)
    result_id = oscal_profile_helper.validate(input)
    assert result_id == response


section_response = """
Section a: My response is a single statement
Section b: My response is a list of statements

This link for section b.
"""

single_response = """
A single response with no sections
"""


@pytest.mark.parametrize(
    "notes, input_status, description, status, remarks",
    [
        (
            single_response,
            Status.MANUAL,
            REPLACE_ME,
            OscalStatus.ALTERNATIVE,
            "A single response with no sections",
        ),
        (
            single_response,
            Status.INHERENTLY_MET,
            "A single response with no sections",
            OscalStatus.IMPLEMENTED,
            None,
        ),
    ],
)
def test_handle_response_with_implemented_requirements(
    vendor_dir, notes, input_status, description, status, remarks
):
    """Test handling responses with various scenarios."""
    cd_generator = ComponentDefinitionGenerator(
        product="test_product",
        vendor_dir=vendor_dir,
        build_config_yaml=TEST_BUILD_CONFIG,
        json_path=TEST_RULE_JSON,
        root=TEST_ROOT,
        profile_name_or_href="simplified_nist_profile",
        control="test_policy",
    )

    control = Control()
    control.notes = notes
    control.status = input_status

    implemented_req = generate_sample_model(ImplementedRequirement)
    implemented_req.control_id = "ac-1"
    cd_generator.handle_response(implemented_req, control)

    assert implemented_req.statements is None
    assert implemented_req.description == description

    prop = next(
        (prop for prop in implemented_req.props if prop.name == IMPLEMENTATION_STATUS),
        None,
    )

    assert prop is not None
    assert prop.value == status
    assert prop.remarks == remarks


@pytest.mark.parametrize(
    "notes, status, id, results",
    [
        (
            section_response,
            Status.PARTIAL,
            "ac-1",
            {
                "ac-1_smt.a": (
                    "My response is a single statement",
                    OscalStatus.PARTIAL,
                    None,
                ),
                "ac-1_smt.b": (
                    "My response is a list of statements\n\nThis link for section b.",
                    OscalStatus.PARTIAL,
                    None,
                ),
            },
        ),
        (
            section_response,
            Status.MANUAL,
            "ac-1",
            {
                "ac-1_smt.a": (
                    REPLACE_ME,
                    OscalStatus.ALTERNATIVE,
                    "My response is a single statement",
                ),
                "ac-1_smt.b": (
                    REPLACE_ME,
                    OscalStatus.ALTERNATIVE,
                    "My response is a list of statements\n\nThis link for section b.",
                ),
            },
        ),
    ],
)
def test_handle_response_with_statements(vendor_dir, notes, status, id, results):
    """Test handling responses with various scenarios."""
    cd_generator = ComponentDefinitionGenerator(
        product="test_product",
        vendor_dir=vendor_dir,
        build_config_yaml=TEST_BUILD_CONFIG,
        json_path=TEST_RULE_JSON,
        root=TEST_ROOT,
        profile_name_or_href="simplified_nist_profile",
        control="test_policy",
    )

    control = Control()
    control.notes = notes
    control.status = status

    implemented_req = generate_sample_model(ImplementedRequirement)
    implemented_req.control_id = id
    cd_generator.handle_response(implemented_req, control)

    assert len(implemented_req.statements) == len(results)

    for stm in implemented_req.statements:
        description, status, remarks = results.get(stm.statement_id)
        assert stm.description == description

        prop = next(
            (prop for prop in stm.props if prop.name == IMPLEMENTATION_STATUS), None
        )

        assert prop is not None
        assert prop.value == status
        assert prop.remarks == remarks


def test_create_cd(vendor_dir):
    """Test creating a component definition."""
    cd_generator = ComponentDefinitionGenerator(
        product="test_product",
        vendor_dir=vendor_dir,
        build_config_yaml=TEST_BUILD_CONFIG,
        json_path=TEST_RULE_JSON,
        root=TEST_ROOT,
        profile_name_or_href="simplified_nist_profile",
        control="test_policy",
    )

    cd_output = os.path.join(vendor_dir, "test_comp.json")
    cd_path = pathlib.Path(cd_output)
    cd_generator.create_cd(cd_output)

    component_definition: ComponentDefinition = ComponentDefinition.oscal_read(cd_path)
    assert component_definition is not None

    assert len(component_definition.components) == 1
    component = component_definition.components[0]

    assert component.title == "test_product"
    assert component.description == "test_product"
    assert component.type == "service"
    assert len(component.control_implementations) == 1
