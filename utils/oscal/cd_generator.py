"""Build a component definition for a product from pre-existing OSCAL profiles"""

import logging
import pathlib
import re
from typing import Any, Dict, List, Optional, Set, Tuple

from trestle.common.common_types import TypeWithProps, TypeWithParts
from trestle.common.const import TRESTLE_HREF_HEADING, IMPLEMENTATION_STATUS, REPLACE_ME
from trestle.common.list_utils import as_list, none_if_empty
from trestle.core.generators import generate_sample_model
from trestle.core.catalog.catalog_interface import CatalogInterface
from trestle.core.control_interface import ControlInterface
from trestle.core.profile_resolver import ProfileResolver
from trestle.oscal import catalog as cat
from trestle.oscal.common import Property
from trestle.oscal.component import (
    ComponentDefinition,
    DefinedComponent,
    ControlImplementation,
    ImplementedRequirement,
    Statement,
    SetParameter,
)


from ssg.controls import Status, Control
from ssg.utils import required_key

from utils.oscal import add_prop
from utils.oscal.control_selector import ControlSelector
from utils.oscal.params_extractor import ParameterExtractor
from utils.oscal.rules_transformer import RulesTransformer, RuleInfo

from utils.oscal import LOGGER_NAME


logger = logging.getLogger(LOGGER_NAME)

SECTION_PATTERN = r"Section ([a-z]):"


class OscalStatus:
    """
    Represent the status of a control in OSCAL.

    Notes:
        This transforms the status from SSG to OSCAL in the from
        string method.
    """

    PLANNED = "planned"
    NOT_APPLICABLE = "not-applicable"
    ALTERNATIVE = "alternative"
    IMPLEMENTED = "implemented"
    PARTIAL = "partial"

    @staticmethod
    def from_string(source: str) -> str:
        data = {
            Status.INHERENTLY_MET: OscalStatus.IMPLEMENTED,
            Status.DOES_NOT_MEET: OscalStatus.ALTERNATIVE,
            Status.DOCUMENTATION: OscalStatus.IMPLEMENTED,
            Status.AUTOMATED: OscalStatus.IMPLEMENTED,
            Status.MANUAL: OscalStatus.ALTERNATIVE,
            Status.PLANNED: OscalStatus.PLANNED,
            Status.PARTIAL: OscalStatus.PARTIAL,
            Status.SUPPORTED: OscalStatus.IMPLEMENTED,
            Status.PENDING: OscalStatus.ALTERNATIVE,
            Status.NOT_APPLICABLE: OscalStatus.NOT_APPLICABLE,
        }
        if source not in data.keys():
            raise ValueError(f"Invalid status: {source}. Use one of {data.keys()}")
        return data.get(source)  # type: ignore

    STATUSES = {PLANNED, NOT_APPLICABLE, ALTERNATIVE, IMPLEMENTED, PARTIAL}


class OSCALProfileHelper:
    """Helper class to handle OSCAL profile."""

    def __init__(self, trestle_root: pathlib.Path) -> None:
        """Initialize."""
        self._root = trestle_root
        self.profile_controls: Set[str] = set()
        self.controls_by_label: Dict[str, str] = dict()

    def load(self, profile_path: str) -> None:
        """Load the profile catalog."""
        profile_resolver = ProfileResolver()
        resolved_catalog: cat.Catalog = profile_resolver.get_resolved_profile_catalog(
            self._root,
            profile_path,
            block_params=False,
            params_format="[.]",
            show_value_warnings=True,
        )

        for control in CatalogInterface(resolved_catalog).get_all_controls_from_dict():
            self.profile_controls.add(control.id)
            label = ControlInterface.get_label(control)
            if label:
                self.controls_by_label[label] = control.id
                self._handle_parts(control)

    def _handle_parts(
        self,
        control: TypeWithParts,
    ) -> None:
        """Handle parts of a control."""
        if control.parts:
            for part in control.parts:
                if not part.id:
                    continue
                self.profile_controls.add(part.id)
                label = ControlInterface.get_label(part)
                # Avoiding key collision here. The higher level control object will take
                # precedence.
                if label and label not in self.controls_by_label.keys():
                    self.controls_by_label[label] = part.id
                self._handle_parts(part)

    def validate(self, control_id: str) -> Optional[str]:
        """Validate that the control id exists in the catalog and return the id"""
        if control_id in self.controls_by_label.keys():
            logger.debug(f"Found control {control_id} in control labels")
            return self.controls_by_label.get(control_id)
        elif control_id in self.profile_controls:
            logger.debug(f"Found control {control_id} in profile control ids")
            return control_id

        logger.debug(f"Control {control_id} does not exist in the profile")
        return None


