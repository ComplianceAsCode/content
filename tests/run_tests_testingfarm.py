#!/usr/bin/env python3

import sys
import time
import gzip
import json
import lzma
import atexit
import signal
import logging
import argparse
import contextlib
from pathlib import Path

from atex.provisioner.testingfarm import TestingFarmProvisioner
from atex.orchestrator.contest import ContestOrchestrator
from atex.aggregator.json import LZMAJSONAggregator
from atex.fmf import FMFTests

logger = logging.getLogger("ATEX")


def kv_pair(keyval):
    if "=" not in keyval:
        raise argparse.ArgumentTypeError(f"expected KEY=VALUE, got: {keyval}")
    return keyval.split("=", 1)

def parse_args():
    """Parse command-line arguments."""
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
    parser.add_argument("--tag", type=kv_pair, default=[], action="append", help="Additional tag(s) to store in TF Request")
    return parser.parse_args()


def setup_logging():
    """Setup logging configuration with console and file handlers."""
    # Log brief info to console, but be verbose in a separate file-based log (uploaded as artifact)
    console_log = logging.StreamHandler(sys.stderr)
    console_log.setLevel(logging.INFO)

    debug_log_fobj = gzip.open("atex_debug.log.gz", "wt")
    atexit.register(debug_log_fobj.close)
    file_log = logging.StreamHandler(debug_log_fobj)
    file_log.setLevel(logging.DEBUG)

    logging.basicConfig(
        level=logging.DEBUG,
        format="%(asctime)s %(name)s: %(message)s",
        datefmt="%Y-%m-%d %H:%M:%S",
        handlers=(console_log, file_log),
        force=True,
    )


def setup_signal_handlers():
    """Setup signal handlers for graceful abort."""
    def abort_on_signal(signum, _):
        logger.error(f"got signal {signum}, aborting")
        raise SystemExit(1)

    signal.signal(signal.SIGTERM, abort_on_signal)
    signal.signal(signal.SIGHUP, abort_on_signal)


def main():
    """Main function to run tests on Testing Farm."""
    setup_logging()
    setup_signal_handlers()

    args = parse_args()

    # Variables exported to tests
    test_env = {
        "CONTEST_CONTENT": ContestOrchestrator.content_dir_on_remote,
        "CONTEST_VERBOSE": "2",
    }

    with contextlib.ExitStack() as stack:
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
        output_results = f"results-centos-stream-{args.os_major_version}-{args.arch}.json.xz"
        output_files = f"files-centos-stream-{args.os_major_version}-{args.arch}"
        partial_runs = Path(output_files) / "old_runs"
        aggregator = LZMAJSONAggregator(output_results, output_files)
        stack.enter_context(aggregator)

        partial_runs.mkdir(parents=True, exist_ok=True)

        platform_name = f"cs{args.os_major_version}@{args.arch}"

        # Setup Testing Farm provisioner
        prov = TestingFarmProvisioner(
            compose=args.compose,
            arch=args.arch,
            max_retries=2,
            timeout=args.timeout,
            tags=dict(args.tag),
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

    # Log final output locations
    logger.info(f"Results written to: {output_results}")
    logger.info(f"Test files in: {output_files}")

    # Read back the compressed JSON results and exit with non-0 if anything failed
    with lzma.open(output_results, "rt") as results:
        for line in results:
            fields = json.loads(line)
            # [platform, status, test name, subtest name, files, note]
            if fields[1] in ("fail", "error", "infra"):
                logger.warning("failures found in the results, exiting with 1")
                sys.exit(1)


if __name__ == "__main__":
    main()
