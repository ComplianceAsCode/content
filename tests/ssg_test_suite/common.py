import logging
import subprocess
from collections import namedtuple
import enum
import functools


Scenario_run = namedtuple(
    "Scenario_run",
    ("rule_id", "script"))
Scenario_conditions = namedtuple(
    "Scenario_conditions",
    ("backend", "scanning_mode", "remediated_by", "datastream"))


IGNORE_KNOWN_HOSTS_OPTIONS = (
    "-o", "StrictHostKeyChecking=no",
    "-o", "UserKnownHostsFile=/dev/null",
)

# Keys are strings used in test scenario header in 'platform' list
# CentOS CPEs are added to allow testing RHEL profiles on CentOS VMs
TEST_PLATFORMS = {
    "Red Hat Enterprise Linux 6": [
        "cpe:/o:redhat:enterprise_linux:6",
        "cpe:/o:centos:centos:6"
    ],
    "Red Hat Enterprise Linux 7": [
        "cpe:/o:redhat:enterprise_linux:7",
        "cpe:/o:centos:centos:7"
    ],
    "Red Hat Enterprise Linux 8": [
        "cpe:/o:redhat:enterprise_linux:8",
        "cpe:/o:centos:centos:8"
    ],
    "Fedora": [
        "cpe:/o:fedoraproject:fedora:28",
        "cpe:/o:fedoraproject:fedora:29",
        "cpe:/o:fedoraproject:fedora:30"
    ],
}

# Keys are strings used in test scenario header in 'platform' list
TEST_MULTI_PLATFORMS = {
    "multi_platform_rhel":
        TEST_PLATFORMS["Red Hat Enterprise Linux 6"] +
        TEST_PLATFORMS["Red Hat Enterprise Linux 7"] +
        TEST_PLATFORMS["Red Hat Enterprise Linux 8"],
    "multi_platform_fedora":
        TEST_PLATFORMS["Fedora"]
}


class Stage(enum.IntEnum):
    NONE = 0
    PREPARATION = 1
    INITIAL_SCAN = 2
    REMEDIATION = 3
    FINAL_SCAN = 4


@functools.total_ordering
class RuleResult(object):
    STAGE_STRINGS = {
        "preparation",
        "initial_scan",
        "remediation",
        "final_scan",
    }

    """
    Result of a test suite testing rule under a scenario.

    Supports ordering by success - the most successful run orders first.
    """
    def __init__(self, result_dict=None):
        self.scenario = Scenario_run("", "")
        self.conditions = Scenario_conditions("", "", "", "")
        self.when = ""
        self.passed_stages = dict()
        self.passed_stages_count = 0
        self.success = False

        if result_dict:
            self.load_from_dict(result_dict)

    def load_from_dict(self, data):
        self.scenario = Scenario_run(data["rule_id"], data["scenario_script"])
        self.conditions = Scenario_conditions(
            data["backend"], data["scanning_mode"],
            data["remediated_by"], data["datastream"])
        self.when = data["run_timestamp"]

        self.passed_stages = {key: data[key] for key in self.STAGE_STRINGS if key in data}
        self.passed_stages_count = sum(self.passed_stages.values())

        self.success = data.get("final_scan", False)
        if not self.success:
            self.success = (
                "remediation" not in data
                and data.get("initial_scan", False))

    def save_to_dict(self):
        data = dict()
        data["rule_id"] = self.scenario.rule_id
        data["scenario_script"] = self.scenario.script

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
