from __future__ import print_function

import logging
import os
import shutil
import os.path
import re
import subprocess
import collections
import json
import fnmatch
import tempfile
import contextlib
import itertools
import math

from ssg.constants import OSCAP_PROFILE, OSCAP_PROFILE_ALL_ID, OSCAP_RULE
from ssg_test_suite import oscap
from ssg_test_suite import xml_operations
from ssg_test_suite import test_env
from ssg_test_suite import common
from ssg_test_suite.log import LogHelper

import ssg.templates

Rule = collections.namedtuple(
    "Rule",
    ["directory", "id", "short_id", "template", "local_env_yaml", "rule"])

RuleTestContent = collections.namedtuple(
    "RuleTestContent", ["scenarios", "other_content"])

logging.getLogger(__name__).addHandler(logging.NullHandler())


def get_viable_profiles(selected_profiles, datastream, benchmark, script=None):
    """Read datastream, and return set intersection of profiles of given
    benchmark and those provided in `selected_profiles` parameter.
    """

    valid_profiles = []
    all_profiles_elements = xml_operations.get_all_profiles_in_benchmark(
        datastream, benchmark, logging)
    all_profiles = [el.attrib["id"] for el in all_profiles_elements]
    all_profiles.append(OSCAP_PROFILE_ALL_ID)

    for ds_profile in all_profiles:
        if 'ALL' in selected_profiles:
            valid_profiles += [ds_profile]
            continue
        for sel_profile in selected_profiles:
            if ds_profile.endswith(sel_profile):
                valid_profiles += [ds_profile]

    if not valid_profiles:
        if script:
            logging.warning('Script {0} - profile {1} not found in datastream'
                            .format(script, ", ".join(selected_profiles)))
        else:
            logging.warning('Profile {0} not found in datastream'
                            .format(", ".join(selected_profiles)))
    return valid_profiles


def generate_xslt_change_value_template(value_short_id, new_value):
    XSLT_TEMPLATE = """<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:ds="http://scap.nist.gov/schema/scap/source/1.2" xmlns:xccdf-1.2="http://checklists.nist.gov/xccdf/1.2">
    <xsl:output omit-xml-declaration="yes" indent="yes"/>
        <xsl:strip-space elements="*"/>
        <xsl:template match="node()|@*">
            <xsl:copy>
                <xsl:apply-templates select="node()|@*"/>
            </xsl:copy>
        </xsl:template>
        <xsl:template match="ds:component/xccdf-1.2:Benchmark//xccdf-1.2:Value[@id='xccdf_org.ssgproject.content_value_{value_short_id}']/xccdf-1.2:value[not(@selector)]/text()">{new_value}</xsl:template>
</xsl:stylesheet>"""
    return XSLT_TEMPLATE.format(value_short_id=value_short_id, new_value=new_value)


def _apply_script(rule_dir, test_env, script):
    """Run particular test script on VM and log it's output."""
    logging.debug("Applying script {0}".format(script))
    rule_name = os.path.basename(rule_dir)
    log_file_name = os.path.join(
        LogHelper.LOG_DIR, rule_name + ".prescripts.log")

    with open(log_file_name, 'a') as log_file:
        log_file.write('##### {0} / {1} #####\n'.format(rule_name, script))
        shared_dir = os.path.join(common.REMOTE_TEST_SCENARIOS_DIRECTORY, "shared")
        command = "cd {0}; SHARED={1} bash -x {2}".format(rule_dir, shared_dir, script)

        try:
            error_msg_template = (
                "Rule '{rule_name}' test setup script '{script}' "
                "failed with exit code {{rc}}".format(rule_name=rule_name, script=script)
            )
            test_env.execute_ssh_command(
                command, log_file, error_msg_template=error_msg_template)
        except RuntimeError as exc:
            logging.error(str(exc))
            return False
    return True


