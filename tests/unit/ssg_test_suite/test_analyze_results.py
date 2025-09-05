import json
import os

import pytest

from ssg_test_suite import common
import analyze_results as analyze


@pytest.fixture
def raw_results():
    return json.load(open(os.path.join(os.path.dirname(__file__), "data", "rules.json"), "r"))


@pytest.fixture
def results_list(raw_results):
    return [common.RuleResult(r) for r in raw_results.values()]


@pytest.fixture
def different_results(raw_results):
    return [common.RuleResult(raw_results[key])
            for key in ("container_failed_remediation", "vm_passed_everything")]


def test_success(raw_results):
    rule_ok = common.RuleResult(raw_results["vm_passed_everything"])
    assert rule_ok.success

    rule_not_ok = common.RuleResult(raw_results["container_failed_remediation"])
    assert not rule_not_ok.success


def test_aggregation(results_list):
    aggregated = analyze.aggregate_results_by_scenarios(results_list)
    assert len(aggregated) == 3


def test_differences(different_results):
    assert sorted(different_results)[0].success

    difference = analyze.analyze_differences(different_results)
    assert difference.why_failed == "remediation"


def test_persistence(raw_results):
    for r in raw_results.values():
        intermediate = common.RuleResult(r)
        assert r == intermediate.save_to_dict()
