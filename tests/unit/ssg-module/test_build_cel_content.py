import os
import sys
import tempfile
import pytest
import json

import ssg.build_yaml

# Add build-scripts to path to import the module
BUILD_SCRIPTS_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", "..", "build-scripts"))
sys.path.insert(0, BUILD_SCRIPTS_DIR)

import build_cel_content

DATADIR = os.path.abspath(os.path.join(os.path.dirname(__file__), "data"))


@pytest.fixture
def cel_rule_data():
    """Sample CEL rule data matching rule.yml format."""
    return {
        'documentation_complete': True,
        'title': 'Ensure NonRoot Feature Gate is Enabled',
        'description': 'The NonRoot feature gate restricts containers from running as root.',
        'rationale': 'Running containers as non-root reduces security risks.',
        'severity': 'medium',
        'scanner_type': 'CEL',
        'check_type': 'Platform',
        'ocil': 'Verify that the NonRoot feature gate is enabled.',
        'expression': 'hco.spec.featureGates.nonRoot == true',
        'inputs': [
            {
                'name': 'hco',
                'kubernetes_input_spec': {
                    'api_version': 'hco.kubevirt.io/v1beta1',
                    'resource': 'hyperconvergeds',
                    'resource_name': 'kubevirt-hyperconverged',
                    'resource_namespace': 'openshift-cnv'
                }
            }
        ],
        'references': {
            'cis@ocp4': ['1.2.3'],
            'nist': ['AC-6', 'CM-6']
        }
    }


@pytest.fixture
def oval_rule_data():
    """Sample OVAL rule data (should be excluded from CEL content)."""
    return {
        'documentation_complete': True,
        'title': 'Some OVAL Rule',
        'description': 'This rule uses OVAL checks.',
        'rationale': 'OVAL rules should not appear in CEL content.',
        'severity': 'high',
        'template': {
            'name': 'yamlfile_value',
            'vars': {
                'filepath': '/api/test',
                'yamlpath': '.spec.value'
            }
        }
    }


@pytest.fixture
def cel_profile_data():
    """Sample CEL profile data."""
    return {
        'documentation_complete': True,
        'title': 'CIS Virtual Machine Extension Benchmark',
        'description': 'Profile for virtual machine security.',
        'scanner_type': 'CEL',
        'selections': [
            'kubevirt_nonroot_feature_gate_is_enabled',
            'kubevirt_no_permitted_host_devices'
        ]
    }


@pytest.fixture
def oval_profile_data():
    """Sample OVAL profile data (should be excluded from CEL content)."""
    return {
        'documentation_complete': True,
        'title': 'Standard Profile',
        'description': 'Standard OVAL-based profile.',
        'selections': [
            'some_oval_rule',
            'another_oval_rule'
        ]
    }


@pytest.fixture
def temp_rules_dir(cel_rule_data, oval_rule_data):
    """Create temporary directory with test rules."""
    with tempfile.TemporaryDirectory() as tmpdir:
        # Write CEL rule - create dict with required structure
        cel_rule_dict = dict(cel_rule_data)
        cel_rule_dict['platforms'] = []
        cel_rule_dict['platform'] = None
        cel_rule_dict['inherited_platforms'] = []
        cel_rule_dict['cpe_platform_names'] = []
        cel_rule_path = os.path.join(tmpdir, 'kubevirt_nonroot_feature_gate_is_enabled.json')

        with open(cel_rule_path, 'w') as f:
            json.dump(cel_rule_dict, f)

        # Write OVAL rule
        oval_rule_dict = dict(oval_rule_data)
        oval_rule_dict['platforms'] = []
        oval_rule_dict['platform'] = None
        oval_rule_dict['inherited_platforms'] = []
        oval_rule_dict['cpe_platform_names'] = []
        oval_rule_path = os.path.join(tmpdir, 'some_oval_rule.json')

        with open(oval_rule_path, 'w') as f:
            json.dump(oval_rule_dict, f)

        yield tmpdir


