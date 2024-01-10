import json

from ssg.build_profile import XCCDFBenchmark


def _count_rules_per_profile(profile, rules):
    for rule in profile.get("rules", []):
        if rule in rules:
            rules[rule] += 1
        else:
            rules[rule] = 1


def _count_rules_per_benchmark(benchmark, rules):
    benchmark = XCCDFBenchmark(benchmark)
    for profile in benchmark.get_all_profile_stats():
        _count_rules_per_profile(profile, rules)


def _sorted_rules(rules):
    sorted_rules = {
        k: v
        for k, v in sorted(rules.items(), key=lambda x: x[1], reverse=True)
    }
    return sorted_rules


def command_most_used_rules(args):
    rules = {}
    for benchmark in args.benchmarks:
        _count_rules_per_benchmark(benchmark, rules)

    sorted_rules = _sorted_rules(rules)

    f_string = "{}: {}"

    if args.format == "json":
        print(json.dumps(sorted_rules, indent=4))
        return
    elif args.format == "csv":
        print("rule_id,count_of_profiles")
        f_string = "{},{}"

    for rule_id, rule_count in sorted_rules.items():
        print(f_string.format(rule_id, rule_count))
