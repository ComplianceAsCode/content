#!/usr/bin/python3

import sys
import time
import gzip
import logging
import argparse
import contextlib
from pathlib import Path

from atex.provisioner.testingfarm import TestingFarmProvisioner
from atex.orchestrator.contest import ContestOrchestrator
from atex.aggregator.json import JSONAggregator
from atex.fmf import FMFTests

logger = logging.getLogger("ATEX")

# Parse command-line arguments
parser = argparse.ArgumentParser(description="Run tests on Testing Farm using atex")
parser.add_argument("--contest-dir", required=True, help="Path to contest repository")
parser.add_argument("--content-dir", required=True, help="Path to built content directory")
parser.add_argument("--plan", required=True, help="TMT plan to run (e.g., daily|ci-gating|weekly)")
parser.add_argument("--compose", required=True, help="compose (e.g., Centos-Stream-9)")
parser.add_argument("--arch", default="x86_64", help="Architecture")
parser.add_argument("--os-major-version", required=True, help="OS Major Version (8|9|10)")
parser.add_argument("--tests", nargs="*", help="Specific tests to run (optional, runs all if not specified)")
parser.add_argument("--timeout", type=int, default=120, help="Timeout in minutes")
parser.add_argument("--max-remotes", type=int, default=10, help="Maximum number of parallel test executions")
parser.add_argument("--reruns", type=int, default=1, help="Number of test reruns on failure")
args = parser.parse_args()

# variables export to tests
test_env = {
    "CONTEST_CONTENT": ContestOrchestrator.content_dir_on_remote,
    "CONTEST_VERBOSE": "2",
}

with contextlib.ExitStack() as stack:
    # log brief info to console, be verbose in a separate file-based log
    console_log = logging.StreamHandler(sys.stderr)
    console_log.setLevel(logging.INFO)
    debug_log_fobj = stack.enter_context(gzip.open("atex_debug.log.gz", "wt"))
    file_log = logging.StreamHandler(debug_log_fobj)
    file_log.setLevel(logging.DEBUG)
    logging.basicConfig(
        level=logging.DEBUG,
        format="%(asctime)s %(name)s: %(message)s",
        datefmt="%Y-%m-%d %H:%M:%S",
        handlers=(console_log, file_log),
        force=True,
    )

    # Load FMF tests from contest directory
    fmf_tests = FMFTests(
        args.contest_dir,
        args.plan,
        names=args.tests or None,
        context={
            "distro": f"centos-stream-{args.os_major_version}",
            "arch": args.arch,
        },
    )

    logger.info(f"plan: {args.plan}")
    logger.info(f"os major version: {args.os_major_version}")
    logger.info(f"arch: {args.arch}")
    logger.info(f"compose: {args.compose}")
    logger.info("will run:")
    for test in fmf_tests.tests:
        logger.info(f"    {test}")

    # Setup result aggregator
    output_results = f"results-centos-stream-{args.os_major_version}-{args.arch}.json.gz"
    output_files = f"files-centos-stream-{args.os_major_version}-{args.arch}"
    partial_runs = Path(output_files) / "old_runs"
    aggregator = JSONAggregator(output_results, output_files)
    stack.enter_context(aggregator)

    partial_runs.mkdir(parents=True, exist_ok=True)

    platform_name = f"cs{args.os_major_version}@{args.arch}"

    # Hardware requirements for Testing Farm
    # if args.arch == "x86_64":
    #     hw = {"virtualization": {"is-supported": True}, "memory": ">= 7 GB"}
    # else:
    #     hw = None

    # Setup Testing Farm provisioner
    prov = TestingFarmProvisioner(
        compose=args.compose,
        arch=args.arch,
        max_retries=2,
        timeout=args.timeout,
        # hardware=hw,
    )

    # Setup Contest orchestrator
    orchestrator = ContestOrchestrator(
        platform=platform_name,
        fmf_tests=fmf_tests,
        provisioners=[prov],
        aggregator=aggregator,
        tmp_dir=partial_runs,
        max_remotes=args.max_remotes,
        max_spares=2,
        max_reruns=args.reruns,
        content_dir=args.content_dir,
        env=test_env,
    )
    stack.enter_context(orchestrator)

    logger.info("Starting test execution...")
    next_writeout = time.monotonic() + 600
    while orchestrator.serve_once():
        if time.monotonic() > next_writeout:
            logger.info(
                f"queued: {len(orchestrator.to_run)}/{len(fmf_tests.tests)} tests, "
                f"running: {len(orchestrator.running_tests)} tests",
            )
            next_writeout = time.monotonic() + 600
        time.sleep(1)

    logger.info("Test execution completed!")

# Check if there were failures
logger.info(f"Results written to: {output_results}")
logger.info(f"Test files in: {output_files}")
