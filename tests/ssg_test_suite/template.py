#!/usr/bin/python3
from __future__ import print_function

from ssg_test_suite import rule


class TemplateChecker(rule.RuleChecker):
    """
    The template mode tests every rule that uses the specified
    target template.

    If the target template doesn't have tests, only the tests
    from the rules are executed.
    If there are templated test scenarios they are executed together
    with any extra tests available for the rule.
    """

    def __init__(self, test_env):
        super(TemplateChecker, self).__init__(test_env)
        self.target_type = "template"

    def _rule_matches_rule_spec(self, rule_short_id):
        return True

    def _rule_matches_template_spec(self, template):
        return (template in self.template_spec)


def perform_template_check(options):
    checker = TemplateChecker(options.test_env)

    checker.datastream = options.datastream
    checker.benchmark_id = options.benchmark_id
    checker.remediate_using = options.remediate_using
    checker.dont_clean = options.dont_clean
    checker.no_reports = options.no_reports
    # No debug option is provided for template mode
    checker.manual_debug = False
    checker.benchmark_cpes = options.benchmark_cpes
    checker.scenarios_regex = options.scenarios_regex
    checker.slice_current = options.slice_current
    checker.slice_total = options.slice_total
    checker.scenarios_profile = options.scenarios_profile

    checker.rule_spec = None
    checker.template_spec = options.target
    checker.test_target()
    return
