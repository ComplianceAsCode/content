from __future__ import print_function

import os
import logging
import subprocess
from collections import namedtuple
import functools
import tarfile
import tempfile
import re
import shutil

from ssg.build_cpe import ProductCPEs
from ssg.build_yaml import Rule as RuleYAML
from ssg.constants import MULTI_PLATFORM_MAPPING
from ssg.constants import FULL_NAME_TO_PRODUCT_MAPPING
from ssg.constants import OSCAP_RULE
from ssg.jinja import process_file
from ssg.products import product_yaml_path, load_product_yaml
from ssg.rules import get_rule_dir_yaml, is_rule_dir
from ssg.rule_yaml import parse_prodtype
from ssg_test_suite.log import LogHelper

Scenario_run = namedtuple(
    "Scenario_run",
    ("rule_id", "script"))
Scenario_conditions = namedtuple(
    "Scenario_conditions",
    ("backend", "scanning_mode", "remediated_by", "datastream"))
Rule = namedtuple(
    "Rule", ["directory", "id", "short_id", "files"])

SSG_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..'))

_BENCHMARK_DIRS = [
        os.path.abspath(os.path.join(SSG_ROOT, 'linux_os', 'guide')),
        os.path.abspath(os.path.join(SSG_ROOT, 'applications')),
        ]

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


def walk_through_benchmark_dirs(product=None):
    directories = _BENCHMARK_DIRS
    if product is not None:
        yaml_path = product_yaml_path(SSG_ROOT, product)
        product_base = os.path.dirname(yaml_path)
        product_yaml = load_product_yaml(yaml_path)
        benchmark_root = os.path.join(product_base, product_yaml['benchmark_root'])
        directories = [os.path.abspath(benchmark_root)]

    for dirname in directories:
        for dirpath, dirnames, filenames in os.walk(dirname):
            yield dirpath, dirnames, filenames


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
    ssg_root = os.path.dirname(os.path.dirname(os.path.dirname(__file__)))
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
            product_yaml_path = os.path.join(ssg_root, "products", p, "product.yml")
            product_yaml = load_product_yaml(product_yaml_path)
            p_cpes = ProductCPEs(product_yaml)
            platform_cpes |= set(p_cpes.get_product_cpe_names())
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
        product_yaml_path = os.path.join(ssg_root, "products", product, "product.yml")
        product_yaml = load_product_yaml(product_yaml_path)
        product_cpes = ProductCPEs(product_yaml)
        platform_cpes = set(product_cpes.get_product_cpe_names())
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
    result = subprocess.run(
            (command,) + args, encoding="utf-8", stdout=subprocess.PIPE,
            stderr=subprocess.PIPE, check=True)
    if result.stdout:
        log_file.write("STDOUT: ")
        log_file.write(result.stdout)
    if result.stderr:
        log_file.write("STDERR: ")
        log_file.write(result.stderr)
    return result.stdout


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


def _rel_abs_path(current_path, base_path):
    """
    Return the value of the current path, relative to the base path, but
    resolving paths absolutely first. This helps when walking a nested
    directory structure and want to get the subtree relative to the original
    path
    """
    tmp_path = os.path.abspath(current_path)
    return os.path.relpath(current_path, base_path)


