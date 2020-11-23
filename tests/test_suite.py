#!/usr/bin/env python2
from __future__ import print_function

import argparse
import textwrap
import logging
import os
import os.path
import time
import sys
from glob import glob
import re
import contextlib
import tempfile

ssg_dir = os.path.join(os.path.dirname(__file__), "..")
sys.path.append(ssg_dir)

from ssg_test_suite.log import LogHelper
import ssg_test_suite.oscap
import ssg_test_suite.test_env
import ssg_test_suite.profile
import ssg_test_suite.rule
import ssg_test_suite.combined
from ssg_test_suite import xml_operations


def parse_args():
    parser = argparse.ArgumentParser()

    common_parser = argparse.ArgumentParser(add_help=False)
    common_parser.set_defaults(test_env=None)

    backends = common_parser.add_mutually_exclusive_group(required=True)

    backends.add_argument(
        "--docker", dest="docker", metavar="BASE_IMAGE",
        help="Use Docker test environment with this base image.")
    backends.add_argument(
        "--container", dest="container", metavar="BASE_IMAGE",
        help="Use container test environment with this base image.")

    backends.add_argument(
        "--libvirt", dest="libvirt", metavar=("HYPERVISOR", "DOMAIN"), nargs=2,
        help="libvirt hypervisor and domain name. When the leading URI driver protocol "
        "is omitted from the hypervisor, qemu:/// protocol is assumed. "
        "Example of a hypervisor domain name tuple: system ssg-test-suite")

    common_parser.add_argument(
        "--datastream", dest="datastream", metavar="DATASTREAM",
        help="Path to the Source DataStream on this machine which is going to be tested. "
        "If not supplied, autodetection is attempted by looking into the build directory.")

    benchmarks = common_parser.add_mutually_exclusive_group()
    benchmarks.add_argument("--xccdf-id",
                               dest="xccdf_id",
                               metavar="REF-ID",
                               default=None,
                               help="Reference ID related to benchmark to "
                                    "be used.")
    benchmarks.add_argument("--xccdf-id-number",
                               dest="xccdf_id_number",
                               metavar="REF-ID-SELECT",
                               type=int,
                               default=0,
                               help="Selection number of reference ID related "
                                    "to benchmark to be used.")
    common_parser.add_argument(
            "--add-platform",
            metavar="<CPE REGEX>",
            default=None,
            help="Find all CPEs that are present in local OpenSCAP's CPE dictionary "
            "that match the provided regex, "
            "and add them as platforms to all datastream benchmarks. "
            "If the regex doesn't match anything, it will be treated "
            "as a literal CPE, and added as a platform. "
            "For example, use 'cpe:/o:fedoraproject:fedora:30' or 'enterprise_linux'.")
    common_parser.add_argument(
            "--remove-machine-only",
            default=False,
            action="store_true",
            help="Removes machine-only platform constraint from rules "
            "to enable testing these rules on container backends.")
    common_parser.add_argument("--loglevel",
                               dest="loglevel",
                               metavar="LOGLEVEL",
                               default="INFO",
                               help="Default level of console output")
    common_parser.add_argument("--logdir",
                               dest="logdir",
                               metavar="LOGDIR",
                               default=None,
                               help="Directory to which all output is saved")

    common_parser.add_argument(
        "--mode",
        dest="scanning_mode",
        default="online",
        choices=("online", "offline"),
        help="What type of check to use - either "
        "Online check done by running oscap inside the concerned system, or "
        "offline check that examines the filesystem from the host "
        "(either may require extended privileges).")

    common_parser.add_argument(
        "--remediate-using",
        dest="remediate_using",
        default="oscap",
        choices=ssg_test_suite.oscap.REMEDIATION_RULE_RUNNERS.keys(),
        help="What type of remediations to use - openscap online one, "
        "or remediation done by using remediation roles "
        "that are saved to disk beforehand.")

    subparsers = parser.add_subparsers(dest="subparser_name",
                                       help="Subcommands: profile, rule, combined")
    subparsers.required = True

    parser_profile = subparsers.add_parser("profile",
                                           formatter_class=argparse.RawDescriptionHelpFormatter,
                                           epilog=textwrap.dedent("""\
                    In case that tested profile contains rules which might prevent root ssh access
                    to the testing VM consider unselecting these rules. To unselect certain rules
                    from a datastream use `ds_unselect_rules.sh` script. List of such rules already
                    exists, see `unselect_rules_list` file.
                    Example usage:
                        ./ds_unselect_rules.sh ../build/ssg-fedora-ds.xml unselect_rules_list
                                           """),
                                           help=("Testing profile-based "
                                                 "remediation applied on already "
                                                 "installed machine"),
                                           parents=[common_parser])
    parser_profile.set_defaults(func=ssg_test_suite.profile.perform_profile_check)
    parser_profile.add_argument("target",
                                nargs="+",
                                metavar="DSPROFILE",
                                help=("Profiles to be tested, 'ALL' means every "
                                      "profile of particular benchmark will be "
                                      "evaluated."))

    parser_rule = subparsers.add_parser("rule",
                                        help=("Testing remediations of particular "
                                              "rule for various situations - "
                                              "currently not supported "
                                              "by openscap!"),
                                        parents=[common_parser])
    parser_rule.set_defaults(func=ssg_test_suite.rule.perform_rule_check)
    parser_rule.add_argument(
        "target",
        nargs="+",
        metavar="RULE",
        help=(
            "Rule or rules to be tested. Special value 'ALL' means every "
            "rule-testing scenario will be evaluated. The SSG rule ID prefix "
            "is appended automatically if not provided. Wildcards to match "
            "multiple rules are accepted."
            )
        )
    parser_rule.add_argument("--debug",
                             dest="manual_debug",
                             action="store_true",
                             help=("If an error is encountered, all execution "
                                   "on the VM / container will pause to allow "
                                   "debugging."))
    parser_rule.add_argument("--dontclean",
                             dest="dont_clean",
                             action="store_true",
                             help="Do not remove html reports of successful runs")
    parser_rule.add_argument("--scenarios",
                             dest="scenarios_regex",
                             default=None,
                             help="Regular expression matching test scenarios to run")
    parser_rule.add_argument("--profile",
                             dest="scenarios_profile",
                             default=None,
                             help="Override the profile used for test scenarios."
                                  " Variable selections will be done according "
                                  "to this profile.")

    parser_combined = subparsers.add_parser("combined",
                                            help=("Tests all rules in a profile evaluating them "
                                                  "against their test scenarios."),
                                            parents=[common_parser])
    parser_combined.set_defaults(func=ssg_test_suite.combined.perform_combined_check)
    parser_combined.add_argument("--dontclean",
                                 dest="dont_clean",
                                 action="store_true",
                                 help="Do not remove html reports of successful runs")
    parser_combined.add_argument("--scenarios",
                                 dest="scenarios_regex",
                                 default=None,
                                 help="Regular expression matching test scenarios to run")
    parser_combined.add_argument("target",
                                 metavar="TARGET",
                                 help=("Profile whose rules are to be tested. Each rule selected "
                                       "in the profile will be evaluated against all its test "
                                       "scenarios."))

    return parser.parse_args()


