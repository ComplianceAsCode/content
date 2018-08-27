import json
import collections
import functools
import re
import argparse


@functools.total_ordering
class RuleResult(object):
    def __init__(self, result_dict):
        self.scenario = (result_dict["rule_id"], result_dict["scenario_script"])
        self.conditions = (
            result_dict["backend"], result_dict["scanning_mode"],
            result_dict["remediated_by"])
        self.when = result_dict["run_timestamp"]
        self.passed_stages = result_dict["passed_stages"]

        self.success = result_dict.get("final_scan", False)
        if not self.success:
            self.success = (
                "remediation" not in result_dict
                and result_dict.get("initial_scan", False))

    def relative_conditions_to(self, other):
        if self.conditions == other.conditions:
            return self.when, other.when
        else:
            return self.conditions, other.conditions

    def __eq__(self, other):
        return self.success == other.success and self.passed_stages == self.passed_stages

    def __lt__(self, other):
        return self.passed_stages > other.passed_stages


class Difference(object):
    def __init__(self, what_failed, why_failed, what_not_failed):
        self.what_failed = what_failed
        self.why_failed = why_failed
        self.what_not_failed = what_not_failed

    def __str__(self):
        ret = ("{failed_stage} failed on {failed_config} and not on {good_config}"
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
    return analyze_pair(rules[0], rules[-1])


def analyze_pair(best, other):
    if best == other:
        return None

    if other.passed_stages == 0:
        failure_string = "preparation"
    elif other.passed_stages == 1:
        failure_string = "initial scan"
    elif other.passed_stages == 2:
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
    rules = [RuleResult(r) for r in sum(results, [])]
    ar = aggregate_results_by_scenarios(rules)

    rules_that_ended_same = 0
    rules_that_ended_by_success = 0

    differences = []
    for rule_id, results in ar.items():
        if len(results) < 2:
            if results[0].success:
                rules_that_ended_by_success += 1
            # There won't be differences to analyze
            continue
        difference = analyze_differences(results)
        if difference:
            rule_stem = re.sub(".*content_rule_", "", rule_id[0])
            msg = ("{scenario} in {rule_stem}: {diff}"
                   .format(scenario=rule_id[1], rule_stem=rule_stem, diff=difference))
            differences.append(msg)
        else:
            rules_that_ended_same += 1
            if results[0].success:
                rules_that_ended_by_success += 1

    msg = ("Analyzed {total_count} scenarios.\n"
           "{same_count} ended the same, {success_count} were a success.\n"
           "{different_count} ended differently:"
           .format(total_count=len(ar), same_count=rules_that_ended_same,
                   success_count=rules_that_ended_by_success, different_count=len(differences)))
    print(msg)
    for d in differences:
        print("\t" + d)


def main():
    args = parse_args()
    print_result_differences(args.json_results)


if __name__ == "__main__":
    main()
