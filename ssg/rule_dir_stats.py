"""
This module contains common code shared by utils/rule_dir_stats.py and
utils/rule_dir_diff.py. This code includes functions for walking the output
of the utils/rule_dir_json.py script, and filtering functions used in both
scripts.
"""

from __future__ import absolute_import
from __future__ import print_function

import os
from collections import defaultdict

from .build_remediations import REMEDIATION_TO_EXT_MAP as REMEDIATION_MAP
from .utils import subset_dict


def get_affected_products(rule_obj):
    """
    From a rule_obj, return the set of affected products from rule.yml
    """
    return set(rule_obj['products'])


def get_all_affected_products(args, rule_obj):
    """
    From a rule_obj, return the set of affected products from rule.yml, and
    all fixes and checks.

    If args.strict is set, this function is equivalent to
    get_affected_products. Otherwise, it includes ovals and fix content based
    on the values of args.fixes_only and args.ovals_only.
    """

    affected_products = get_affected_products(rule_obj)

    if args.strict:
        return affected_products

    if not args.fixes_only:
        for product in rule_obj['oval_products']:
            affected_products.add(product)

    if not args.ovals_only:
        for product in rule_obj['remediation_products']:
            affected_products.add(product)

    return affected_products


def _walk_rule(args, rule_obj, oval_func, remediation_func, verbose_output):
    """
    Walks a single rule and updates verbose_output if visited. Returns visited
    state as a boolean.

    Internal function for walk_rules and walk_rules_parallel.
    """

    rule_id = rule_obj['id']

    affected_products = get_all_affected_products(args, rule_obj)
    if not affected_products.intersection(args.products):
        return False
    if args.query and rule_id not in args.query:
        return False

    if not args.fixes_only:
        result = oval_func(rule_obj)
        if result:
            verbose_output[rule_id]['oval'] = result

    if not args.ovals_only:
        for r_type in REMEDIATION_MAP:
            result = remediation_func(rule_obj, r_type)
            if result:
                verbose_output[rule_id][r_type] = result

    return True


def walk_rules(args, known_rules, oval_func, remediation_func):
    """
    Walk a dictionary of known_rules, returning the number of visited rules
    and the output at each visited rule, conditionally calling oval_func and
    remediation_func based on the values of args.fixes_only and
    args.ovals_only. If the result of these functions are not Falsy, set the
    appropriate output content.

    The input rule_obj structure is the value of known_rules[rule_id].

    The output structure is a dict as follows:
    {
        rule_id: {
            "oval": oval_func(args, rule_obj),
            "ansible": remediation_func(args, "ansible", rule_obj),
            "anaconda": remediation_func(args, "anaconda", rule_obj),
            "bash": remediation_func(args, "bash", rule_obj),
            "puppet": remediation_func(args, "puppet", rule_obj)
        },
        ...
    }

    The arguments supplied to oval_func are args and rule_obj.
    The arguments supplied to remediation_func are args, the remediation type,
    and rule_obj.
    """

    affected_rules = 0
    verbose_output = defaultdict(lambda: defaultdict(lambda: None))

    for rule_id in known_rules:
        rule_obj = known_rules[rule_id]
        if _walk_rule(args, rule_obj, oval_func, remediation_func, verbose_output):
            affected_rules += 1

    return affected_rules, verbose_output


def walk_rule_stats(rule_output):
    """
    Walk the output of a rule, generating statistics about affected
    ovals, remediations, and generating verbose output in a stable order.

    Returns a tuple of (affected_ovals, affected_remediations,
    all_affected_remediations, affected_remediations_type, all_output)
    """

    affected_ovals = 0
    affected_remediations = 0
    all_affected_remediations = 0
    affected_remediations_type = defaultdict(lambda: 0)
    all_output = []

    affected_remediation = False
    all_remedation = True

    if 'oval' in rule_output:
        affected_ovals += 1
        all_output.append(rule_output['oval'])

    for r_type in sorted(REMEDIATION_MAP):
        if r_type in rule_output:
            affected_remediation = True
            affected_remediations_type[r_type] += 1
            all_output.append(rule_output[r_type])
        else:
            all_remedation = False

    if affected_remediation:
        affected_remediations += 1
    if all_remedation:
        all_affected_remediations += 1

    return (affected_ovals, affected_remediations, all_affected_remediations,
            affected_remediations_type, all_output)