def get_logging_dir(options):
    body = 'custom'
    if 'ALL' in options.target:
        body = 'ALL'

    generic_logdir_stem = "{0}-{1}".format(options.subparser_name, body)

    if options.logdir is None:

        date_string = time.strftime('%Y-%m-%d-%H%M', time.localtime())
        logging_dir = os.path.join(
            os.getcwd(), 'logs', '{0}-{1}'.format(
                generic_logdir_stem, date_string))
        logging_dir = LogHelper.find_name(logging_dir)
    else:
        logging_dir = LogHelper.find_name(options.logdir)

    return logging_dir


def _print_available_benchmarks(xccdf_ids, n_xccdf_ids):
    logging.info("The DataStream contains {0} Benchmarks".format(n_xccdf_ids))
    for i in range(0, n_xccdf_ids):
        logging.info("{0} - {1}".format(i, xccdf_ids[i]))


def auto_select_xccdf_id(datastream, bench_number):
    xccdf_ids = xml_operations.get_all_xccdf_ids_in_datastream(datastream)
    n_xccdf_ids = len(xccdf_ids)

    if n_xccdf_ids == 0:
        msg = ("The provided DataStream doesn't contain any Benchmark")
        raise RuntimeError(msg)

    if bench_number < 0 or bench_number >= n_xccdf_ids:
        _print_available_benchmarks(xccdf_ids, n_xccdf_ids)
        logging.info("Selected Benchmark is {0}".format(bench_number))

        msg = ("Please select a valid Benchmark number")
        raise RuntimeError(msg)

    if n_xccdf_ids > 1:
        _print_available_benchmarks(xccdf_ids, n_xccdf_ids)
        logging.info("Selected Benchmark is {0}".format(bench_number))

        logging.info("To select a different Benchmark, "
                     "use --xccdf-id-number option.")

    return xccdf_ids[bench_number]


