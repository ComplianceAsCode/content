import argparse
import os
import pathlib
import shutil
from typing import Any, Dict, Generator, Tuple
from tempfile import TemporaryDirectory
from unittest.mock import Mock

import pytest
from trestle.common.common_types import TopLevelOscalModel
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

import ssg.environment
import ssg.products
from ssg.controls import Control, Status

from utils.oscal.cd_generator import (
    ComponentDefinitionGenerator,
    OscalStatus,
    OSCALProfileHelper,
)
from utils.oscal.control_selector import ControlSelector, PolicyControlSelector


DATADIR = os.path.join(os.path.dirname(__file__), "data")
TEST_ROOT = os.path.abspath(os.path.join(DATADIR, "test_root"))
TEST_BUILD_CONFIG = os.path.join(DATADIR, "build-config.yml")
TEST_RULE_JSON = os.path.join(DATADIR, "rule_dirs.json")


@pytest.fixture(scope="function")
def vendor_dir() -> Generator[str, None, None]:
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
            load_oscal_test_data(tmp_path, "simplified_nist_catalog", cat.Catalog)  # type: ignore
            load_oscal_test_data(tmp_path, "simplified_nist_profile", prof.Profile)  # type: ignore
        except Exception as e:
            raise TrestleError(
                f"Initialization failed for temporary trestle directory: {e}."
            )
        yield tmpdir


@pytest.fixture(scope="function")
def env_yaml() -> Generator[Dict[str, Any], None, None]:
    product_yaml_path = ssg.products.product_yaml_path(TEST_ROOT, "test_product")
    env_yaml = ssg.environment.open_environment(
        TEST_BUILD_CONFIG,
        product_yaml_path,
        os.path.join(TEST_ROOT, "product_properties"),
    )
    yield env_yaml


def load_oscal_test_data(
    trestle_dir: pathlib.Path, model_name: str, model_type: TopLevelOscalModel
) -> None:
    dst_path = ModelUtils.get_model_path_for_name_and_class(
        trestle_dir, model_name, model_type, FileContentType.JSON  # type: ignore
    )
    if dst_path is None:
        raise TrestleError(f"Unable to get model path for {model_name}")
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
def test_oscal_profile_helper(vendor_dir: str, input: str, response: str) -> None:
    "Test the OSCALProfileHelper class validate method."
    trestle_root = pathlib.Path(vendor_dir)
    oscal_profile_helper = OSCALProfileHelper(trestle_root=trestle_root)
    profile_path = f"{vendor_dir}/profiles/simplified_nist_profile/profile.json"
    oscal_profile_helper.load(profile_path=profile_path)
    result_id = oscal_profile_helper.validate(input)
    assert result_id == response


@pytest.mark.parametrize(
    "ssg_status, oscal_status, err_msg",
    [
        (Status.INHERENTLY_MET, OscalStatus.IMPLEMENTED, ""),
        (Status.PARTIAL, OscalStatus.PARTIAL, ""),
        (Status.MANUAL, OscalStatus.ALTERNATIVE, ""),
        ("fake_status", "", "Invalid status: fake_status.*"),
    ],
)
def test_oscal_status(ssg_status: str, oscal_status: str, err_msg: str) -> None:
    """
    Test OSCALStatus class mapping.

    Test a few valid mappings and an invalid mapping.
    """
    if not err_msg:
        assert OscalStatus.from_string(ssg_status) == oscal_status
    else:
        with pytest.raises(ValueError, match=err_msg):
            OscalStatus.from_string(ssg_status)


section_response = """
Section a: My response is a single statement
Section b: My response is a list of statements

This link for section b.
"""

single_response = """
A single response with no sections
"""

expected_single_response = "A single response with no sections"
expected_section_a_response = "My response is a single statement"
expected_section_b_response = (
    "My response is a list of statements\n\nThis link for section b."
)