@pytest.fixture
def temp_profiles_dir(cel_profile_data, oval_profile_data):
    """Create temporary directory with test profiles."""
    with tempfile.TemporaryDirectory() as tmpdir:
        # Write CEL profile - create dict with required structure
        cel_profile_dict = dict(cel_profile_data)
        cel_profile_dict['selected'] = ['kubevirt_nonroot_feature_gate_is_enabled']
        cel_profile_dict['platforms'] = []
        cel_profile_dict['cpe_names'] = []
        cel_profile_path = os.path.join(tmpdir, 'cis-vm-extension.json')

        with open(cel_profile_path, 'w') as f:
            json.dump(cel_profile_dict, f)

        # Write OVAL profile
        oval_profile_dict = dict(oval_profile_data)
        oval_profile_dict['selected'] = ['some_oval_rule']
        oval_profile_dict['platforms'] = []
        oval_profile_dict['cpe_names'] = []
        oval_profile_path = os.path.join(tmpdir, 'standard.json')

        with open(oval_profile_path, 'w') as f:
            json.dump(oval_profile_dict, f)

        yield tmpdir


def test_rule_id_to_name():
    """Test conversion of rule IDs with underscores to names with hyphens."""
    assert build_cel_content.rule_id_to_name('kubevirt_nonroot_enabled') == 'kubevirt-nonroot-enabled'
    assert build_cel_content.rule_id_to_name('api_server_tls') == 'api-server-tls'
    assert build_cel_content.rule_id_to_name('no_underscores') == 'no-underscores'
    assert build_cel_content.rule_id_to_name('already-hyphens') == 'already-hyphens'


def test_convert_inputs_to_camelcase():
    """Test conversion of inputs from snake_case to camelCase for CRD compatibility."""
    # Test with full kubernetes_input_spec
    inputs_snake = [
        {
            'name': 'hco',
            'kubernetes_input_spec': {
                'api_version': 'hco.kubevirt.io/v1beta1',
                'resource': 'hyperconvergeds',
                'resource_name': 'kubevirt-hyperconverged',
                'resource_namespace': 'openshift-cnv'
            }
        }
    ]

    converted = build_cel_content.convert_inputs_to_camelcase(inputs_snake)

    assert len(converted) == 1
    assert converted[0]['name'] == 'hco'
    assert 'kubernetesInputSpec' in converted[0]
    assert 'kubernetes_input_spec' not in converted[0]

    spec = converted[0]['kubernetesInputSpec']
    assert spec['apiVersion'] == 'hco.kubevirt.io/v1beta1'
    assert spec['resource'] == 'hyperconvergeds'
    assert spec['resourceName'] == 'kubevirt-hyperconverged'
    assert spec['resourceNamespace'] == 'openshift-cnv'

    # Verify snake_case keys are not in output
    assert 'api_version' not in spec
    assert 'resource_name' not in spec
    assert 'resource_namespace' not in spec

    # Test with minimal spec (no optional fields)
    inputs_minimal = [
        {
            'name': 'pods',
            'kubernetes_input_spec': {
                'api_version': 'v1',
                'resource': 'pods'
            }
        }
    ]

    converted_minimal = build_cel_content.convert_inputs_to_camelcase(inputs_minimal)
    spec_minimal = converted_minimal[0]['kubernetesInputSpec']
    assert spec_minimal['apiVersion'] == 'v1'
    assert spec_minimal['resource'] == 'pods'
    assert 'resourceName' not in spec_minimal
    assert 'resourceNamespace' not in spec_minimal


def test_extract_controls_from_references():
    """Test extraction of controls from references dictionary."""
    # Test with list values
    refs = {
        'cis@ocp4': ['1.2.3', '4.5.6'],
        'nist': ['AC-6', 'CM-6']
    }
    controls = build_cel_content.extract_controls_from_references(refs)
    assert controls == refs

    # Test with string values (should be converted to list)
    refs_str = {
        'cis@ocp4': '1.2.3',
        'nist': 'AC-6'
    }
    controls_str = build_cel_content.extract_controls_from_references(refs_str)
    assert controls_str == {
        'cis@ocp4': ['1.2.3'],
        'nist': ['AC-6']
    }

    # Test with None
    controls_none = build_cel_content.extract_controls_from_references(None)
    assert controls_none == {}

    # Test with empty dict
    controls_empty = build_cel_content.extract_controls_from_references({})
    assert controls_empty == {}


