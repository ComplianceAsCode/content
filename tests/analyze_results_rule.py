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
        aggregated[result.run].append(result)
    return aggregated


def analyze_differences(rules):
    rules = sorted(rules)
    # For the time being, support only comparison of two results -
    # compare the best one and the worst one
    diffs = analyze_pair(rules[0], rules[-1])
    return diffs


def get_failure_string(passed_stages_count):
    if passed_stages_count < common.Stage.PREPARATION:
        failure_string = "preparation"
    elif passed_stages_count < common.Stage.INITIAL_SCAN:
        failure_string = "initial scan"
    elif passed_stages_count < common.Stage.REMEDIATION:
        failure_string = "remediation"
    else:
        failure_string = "final scan"
    return failure_string


def analyze_pair(best, other):
    if best == other:
        return None

    failure_string = get_failure_string(other.passed_stages_count)
    good_conditions, bad_conditions = best.relative_conditions_to(other)

    return Difference(bad_conditions, failure_string, good_conditions)


def parse_args():
    parser = argparse.ArgumentParser("Rule-based scan result analysis/comparison.")
    parser.add_argument("json_results", nargs="+")
    return parser.parse_args()


def print_result_differences(results):
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
            rule_stem = common.shorten_rule_id(scenario.rule_id)
            msg = ("{scenario} in {rule_stem}: {diff}"
                   .format(scenario=scenario.name, rule_stem=rule_stem, diff=difference))
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


def sum_up_result(results):
    results = [common.RuleResult(r) for r in results]

    total_count = len(results)
    success_count = 0
    failed_in = collections.defaultdict(set)
    for result in results:
        if result.success:
            success_count += 1
        else:
            failed_in[get_failure_string(result.passed_stages_count)].add(result.name)

    print("Of {total} scenarios, {success} succeeded and {fail} failed"
          .format(total=total_count, success=success_count, fail=total_count - success_count))
    print()

    for failing_stage, scenarios in failed_in.items():
        print("{stage}: {failed} failed scenarios"
              .format(stage=failing_stage, failed=len(scenarios)))
        for s in scenarios:
            print(" - {scenario} in {stem}"
                  .format(scenario=s.name, stem=common.shorten_rule_id(s.rule_id)))
        print()


def main():
    args = parse_args()
    results = [json.load(open(fname, "r")) for fname in args.json_results]
    if len(results) > 1:
        print_result_differences(results)
    else:
        sum_up_result(results[0])


if __name__ == "__main__":
    main()