def template_tests(product=None):
    """
    Create a temporary directory with test cases parsed via jinja using
    product-specific context.
    """
    # Set up an empty temp directory
    tmpdir = tempfile.mkdtemp()

    # We want to remove the temporary directory on failure, but preserve
    # it on success. Wrap in a try/except block and reraise the original
    # exception after removing the temporary directory.
    try:
        # Load product's YAML file if present. This will allow us to parse
        # tests in the context of the product we're executing under.
        product_yaml = dict()
        if product:
            yaml_path = product_yaml_path(SSG_ROOT, product)
            product_yaml = load_product_yaml(yaml_path)

        # Below we could run into a DocumentationNotComplete error. However,
        # because the test suite isn't executed in the context of a particular
        # build (though, ideally it would be linked), we may not know exactly
        # whether the top-level rule/profile we're testing is actually
        # completed. Thus, forcibly set the required property to bypass this
        # error.
        product_yaml['cmake_build_type'] = 'Debug'

        # Note that we're not exactly copying 1-for-1 the contents of the
        # directory structure into the temporary one. Instead we want a
        # flattened mapping with all rules in a single top-level directory
        # and all tests immediately contained within it. That is:
        #
        # /group_a/rule_a/tests/something.pass.sh -> /rule_a/something.pass.sh
        for dirpath, dirnames, _ in walk_through_benchmark_dirs(product):
            # Skip anything that isn't obviously a rule.
            if "tests" not in dirnames or not is_rule_dir(dirpath):
                continue

            # Load rule content in our environment. We use this to satisfy
            # some implied properties that might be used in the test suite.
            rule_path = get_rule_dir_yaml(dirpath)
            rule = RuleYAML.from_yaml(rule_path, product_yaml)

            # Note that most places would check prodtype, but we don't care
            # about that here: if the rule is available to the product, we
            # load and parse it anyways as we have no knowledge of the
            # top-level profile or rule passed into the test suite.
            prodtypes = parse_prodtype(rule.prodtype)

            # Our local copy of env_yaml needs some properties from rule.yml
            # for completeness.
            local_env_yaml = dict()
            local_env_yaml.update(product_yaml)
            local_env_yaml['rule_id'] = rule.id_
            local_env_yaml['rule_title'] = rule.title
            local_env_yaml['products'] = prodtypes

            # Create the destination directory.
            dest_path = os.path.join(tmpdir, rule.id_)
            os.mkdir(dest_path)

            # Walk the test directory, writing all tests into the output
            # directory, recursively.
            tests_dir_path = os.path.join(dirpath, "tests")
            tests_dir_path = os.path.abspath(tests_dir_path)
            for dirpath, dirnames, filenames in os.walk(tests_dir_path):
                for dirname in dirnames:
                    # We want to recreate the correct path under the temporary
                    # directory. Resolve it to a relative path from the tests/
                    # directory.
                    dir_path = _rel_abs_path(os.path.join(dirpath, dirname), tests_dir_path)
                    assert '../' not in dir_path
                    tmp_dir_path = os.path.join(dest_path, dir_path)
                    os.mkdir(tmp_dir_path)

                for filename in filenames:
                    # We want to recreate the correct path under the temporary
                    # directory. Resolve it to a relative path from the tests/
                    # directory. Assumption: directories should be created
                    # prior to recursing into them, so we don't need to handle
                    # if a file's parent directory doesn't yet exist under the
                    # destination.
                    src_test_path = os.path.join(dirpath, filename)
                    rel_test_path = _rel_abs_path(src_test_path, tests_dir_path)
                    dest_test_path = os.path.join(dest_path, rel_test_path)

                    # Rather than performing an OS-level copy, we need to
                    # first parse the test with jinja and then write it back
                    # out to the destination.
                    parsed_test = process_file(src_test_path, local_env_yaml)
                    with open(dest_test_path, 'w') as output_fp:
                        print(parsed_test, file=output_fp)

    except Exception as exp:
        shutil.rmtree(tmpdir, ignore_errors=True)
        raise exp

    return tmpdir


def create_tarball(product):
    """Create a tarball which contains all test scenarios for every rule.
    Tarball contains directories with the test scenarios. The name of the
    directories is the same as short rule ID. There is no tree structure.
    """
    templated_tests = template_tests(product=product)

    try:
        with tempfile.NamedTemporaryFile(
                "wb", suffix=".tar.gz", delete=False) as fp:
            with tarfile.TarFile.open(fileobj=fp, mode="w") as tarball:
                tarball.add(_SHARED_DIR, arcname="shared", filter=_make_file_root_owned)
                for rule_id in os.listdir(templated_tests):
                    # When a top-level directory exists under the temporary
                    # templated tests directory, we've already validated that
                    # it is a valid rule directory. Thus we can simply add it
                    # to the tarball.
                    absolute_dir = os.path.join(templated_tests, rule_id)
                    if not os.path.isdir(absolute_dir):
                        continue

                    tarball.add(
                        absolute_dir, arcname=rule_id,
                        filter=lambda tinfo: _exclude_garbage(_make_file_root_owned(tinfo))
                    )

            # Since we've added the templated contents into the tarball, we
            # can now delete the tree.
            shutil.rmtree(templated_tests, ignore_errors=True)
            return fp.name
    except Exception as exp:
        shutil.rmtree(templated_tests, ignore_errors=True)
        raise exp