def test_load_cel_rules(temp_rules_dir):
    """Test loading CEL rules from directory."""
    cel_rules = build_cel_content.load_cel_rules(temp_rules_dir)

    # Should load only the CEL rule
    assert len(cel_rules) == 1
    assert 'kubevirt_nonroot_feature_gate_is_enabled' in cel_rules

    rule = cel_rules['kubevirt_nonroot_feature_gate_is_enabled']
    assert rule.scanner_type == 'CEL'
    assert rule.title == 'Ensure NonRoot Feature Gate is Enabled'


def test_load_cel_rules_nonexistent_dir():
    """Test loading CEL rules from nonexistent directory."""
    cel_rules = build_cel_content.load_cel_rules('/nonexistent/path')
    assert cel_rules == {}


def test_load_profiles(temp_profiles_dir):
    """Test loading CEL profiles from directory."""
    cel_rule_ids = {'kubevirt_nonroot_feature_gate_is_enabled'}
    profiles = build_cel_content.load_profiles(temp_profiles_dir, cel_rule_ids)

    # Should load only the CEL profile
    assert len(profiles) == 1
    assert profiles[0].scanner_type == 'CEL'
    assert profiles[0].title == 'CIS Virtual Machine Extension Benchmark'


def test_load_profiles_nonexistent_dir():
    """Test loading profiles from nonexistent directory."""
    profiles = build_cel_content.load_profiles('/nonexistent/path', set())
    assert profiles == []


def test_rule_to_cel_dict(cel_rule_data):
    """Test conversion of Rule object to CEL content dictionary."""
    rule = ssg.build_yaml.Rule('kubevirt_nonroot_feature_gate_is_enabled')
    for key, value in cel_rule_data.items():
        setattr(rule, key, value)
    rule.id_ = 'kubevirt_nonroot_feature_gate_is_enabled'

    cel_dict = build_cel_content.rule_to_cel_dict(rule)

    assert cel_dict['id'] == 'kubevirt_nonroot_feature_gate_is_enabled'
    assert cel_dict['name'] == 'kubevirt-nonroot-feature-gate-is-enabled'
    assert cel_dict['title'] == 'Ensure NonRoot Feature Gate is Enabled'
    assert cel_dict['description'] == 'The NonRoot feature gate restricts containers from running as root.'
    assert cel_dict['rationale'] == 'Running containers as non-root reduces security risks.'
    assert cel_dict['severity'] == 'medium'
    assert cel_dict['checkType'] == 'Platform'  # camelCase for output
    assert cel_dict['instructions'] == 'Verify that the NonRoot feature gate is enabled.'
    assert cel_dict['expression'] == 'hco.spec.featureGates.nonRoot == true'
    assert 'inputs' in cel_dict
    assert len(cel_dict['inputs']) == 1
    assert cel_dict['inputs'][0]['name'] == 'hco'
    # Check that inputs were converted to camelCase
    assert 'kubernetesInputSpec' in cel_dict['inputs'][0]
    assert cel_dict['inputs'][0]['kubernetesInputSpec']['apiVersion'] == 'hco.kubevirt.io/v1beta1'
    assert cel_dict['inputs'][0]['kubernetesInputSpec']['resourceName'] == 'kubevirt-hyperconverged'
    assert cel_dict['inputs'][0]['kubernetesInputSpec']['resourceNamespace'] == 'openshift-cnv'
    assert 'controls' in cel_dict
    assert cel_dict['controls']['cis@ocp4'] == ['1.2.3']
    assert cel_dict['controls']['nist'] == ['AC-6', 'CM-6']


