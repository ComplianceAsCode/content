#!/usr/bin/env python

import json
import collections
import re
import argparse

from ssg_test_suite import common


class Difference(object):
    def __init__(self, what_failed, why_failed, what_not_failed):
        self.what_failed = what_failed
        self.why_failed = why_failed
        self.what_not_failed = what_not_failed

    def __str__(self):
        ret = ("failed {failed_stage}\n\t\tfailed on {failed_config}\n\t\tpassed on {good_config}"
               .format(
                   failed_stage=self.why_failed, failed_config=self.what_failed,
                   good_config=self.what_not_failed))
        return ret


def aggregate_results_by_scenarios(rule_results):
    aggregated = collections.defaultdict(list)
    for result in rule_results:
        aggregated[result.scenario].append(result)
    return aggregated


def analyze_differences(rules):
    rules = sorted(rules)
    # For the time being, support only comparison of two results -
    # compare the best one and the worst one
    return analyze_pair(rules[0], rules[-1])


def analyze_pair(best, other):
    if best == other:
        return None

    if other.passed_stages_count < common.Stage.PREPARATION:
        failure_string = "preparation"
    elif other.passed_stages_count < common.Stage.INITIAL_SCAN:
        failure_string = "initial scan"
    elif other.passed_stages_count < common.Stage.REMEDIATION:
        failure_string = "remediation"
    else:
        failure_string = "final scan"

    good_conditions, bad_conditions = best.relative_conditions_to(other)

    return Difference(bad_conditions, failure_string, good_conditions)


def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("json_results", nargs="+")
    return parser.parse_args()


def print_result_differences(json_results):
    results = [json.load(open(fname, "r")) for fname in json_results]
    rules = [common.RuleResult(r) for r in sum(results, [])]
    aggregated_results = aggregate_results_by_scenarios(rules)

    # Number of scenarios that ended the same way
    # despite testing conditions may have been different.
    rules_that_ended_same = 0
    # Number of scenarios that succeeded regardless of different conditions
    rules_that_ended_by_success = 0

    differences = []
    for scenario, results in aggregated_results.items():
        if len(results) < 2:
            if results[0].success:
                rules_that_ended_by_success += 1
            # At most one scenario => no difference analysis is applicable.
            continue
        difference = analyze_differences(results)
        if difference:
            rule_stem = re.sub("xccdf_org.ssgproject.content_rule_(.+)", r"\1", scenario.rule_id)
            assert len(rule_stem) < len(scenario.rule_id), (
                "The rule ID '{rule_id}' has a strange form, as it doesn't have "
                "the common rule prefix.".format(rule_id=scenario.rule_id))
            msg = ("{scenario} in {rule_stem}: {diff}"
                   .format(scenario=scenario.script, rule_stem=rule_stem, diff=difference))
            differences.append(msg)
        else:
            rules_that_ended_same += 1
            if results[0].success:
                rules_that_ended_by_success += 1

    msg = ("Analyzed {total_count} scenarios. Of those,\n"
           "\t{same_count} ended the same,\n\t{success_count} were a success.\n\n"
           "{different_count} ended differently:"
           .format(total_count=len(aggregated_results), same_count=rules_that_ended_same,
                   success_count=rules_that_ended_by_success, different_count=len(differences)))
    print(msg)
    for d in differences:
        print("\t" + d)

    return len(aggregated_results) == rules_that_ended_by_success


def main():
    args = parse_args()
    print_result_differences(args.json_results)


if __name__ == "__main__":
    main()