def send_scripts(test_env):
    remote_dir = REMOTE_TEST_SCENARIOS_DIRECTORY
    archive_file = create_tarball(test_env.product)
    archive_file_basename = os.path.basename(archive_file)
    remote_archive_file = os.path.join(remote_dir, archive_file_basename)
    logging.debug("Uploading scripts.")
    log_file_name = os.path.join(LogHelper.LOG_DIR, "env-preparation.log")

    with open(log_file_name, 'a') as log_file:
        print("Setting up test setup scripts", file=log_file)

        test_env.execute_ssh_command(
            "mkdir -p {remote_dir}".format(remote_dir=remote_dir),
            log_file, "Cannot create directory {0}".format(remote_dir))
        test_env.scp_upload_file(
            archive_file, remote_dir,
            log_file, "Cannot copy archive {0} to the target machine's directory {1}"
            .format(archive_file, remote_dir))
        test_env.execute_ssh_command(
            "tar xf {remote_archive_file} -C {remote_dir}"
            .format(remote_dir=remote_dir, remote_archive_file=remote_archive_file),
            log_file, "Cannot extract data tarball {0}".format(remote_archive_file))
    os.unlink(archive_file)
    return remote_dir


def iterate_over_rules(product=None):
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
    for dirpath, dirnames, filenames in walk_through_benchmark_dirs(product):
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


def get_cpe_of_tested_os(test_env, log_file):
    os_release_file = "/etc/os-release"
    cpe_line = test_env.execute_ssh_command(
        "grep CPE_NAME {os_release_file}".format(os_release_file=os_release_file),
        log_file)
    # We are parsing an assignment that is possibly quoted
    cpe = re.match(r'''CPE_NAME=(["']?)(.*)\1''', cpe_line)
    if cpe and cpe.groups()[1]:
        return cpe.groups()[1]
    msg = ["Unable to get a CPE of the system running tests"]
    if cpe_line:
        msg.append(
            "Retreived a CPE line that we couldn't parse: {cpe_line}"
            .format(cpe_line=cpe_line))
    else:
        msg.append(
            "Couldn't get CPE entry from '{os_release_file}'"
            .format(os_release_file=os_release_file))
    raise RuntimeError("\n".join(msg))


INSTALL_COMMANDS = dict(
    fedora=("dnf", "install", "-y"),
    rhel7=("yum", "install", "-y"),
    rhel8=("yum", "install", "-y"),
    rhel9=("yum", "install", "-y"),
    ubuntu=("DEBIAN_FRONTEND=noninteractive", "apt", "install", "-y"),
)


def install_packages(test_env, packages):
    log_file_name = os.path.join(LogHelper.LOG_DIR, "env-preparation.log")

    with open(log_file_name, "a") as log_file:
        platform_cpe = get_cpe_of_tested_os(test_env, log_file)
    platform = cpes_to_platform([platform_cpe])

    command_str = " ".join(INSTALL_COMMANDS[platform] + tuple(packages))

    with open(log_file_name, 'a') as log_file:
        print("Installing packages", file=log_file)
        log_file.flush()
        test_env.execute_ssh_command(
            command_str, log_file,
            "Couldn't install required packages {packages}".format(packages=packages))


def cpes_to_platform(cpes):
    for cpe in cpes:
        if "fedora" in cpe:
            return "fedora"
        if "redhat:enterprise_linux" in cpe:
            match = re.search(r":enterprise_linux:([^:]+):", cpe)
            if match:
                major_version = match.groups()[0].split(".")[0]
                return "rhel" + major_version
        if "ubuntu" in cpe:
            return "ubuntu"
    msg = "Unable to deduce a platform from these CPEs: {cpes}".format(cpes=cpes)
    raise ValueError(msg)
