import sys

from ssg.build_profile import XCCDFBenchmark

from .common import generate_output


PYTHON_2 = sys.version_info[0] < 3

if not PYTHON_2:
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
    if PYTHON_2:
        raise Exception("This feature is not supported for python2.")

    for product in get_available_products():
        controls_manager = load_controls_manager("./controls/", product)
        for profile in _get_profiles_for_product(controls_manager, product):
            _count_rules_per_rules_list(profile.rules, rules)


def _sorted_dict_by_num_value(dict_):
    sorted_ = {k: v for k, v in sorted(dict_.items(), key=lambda x: x[1], reverse=True)}
    return sorted_


def command_most_used_rules(args):
    rules = {}

    if not args.BENCHMARKS:
        _process_all_products_from_controls(rules)
    else:
        for benchmark in args.BENCHMARKS:
            _count_rules_per_benchmark(benchmark, rules)

    sorted_rules = _sorted_dict_by_num_value(rules)
    csv_header = "rule_id,count_of_profiles"
    generate_output(sorted_rules, args.format, csv_header)