class ComponentDefinitionGenerator:
    """Generate a component definition from a product"""

    def __init__(
        self,
        root: str,
        json_path: str,
        env_yaml: Dict[str, Any],
        vendor_dir: str,
        profile_name_or_href,
        control_selector: ControlSelector,
    ) -> None:
        """
        Initialize the component definition generator and load the necessary files.

        Args:
            root: Root of the SSG project
            json_path: Path to the rules_dir.json file
            env_yaml: Yaml file with environment information
            vendor_dir: Path to the vendor directory
            profile_name_or_href: Name or href of the profile to use
            control_selector: Control selector that contains control responses
        """
        self.ssg_root = root
        self.trestle_root = pathlib.Path(vendor_dir)
        self.product = required_key(env_yaml, "product")
        self.env_yaml = env_yaml
        self.control_selector = control_selector

        profile_path, profile_href = self.get_source(profile_name_or_href)
        self.profile_href = profile_href

        self.profile = OSCALProfileHelper(self.trestle_root)
        self.profile.load(profile_path)

        self.params_extractor = ParameterExtractor(root, self.env_yaml)
        self.rules_transformer = RulesTransformer(
            root, self.env_yaml, json_path, self.params_extractor
        )

    def get_source(self, profile_name_or_href: str) -> Tuple[str, str]:
        """Get the source of the profile."""
        profile_in_trestle_dir = "://" not in profile_name_or_href
        profile_href = profile_name_or_href
        if profile_in_trestle_dir:
            local_path = f"profiles/{profile_name_or_href}/profile.json"
            profile_href = TRESTLE_HREF_HEADING + local_path
            profile_path = str(self.trestle_root / local_path)
        else:
            profile_path = profile_href

        return profile_path, profile_href

    def create_implemented_requirement(
        self, control: Control
    ) -> Optional[ImplementedRequirement]:
        """Create implemented requirement from a control object"""

        logger.info(f"Creating implemented requirement for {control.id}")
        control_id = self.profile.validate(control.id)
        if control_id:
            implemented_req = generate_sample_model(ImplementedRequirement)
            implemented_req.control_id = control_id
            self.handle_response(implemented_req, control)

            rule_ids, params_values = self._process_rule_ids(control.rules)
            self.add_rules(implemented_req, rule_ids, params_values)
            return implemented_req
        return None

    def add_rules(
        self,
        type_with_props: TypeWithProps,
        rule_ids: List[str],
        params_values: Optional[Dict[str, str]] = None,
    ) -> None:
        """Add rules to a type with props."""
        all_props: List[Property] = as_list(type_with_props.props)
        self.rules_transformer.add_rules(rule_ids, params_values)
        rule_properties: List[Property] = self.rules_transformer.get_rule_id_props(
            rule_ids
        )
        all_props.extend(rule_properties)
        type_with_props.props = none_if_empty(all_props)

    def _process_rule_ids(
        self, rule_ids: List[str]
    ) -> Tuple[List[str], Dict[str, str]]:
        """
        Process rule ids.

        Returns:
            A tuple of processed rule ids and parameter selection values.

        Notes: Rule ids with an "=" are parameters and should not be included when searching for
        rules.
        """
        processed_rule_ids: List[str] = list()
        params_values: Dict[str, str] = dict()
        for rule_id in rule_ids:
            parts = rule_id.split("=")
            if len(parts) == 2:
                param_id, value = parts
                params_values[param_id] = value
            else:
                processed_rule_ids.append(rule_id)
        return (processed_rule_ids, params_values)

    def handle_response(self, implemented_req, control: Control) -> None:
        """
        Break down the response into parts.

        Args:
            implemented_req: The implemented requirement to add the response and statements to.
            control_response: The control response to add to the implemented requirement.
        """
        control_response = control.notes
        pattern = re.compile(SECTION_PATTERN, re.IGNORECASE)

        sections_dict = self.build_sections_dict(control_response, pattern)
        oscal_status = OscalStatus.from_string(control.status)

        if sections_dict:
            self._add_response_by_status(implemented_req, oscal_status, REPLACE_ME)
            # process into statements
            implemented_req.statements = list()
            for section_label, section_content in sections_dict.items():
                statement_id = self.profile.validate(
                    f"{implemented_req.control_id}_smt.{section_label}"
                )
                if statement_id is None:
                    continue

                section_content_str = "\n".join(section_content)
                section_content_str = pattern.sub("", section_content_str)
                statement = self.create_statement(
                    statement_id, section_content_str.strip()
                )
                implemented_req.statements.append(statement)
        else:
            self._add_response_by_status(
                implemented_req, oscal_status, control_response.strip()
            )

    @staticmethod
    def build_sections_dict(
        control_response: str, section_pattern: re.Pattern
    ) -> Dict[str, List[str]]:
        """Find all sections in the control response and build a dictionary of them."""
        lines = control_response.split("\n")

        sections_dict: Dict[str, List[str]] = dict()
        current_section_label = None

        for line in lines:
            match = section_pattern.match(line)

            if match:
                current_section_label = match.group(1)
                sections_dict[current_section_label] = [line]
            elif current_section_label is not None:
                sections_dict[current_section_label].append(line)

        return sections_dict

    @staticmethod
    def _add_response_by_status(
        impl_req: ImplementedRequirement,
        implementation_status: str,
        control_response: str,
    ) -> None:
        """
        Add the response to the implemented requirement depending on the status.

        Notes: Per OSCAL requirements, any status other than implemented and partial should have
        remarks with justification for the status.
        """

        status_prop = add_prop(IMPLEMENTATION_STATUS, implementation_status, "")

        if (
            implementation_status == OscalStatus.IMPLEMENTED
            or implementation_status == OscalStatus.PARTIAL
        ):
            impl_req.description = control_response
        else:
            status_prop.remarks = control_response

        impl_req.props = as_list(impl_req.props)
        impl_req.props.append(status_prop)

    def create_statement(self, statement_id, description="") -> Statement:
        """Create a statement."""
        statement = generate_sample_model(Statement)
        statement.statement_id = statement_id
        if description:
            statement.description = description
        return statement

    def add_set_parameters(self, control_implementation: ControlImplementation) -> None:
        """Add set parameters to a type with props."""
        param_selections: Dict[
            str, str
        ] = self.params_extractor.get_all_selected_values()
        if param_selections:
            all_set_params: List[SetParameter] = as_list(
                control_implementation.set_parameters
            )
            for param_id, value in param_selections.items():
                set_param = generate_sample_model(SetParameter)
                set_param.param_id = param_id
                set_param.values = [value]
                all_set_params.append(set_param)
            control_implementation.set_parameters = none_if_empty(all_set_params)

    def create_control_implementation(self) -> ControlImplementation:
        """Get the control implementation for a component."""
        ci = generate_sample_model(ControlImplementation)
        ci.source = self.profile_href
        all_implement_reqs = list()

        for control in self.control_selector.get_controls():
            implemented_req = self.create_implemented_requirement(control)
            if implemented_req:
                all_implement_reqs.append(implemented_req)
        ci.implemented_requirements = all_implement_reqs
        self.add_set_parameters(ci)
        return ci

    def create_cd(
        self, output: str, component_definition_type: str = "service"
    ) -> None:
        """Create a component definition and write it to a file."""
        logger.info(f"Creating component definition for {self.product}")
        component_definition = generate_sample_model(ComponentDefinition)
        component_definition.metadata.title = f"Component definition for {self.product}"
        component_definition.components = list()

        control_implementation: ControlImplementation = (
            self.create_control_implementation()
        )

        if not control_implementation.implemented_requirements:
            logger.warning(
                f"No implemented requirements found for {self.product}, exiting"
            )
            return

        oscal_component = generate_sample_model(DefinedComponent)
        oscal_component.title = self.product
        oscal_component.type = component_definition_type
        oscal_component.description = self.product
        oscal_component.control_implementations = [control_implementation]

        # Create all of the top-level component properties for rules
        rules: List[RuleInfo] = self.rules_transformer.get_all_rules()
        all_rule_properties: List[Property] = self.rules_transformer.transform(rules)
        oscal_component.props = none_if_empty(all_rule_properties)

        component_definition.components.append(oscal_component)

        output_str = output
        out_path = pathlib.Path(output_str)
        logger.info(f"Writing component definition to {out_path}")
        component_definition.oscal_write(out_path)
