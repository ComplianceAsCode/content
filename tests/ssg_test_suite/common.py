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
import time

import ssg.yaml
from ssg.build_cpe import ProductCPEs
from ssg.build_yaml import Rule as RuleYAML
from ssg.constants import MULTI_PLATFORM_MAPPING
from ssg.constants import FULL_NAME_TO_PRODUCT_MAPPING
from ssg.constants import OSCAP_RULE
from ssg.jinja import process_file_with_macros
from ssg.products import product_yaml_path, load_product_yaml
from ssg.rules import get_rule_dir_yaml, is_rule_dir
from ssg.rule_yaml import parse_prodtype
from ssg_test_suite.log import LogHelper

import ssg.templates


Scenario_run = namedtuple(
    "Scenario_run",
    ("rule_id", "script"))
Scenario_conditions = namedtuple(
    "Scenario_conditions",
    ("backend", "scanning_mode", "remediated_by", "datastream"))

SSG_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..'))

_BENCHMARK_DIRS = [
        os.path.abspath(os.path.join(SSG_ROOT, 'linux_os', 'guide')),
        os.path.abspath(os.path.join(SSG_ROOT, 'applications')),
        ]

_SHARED_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), '../shared'))

_SHARED_TEMPLATES = os.path.abspath(os.path.join(SSG_ROOT, 'shared/templates'))

TEST_SUITE_NAME="ssgts"
TEST_SUITE_PREFIX = "_{}".format(TEST_SUITE_NAME)
REMOTE_USER = "root"
REMOTE_USER_HOME_DIRECTORY = "/root"
REMOTE_TEST_SCENARIOS_DIRECTORY = os.path.join(REMOTE_USER_HOME_DIRECTORY, TEST_SUITE_NAME)

try:
    SSH_ADDITIONAL_OPTS = tuple(os.environ.get('SSH_ADDITIONAL_OPTIONS').split())
except AttributeError:
    # If SSH_ADDITIONAL_OPTIONS is not defined set it to empty tuple.
    SSH_ADDITIONAL_OPTS = tuple()

SSH_ADDITIONAL_OPTS = (
    "-o", "StrictHostKeyChecking=no",
    "-o", "UserKnownHostsFile=/dev/null",
) + SSH_ADDITIONAL_OPTS

TESTS_CONFIG_NAME = "test_config.yml"


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
            p_cpes = ProductCPEs()
            p_cpes.load_product_cpes(product_yaml)
            p_cpes.load_content_cpes(product_yaml)
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
        product_cpes = ProductCPEs()
        product_cpes.load_product_cpes(product_yaml)
        product_cpes.load_content_cpes(product_yaml)
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
            stderr=subprocess.PIPE, check=False)
    if result.stdout:
        log_file.write("STDOUT: ")
        log_file.write(result.stdout)
    if result.stderr:
        log_file.write("STDERR: ")
        log_file.write(result.stderr)
    return result


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
        # set permission to 775
        tarinfo.mode = 509
    return tarinfo


def get_product_context(product=None):
    """
    Returns a product YAML context if any product is specified. Hard-coded to
    assume a debug build.
    """
    # Load product's YAML file if present. This will allow us to parse
    # tests in the context of the product we're executing under.
    product_yaml = dict()
    if product:
        yaml_path = product_yaml_path(SSG_ROOT, product)
        product_yaml = load_product_yaml(yaml_path)

    # We could run into a DocumentationNotComplete error when loading a
    # rule's YAML contents. However, because the test suite isn't executed
    # in the context of a particular build (though, ideally it would be
    # linked), we may not know exactly whether the top-level rule/profile
    # we're testing is actually completed. Thus, forcibly set the required
    # property to bypass this error.
    product_yaml['cmake_build_type'] = 'Debug'

    # Set the Jinja processing environment to Test Suite,
    # this allows Jinja macros to behave differently in a content build time and in a test time.
    product_yaml['SSG_TEST_SUITE_ENV'] = True

    return product_yaml


def load_rule_and_env(rule_dir_path, env_yaml, product=None):
    """
    Loads a rule and returns the combination of the RuleYAML class and
    the corresponding local environment for that rule.
    """

    # First build the path to the rule.yml file
    rule_path = get_rule_dir_yaml(rule_dir_path)

    # Load rule content in our environment. We use this to satisfy
    # some implied properties that might be used in the test suite.
    # Make sure we normalize to a specific product as well so that
    # when we load templated content it is correct.
    rule = RuleYAML.from_yaml(rule_path, env_yaml)
    rule.normalize(product)

    # Note that most places would check prodtype, but we don't care
    # about that here: if the rule is available to the product, we
    # load and parse it anyways as we have no knowledge of the
    # top-level profile or rule passed into the test suite.
    prodtypes = parse_prodtype(rule.prodtype)

    # Our local copy of env_yaml needs some properties from rule.yml
    # for completeness.
    local_env_yaml = dict()
    local_env_yaml.update(env_yaml)
    local_env_yaml['rule_id'] = rule.id_
    local_env_yaml['rule_title'] = rule.title
    local_env_yaml['products'] = prodtypes

    return rule, local_env_yaml


