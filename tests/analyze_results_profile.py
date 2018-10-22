#!/usr/bin/env python

from __future__ import print_function

import json
import collections
import argparse

from ssg_test_suite import common


set_dict = collections.defaultdict(set)


def aggregate_results_by_scenarios(rule_results):
    aggregated = collections.defaultdict(list)
    for result in rule_results:
        aggregated[result.run].append(result)
    return aggregated


def parse_args():
    parser = argparse.ArgumentParser("Profile-based scan result analysis/comparison.")
    parser.add_argument("json_results", nargs="+")
    parser.add_argument("--stage")
    return parser.parse_args()


def summarize_results(results, aggregated_results):
    rules_that_ended_by_success = 0
    for r in results:
        if r.success:
            rules_that_ended_by_success += 1

    msg = ("Analyzed {total_count} rules. Of those, "
           "{success_count} were not a failiure of some kind.\n"
           .format(total_count=len(results),
                   success_count=rules_that_ended_by_success))
    print(msg)

    for stage, results in aggregated_results.items():
        msg = "*** {stage} ***".format(stage=stage)
        print(msg)

        for status, rules in results.items():
            msg = ("{status}: {count}\t"  # {rules}"
                   .format(status=status, count=len(rules), rules=" ".join(rules)))
            print(msg)
        print()


def summarize_differences(ar1, ar2, stage=None):
    if stage:
        stages = [stage]
    else:
        stages = ar1.keys()

    for stage in stages:
        results1 = ar1[stage]
        results2 = ar2[stage]

        status_by_rules2 = dict()
        for status, rules2 in results2.items():
            for r in rules2:
                status_by_rules2[r] = status

        msg = "*** stage {stage} ***".format(stage=stage)
        print(msg)

        for status, rules1 in results1.items():
            rules2 = results2[status]

            rules_of_different_status = rules1.difference(rules2)
            new_status_by_rules = {r: status_by_rules2[r] for r in rules_of_different_status}

            msg = ("{status}: {num_changed} changed the status:"
                   .format(status=status, num_changed=len(new_status_by_rules)))
            print(msg)

            for r, new in new_status_by_rules.items():
                msg = "\t- {rid} -> {new}".format(rid=r, new=new)
                print(msg)
        print()


def aggregate_results_by_stage(rules):
    aggregated_results = dict(
        initial_scan=collections.defaultdict(set),
        final_scan=collections.defaultdict(set))

    for r in rules:
        rule_stem = common.shorten_rule_id(r.run.rule_id)
        for stage, status in r.passed_stages.items():
            if stage in aggregated_results:
                aggregated_results[stage][status].add(rule_stem)

    return aggregated_results


def analyze_results(json_results, stage):
    results = [json.load(open(fname, "r")) for fname in json_results]
    rules = [[common.ProfileResult(r) for r in r_list] for r_list in results]
    ar = [aggregate_results_by_stage(r) for r in rules]

    if len(ar) == 2:
        summarize_differences(ar[0], ar[1], stage)
    elif len(ar) == 1:
        summarize_results(rules[0], ar[0])


def main():
    args = parse_args()
    analyze_results(args.json_results, args.stage)


if __name__ == "__main__":
    main()