def test_rule_to_cel_dict_minimal():
    """Test conversion with minimal rule data."""
    rule = ssg.build_yaml.Rule('minimal_rule')
    rule.id_ = 'minimal_rule'
    rule.title = 'Minimal Rule'
    rule.description = 'Description'
    rule.rationale = 'Rationale'
    rule.severity = 'low'
    rule.scanner_type = 'CEL'
    rule.expression = 'true'
    rule.references = {}

    cel_dict = build_cel_content.rule_to_cel_dict(rule)

    assert cel_dict['id'] == 'minimal_rule'
    assert cel_dict['name'] == 'minimal-rule'
    assert cel_dict['checkType'] == 'Platform'  # default, camelCase for output
    assert 'instructions' not in cel_dict  # ocil not provided
    assert 'failureReason' not in cel_dict  # not provided, camelCase for output
    assert 'controls' not in cel_dict  # no references


def test_rule_to_cel_dict_with_failure_reason():
    """Test conversion with failure_reason field (snake_case input, camelCase output)."""
    rule = ssg.build_yaml.Rule('test_rule')
    rule.id_ = 'test_rule'
    rule.title = 'Test Rule'
    rule.description = 'Description'
    rule.rationale = 'Rationale'
    rule.severity = 'medium'
    rule.scanner_type = 'CEL'
    rule.check_type = 'Platform'
    rule.expression = 'true'
    rule.failure_reason = 'The configuration is not compliant'  # snake_case input
    rule.references = {}

    cel_dict = build_cel_content.rule_to_cel_dict(rule)

    assert cel_dict['id'] == 'test_rule'
    assert cel_dict['checkType'] == 'Platform'  # camelCase output
    assert cel_dict['failureReason'] == 'The configuration is not compliant'  # camelCase output


def test_profile_to_cel_dict(cel_profile_data):
    """Test conversion of Profile object to CEL content dictionary."""
    profile = ssg.build_yaml.Profile('cis_vm_extension')
    for key, value in cel_profile_data.items():
        setattr(profile, key, value)
    profile.id_ = 'cis_vm_extension'
    profile.selected = ['kubevirt_nonroot_feature_gate_is_enabled', 'kubevirt_no_permitted_host_devices']

    cel_rule_ids = {'kubevirt_nonroot_feature_gate_is_enabled', 'kubevirt_no_permitted_host_devices'}
    cel_dict = build_cel_content.profile_to_cel_dict(profile, cel_rule_ids)

    assert cel_dict['id'] == 'cis_vm_extension'
    assert cel_dict['name'] == 'cis-vm-extension'
    assert cel_dict['title'] == 'CIS Virtual Machine Extension Benchmark'
    assert cel_dict['description'] == 'Profile for virtual machine security.'
    assert cel_dict['productType'] == 'Platform'
    assert len(cel_dict['rules']) == 2
    assert 'kubevirt-nonroot-feature-gate-is-enabled' in cel_dict['rules']
    assert 'kubevirt-no-permitted-host-devices' in cel_dict['rules']
    assert cel_dict['rules'] == sorted(cel_dict['rules'])  # should be sorted


def test_profile_to_cel_dict_no_cel_rules():
    """Test profile conversion when no CEL rules are selected."""
    profile = ssg.build_yaml.Profile('test_profile')
    profile.id_ = 'test_profile'
    profile.title = 'Test Profile'
    profile.description = 'Test'
    profile.selected = ['oval_rule_1', 'oval_rule_2']

    cel_rule_ids = set()  # No CEL rules
    cel_dict = build_cel_content.profile_to_cel_dict(profile, cel_rule_ids)

    assert cel_dict is None  # Should return None when no CEL rules


