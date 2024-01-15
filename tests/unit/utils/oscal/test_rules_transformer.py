import os
import pytest
from typing import Any, Dict, List

from trestle.oscal.common import Property


from ssg.environment import open_environment
from ssg.products import product_yaml_path

from utils.oscal.params_extractor import ParameterExtractor, ParamInfo
from utils.oscal.rules_transformer import RulesTransformer, RuleInfo


DATADIR = os.path.join(os.path.dirname(__file__), "data")
TEST_ROOT = os.path.abspath(os.path.join(DATADIR, "test_root"))
TEST_BUILD_CONFIG = os.path.join(DATADIR, "build-config.yml")
TEST_RULE_JSON = os.path.join(DATADIR, "rule_dirs.json")
TEST_PRODUCT = "test_product"


@pytest.fixture(scope="function")
def env_yaml() -> Dict[str, Any]:
    """Return the environment yaml."""
    product_yaml = product_yaml_path(TEST_ROOT, TEST_PRODUCT)
    return open_environment(
        TEST_BUILD_CONFIG,
        product_yaml,
        os.path.join(TEST_ROOT, "product_properties"),
    )


@pytest.fixture(scope="function")
def test_rule_objs() -> List[RuleInfo]:
    """Create a set of test rules."""
    rule_with_parameter = RuleInfo(rule_id="rule_1", rule_dir="rule_dir")
    rule_with_parameter.add_description("Rule 1 description")
    test_parameter = ParamInfo(
        param_id="var_test",
        description="Test parameter",
    )
    test_parameter.set_selected_value("default")
    test_parameter.set_options({"default": "default", "alternate": "alternate"})
    rule_with_parameter.add_parameter(test_parameter)
    rule_with_no_parameter = RuleInfo(
        rule_id="rule_2",
        rule_dir="rule_dir",
    )
    rule_with_no_parameter.add_description("Rule 2 description")
    return [rule_with_parameter, rule_with_no_parameter]


def test_rule_transformer_load(env_yaml: Dict[str, Any]) -> None:
    """Test loading rules from a set of rules ids."""
    transformer = RulesTransformer(
        TEST_ROOT,
        env_yaml,
        TEST_RULE_JSON,
        ParameterExtractor(TEST_ROOT, env_yaml),
    )
    transformer.add_rules(["rule_1", "rule_2"])
    rule_objs = transformer.get_all_rules()

    assert len(rule_objs) == 2
    assert rule_objs[0].id == "rule_1"
    assert (
        rule_objs[0].description
        == "This is a rule with a template example. It has two lines."
    )
    assert rule_objs[0].parameters is not None
    assert rule_objs[0].parameters[0].id == "var_test"
    assert rule_objs[0].parameters[0].description == "This is a test variable."
    assert rule_objs[0].parameters[0].selected_value == "default"
    assert rule_objs[0].parameters[0].options == {
        "default": "default",
        "alt": "alternate",
    }
    assert rule_objs[1].id == "rule_2"
    assert rule_objs[1].description == "This is a rule with no template."
    assert not rule_objs[1].parameters


def test_rule_transformer_load_with_param(env_yaml: Dict[str, Any]) -> None:
    """Test loading rules from a set of rules ids with a parameter override."""
    transformer = RulesTransformer(
        TEST_ROOT,
        env_yaml,
        TEST_RULE_JSON,
        ParameterExtractor(TEST_ROOT, env_yaml),
    )
    transformer.add_rules(
        [
            "rule_1",
            "rule_2",
        ],
        {"var_test": "alternate"},
    )
    rule_objs = transformer.get_all_rules()

    assert len(rule_objs) == 2
    assert rule_objs[0].id == "rule_1"
    assert rule_objs[0].parameters is not None
    assert rule_objs[0].parameters[0].id == "var_test"
    assert rule_objs[0].parameters[0].selected_value == "alternate"
    assert rule_objs[1].id == "rule_2"
    assert not rule_objs[1].parameters


def test_rules_transformer_transform(
    test_rule_objs: List[RuleInfo], env_yaml: Dict[str, Any]
) -> None:
    """Test transforming a set of rules into properties."""
    transformer = RulesTransformer(
        TEST_ROOT,
        env_yaml,
        TEST_RULE_JSON,
        ParameterExtractor(TEST_ROOT, env_yaml),
    )
    props = transformer.transform(test_rule_objs)

    assert len(props) == 7

    # Verify there are two rule sets
    rulesets: Dict[str, List[Property]] = dict()
    for prop in props:
        if prop.remarks not in rulesets:
            rulesets[prop.remarks] = []  # type: ignore
        rulesets[prop.remarks].append(prop)  # type: ignore

    assert len(rulesets) == 2

    set1_props: List[Property] = next(
        (rulesets[ruleset] for ruleset in rulesets.keys() if ruleset == "rule_set_0"),
        [],
    )

    assert len(set1_props) == 5
    prop_names = [prop.name for prop in set1_props]
    expected_prop_names = [
        "Rule_Id",
        "Rule_Description",
        "Parameter_Id",
        "Parameter_Description",
        "Parameter_Value_Alternatives",
    ]
    assert sorted(prop_names) == sorted(expected_prop_names)
    prop_values = [prop.value for prop in set1_props]
    expected_prop_values = [
        "rule_1",
        "Rule 1 description",
        "var_test",
        "Test parameter",
        "{'default': 'default', 'alternate': 'alternate'}",
    ]
    assert sorted(prop_values) == sorted(expected_prop_values)

    set2_props: List[Property] = next(
        (rulesets[ruleset] for ruleset in rulesets.keys() if ruleset == "rule_set_1"),
        [],
    )

    assert len(set2_props) == 2
    prop_names = [prop.name for prop in set2_props]
    expected_prop_names = [
        "Rule_Id",
        "Rule_Description",
    ]
    assert sorted(prop_names) == sorted(expected_prop_names)
    prop_values = [prop.value for prop in set2_props]
    expected_prop_values = [
        "rule_2",
        "Rule 2 description",
    ]
    assert sorted(prop_values) == sorted(expected_prop_values)