@pytest.mark.parametrize(
    "notes, input_status, description, status, remarks",
    [
        (
            single_response,
            Status.MANUAL,
            REPLACE_ME,
            OscalStatus.ALTERNATIVE,
            expected_single_response,
        ),
        (
            single_response,
            Status.INHERENTLY_MET,
            expected_single_response,
            OscalStatus.IMPLEMENTED,
            None,
        ),
    ],
)
def test_handle_response_with_implemented_requirements(
    vendor_dir: str,
    env_yaml: Dict[str, Any],
    notes: str,
    input_status: str,
    description: str,
    status: str,
    remarks: str,
) -> None:
    """Test handling responses with various scenarios."""

    control = Control()
    control.notes = notes
    control.status = input_status

    mock_selector = Mock(spec=ControlSelector)
    mock_selector.get_controls = [control]

    cd_generator = ComponentDefinitionGenerator(
        vendor_dir=vendor_dir,
        json_path=TEST_RULE_JSON,
        root=TEST_ROOT,
        profile_name_or_href="simplified_nist_profile",
        env_yaml=env_yaml,
        control_selector=mock_selector,
    )

    implemented_req = generate_sample_model(ImplementedRequirement)
    implemented_req.control_id = "ac-1"
    cd_generator.handle_response(implemented_req, control)

    assert implemented_req.statements is None
    assert implemented_req.description == description
    assert implemented_req.props is not None

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
            (
                OscalStatus.PARTIAL,
                None,
                {
                    "ac-1_smt.a": expected_section_a_response,
                    "ac-1_smt.b": expected_section_b_response,
                },
            ),
        ),
        (
            section_response,
            Status.MANUAL,
            "ac-1",
            (
                OscalStatus.ALTERNATIVE,
                REPLACE_ME,
                {
                    "ac-1_smt.a": expected_section_a_response,
                    "ac-1_smt.b": expected_section_b_response,
                },
            ),
        ),
    ],
)
def test_handle_response_with_statements(
    vendor_dir: str,
    env_yaml: Dict[str, Any],
    notes: str,
    status: str,
    id: str,
    results: Tuple[str, str, Dict[str, str]],
) -> None:
    """Test handling responses with various scenarios."""
    product_yaml_path = ssg.products.product_yaml_path(TEST_ROOT, "test_product")
    env_yaml = ssg.environment.open_environment(
        TEST_BUILD_CONFIG,
        product_yaml_path,
        os.path.join(TEST_ROOT, "product_properties"),
    )

    control = Control()
    control.notes = notes
    control.status = status

    mock_selector = Mock(spec=ControlSelector)
    mock_selector.get_controls = [control]

    cd_generator = ComponentDefinitionGenerator(
        vendor_dir=vendor_dir,
        json_path=TEST_RULE_JSON,
        root=TEST_ROOT,
        profile_name_or_href="simplified_nist_profile",
        env_yaml=env_yaml,
        control_selector=mock_selector,
    )

    implemented_req = generate_sample_model(ImplementedRequirement)
    implemented_req.control_id = id
    cd_generator.handle_response(implemented_req, control)

    status, remarks, statements = results

    assert implemented_req.description == REPLACE_ME
    assert implemented_req.props is not None

    prop = next(
        (prop for prop in implemented_req.props if prop.name == IMPLEMENTATION_STATUS),
        None,
    )

    assert prop is not None
    assert prop.value == status
    assert prop.remarks == remarks

    assert implemented_req.statements is not None
    assert len(implemented_req.statements) == len(statements)

    for stm in implemented_req.statements:
        assert stm.description == statements.get(stm.statement_id)  # type: ignore


def test_create_control_implementation(
    vendor_dir: str, env_yaml: Dict[str, Any]
) -> None:
    """Test the create_control_implementation with PolicyControlSelection."""
    control_selector = PolicyControlSelector(
        control="test_policy",
        ssg_root=TEST_ROOT,
        env_yaml=env_yaml,
    )

    cd_generator = ComponentDefinitionGenerator(
        vendor_dir=vendor_dir,
        json_path=TEST_RULE_JSON,
        root=TEST_ROOT,
        profile_name_or_href="simplified_nist_profile",
        env_yaml=env_yaml,
        control_selector=control_selector,
    )

    control_impl = cd_generator.create_control_implementation()

    assert len(control_impl.implemented_requirements) == 2
    assert control_impl.implemented_requirements[0].control_id == "ac-1"
    assert control_impl.implemented_requirements[1].control_id == "ac-2.1"

    # Check set parameters
    assert control_impl.set_parameters is not None
    assert len(control_impl.set_parameters) == 1
    assert control_impl.set_parameters[0].param_id == "var_test"
    assert "default" in control_impl.set_parameters[0].values


def test_create_control_implementation_with_level(
    vendor_dir: str, env_yaml: Dict[str, Any]
) -> None:
    """Test the create_component_definition with a level filter on the control file."""
    control_selector = PolicyControlSelector(
        control="test_policy",
        ssg_root=TEST_ROOT,
        env_yaml=env_yaml,
        filter_by_level="low",
    )

    cd_generator = ComponentDefinitionGenerator(
        vendor_dir=vendor_dir,
        json_path=TEST_RULE_JSON,
        root=TEST_ROOT,
        profile_name_or_href="simplified_nist_profile",
        env_yaml=env_yaml,
        control_selector=control_selector,
    )

    control_impl = cd_generator.create_control_implementation()

    assert len(control_impl.implemented_requirements) == 1
    assert control_impl.implemented_requirements[0].control_id == "ac-1"


def test_create_cd(vendor_dir: str, env_yaml: Dict[str, Any]) -> None:
    """Test creating a component definition."""
    control_selector = PolicyControlSelector(
        control="test_policy",
        ssg_root=TEST_ROOT,
        env_yaml=env_yaml,
    )

    cd_generator = ComponentDefinitionGenerator(
        vendor_dir=vendor_dir,
        json_path=TEST_RULE_JSON,
        root=TEST_ROOT,
        profile_name_or_href="simplified_nist_profile",
        env_yaml=env_yaml,
        control_selector=control_selector,
    )
    cd_output = os.path.join(vendor_dir, "test_comp.json")
    cd_path = pathlib.Path(cd_output)
    cd_generator.create_cd(cd_output)

    component_definition: ComponentDefinition
    component_definition = ComponentDefinition.oscal_read(cd_path)  # type: ignore
    assert component_definition is not None

    assert component_definition.components is not None
    assert len(component_definition.components) == 1
    component = component_definition.components[0]

    assert component.title == "test_product"
    assert component.description == "test_product"
    assert component.type == "service"

    assert component.control_implementations is not None
    assert len(component.control_implementations) == 1
    assert len(component.control_implementations[0].implemented_requirements) == 2

    assert component.props is not None
    assert len(component.props) == 7