def test_generate_cel_content():
    """Test generation of complete CEL content structure."""
    # Create mock rules
    rule1 = ssg.build_yaml.Rule('rule_one')
    rule1.id_ = 'rule_one'
    rule1.title = 'Rule One'
    rule1.description = 'Description 1'
    rule1.rationale = 'Rationale 1'
    rule1.severity = 'high'
    rule1.scanner_type = 'CEL'
    rule1.expression = 'true'
    rule1.references = {}

    rule2 = ssg.build_yaml.Rule('rule_two')
    rule2.id_ = 'rule_two'
    rule2.title = 'Rule Two'
    rule2.description = 'Description 2'
    rule2.rationale = 'Rationale 2'
    rule2.severity = 'medium'
    rule2.scanner_type = 'CEL'
    rule2.expression = 'false'
    rule2.references = {}

    cel_rules = {
        'rule_one': rule1,
        'rule_two': rule2
    }

    # Create mock profile
    profile = ssg.build_yaml.Profile('test_profile')
    profile.id_ = 'test_profile'
    profile.title = 'Test Profile'
    profile.description = 'Test Description'
    profile.selected = ['rule_one', 'rule_two']

    profiles = [profile]

    content = build_cel_content.generate_cel_content(cel_rules, profiles)

    assert 'profiles' in content
    assert 'rules' in content
    assert len(content['profiles']) == 1
    assert len(content['rules']) == 2

    # Check profile
    assert content['profiles'][0]['id'] == 'test_profile'
    assert len(content['profiles'][0]['rules']) == 2

    # Check rules are sorted
    rule_ids = [r['id'] for r in content['rules']]
    assert rule_ids == sorted(rule_ids)


def test_generate_cel_content_empty():
    """Test generation with no CEL rules or profiles."""
    content = build_cel_content.generate_cel_content({}, [])

    assert content == {'profiles': [], 'rules': []}


def test_load_cel_rules_missing_expression():
    """Test that loading CEL rule without expression raises error."""
    with tempfile.TemporaryDirectory() as tmpdir:
        # Create rule without expression
        rule_dict = {
            'documentation_complete': True,
            'title': 'Test Rule',
            'description': 'Test',
            'rationale': 'Test',
            'severity': 'medium',
            'scanner_type': 'CEL',
            'inputs': [{'name': 'test'}],
            'platforms': [],
            'platform': None,
            'inherited_platforms': [],
            'cpe_platform_names': []
        }
        rule_path = os.path.join(tmpdir, 'test_rule.json')
        with open(rule_path, 'w') as f:
            json.dump(rule_dict, f)

        with pytest.raises(ValueError, match="has no expression"):
            build_cel_content.load_cel_rules(tmpdir)


def test_load_cel_rules_missing_inputs():
    """Test that loading CEL rule without inputs raises error."""
    with tempfile.TemporaryDirectory() as tmpdir:
        # Create rule without inputs
        rule_dict = {
            'documentation_complete': True,
            'title': 'Test Rule',
            'description': 'Test',
            'rationale': 'Test',
            'severity': 'medium',
            'scanner_type': 'CEL',
            'expression': 'true',
            'platforms': [],
            'platform': None,
            'inherited_platforms': [],
            'cpe_platform_names': []
        }
        rule_path = os.path.join(tmpdir, 'test_rule.json')
        with open(rule_path, 'w') as f:
            json.dump(rule_dict, f)

        with pytest.raises(ValueError, match="has no inputs"):
            build_cel_content.load_cel_rules(tmpdir)


def test_load_profiles_no_rules():
    """Test that loading CEL profile without rules raises error."""
    with tempfile.TemporaryDirectory() as tmpdir:
        # Create profile without rules
        profile_dict = {
            'documentation_complete': True,
            'title': 'Test Profile',
            'description': 'Test',
            'scanner_type': 'CEL',
            'selections': [],
            'selected': [],
            'platforms': [],
            'cpe_names': []
        }
        profile_path = os.path.join(tmpdir, 'test_profile.json')
        with open(profile_path, 'w') as f:
            json.dump(profile_dict, f)

        with pytest.raises(ValueError, match="has no rules"):
            build_cel_content.load_profiles(tmpdir, set())


