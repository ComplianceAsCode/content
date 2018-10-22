import logging
import subprocess
from collections import namedtuple
import enum
import functools
import re


Run_id = namedtuple(
    "Run_id",
    ("rule_id", "name"))
Run_conditions = namedtuple(
    "Run_conditions",
    ("backend", "scanning_mode", "remediated_by", "datastream"))


IGNORE_KNOWN_HOSTS_OPTIONS = (
    "-o", "StrictHostKeyChecking=no",
    "-o", "UserKnownHostsFile=/dev/null",
)


class Stage(enum.IntEnum):
    NONE = 0
    PREPARATION = 1
    INITIAL_SCAN = 2
    REMEDIATION = 3
    FINAL_SCAN = 4


class ResultBase(object):
    STAGE_STRINGS = {
        "initial_scan",
        "final_scan",
    }

    """
    Result of a test suite testing rule under a scenario.

    Supports ordering by success - the most successful run orders first.
    """
    def __init__(self, result_dict=None):
        self.run = Run_id("", "")
        self.conditions = Run_conditions("", "", "", "")
        self.when = ""
        self.passed_stages = dict()
        self.passed_stages_count = 0
        self.success = False

        if result_dict:
            self.load_from_dict(result_dict)

    def load_from_dict(self, data):
        self.run = Run_id(data["rule_id"], self.get_run_name(data))

        self.conditions = Run_conditions(
            backend=data["backend"], scanning_mode=data["scanning_mode"],
            remediated_by=data["remediated_by"], datastream=data["datastream"])
        self.when = data["run_timestamp"]

        self.analyze_success(data)

    def save_to_dict(self):
        data = dict()
        data["rule_id"] = self.run.rule_id

        data["backend"] = self.conditions.backend
        data["scanning_mode"] = self.conditions.scanning_mode
        data["remediated_by"] = self.conditions.remediated_by
        data["datastream"] = self.conditions.datastream

        data["run_timestamp"] = self.when

        for stage_str, result in self.passed_stages.items():
            data[stage_str] = result

        return data

    def record_stage_result(self, stage, successful):
        assert stage in self.STAGE_STRINGS, (
            "Stage name {name} is invalid, choose one from {choices}"
            .format(name=stage, choices=", ".join(self.STAGE_STRINGS))
        )
        self.passed_stages[stage] = successful

    def relative_conditions_to(self, other):
        if self.conditions == other.conditions:
            return self.when, other.when
        else:
            return tuple(self.conditions), tuple(other.conditions)

    def __eq__(self, other):
        return (self.success == other.success
                and tuple(self.passed_stages) == tuple(self.passed_stages))

    def __lt__(self, other):
        return self.passed_stages_count > other.passed_stages_count


@functools.total_ordering
class ProfileResult(ResultBase):
    def get_run_name(self, data):
        return data["profile"]

    def analyze_success(self, data):
        successes = ("pass", "fixed", "notselected")
        self.passed_stages = {key: data[key] for key in self.STAGE_STRINGS if key in data}
        self.passed_stages_count = sum(
            [1 for val in self.passed_stages.values() if val in successes])

        self.success = data.get("final_scan", False)
        if not self.success:
            self.success = (
                "remediation" not in data
                and data.get("initial_scan", False))

        self.success = self.success in successes

    def save_to_dict(self):
        data = super(ProfileResult, self).save_to_dict()
        data["profile"] = self.run.name
        return data


@functools.total_ordering
class RuleResult(ResultBase):
    STAGE_STRINGS = {
        "preparation",
        "initial_scan",
        "remediation",
        "final_scan",
    }

    def get_run_name(self, data):
        return data["scenario_script"]

    def analyze_success(self, data):
        self.passed_stages = {key: data[key] for key in self.STAGE_STRINGS if key in data}
        self.passed_stages_count = sum(self.passed_stages.values())

        self.success = data.get("final_scan", False)
        if not self.success:
            self.success = (
                "remediation" not in data
                and data.get("initial_scan", False))

    def save_to_dict(self):
        data = super(RuleResult, self).save_to_dict()
        data["scenario_script"] = self.run.name
        return data


def run_cmd_local(command, verbose_path, env=None):
    command_string = ' '.join(command)
    logging.debug('Running {}'.format(command_string))
    returncode, output = _run_cmd(command, verbose_path, env)
    return returncode, output


def run_cmd_remote(command_string, domain_ip, verbose_path, env=None):
    machine = 'root@{0}'.format(domain_ip)
    remote_cmd = ['ssh'] + list(IGNORE_KNOWN_HOSTS_OPTIONS) + [machine, command_string]
    logging.debug('Running {}'.format(command_string))
    returncode, output = _run_cmd(remote_cmd, verbose_path, env)
    return returncode, output


def _run_cmd(command_list, verbose_path, env=None):
    returncode = 0
    output = b""
    try:
        with open(verbose_path, 'w') as verbose_file:
            output = subprocess.check_output(
                command_list, stderr=verbose_file, env=env)
    except subprocess.CalledProcessError as e:
        returncode = e.returncode
        output = e.output
    return returncode, output.decode('utf-8')


def shorten_rule_id(rule_id):
    rule_stem = re.sub("xccdf_org.ssgproject.content_rule_(.+)", r"\1", rule_id)
    assert len(rule_stem) < len(rule_id), (
        "The rule ID '{rule_id}' has a strange form, as it doesn't have "
        "the common rule prefix.".format(rule_id=rule_id))
    return rule_stem