class RuleChecker(oscap.Checker):
    """
    Rule checks generally work like this -
    for every profile that supports that rule:

    - Alter the system.
    - Run the scan, check that the result meets expectations.
      If the test scenario passed as requested, return True,
      if it failed or passed unexpectedly, return False.

    The following sequence applies if the initial scan
    has failed as expected:

    - If there are no remediations, return True.
    - Run remediation, return False if it failed.
    - Return result of the final scan of remediated system.
    """
    def __init__(self, test_env):
        super(RuleChecker, self).__init__(test_env)

        self.results = list()
        self._current_result = None
        self.remote_dir = ""
        self.target_type = "rule ID"
        self.used_templated_test_scenarios = collections.defaultdict(set)
        self.rule_spec = None
        self.template_spec = None
        self.scenarios_profile = None

    def _run_test(self, profile, test_data):
        scenario = test_data["scenario"]
        rule_id = test_data["rule_id"]
        remediation_available = test_data["remediation_available"]

        LogHelper.preload_log(
            logging.INFO, "Script {0} using profile {1} OK".format(scenario.script, profile),
            log_target='pass')
        LogHelper.preload_log(
            logging.WARNING, "Script {0} using profile {1} notapplicable".format(scenario.script, profile),
            log_target='notapplicable')
        LogHelper.preload_log(
            logging.ERROR,
            "Script {0} using profile {1} found issue:".format(scenario.script, profile),
            log_target='fail')

        runner_cls = oscap.REMEDIATION_RULE_RUNNERS[self.remediate_using]
        runner_instance = runner_cls(
            self.test_env, oscap.process_profile_id(profile), self.datastream, self.benchmark_id,
            rule_id, scenario.script, self.dont_clean, self.no_reports, self.manual_debug)

        with runner_instance as runner:
            initial_scan_res = self._initial_scan_went_ok(runner, rule_id, scenario.context)
            if not initial_scan_res:
                return False
            if initial_scan_res == 2:
                # notapplicable
                return True

            supported_and_available_remediations = self._get_available_remediations(scenario)
            if (scenario.context not in ['fail', 'error']
                    or not supported_and_available_remediations):
                return True

            if remediation_available:
                if not self._remediation_went_ok(runner, rule_id):
                    return False

                return self._final_scan_went_ok(runner, rule_id)
            else:
                msg = ("No remediation is available for rule '{}'."
                       .format(rule_id))
                logging.warning(msg)
                return False

    def _initial_scan_went_ok(self, runner, rule_id, context):
        success = runner.run_stage_with_context("initial", context)
        self._current_result.record_stage_result("initial_scan", success)
        if not success:
            msg = ("The initial scan failed for rule '{}'."
                   .format(rule_id))
            logging.error(msg)
        return success

    def _is_remediation_available(self, rule):
        if xml_operations.find_fix_in_benchmark(
                self.datastream, self.benchmark_id, rule.id, self.remediate_using) is None:
            return False
        else:
            return True


    def _get_available_remediations(self, scenario):
        is_supported = set(['all'])
        is_supported.add(
            oscap.REMEDIATION_RUNNER_TO_REMEDIATION_MEANS[self.remediate_using])
        supported_and_available_remediations = set(
            scenario.script_params['remediation']).intersection(is_supported)
        return supported_and_available_remediations

    def _remediation_went_ok(self, runner, rule_id):
        success = runner.run_stage_with_context('remediation', 'fixed')
        self._current_result.record_stage_result("remediation", success)
        if not success:
            msg = ("The remediation failed for rule '{}'."
                   .format(rule_id))
            logging.error(msg)

        return success

    def _final_scan_went_ok(self, runner, rule_id):
        success = runner.run_stage_with_context('final', 'pass')
        self._current_result.record_stage_result("final_scan", success)
        if not success:
            msg = ("The check after remediation failed for rule '{}'."
                   .format(rule_id))
            logging.error(msg)
        return success

    def _rule_template_been_tested(self, rule, tested_templates):
        if rule.template is None:
            return False
        if self.test_env.duplicate_templates:
            return False
        if rule.template in tested_templates:
            return True
        tested_templates.add(rule.template)
        return False

    def _rule_matches_rule_spec(self, rule_short_id):
        rule_id = OSCAP_RULE + rule_short_id
        if 'ALL' in self.rule_spec:
            return True
        else:
            for rule_to_be_tested in self.rule_spec:
                # we check for a substring
                if rule_to_be_tested.startswith(OSCAP_RULE):
                    pattern = rule_to_be_tested
                else:
                    pattern = OSCAP_RULE + rule_to_be_tested
                if fnmatch.fnmatch(rule_id, pattern):
                    return True
            return False

    def _rule_matches_template_spec(self, template):
        return True

    def _ensure_package_present_for_all_scenarios(
            self, test_content_by_rule_id):
        packages_required = set()
        for rule_test_content in test_content_by_rule_id.values():
            for s in rule_test_content.scenarios:
                scenario_packages = s.script_params["packages"]
                packages_required.update(scenario_packages)
        if packages_required:
            common.install_packages(self.test_env, packages_required)

    def _prepare_environment(self, test_content_by_rule_id):
        try:
            self.remote_dir = common.send_scripts(
                self.test_env, test_content_by_rule_id)
        except RuntimeError as exc:
            msg = "Unable to upload test scripts: {more_info}".format(more_info=str(exc))
            raise RuntimeError(msg)

        self._ensure_package_present_for_all_scenarios(test_content_by_rule_id)

    def _get_rules_to_test(self):
        """
        Returns:
            List of named tuples Rule having these fields:
                directory -- absolute path to the rule "tests" subdirectory
                            containing the test scenarios in Bash
                id -- full rule id as it is present in datastream
                short_id -- short rule ID, the same as basename of the directory
                            containing the test scenarios in Bash
                template -- name of the template the rule uses
                local_env_yaml -- env_yaml specific to rule's own context
                rule -- rule class, contains information parsed from rule.yml
        """

        # Here we need to perform some magic to handle parsing the rule (from a
        # product perspective) and loading any templated tests. In particular,
        # identifying which tests to potentially run involves invoking the
        # templating engine.
        #
        # Begin by loading context about our execution environment, if any.
        product = self.test_env.product
        product_yaml = common.get_product_context(product)
        all_rules_in_benchmark = xml_operations.get_all_rules_in_benchmark(
            self.datastream, self.benchmark_id)
        rules = []

        for dirpath, dirnames, filenames in common.walk_through_benchmark_dirs(
                product):
            if not common.is_rule_dir(dirpath):
                continue
            short_rule_id = os.path.basename(dirpath)
            full_rule_id = OSCAP_RULE + short_rule_id
            if not self._rule_matches_rule_spec(short_rule_id):
                continue
            if full_rule_id not in all_rules_in_benchmark:
                # This is an error only if the user specified the rules to be
                # tested explicitly using command line arguments
                if self.target_type == "rule ID":
                    logging.error(
                        "Rule '{0}' isn't present in benchmark '{1}' in '{2}'"
                        .format(
                            full_rule_id, self.benchmark_id, self.datastream))
                continue

            # Load the rule itself to check for a template.
            rule, local_env_yaml = common.load_rule_and_env(
                dirpath, product_yaml, product)

            # Before we get too far, we wish to search the rule YAML to see if
            # it is applicable to the current product. If we have a product
            # and the rule isn't applicable for the product, there's no point
            # in continuing with the rest of the loading. This should speed up
            # the loading of the templated tests. Note that we've already
            # parsed the prodtype into local_env_yaml
            if product and local_env_yaml['products']:
                prodtypes = local_env_yaml['products']
                if "all" not in prodtypes and product not in prodtypes:
                    continue

            tests_dir = os.path.join(dirpath, "tests")
            template_name = None
            if rule.template and rule.template['vars']:
                template_name = rule.template['name']
            if not self._rule_matches_template_spec(template_name):
                continue
            result = Rule(
                directory=tests_dir, id=full_rule_id,
                short_id=short_rule_id, template=template_name,
                local_env_yaml=local_env_yaml, rule=rule)
            rules.append(result)
        return rules

    def test_rule(self, state, rule, scenarios):
        remediation_available = self._is_remediation_available(rule)
        self._check_rule(
            rule, scenarios,
            self.remote_dir, state, remediation_available)

    def _slice_sbr(self, test_content_by_rule_id, slice_current, slice_total):
        """  Returns only a subset of test scenarios, representing slice_current-th
        slice out of slice_total"""

        tuple_repr = []
        for rule_id in test_content_by_rule_id:
            tuple_repr += itertools.product(
                [rule_id], test_content_by_rule_id[rule_id].scenarios)

        total_scenarios = len(tuple_repr)
        slice_low_bound = math.ceil(total_scenarios / slice_total * (slice_current - 1))
        slice_high_bound = math.ceil(total_scenarios / slice_total * slice_current)

        new_sbr = {}
        for rule_id, scenario in tuple_repr[slice_low_bound:slice_high_bound]:
            try:
                new_sbr[rule_id].scenarios.append(scenario)
            except KeyError:
                scenarios = [scenario]
                other_content = test_content_by_rule_id[rule_id].other_content
                new_sbr[rule_id] = RuleTestContent(scenarios, other_content)
        return new_sbr

    def _find_tests_paths(self, rule, template_builder, product_yaml):
        # Start by checking for templating tests
        templated_tests_paths = common.fetch_templated_tests_paths(
            rule, template_builder, product_yaml)

        # Add additional tests from the local rule directory. Note that,
        # like the behavior in template_tests, this will overwrite any
        # templated tests with the same file name.
        local_tests_paths = common.fetch_local_tests_paths(rule.directory)

        for filename in local_tests_paths:
            templated_tests_paths.pop(filename, None)
        if self.target_type != "template":
            for filename in self.used_templated_test_scenarios[rule.template]:
                templated_tests_paths.pop(filename, None)
            self.used_templated_test_scenarios[rule.template] |= set(
                templated_tests_paths.keys())
        return templated_tests_paths.values(), local_tests_paths.values()

    def _load_all_tests(self, rule):
        product_yaml = common.get_product_context(self.test_env.product)
        # Initialize a mock template_builder.
        empty = "/ssgts/empty/placeholder"
        template_builder = ssg.templates.Builder(
            product_yaml, empty, common._SHARED_TEMPLATES, empty, empty)

        templated_tests_paths, local_tests_paths = self._find_tests_paths(
            rule, template_builder, product_yaml)

        # All tests is a mapping from path (in the tarball) to contents
        # of the test case. This is necessary because later code (which
        # attempts to parse headers from the test case) don't have easy
        # access to templated content. By reading it and returning it
        # here, we can save later code from having to understand the
        # templating system.
        all_tests = dict()
        templated_tests = common.load_templated_tests(
            templated_tests_paths, template_builder, rule.rule.template,
            rule.local_env_yaml)
        local_tests = common.load_local_tests(
            local_tests_paths, rule.local_env_yaml)
        all_tests.update(templated_tests)
        all_tests.update(local_tests)
        return all_tests

    def _get_rule_test_content(self, rule):
        all_tests = self._load_all_tests(rule)
        scenarios = []
        other_content = dict()
        for file_name, file_content in all_tests.items():
            scenario_matches_regex = r'.*\.[^.]*\.sh$'
            if re.search(scenario_matches_regex, file_name):
                scenario = Scenario(file_name, file_content)
                scenario.override_profile(self.scenarios_profile)
                if scenario.matches_regex_and_platform(
                        self.scenarios_regex, self.benchmark_cpes):
                    scenarios.append(scenario)
            else:
                other_content[file_name] = file_content
        return RuleTestContent(scenarios, other_content)

    def _get_test_content_by_rule_id(self, rules_to_test):
        test_content_by_rule_id = dict()
        for rule in rules_to_test:
            rule_test_content = self._get_rule_test_content(rule)
            test_content_by_rule_id[rule.id] = rule_test_content
        sliced_test_content_by_rule_id = self._slice_sbr(
            test_content_by_rule_id, self.slice_current, self.slice_total)
        return sliced_test_content_by_rule_id

    def _test_target(self):
        rules_to_test = self._get_rules_to_test()
        if not rules_to_test:
            logging.error("No tests found matching the {0}(s) '{1}'".format(
                self.target_type,
                ", ".join(self.rule_spec)))
            return

        test_content_by_rule_id = self._get_test_content_by_rule_id(
            rules_to_test)

        self._prepare_environment(test_content_by_rule_id)

        with test_env.SavedState.create_from_environment(
                self.test_env, "tests_uploaded") as state:
            for rule in rules_to_test:
                try:
                    scenarios = test_content_by_rule_id[rule.id].scenarios
                    self.test_rule(state, rule, scenarios)
                except KeyError:
                    # rule is not processed in given slice
                    pass

    def _check_rule(self, rule, scenarios, remote_dir, state, remediation_available):
        remote_rule_dir = os.path.join(remote_dir, rule.short_id)
        logging.info(rule.id)

        logging.debug("Testing rule directory {0}".format(rule.directory))

        args_list = [
            (s, remote_rule_dir, rule.id, remediation_available) for s in scenarios
        ]
        state.map_on_top(self._check_and_record_rule_scenario, args_list)

    def _check_and_record_rule_scenario(self, scenario, remote_rule_dir, rule_id, remediation_available):
        self._current_result = common.RuleResult()

        self._current_result.conditions = common.Scenario_conditions(
            self.test_env.name, self.test_env.scanning_mode,
            self.remediate_using, self.datastream)
        self._current_result.scenario = common.Scenario_run(rule_id, scenario.script)
        self._current_result.when = self.test_timestamp_str

        with self.copy_of_datastream():
            self._check_rule_scenario(scenario, remote_rule_dir, rule_id, remediation_available)
        self.results.append(self._current_result.save_to_dict())

    @contextlib.contextmanager
    def copy_of_datastream(self, new_filename=None):
        prefixed_name = common.get_prefixed_name("ds_modified")
        old_filename = self.datastream
        if not new_filename:
            descriptor, new_filename = tempfile.mkstemp(prefix=prefixed_name, dir="/tmp")
        os.close(descriptor)
        shutil.copy(old_filename, new_filename)
        self.datastream = new_filename
        yield new_filename
        self.datastream = old_filename
        os.unlink(new_filename)

    def _change_variable_value(self, varname, value):
        descriptor, xslt_filename = tempfile.mkstemp(prefix="xslt-change-value", dir="/tmp")
        os.close(descriptor)
        template = generate_xslt_change_value_template(varname, value)
        with open(xslt_filename, "w") as fp:
            fp.write(template)
        descriptor, temp_datastream = tempfile.mkstemp(prefix="ds-temp", dir="/tmp")
        os.close(descriptor)
        log_file_name = os.path.join(LogHelper.LOG_DIR, "env-preparation.log")
        with open(log_file_name, "a") as log_file:
            result = common.run_with_stdout_logging(
                    "xsltproc", ("--output", temp_datastream, xslt_filename, self.datastream),
                    log_file)
            if result.returncode:
                msg = (
                    "Error changing value of '{varname}': {stderr}"
                    .format(varname=varname, stderr=result.stderr)
                )
                raise RuntimeError(msg)
        os.rename(temp_datastream, self.datastream)
        os.unlink(xslt_filename)

    def _check_rule_scenario(self, scenario, remote_rule_dir, rule_id, remediation_available):
        if not _apply_script(
                remote_rule_dir, self.test_env, scenario.script):
            logging.error("Environment failed to prepare, skipping test")
            self._current_result.record_stage_result("preparation", False)
            return

        if scenario.script_params["variables"]:
            for assignment in scenario.script_params["variables"]:
                varname, value = assignment.split("=", 1)
                self._change_variable_value(varname, value)
        self._current_result.record_stage_result("preparation", True)
        logging.debug('Using test script {0} with context {1}'
                      .format(scenario.script, scenario.context))

        if scenario.script_params['profiles']:
            profiles = get_viable_profiles(
                scenario.script_params['profiles'], self.datastream, self.benchmark_id, scenario.script)
        else:
            # Special case for combined mode when scenario.script_params['profiles']
            # is empty which means scenario is not applicable on given profile.
            logging.warning('Script {0} is not applicable on given profile'
                            .format(scenario.script))
            return

        test_data = dict(scenario=scenario,
                         rule_id=rule_id,
                         remediation_available=remediation_available)
        self.run_test_for_all_profiles(profiles, test_data)

        self.executed_tests += 1

    def finalize(self):
        super(RuleChecker, self).finalize()
        with open(os.path.join(LogHelper.LOG_DIR, "results.json"), "w") as f:
            json.dump(self.results, f)