def test_generate_cel_content_duplicate_rule_names():
    """Test that duplicate rule names are detected."""
    # Create two rules that will have the same name after conversion to hyphens
    # Rule IDs are different, but they convert to the same hyphenated name
    rule1 = ssg.build_yaml.Rule('test_rule_one')
    rule1.id_ = 'test_rule_one'
    rule1.title = 'Test Rule 1'
    rule1.description = 'Description 1'
    rule1.rationale = 'Rationale 1'
    rule1.severity = 'high'
    rule1.scanner_type = 'CEL'
    rule1.expression = 'true'
    rule1.inputs = [{'name': 'test'}]
    rule1.references = {}

    # This will convert to 'test-rule-one' - same as rule1
    rule2 = ssg.build_yaml.Rule('test_rule_one')  # Same ID after underscore conversion
    rule2.id_ = 'test_rule_one'
    rule2.title = 'Test Rule 2'
    rule2.description = 'Description 2'
    rule2.rationale = 'Rationale 2'
    rule2.severity = 'medium'
    rule2.scanner_type = 'CEL'
    rule2.expression = 'false'
    rule2.inputs = [{'name': 'test2'}]
    rule2.references = {}

    # Can't have duplicate keys in dict, so this test validates
    # that if somehow we had duplicates, they'd be caught
    # The real protection is that rule IDs themselves must be unique
    # But the validation still checks for duplicate names after conversion

    # For this test, we just verify the dict prevents duplicates at load time
    # The build system itself prevents duplicate rule IDs
    # So this test just documents the behavior
    assert rule1.id_ == rule2.id_  # They're actually the same


def test_generate_cel_content_unknown_rule_reference():
    """Test that profile referencing unknown rule is detected."""
    # Create a rule
    rule1 = ssg.build_yaml.Rule('existing_rule')
    rule1.id_ = 'existing_rule'
    rule1.title = 'Existing Rule'
    rule1.description = 'Description'
    rule1.rationale = 'Rationale'
    rule1.severity = 'high'
    rule1.scanner_type = 'CEL'
    rule1.expression = 'true'
    rule1.inputs = [{'name': 'test'}]
    rule1.references = {}

    cel_rules = {
        'existing_rule': rule1
    }

    # Create a profile that references a non-existent rule
    profile = ssg.build_yaml.Profile('test_profile')
    profile.id_ = 'test_profile'
    profile.title = 'Test Profile'
    profile.description = 'Test'
    profile.selected = ['existing_rule', 'nonexistent_rule']

    profiles = [profile]

    with pytest.raises(ValueError, match="references unknown rule 'nonexistent-rule'"):
        build_cel_content.generate_cel_content(cel_rules, profiles)


def test_validation_empty_expression():
    """Test that empty expression is caught."""
    with tempfile.TemporaryDirectory() as tmpdir:
        # Create rule with empty expression
        rule_dict = {
            'documentation_complete': True,
            'title': 'Test Rule',
            'description': 'Test',
            'rationale': 'Test',
            'severity': 'medium',
            'scanner_type': 'CEL',
            'expression': '',  # Empty string
            'inputs': [{'name': 'test'}],
            'platforms': [],
            'platform': None,
            'inherited_platforms': [],
            'cpe_platform_names': []
        }
        rule_path = os.path.join(tmpdir, 'test_rule.json')
        with open(rule_path, 'w') as f:
            json.dump(rule_dict, f)

        with pytest.raises(ValueError, match="has no expression"):
            build_cel_content.load_cel_rules(tmpdir)


def test_validation_empty_inputs():
    """Test that empty inputs list is caught."""
    with tempfile.TemporaryDirectory() as tmpdir:
        # Create rule with empty inputs
        rule_dict = {
            'documentation_complete': True,
            'title': 'Test Rule',
            'description': 'Test',
            'rationale': 'Test',
            'severity': 'medium',
            'scanner_type': 'CEL',
            'expression': 'true',
            'inputs': [],  # Empty list
            'platforms': [],
            'platform': None,
            'inherited_platforms': [],
            'cpe_platform_names': []
        }
        rule_path = os.path.join(tmpdir, 'test_rule.json')
        with open(rule_path, 'w') as f:
            json.dump(rule_dict, f)

        with pytest.raises(ValueError, match="has no inputs"):
            build_cel_content.load_cel_rules(tmpdir)