def write_rule_test_content_to_dir(rule_dir, test_content):
    for scenario in test_content.scenarios:
        scenario_file_path = os.path.join(rule_dir, scenario.script)
        with open(scenario_file_path, "w") as f:
            f.write(scenario.contents)
    for file_name, file_content in test_content.other_content.items():
        file_path = os.path.join(rule_dir, file_name)
        with open(file_path, "w") as f:
            f.write(file_content)


def create_tarball(test_content_by_rule_id):
    """
    Create a tarball which contains all test scenarios and additional
    content for every rule that is selected to be tested. The tarball contains
    directories with the test scenarios. The name of the directories is the
    same as short rule ID. There is no tree structure.
    """

    tmpdir = tempfile.mkdtemp()
    for rule_id, test_content in test_content_by_rule_id.items():
        short_rule_id = rule_id.replace(OSCAP_RULE, "")
        rule_dir = os.path.join(tmpdir, short_rule_id)
        os.mkdir(rule_dir)
        write_rule_test_content_to_dir(rule_dir, test_content)

    try:
        with tempfile.NamedTemporaryFile(
                "wb", suffix=".tar.gz", delete=False) as fp:
            with tarfile.TarFile.open(fileobj=fp, mode="w") as tarball:
                tarball.add(_SHARED_DIR, arcname="shared", filter=_make_file_root_owned)
                for rule_id in os.listdir(tmpdir):
                    # When a top-level directory exists under the temporary
                    # templated tests directory, we've already validated that
                    # it is a valid rule directory. Thus we can simply add it
                    # to the tarball.
                    absolute_dir = os.path.join(tmpdir, rule_id)
                    if not os.path.isdir(absolute_dir):
                        continue

                    tarball.add(
                        absolute_dir, arcname=rule_id,
                        filter=lambda tinfo: _exclude_garbage(_make_file_root_owned(tinfo))
                    )

            # Since we've added the templated contents into the tarball, we
            # can now delete the tree.
            shutil.rmtree(tmpdir, ignore_errors=True)
            return fp.name
    except Exception as exp:
        shutil.rmtree(tmpdir, ignore_errors=True)
        raise exp


def send_scripts(test_env, test_content_by_rule_id):
    remote_dir = REMOTE_TEST_SCENARIOS_DIRECTORY
    archive_file = create_tarball(test_content_by_rule_id)
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


def get_prefixed_name(state_name):
    return "{}_{}".format(TEST_SUITE_PREFIX, state_name)


def get_test_dir_config(test_dir, product_yaml):
    test_config = dict()
    test_config_filename = os.path.join(test_dir, TESTS_CONFIG_NAME)
    if os.path.exists(test_config_filename):
        test_config = ssg.yaml.open_and_expand(test_config_filename, product_yaml)
    return test_config


def select_templated_tests(test_dir_config, available_scenarios_basenames):
    deny_scenarios = set(test_dir_config.get("deny_templated_scenarios", []))
    available_scenarios_basenames = {
        test_name for test_name in available_scenarios_basenames
        if test_name not in deny_scenarios
    }

    allow_scenarios = set(test_dir_config.get("allow_templated_scenarios", []))
    if allow_scenarios:
        available_scenarios_basenames = {
            test_name for test_name in available_scenarios_basenames
            if test_name in allow_scenarios
        }

    allowed_and_denied = deny_scenarios.intersection(allow_scenarios)
    if allowed_and_denied:
        msg = (
            "Test directory configuration contain inconsistencies: {allowed_and_denied} "
            "scenarios are both allowed and denied."
            .format(test_dir_config=test_dir_config, allowed_and_denied=allowed_and_denied)
        )
        raise ValueError(msg)
    return available_scenarios_basenames


def fetch_templated_tests_paths(
        rule_namedtuple, product_yaml):
    rule = rule_namedtuple.rule
    if not rule.template or not rule.template['vars']:
        return dict()
    tests_paths = fetch_all_templated_tests_paths(rule.template)
    test_config = get_test_dir_config(rule_namedtuple.directory, product_yaml)
    allowed_tests_paths = select_templated_tests(
        test_config, tests_paths.keys())
    templated_test_scenarios = {
        name: tests_paths[name] for name in allowed_tests_paths}
    return templated_test_scenarios