def walk_rules_stats(args, known_rules, oval_func, remediation_func):
    """
    Walk a dictionary of known_rules and generate simple aggregate statistics
    for all visited rules. The oval_func and remediation_func arguments behave
    according to walk_rules().

    Returned values are visited_rules, affected_ovals, affected_remediation,
    a dictionary containing all fix types and the quantity of affected fixes,
    and the ordered output of all functions.

    An effort is made to provide consistently ordered verbose_output by
    sorting all visited keys and the keys of
    ssg.build_remediations.REMEDIATION_MAP.
    """
    affected_rules, verbose_output = walk_rules(args, known_rules, oval_func, remediation_func)

    affected_ovals = 0
    affected_remediations = 0
    all_affected_remediations = 0
    affected_remediations_type = defaultdict(lambda: 0)
    all_output = []

    for rule_id in sorted(verbose_output):
        rule_output = verbose_output[rule_id]
        results = walk_rule_stats(rule_output)

        affected_ovals += results[0]
        affected_remediations += results[1]
        all_affected_remediations += results[2]
        for key in results[3]:
            affected_remediations_type[key] += results[3][key]

        all_output.extend(results[4])

    return (affected_rules, affected_ovals, affected_remediations,
            all_affected_remediations, affected_remediations_type, all_output)


def walk_rules_parallel(args, left_rules, right_rules, oval_func, remediation_func):
    """
    Walks two sets of known_rules (left_rules and right_rules) with identical
    keys and returns left_only, right_only, and common_only output from
    _walk_rule. If the outputted data for a rule when called on left_rules and
    right_rules is the same, it is added to common_only. Only rules which
    output different data will have their data added to left_only and
    right_only respectively.

    Can assert.
    """

    left_affected_rules = 0
    right_affected_rules = 0
    common_affected_rules = 0

    left_verbose_output = defaultdict(lambda: defaultdict(lambda: None))
    right_verbose_output = defaultdict(lambda: defaultdict(lambda: None))
    common_verbose_output = defaultdict(lambda: defaultdict(lambda: None))

    assert set(left_rules) == set(right_rules)

    for rule_id in left_rules:
        left_rule_obj = left_rules[rule_id]
        right_rule_obj = right_rules[rule_id]

        if left_rule_obj == right_rule_obj:
            if _walk_rule(args, left_rule_obj, oval_func, remediation_func, common_verbose_output):
                common_affected_rules += 1
        else:
            left_temp = defaultdict(lambda: defaultdict(lambda: None))
            right_temp = defaultdict(lambda: defaultdict(lambda: None))

            left_ret = _walk_rule(args, left_rule_obj, oval_func, remediation_func, left_temp)
            right_ret = _walk_rule(args, right_rule_obj, oval_func, remediation_func, right_temp)

            if left_ret == right_ret and left_temp == right_temp:
                common_verbose_output.update(left_temp)
                if left_ret:
                    common_affected_rules += 1
            else:
                left_verbose_output.update(left_temp)
                right_verbose_output.update(right_temp)
                if left_ret:
                    left_affected_rules += 1
                if right_ret:
                    right_affected_rules += 1

    left_only = (left_affected_rules, left_verbose_output)
    right_only = (right_affected_rules, right_verbose_output)
    common_only = (common_affected_rules, common_verbose_output)

    return left_only, right_only, common_only


