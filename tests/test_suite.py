#!/usr/bin/env python2
from __future__ import print_function

import argparse
import logging
import os
import os.path
import time
import sys

ssg_dir = os.path.join(os.path.dirname(__file__), "..")
sys.path.append(ssg_dir)

from ssg_test_suite.log import LogHelper
import ssg_test_suite.oscap
import ssg_test_suite.test_env
import ssg_test_suite.profile
import ssg_test_suite.rule
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
        "--libvirt", dest="libvirt", metavar="HYPERVISOR DOMAIN", nargs=2,
        help="libvirt hypervisor and domain name. "
        "Example of a hypervisor domain name tuple: qemu:///system ssg-test-suite")

    common_parser.add_argument("--datastream",
                               dest="datastream",
                               metavar="DATASTREAM",
                               required=True,
                               help=("Path to the Source DataStream on this "
                                     "machine which is going to be tested"))
    common_parser.add_argument("--xccdf-id",
                               dest="xccdf_id",
                               metavar="REF-ID",
                               required=True,
                               help="Reference ID related to benchmark to be used."
                                    " Get one using 'oscap info <datastream>'.")
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
                                       help="Subcommands: profile, rule")
    subparsers.required = True

    parser_profile = subparsers.add_parser("profile",
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
    parser_rule.add_argument("target",
                             nargs="+",
                             metavar="RULE",
                             help=("Rule to be tested, 'ALL' means every "
                                   "rule-testing scenario will be evaluated. Each "
                                   "target is handled as a substring - so you can "
                                   "ask for subset of all rules this way. (If you "
                                   "type ipv6 as a target, all rules containing "
                                   "ipv6 within id will be performed."))
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


def normalize_passed_arguments(options):
    if 'ALL' in options.target:
        options.target = ['ALL']

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
    else:
        hypervisor, domain_name = options.libvirt
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

    options.func(options)


if __name__ == "__main__":
    main()
