import os
import logging
import subprocess
from collections import namedtuple
import functools
import tarfile
import tempfile

from ssg.constants import MULTI_PLATFORM_MAPPING
from ssg.constants import PRODUCT_TO_CPE_MAPPING
from ssg.constants import FULL_NAME_TO_PRODUCT_MAPPING
from ssg.constants import OSCAP_RULE
from ssg_test_suite.log import LogHelper

Scenario_run = namedtuple(
    "Scenario_run",
    ("rule_id", "script"))
Scenario_conditions = namedtuple(
    "Scenario_conditions",
    ("backend", "scanning_mode", "remediated_by", "datastream"))
Rule = namedtuple(
    "Rule", ["directory", "id", "short_id", "files"])

_BENCHMARK_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), '../../linux_os/guide'))
_SHARED_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), '../shared'))

REMOTE_USER = "root"
REMOTE_USER_HOME_DIRECTORY = "/root"
REMOTE_TEST_SCENARIOS_DIRECTORY = os.path.join(REMOTE_USER_HOME_DIRECTORY, "ssgts")

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
    machine = '{0}@{1}'.format(REMOTE_USER, domain_ip)
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


def _exclude_garbage(tarinfo):
    file_name = tarinfo.name
    if file_name.endswith('pyc'):
        return None
    if file_name.endswith('swp'):
        return None
    return tarinfo


def _make_file_root_owned(tarinfo):
    if tarinfo:
        tarinfo.uid = 0
        tarinfo.gid = 0
    return tarinfo


def create_tarball():
    """Create a tarball which contains all test scenarios for every rule.
    Tarball contains directories with the test scenarios. The name of the
    directories is the same as short rule ID. There is no tree structure.
    """
    with tempfile.NamedTemporaryFile(
            "wb", suffix=".tar.gz", delete=False) as fp:
        with tarfile.TarFile.open(fileobj=fp, mode="w") as tarball:
            tarball.add(_SHARED_DIR, arcname="shared", filter=_make_file_root_owned)
            for dirpath, dirnames, _ in os.walk(_BENCHMARK_DIR):
                rule_id = os.path.basename(dirpath)
                if "tests" in dirnames:
                    tests_dir_path = os.path.join(dirpath, "tests")
                    tarball.add(
                        tests_dir_path, arcname=rule_id,
                        filter=lambda tinfo: _exclude_garbage(_make_file_root_owned(tinfo))
                    )
        return fp.name


def send_scripts(domain_ip):
    remote_dir = REMOTE_TEST_SCENARIOS_DIRECTORY
    archive_file = create_tarball()
    archive_file_basename = os.path.basename(archive_file)
    remote_archive_file = os.path.join(remote_dir, archive_file_basename)
    machine = "{0}@{1}".format(REMOTE_USER, domain_ip)
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
    os.unlink(archive_file)
    return remote_dir


def iterate_over_rules():
    """Iterate over rule directories which have test scenarios".

    Returns:
        Named tuple Rule having these fields:
            directory -- absolute path to the rule "tests" subdirectory
                         containing the test scenarios in Bash
            id -- full rule id as it is present in datastream
            short_id -- short rule ID, the same as basename of the directory
                        containing the test scenarios in Bash
            files -- list of executable .sh files in the "tests" directory
    """
    for dirpath, dirnames, filenames in os.walk(_BENCHMARK_DIR):
        if "rule.yml" in filenames and "tests" in dirnames:
            short_rule_id = os.path.basename(dirpath)
            tests_dir = os.path.join(dirpath, "tests")
            tests_dir_files = os.listdir(tests_dir)
            # Filter out everything except the shell test scenarios.
            # Other files in rule directories are editor swap files
            # or other content than a test case.
            scripts = filter(lambda x: x.endswith(".sh"), tests_dir_files)
            full_rule_id = OSCAP_RULE + short_rule_id
            result = Rule(
                directory=tests_dir, id=full_rule_id, short_id=short_rule_id,
                files=scripts)
            yield result
