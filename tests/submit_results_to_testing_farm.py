#!/usr/bin/env python3

import sys
import time
import atexit
import logging
import argparse
import xml.etree.ElementTree as ET

from atex.provisioner.testingfarm import api


# Reuse urllib3 PoolManager configured for heavy Retry attempts
# (because of TestingFarm API reboots, and other transient issues)
http = api._http


def parse_args():
    """Parse command-line arguments."""
    parser = argparse.ArgumentParser(description="Submit TMT test to Testing Farm")
    parser.add_argument("--repo-url", required=True, help="GitHub repository URL")
    parser.add_argument("--pr-number", required=True, help="Pull request number")
    parser.add_argument("--plan-name", default="/atex_results_plan", help="TMT plan name to run")
    parser.add_argument("--os", default=None, help="OS to test on (e.g., rhel-9)")
    parser.add_argument("--arch", default="x86_64", help="Architecture to test on")
    return parser.parse_args()


def setup_logging():
    """Setup logging configuration."""
    logging.basicConfig(
        level=logging.INFO,  # use DEBUG to see HTTP queries
        stream=sys.stderr,
        format="%(asctime)s %(name)s: %(message)s",
        datefmt="%Y-%m-%d %H:%M:%S",
    )


def build_request_json(args):
    """Build the Testing Farm API request JSON payload."""
    return {
        "test": {
            "fmf": {
                "url": args.repo_url,
                "ref": f"PR{args.pr_number}",
                "name": args.plan_name,
            },
        },
        "environments": [{"arch": args.arch, "os": args.os}],
    }


def get_html_link(artifacts_url):
    """
    Get the HTML link for test results from Testing Farm artifacts.

    Args:
        artifacts_url: URL to Testing Farm artifacts

    Returns:
        str: URL to the HTML results viewer

    Raises:
        RuntimeError: If results.xml or workdir cannot be retrieved
    """
    # Get results.xml for those artifacts, which is a XML representation of the
    # HTML artifacts view and contains links to logs and workdir
    reply = http.request("GET", f"{artifacts_url}/results.xml")
    if reply.status != 200:
        raise RuntimeError("could not get results.xml")

    # Find which log is the workdir and get its URL
    results_xml = ET.fromstring(reply.data)
    for log in results_xml.find("testsuite").find("logs"):
        if log.get("name") == "workdir":
            workdir_url = log.get("href")
            break
    else:
        raise RuntimeError("could not find workdir")

    # TODO: a more reliable way would be to read
    #         {workdir_url}/testing-farm/sanity/execute/results.yaml
    #       as YAML and look for the test name and get its 'data-path'
    #       relative to the /execute/ dir
    return f"{workdir_url}/atex_results_plan/execute/data/guest/default-0/atex_results_test-1/data/index.html?q=status%20IN%20%28%27fail%27%2C%20%27error%27%2C%20%27infra%27%29%20OR%20subtest%20IS%20NULL"


def main():
    """Main function to submit test results to Testing Farm."""
    args = parse_args()
    setup_logging()

    request_json = build_request_json(args)

    # Do faster queries than the default 30 secs, because we don't track
    # many dozens of requests, just one
    class FastRequest(api.Request):
        """
        A request class that executes queries faster than the default 30 seconds.

        This optimization is implemented because the system does not track
        many dozens of requests, typically just one, eliminating the need
        for the standard, longer default timeout.
        """
        api_query_limit = 5

    req = FastRequest()
    req.submit(request_json)
    atexit.register(req.cancel)  # just in case we traceback

    req.wait_for_state("running")

    # Artifacts URL doesn't appear instantly, wait for it
    while "run" not in req:
        time.sleep(FastRequest.api_query_limit)
    while "artifacts" not in req["run"]:
        time.sleep(FastRequest.api_query_limit)

    artifacts_url = req["run"]["artifacts"]
    logging.info(f"artifacts: {artifacts_url}")

    # results.xml appears only after completion
    req.wait_for_state("complete")
    atexit.unregister(req.cancel)

    # Get and print HTML link
    html_link = get_html_link(artifacts_url)
    logging.info(f"HTML: {html_link}")


if __name__ == "__main__":
    main()