def walk_rules_diff(args, left_rules, right_rules, oval_func, remediation_func):
    """
    Walk a two dictionary of known_rules (left_rules and right_rules) and generate
    five sets of output: left_only rules output, right_only rules output,
    shared left output, shared right output, and shared common output, as a
    five-tuple, where each tuple element is equivalent to walk_rules on the
    appropriate set of rules.

    Does not understand renaming of rule_ids as this would depend on disk
    content to reflect these differences. Unless significantly more data is
    added to the rule_obj structure (contents of rule.yml, ovals,
    remediations, etc.), all information besides 'title' is not uniquely
    identifying or could be easily updated.
    """

    left_rule_ids = set(left_rules)
    right_rule_ids = set(right_rules)

    left_only_rule_ids = left_rule_ids.difference(right_rule_ids)
    right_only_rule_ids = right_rule_ids.difference(left_rule_ids)
    common_rule_ids = left_rule_ids.intersection(right_rule_ids)

    left_restricted = subset_dict(left_rules, left_only_rule_ids)
    left_common = subset_dict(left_rules, common_rule_ids)
    right_restricted = subset_dict(right_rules, right_only_rule_ids)
    right_common = subset_dict(right_rules, common_rule_ids)

    left_only_data = walk_rules(args, left_restricted, oval_func, remediation_func)
    right_only_data = walk_rules(args, right_restricted, oval_func, remediation_func)
    l_c_d, r_c_d, c_d = walk_rules_parallel(args, left_common, right_common,
                                            oval_func, remediation_func)

    left_changed_data = l_c_d
    right_changed_data = r_c_d
    common_data = c_d

    return (left_only_data, right_only_data, left_changed_data, right_changed_data, common_data)


def walk_rules_diff_stats(results):
    """
    Takes the results of walk_rules_diff (results) and generates five sets of
    output statistics: left_only rules output, right_only rules output,
    shared left output, shared right output, and shared common output, as a
    five-tuple, where each tuple element is equivalent to walk_rules_stats on
    the appropriate set of rules.

    Can assert.
    """

    assert len(results) == 5

    output_data = []

    for data in results:
        affected_rules, verbose_output = data

        affected_ovals = 0
        affected_remediations = 0
        all_affected_remediations = 0
        affected_remediations_type = defaultdict(lambda: 0)
        all_output = []

        for rule_id in sorted(verbose_output):
            rule_output = verbose_output[rule_id]
            _results = walk_rule_stats(rule_output)

            affected_ovals += _results[0]
            affected_remediations += _results[1]
            all_affected_remediations += _results[2]
            for key in _results[3]:
                affected_remediations_type[key] += _results[3][key]

            all_output.extend(_results[4])

        output_data.append((affected_rules, affected_ovals,
                            affected_remediations, all_affected_remediations,
                            affected_remediations_type, all_output))

    assert len(output_data) == 5

    return tuple(output_data)


def filter_rule_ids(all_keys, queries):
    """
    From a set of queries (a comma separated list of queries, where a query is either a
    rule id or a substring thereof), return the set of matching keys from all_keys. When
    queries is the literal string "all", return all of the keys.
    """

    if not queries:
        return set()

    if queries == 'all':
        return set(all_keys)

    # We assume that all_keys is much longer than queries; this allows us to do
    # len(all_keys) iterations of size len(query_parts) instead of len(query_parts)
    # queries of size len(all_keys) -- which hopefully should be a faster data access
    # pattern due to caches but in reality shouldn't matter. Note that we have to iterate
    # over the keys in all_keys either way, because we wish to check whether query is a
    # substring of a key, not whether query is a key.
    #
    # This does have the side-effect of not having the results be ordered according to
    # their order in query_parts, so we instead, we intentionally discard order by using
    # a set. This also guarantees that our results are unique.
    results = set()
    query_parts = queries.split(',')
    for key in all_keys:
        for query in query_parts:
            if query in key:
                results.add(key)

    return results


