import json

from ssg.build_profile import XCCDFBenchmark
from .profile import get_profile
from ..controleval import (
    load_controls_manager,
    get_available_products,
    get_product_profiles_files,
)


def _count_rules_per_rules_list(rules_list, rules):
    for rule in rules_list:
        if rule in rules:
            rules[rule] += 1
        else:
            rules[rule] = 1


def _count_rules_per_benchmark(benchmark, rules):
    benchmark = XCCDFBenchmark(benchmark)
    for profile in benchmark.get_all_profile_stats():
        _count_rules_per_rules_list(profile.get("rules", []), rules)


def _get_profiles_for_product(ctrls_mgr, product):
    profiles_files = get_product_profiles_files(product)

    profiles = []
    for file in profiles_files:
        profiles.append(get_profile(profiles_files, file, ctrls_mgr.policies))
    return profiles


def _process_all_products_from_controls(rules):
    for product in get_available_products():
        controls_manager = load_controls_manager("./controls/", product)
        for profile in _get_profiles_for_product(controls_manager, product):
            _count_rules_per_rules_list(profile.rules, rules)


def _sorted_rules(rules):
    sorted_rules = {
        k: v
        for k, v in sorted(rules.items(), key=lambda x: x[1], reverse=True)
    }
    return sorted_rules


def command_most_used_rules(args):
    rules = {}

    if not args.BENCHMARKS:
        _process_all_products_from_controls(rules)
    else:
        for benchmark in args.BENCHMARKS:
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