class Scenario():
    def __init__(self, script, script_contents):
        self.script = script
        self.context = self._get_script_context()
        self.contents = script_contents
        self.script_params = self._parse_parameters()

    def _get_script_context(self):
        """Return context of the script."""
        result = re.search(r'.*\.([^.]*)\.[^.]*$', self.script)
        if result is None:
            return None
        return result.group(1)

    def _parse_parameters(self):
        """Parse parameters from script header"""
        params = {
            'profiles': [],
            'templates': [],
            'packages': [],
            'platform': ['multi_platform_all'],
            'remediation': ['all'],
            'variables': [],
        }

        for parameter in params:
            found = re.search(
                r'^# {0} = (.*)$'.format(parameter),
                self.contents, re.MULTILINE)
            if found is None:
                continue
            if parameter == "variables":
                variables = []
                for token in found.group(1).split(','):
                    token = token.strip()
                    if '=' in token:
                        variables.append(token)
                    else:
                        variables[-1] += "," + token
                params["variables"] = variables
            else:
                splitted = found.group(1).split(',')
                params[parameter] = [value.strip() for value in splitted]

        if not params["profiles"]:
            params["profiles"].append(OSCAP_PROFILE_ALL_ID)
            logging.debug(
                "Added the {0} profile to the list of available profiles "
                "for {1}"
                .format(OSCAP_PROFILE_ALL_ID, self.script))

        return params

    def override_profile(self, scenarios_profile):
        if scenarios_profile:
            self.script_params['profiles'] = [scenarios_profile]

    def matches_regex(self, scenarios_regex):
        if scenarios_regex is not None:
            scenarios_pattern = re.compile(scenarios_regex)
            if scenarios_pattern.match(self.script) is None:
                logging.debug(
                    "Skipping script %s - it did not match "
                    "--scenarios regex" % self.script
                )
                return False
        return True

    def matches_platform(self, benchmark_cpes):
        if self.context is None:
            return False
        if common.matches_platform(
                self.script_params["platform"], benchmark_cpes):
            return True
        else:
            logging.warning(
                "Script %s is not applicable on given platform" %
                self.script)
            return False

    def matches_regex_and_platform(self, scenarios_regex, benchmark_cpes):
        return (
            self.matches_regex(scenarios_regex)
            and self.matches_platform(benchmark_cpes))


def perform_rule_check(options):
    checker = RuleChecker(options.test_env)

    checker.datastream = options.datastream
    checker.benchmark_id = options.benchmark_id
    checker.remediate_using = options.remediate_using
    checker.dont_clean = options.dont_clean
    checker.no_reports = options.no_reports
    checker.manual_debug = options.manual_debug
    checker.benchmark_cpes = options.benchmark_cpes
    checker.scenarios_regex = options.scenarios_regex
    checker.slice_current = options.slice_current
    checker.slice_total = options.slice_total
    checker.keep_snapshots = options.keep_snapshots
    checker.rule_spec = options.target
    checker.template_spec = None
    checker.scenarios_profile = options.scenarios_profile
    # check if target is a complete profile ID, if not prepend profile prefix
    if (checker.scenarios_profile is not None and
            not checker.scenarios_profile.startswith(OSCAP_PROFILE) and
            not oscap.is_virtual_oscap_profile(checker.scenarios_profile)):
        checker.scenarios_profile = OSCAP_PROFILE+options.scenarios_profile
    checker.test_target()