def missing_oval(rule_obj):
    """
    For a rule object, check if it is missing an oval.
    """

    rule_id = rule_obj['id']
    check = len(rule_obj['ovals']) > 0
    if not check:
        return "\trule_id:%s is missing all OVALs" % rule_id


def missing_remediation(rule_obj, r_type):
    """
    For a rule object, check if it is missing a remediation of type r_type.
    """

    rule_id = rule_obj['id']
    check = (r_type in rule_obj['remediations'] and
             len(rule_obj['remediations'][r_type]) > 0)
    if not check:
        return "\trule_id:%s is missing %s remediations" % (rule_id, r_type)


def two_plus_oval(rule_obj):
    """
    For a rule object, check if it has two or more OVALs.
    """

    rule_id = rule_obj['id']
    check = len(rule_obj['ovals']) >= 2
    if check:
        return "\trule_id:%s has two or more OVALs: %s" % (rule_id, ','.join(rule_obj['ovals']))


def two_plus_remediation(rule_obj, r_type):
    """
    For a rule object, check if it has two or more remediations of type r_type.
    """

    rule_id = rule_obj['id']
    check = (r_type in rule_obj['remediations'] and
             len(rule_obj['remediations'][r_type]) >= 2)
    if check:
        return "\trule_id:%s has two or more %s remediations: %s" % \
               (rule_id, r_type, ','.join(rule_obj['remediations'][r_type]))


def prodtypes_oval(rule_obj):
    """
    For a rule object, check if the prodtypes match between the YAML and the
    OVALs.
    """

    rule_id = rule_obj['id']

    rule_products = set(rule_obj.get('products', []))
    if not rule_products:
        return

    oval_products = set()
    for oval in rule_obj.get('ovals', []):
        oval_products.update(rule_obj['ovals'][oval].get('products', []))
    if not oval_products:
        return

    sym_diff = sorted(rule_products.symmetric_difference(oval_products))
    check = len(sym_diff) > 0
    if check:
        return "\trule_id:%s has a different prodtypes between YAML and OVALs: %s" % \
               (rule_id, ','.join(sym_diff))


def prodtypes_remediation(rule_obj, r_type):
    """
    For a rule object, check if the prodtypes match between the YAML and the
    remediations of type r_type.
    """

    rule_id = rule_obj['id']

    rule_products = set(rule_obj.get('products', []))
    if not rule_products:
        return

    remediation_products = set()
    for remediation in rule_obj.get('remediations', dict()).get(r_type, dict()):
        remediation_products.update(rule_obj['remediations'][r_type][remediation]['products'])
    if not remediation_products:
        return

    sym_diff = sorted(rule_products.symmetric_difference(remediation_products))
    check = len(sym_diff) > 0 and rule_products and remediation_products
    if check:
        return "\trule_id:%s has a different prodtypes between YAML and %s remediations: %s" % \
               (rule_id, r_type, ','.join(sym_diff))


def product_names_oval(rule_obj):
    """
    For a rule_obj, check the scope of the platforms versus the product name
    of the OVAL objects.
    """

    rule_id = rule_obj['id']
    for oval_name in rule_obj['ovals']:
        if oval_name == "shared.xml":
            continue

        oval_product, _ = os.path.splitext(oval_name)
        for product in rule_obj['ovals'][oval_name]['products']:
            if product != oval_product:
                return "\trule_id:%s has a different product and OVALs names: %s is not %s" % \
                       (rule_id, product, oval_product)


def product_names_remediation(rule_obj, r_type):
    """
    For a rule_obj, check the scope of the platforms versus the product name
    of the remediations of type r_type.
    """

    rule_id = rule_obj['id']
    for r_name in rule_obj['remediations'][r_type]:
        r_product, _ = os.path.splitext(r_name)
        if r_product == "shared":
            continue

        for product in rule_obj['remediations'][r_type][r_name]['products']:
            if product != r_product:
                return "\trule_id:%s has a different product and %s remediation names: %s is not %s" % \
                       (rule_id, r_type, product, r_product)