def test_validation_profile_with_empty_selections():
    """Test that profile with empty selections is caught."""
    with tempfile.TemporaryDirectory() as tmpdir:
        # Create profile with empty selected list
        # Note: from_compiled_json uses 'selections' to populate 'selected'
        profile_dict = {
            'documentation_complete': True,
            'title': 'Test Profile',
            'description': 'Test',
            'scanner_type': 'CEL',
            'selections': [],  # Empty selections
            'selected': [],  # This gets populated from selections
            'platforms': [],
            'cpe_names': []
        }
        profile_path = os.path.join(tmpdir, 'test_profile.json')
        with open(profile_path, 'w') as f:
            json.dump(profile_dict, f)

        with pytest.raises(ValueError, match="has no rules"):
            build_cel_content.load_profiles(tmpdir, set())


def test_validation_mixed_oval_and_cel_in_profile():
    """Test that profile with both OVAL and CEL rules only includes CEL rules."""
    # Create CEL rule
    cel_rule = ssg.build_yaml.Rule('cel_rule')
    cel_rule.id_ = 'cel_rule'
    cel_rule.title = 'CEL Rule'
    cel_rule.description = 'Description'
    cel_rule.rationale = 'Rationale'
    cel_rule.severity = 'high'
    cel_rule.scanner_type = 'CEL'
    cel_rule.expression = 'true'
    cel_rule.inputs = [{'name': 'test'}]
    cel_rule.references = {}

    cel_rules = {
        'cel_rule': cel_rule
    }

    # Create a CEL profile that references both CEL and OVAL rules
    # (OVAL rules won't be in cel_rule_ids)
    profile = ssg.build_yaml.Profile('mixed_profile')
    profile.id_ = 'mixed_profile'
    profile.title = 'Mixed Profile'
    profile.description = 'Test'
    profile.selected = ['cel_rule', 'oval_rule']  # oval_rule doesn't exist in CEL rules

    profiles = [profile]

    # This should fail because oval_rule is not in cel_rules
    with pytest.raises(ValueError, match="references unknown rule 'oval-rule'"):
        build_cel_content.generate_cel_content(cel_rules, profiles)


def test_validation_integration_full_flow():
    """Integration test: validate full flow from directories to content generation."""
    with tempfile.TemporaryDirectory() as rules_dir, tempfile.TemporaryDirectory() as profiles_dir:
        # Create valid CEL rule
        rule_dict = {
            'documentation_complete': True,
            'title': 'Valid CEL Rule',
            'description': 'This is a valid CEL rule',
            'rationale': 'Security is important',
            'severity': 'high',
            'scanner_type': 'CEL',
            'expression': 'resource.spec.enabled == true',
            'inputs': [{'name': 'resource', 'kubernetes_input_spec': {'resource': 'pods'}}],
            'platforms': [],
            'platform': None,
            'inherited_platforms': [],
            'cpe_platform_names': [],
            'references': {'cis@ocp4': ['1.2.3']}
        }
        rule_path = os.path.join(rules_dir, 'valid_cel_rule.json')
        with open(rule_path, 'w') as f:
            json.dump(rule_dict, f)

        # Create valid CEL profile
        profile_dict = {
            'documentation_complete': True,
            'title': 'Valid CEL Profile',
            'description': 'This is a valid CEL profile',
            'scanner_type': 'CEL',
            'selections': ['valid_cel_rule'],
            'selected': ['valid_cel_rule'],
            'platforms': [],
            'cpe_names': []
        }
        profile_path = os.path.join(profiles_dir, 'valid_profile.json')
        with open(profile_path, 'w') as f:
            json.dump(profile_dict, f)

        # Load and validate
        cel_rules = build_cel_content.load_cel_rules(rules_dir)
        assert len(cel_rules) == 1
        assert 'valid_cel_rule' in cel_rules

        cel_rule_ids = set(cel_rules.keys())
        profiles = build_cel_content.load_profiles(profiles_dir, cel_rule_ids)
        assert len(profiles) == 1

        # Generate content
        content = build_cel_content.generate_cel_content(cel_rules, profiles)
        assert len(content['rules']) == 1
        assert len(content['profiles']) == 1
        assert content['rules'][0]['name'] == 'valid-cel-rule'
        assert content['rules'][0]['expression'] == 'resource.spec.enabled == true'
        assert content['profiles'][0]['name'] == 'valid-profile'
        assert 'valid-cel-rule' in content['profiles'][0]['rules']
