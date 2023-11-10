#! /usr/bin/python3

"""Build a component definition for a product from pre-existing profiles"""

import json
import logging
import os
import pathlib
import re
import uuid

from trestle.common.const import TRESTLE_HREF_HEADING, IMPLEMENTATION_STATUS
from trestle.common.list_utils import as_list
from trestle.core.generators import generate_sample_model
from trestle.core.catalog.catalog_interface import CatalogInterface
from trestle.core.control_interface import ControlInterface
from trestle.core.profile_resolver import ProfileResolver
from trestle.oscal.common import Property
from trestle.oscal.component import (
    ComponentDefinition,
    DefinedComponent,
    ControlImplementation,
    ImplementedRequirement,
    Statement,
)

import ssg.components
import ssg.environment
import ssg.rules
import ssg.build_yaml
from ssg.controls import ControlsManager, Status

from utils.oscal import LOGGER_NAME


logger = logging.getLogger(LOGGER_NAME)

SECTION_PATTERN = r'Section ([a-z]):'


class OscalStatus:
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
        }
        return data.get(source, source)

    STATUSES = {PLANNED, NOT_APPLICABLE, ALTERNATIVE, IMPLEMENTED, PARTIAL}


class ComponentDefinitionGenerator:
    """Generate a component definition from a product"""

    def __init__(
        self,
        product,
        root,
        json_path,
        build_config_yaml,
        vendor_dir,
        profile_name_or_href,
        control,
    ):
        """
        Initialize the component definition generator and load the necessary files.

        Args:
            product: Product to generate the component definition for
            root: Root of the SSG project
            json_path: Path to the rules_dir.json file
            build_config_yaml: Path to the build_config.yml file
            vendor_dir: Path to the vendor directory
            profile_name_or_href: Name or href of the profile to use
        """
        self.ssg_root = root
        self.trestle_root = pathlib.Path(vendor_dir)
        self.product = product

        profile_path, profile_href = self.get_source(profile_name_or_href)
        self.profile_path = profile_path
        self.profile_href = profile_href

        # Used to match by profile control id and then by label property
        (
            self.profile_controls,
            self.controls_by_label,
        ) = self.resolve_profile_to_controls()

        self.env_yaml = self.get_env_yaml(build_config_yaml)
        self.policy_id = control
        self.controls_mgr = self.get_controls_mgr(control)

        with open(json_path, 'r') as f:
            rule_dir_json = json.load(f)
        self.rule_json = rule_dir_json

    def get_env_yaml(self, build_config_yaml):
        """Get the environment yaml."""
        product_dir = os.path.join(self.ssg_root, "products", self.product)
        product_yaml_path = os.path.join(product_dir, "product.yml")
        env_yaml = ssg.environment.open_environment(
            build_config_yaml,
            product_yaml_path,
            os.path.join(self.ssg_root, "product_properties"),
        )
        return env_yaml

    def get_source(self, profile_name_or_href):
        """Get the source of the profile."""
        profile_in_trestle_dir = '://' not in profile_name_or_href
        profile_href = profile_name_or_href
        if profile_in_trestle_dir:
            local_path = f'profiles/{profile_name_or_href}/profile.json'
            profile_href = TRESTLE_HREF_HEADING + local_path
            profile_path = self.trestle_root / local_path
        else:
            profile_path = profile_href

        return profile_path, profile_href

    def get_controls_mgr(self, control):
        """Get the control response and implementation status from the policy."""
        controls_dir = os.path.join(self.ssg_root, "controls")
        controls_manager = ControlsManager(
            controls_dir=controls_dir, env_yaml=self.env_yaml
        )
        controls_manager.load()
        if control not in controls_manager.policies:
            raise ValueError(f"Policy {control} not found in controls")
        return controls_manager

    def resolve_profile_to_controls(self):
        """
        Resolve the profile to a list of control ids.

        Returns:
            profile_controls: List of control ids in the profile
            controls_by_label: Dictionary of controls by label
        """
        profile_resolver = ProfileResolver()
        resolved_catalog = profile_resolver.get_resolved_profile_catalog(
            self.trestle_root,
            self.profile_path,
            block_params=False,
            params_format='[.]',
            show_value_warnings=True,
        )
        profile_controls = set()
        controls_by_label = dict()

        for control in CatalogInterface(resolved_catalog).get_all_controls_from_dict():
            profile_controls.add(control.id)
            label = ControlInterface.get_label(control)
            if label:
                controls_by_label[label] = control.id
                self.handle_parts(control, profile_controls, controls_by_label)
        return profile_controls, controls_by_label

    def handle_parts(self, control, profile_controls, controls_by_label):
        """Handle parts of a control."""
        if control.parts:
            for part in control.parts:
                profile_controls.add(part.id)
                label = ControlInterface.get_label(part)
                if label:
                    controls_by_label[label] = part.id
                self.handle_parts(part, profile_controls, controls_by_label)

    def handle_rule_yaml(self, rule_id: str):
        """Create rule object from rule yaml."""
        rule_dir = self.rule_json[rule_id]['dir']
        guide_dir = self.rule_json[rule_id]['guide']
        product = self.env_yaml['product']
        rule_obj = {'id': rule_id, 'dir': rule_dir, 'guide': guide_dir}
        rule_file = ssg.rules.get_rule_dir_yaml(rule_dir)

        rule_yaml = ssg.build_yaml.Rule.from_yaml(rule_file, env_yaml=self.env_yaml)
        rule_yaml.normalize(product)
        rule_obj['description'] = rule_yaml.description
        rule_obj['fixtext'] = rule_yaml.fixtext
        return rule_obj

    def get_profile_control_id(self, control_name):
        """
        Get control info if it is in the parent profile.

        Returns:
            control_id: The control id if it is in the profile
        """
        if control_name in self.controls_by_label.keys():
            logging.debug(f"Found control {control_name} in control labels")
            return self.controls_by_label.get(control_name)
        elif control_name in self.profile_controls:
            logging.debug(f"Found control {control_name} in profile control ids")
            return control_name

        logger.debug(f"Control {control_name} does not exist in the profile")
        return None

    def create_implemented_requirement(self, control):
        """Create implemented requirement from a control object"""

        logger.info(f"Creating implemented requirement for {control.id}")
        control_id = self.get_profile_control_id(control.id)
        if control_id:
            implemented_req = generate_sample_model(ImplementedRequirement)
            implemented_req.control_id = control_id
            self.handle_response(implemented_req, control)
            # TODO(jpower432): Setup rules in the properties file
            return implemented_req
        return None

    def handle_response(self, implemented_req, control):
        """
        Break down the response into parts.

        Args:
            implemented_req: The implemented requirement to add the response and statements to.
            control_response: The control response to add to the implemented requirement.
        """
        control_response = control.notes
        pattern = re.compile(SECTION_PATTERN, re.IGNORECASE)
        lines = control_response.split('\n')

        sections_dict = dict()
        current_section_label = None

        for line in lines:
            match = pattern.match(line)

            if match:
                current_section_label = match.group(1)
                sections_dict[current_section_label] = [line]
            elif current_section_label is not None:
                sections_dict[current_section_label].append(line)

        oscal_status = OscalStatus.from_string(control.status)

        if not sections_dict:
            self.add_response_by_status(
                implemented_req, oscal_status, control_response.strip()
            )
        else:
            # process into statements
            implemented_req.statements = list()
            for section_label, section_content in sections_dict.items():
                statement_id = self.get_profile_control_id(
                    f"{implemented_req.control_id}_smt.{section_label}"
                )
                if statement_id is None:
                    continue

                section_content_str = '\n'.join(section_content)
                section_content_str = pattern.sub('', section_content_str)
                statement = self.create_statement(statement_id)
                self.add_response_by_status(
                    statement, oscal_status, section_content_str.strip()
                )
                implemented_req.statements.append(statement)

    def add_response_by_status(
        self, type_with_props, implementation_status, control_response
    ):
        """
        Add the response to the implemented requirement depending on the status.

        Notes: Per OSCAL requirements, any status other than implemented and partial should have
        remarks with justification for the status.
        """

        status_prop = Property(name=IMPLEMENTATION_STATUS, value=implementation_status)
        if (
            implementation_status == OscalStatus.IMPLEMENTED
            or implementation_status == OscalStatus.PARTIAL
        ):
            type_with_props.description = control_response
        else:
            status_prop.remarks = control_response

        type_with_props.props = as_list(type_with_props.props)
        type_with_props.props.append(status_prop)

    def create_statement(self, statement_id, description=""):
        """Create a statement."""
        statement = generate_sample_model(Statement)
        statement.statement_id = statement_id
        if description:
            statement.description = description
        return statement

    def create_control_implementation(self):
        """Get the control implementation for a component."""
        ci = generate_sample_model(ControlImplementation)
        ci.source = self.profile_href
        all_implement_reqs = list()
        for control in self.controls_mgr.get_all_controls(self.policy_id):
            implemented_req = self.create_implemented_requirement(control)
            if implemented_req:
                all_implement_reqs.append(implemented_req)
        ci.implemented_requirements = all_implement_reqs
        return ci

    def create_cd(self, output, component_definition_type="service"):
        """Create a component definition and write it to a file."""
        logger.info(f"Creating component definition for {self.product}")
        component_definition = generate_sample_model(ComponentDefinition)
        component_definition.metadata.title = f"Component definition for {self.product}"
        component_definition.components = list()

        control_implementation = self.create_control_implementation()

        if not control_implementation.implemented_requirements:
            logger.warning(
                f"No implemented requirements found for {self.product}, exiting"
            )
            return

        oscal_component = DefinedComponent(
            uuid=str(uuid.uuid4()),
            title=self.product,
            type=component_definition_type,
            description=self.product,
            control_implementations=[control_implementation],
        )
        component_definition.components.append(oscal_component)

        output_str = output
        out_path = pathlib.Path(output_str)
        logger.info(f"Writing component definition to {out_path}")
        component_definition.oscal_write(out_path)