def get_datastreams():
    ds_glob = "ssg-*-ds.xml"
    build_dir_path = [os.path.dirname(__file__) or ".", "..", "build"]
    glob_pattern = os.path.sep.join(build_dir_path + [ds_glob])
    datastreams = [os.path.normpath(p) for p in glob(glob_pattern)]
    return datastreams


def get_unique_datastream():
    datastreams = get_datastreams()
    if len(datastreams) == 1:
        return datastreams[0]
    msg = ("Autodetection of the datastream file is possible only when there is "
           "a single one in the build dir, but")
    if not datastreams:
        raise RuntimeError(msg + " there is none.")
    raise RuntimeError(
        msg + " there are {0} of them. Use the --datastream option to select "
        "e.g. {1}".format(len(datastreams), datastreams))


@contextlib.contextmanager
def datastream_in_stash(current_location):
    tfile = tempfile.NamedTemporaryFile(prefix="ssgts-ds-")

    tfile.write(open(current_location, "rb").read())
    tfile.flush()
    yield tfile.name


def normalize_passed_arguments(options):
    if 'ALL' in options.target:
        options.target = ['ALL']

    if not options.datastream:
        options.datastream = get_unique_datastream()

    if options.xccdf_id is None:
        options.xccdf_id = auto_select_xccdf_id(options.datastream,
                                                options.xccdf_id_number)
    try:
        bench_id = xml_operations.infer_benchmark_id_from_component_ref_id(
            options.datastream, options.xccdf_id)
        options.benchmark_id = bench_id
    except RuntimeError as exc:
        msg = "Error inferring benchmark ID from component refId: {}".format(str(exc))
        raise RuntimeError(msg)

    if options.docker:
        options.test_env = ssg_test_suite.test_env.DockerTestEnv(
            options.scanning_mode, options.docker)
        logging.info(
            "The base image option has been specified, "
            "choosing Docker-based test environment.")
    elif options.container:
        options.test_env = ssg_test_suite.test_env.PodmanTestEnv(
            options.scanning_mode, options.container)
        logging.info(
            "The base image option has been specified, "
            "choosing Podman-based test environment.")
    else:
        hypervisor, domain_name = options.libvirt
        # Possible hypervisor spec we have to catch: qemu+unix:///session
        if not re.match(r"[\w\+]+:///", hypervisor):
            hypervisor = "qemu:///" + hypervisor
        options.test_env = ssg_test_suite.test_env.VMTestEnv(
            options.scanning_mode, hypervisor, domain_name)
        logging.info(
            "The base image option has not been specified, "
            "choosing libvirt-based test environment.")

    try:
        benchmark_cpes = xml_operations.benchmark_get_applicable_platforms(
            options.datastream, options.benchmark_id
        )
        options.benchmark_cpes = benchmark_cpes
    except RuntimeError as exc:
        msg = "Error inferring platform from benchmark: {}".format(str(exc))
        raise RuntimeError(msg)


def main():
    options = parse_args()

    log = logging.getLogger()
    # this is general logger level - needs to be
    # debug otherwise it cuts silently everything
    log.setLevel(logging.DEBUG)

    LogHelper.add_console_logger(log, options.loglevel)

    try:
        normalize_passed_arguments(options)
    except RuntimeError as exc:
        msg = "Error occurred during options normalization: {}".format(str(exc))
        logging.error(msg)
        sys.exit(1)
    # logging dir needs to be created based on other options
    # thus we have to postprocess it

    logging_dir = get_logging_dir(options)

    LogHelper.add_logging_dir(log, logging_dir)

    with datastream_in_stash(options.datastream) as stashed_datastream:
        options.datastream = stashed_datastream

        with xml_operations.datastream_root(stashed_datastream, stashed_datastream) as root:
            if options.remove_machine_only:
                xml_operations.remove_machine_platform(root)
                xml_operations.remove_machine_remediation_condition(root)
            if options.add_platform:
                xml_operations.add_platform_to_benchmark(root, options.add_platform)

        options.func(options)


if __name__ == "__main__":
    main()