def fetch_all_templated_tests_paths(rule_template):
    """
    Builds a dictionary of a test case relative path -> test case absolute path mapping.

    Here, we want to know what the relative path on disk (under the tests/
    subdirectory) is (such as "installed.pass.sh"), along with the actual
    absolute path.
    """
    template_name = rule_template['name']

    base_dir = os.path.abspath(os.path.join(_SHARED_TEMPLATES, template_name, "tests"))
    results = dict()

    # If no test cases exist, return an empty dictionary.
    if not os.path.exists(base_dir):
        return results

    # Walk files; note that we don't need to do anything about directories
    # as only files are recorded in the mapping; directories can be
    # inferred from the path.
    for dirpath, _, filenames in os.walk(base_dir):
        if not filenames:
            continue

        for filename in filenames:
            if filename.endswith(".swp"):
                continue

            # Relative path to the file becomes our results key.
            absolute_path = os.path.abspath(os.path.join(dirpath, filename))
            relative_path = os.path.relpath(absolute_path, base_dir)

            # Save the results under the relative path.
            results[relative_path] = absolute_path
    return results


def load_templated_tests(
        templated_tests_paths, template, local_env_yaml):
    templated_tests = dict()
    for path in templated_tests_paths:
        test = load_test(path, template, local_env_yaml)
        basename = os.path.basename(path)
        templated_tests[basename] = test
    return templated_tests


def load_test(absolute_path, rule_template, local_env_yaml):
    template_name = rule_template['name']
    template_vars = rule_template['vars']
    # Load template parameters and apply it to the test case.
    maybe_template = ssg.templates.Template.load_template(_SHARED_TEMPLATES, template_name)
    if maybe_template is not None:
        template_parameters = maybe_template.preprocess(template_vars, "tests")
    else:
        raise ValueError("Rule uses template '{}' "
                         "which doesn't exist in '{}".format(template_name, _SHARED_TEMPLATES))

    jinja_dict = ssg.utils.merge_dicts(local_env_yaml, template_parameters)
    filled_template = ssg.jinja.process_file_with_macros(
        absolute_path, jinja_dict)
    return filled_template


def file_known_as_useless(file_name):
    return file_name.endswith(".swp")


def fetch_local_tests_paths(tests_dir):
    if not os.path.exists(tests_dir):
        return dict()
    all_tests = dict()
    tests_dir_files = os.listdir(tests_dir)
    for test_case in tests_dir_files:
        # Skip vim swap files, they are not relevant and cause Jinja
        # expansion tracebacks
        if file_known_as_useless(test_case):
            continue
        test_path = os.path.join(tests_dir, test_case)
        if os.path.isdir(test_path):
            continue
        all_tests[test_case] = test_path
    return all_tests


def load_local_tests(local_tests_paths, local_env_yaml):
    local_tests = dict()
    for path in local_tests_paths:
        test = process_file_with_macros(path, local_env_yaml)
        basename = os.path.basename(path)
        local_tests[basename] = test
    return local_tests


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
    ol7=("yum", "install", "-y"),
    ol8=("yum", "install", "-y"),
    ol9=("yum", "install", "-y"),
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
            "Couldn't install required packages: {packages}".format(packages=",".join(packages)))


def cpes_to_platform(cpes):
    rhel_cpe = {"redhat:enterprise_linux": r":enterprise_linux:([^:]+):", "centos:centos": r"centos:centos:([0-9]+)"}
    for cpe in cpes:
        if "fedora" in cpe:
            return "fedora"
        for cpe_item in rhel_cpe.keys():
            if cpe_item in cpe:
                match = re.search(rhel_cpe.get(cpe_item), cpe)
                if match:
                    major_version = match.groups()[0].split(".")[0]
                    return "rhel" + major_version
        if "ubuntu" in cpe:
            return "ubuntu"
        if "oracle:linux" in cpe:
            match = re.search(r":linux:([^:]+):", cpe)
            if match:
                major_version = match.groups()[0]
                return "ol" + major_version
    msg = "Unable to deduce a platform from these CPEs: {cpes}".format(cpes=cpes)
    raise ValueError(msg)


def retry_with_stdout_logging(command, args, log_file, max_attempts=5):
    attempt = 0
    while attempt < max_attempts:
        result = run_with_stdout_logging(command, args, log_file)
        if result.returncode == 0:
            return result
        attempt += 1
        time.sleep(1)
    return result
