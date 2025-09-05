import os
import logging
import subprocess
from collections import namedtuple
import functools
from ssg.constants import MULTI_PLATFORM_MAPPING
from ssg.constants import PRODUCT_TO_CPE_MAPPING
from ssg.constants import FULL_NAME_TO_PRODUCT_MAPPING
from ssg_test_suite.log import LogHelper
import data

Scenario_run = namedtuple(
    "Scenario_run",
    ("rule_id", "script"))
Scenario_conditions = namedtuple(
    "Scenario_conditions",
    ("backend", "scanning_mode", "remediated_by", "datastream"))


try:
    SSH_ADDITIONAL_OPTS = tuple(os.environ.get('SSH_ADDITIONAL_OPTIONS').split())
except AttributeError:
    # If SSH_ADDITIONAL_OPTIONS is not defined set it to empty tuple.
    SSH_ADDITIONAL_OPTS = tuple()

SSH_ADDITIONAL_OPTS = (
    "-o", "StrictHostKeyChecking=no",
    "-o", "UserKnownHostsFile=/dev/null",
) + SSH_ADDITIONAL_OPTS


class Stage(object):
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
    remote_cmd = ['ssh'] + list(SSH_ADDITIONAL_OPTS) + [machine, command_string]
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


def _get_platform_cpes(platform):
    if platform.startswith("multi_platform_"):
        try:
            products = MULTI_PLATFORM_MAPPING[platform]
        except KeyError:
            logging.error(
                "Unknown multi_platform specifier: %s is not from %s"
                % (platform, ", ".join(MULTI_PLATFORM_MAPPING.keys())))
            raise ValueError
        platform_cpes = set()
        for p in products:
            platform_cpes |= set(PRODUCT_TO_CPE_MAPPING[p])
        return platform_cpes
    else:
        # scenario platform is specified by a full product name
        try:
            product = FULL_NAME_TO_PRODUCT_MAPPING[platform]
        except KeyError:
            logging.error(
                "Unknown product name: %s is not from %s"
                % (platform, ", ".join(FULL_NAME_TO_PRODUCT_MAPPING.keys())))
            raise ValueError
        platform_cpes = set(PRODUCT_TO_CPE_MAPPING[product])
        return platform_cpes


def matches_platform(scenario_platforms, benchmark_cpes):
    if "multi_platform_all" in scenario_platforms:
        return True
    scenario_cpes = set()
    for p in scenario_platforms:
        scenario_cpes |= _get_platform_cpes(p)
    return len(scenario_cpes & benchmark_cpes) > 0


def run_with_stdout_logging(command, args, log_file):
    log_file.write("{0} {1}\n".format(command, " ".join(args)))
    subprocess.check_call(
        (command,) + args, stdout=log_file, stderr=subprocess.STDOUT)


def send_scripts(domain_ip):
    remote_dir = './ssgts'
    archive_file = data.create_tarball('.')
    remote_archive_file = os.path.join(remote_dir, archive_file)
    machine = "root@{0}".format(domain_ip)
    logging.debug("Uploading scripts.")
    log_file_name = os.path.join(LogHelper.LOG_DIR, "data.upload.log")

    with open(log_file_name, 'a') as log_file:
        args = SSH_ADDITIONAL_OPTS + (machine, "mkdir", "-p", remote_dir)
        try:
            run_with_stdout_logging("ssh", args, log_file)
        except Exception:
            msg = "Cannot create directory {0}.".format(remote_dir)
            logging.error(msg)
            raise RuntimeError(msg)

        args = (SSH_ADDITIONAL_OPTS
                + (archive_file, "{0}:{1}".format(machine, remote_dir)))
        try:
            run_with_stdout_logging("scp", args, log_file)
        except Exception:
            msg = ("Cannot copy archive {0} to the target machine's directory {1}."
                   .format(archive_file, remote_dir))
            logging.error(msg)
            raise RuntimeError(msg)

        args = (SSH_ADDITIONAL_OPTS
                + (machine, "tar xf {0} -C {1}".format(remote_archive_file, remote_dir)))
        try:
            run_with_stdout_logging("ssh", args, log_file)
        except Exception:
            msg = "Cannot extract data tarball {0}.".format(remote_archive_file)
            logging.error(msg)
            raise RuntimeError(msg)

    return remote_dir
