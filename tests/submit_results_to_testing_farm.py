#!/usr/bin/env python3

import sys
import time
import atexit
import logging
import argparse
import xml.etree.ElementTree as ET

from atex.provisioner.testingfarm import api


# reuse urllib3 PoolManager configured for heavy Retry attempts
# (because of TestingFarm API reboots, and other transient issues)
http = api._http

logging.basicConfig(
    level=logging.INFO,  # use DEBUG to see HTTP queries
    stream=sys.stderr,
    format="%(asctime)s %(name)s: %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S",
)

# Parse command-line arguments
parser = argparse.ArgumentParser(description="Submit TMT test to Testing Farm")
parser.add_argument("--repo-url", required=True, help="GitHub repository URL")
parser.add_argument("--pr-number", required=True, help="Pull request number")
parser.add_argument("--plan-name", default="/dummy_plan", help="TMT plan name to run")
parser.add_argument("--os", default=None, help="OS to test on (e.g., rhel-9)")
parser.add_argument("--arch", default="x86_64", help="Architecture to test on")
args = parser.parse_args()

request_json = {
  "test": {
    "fmf": {
      "url": args.repo_url,
      "ref": f"PR{args.pr_number}",
      "name": args.plan_name,
    },
  },
  "environments": [{"arch": args.arch, "os": args.os}],
}

# do faster queries than the default 30 secs, because we don't track
# many dozens of requests, just one
class FastRequest(api.Request):
    api_query_limit = 5

req = FastRequest()
req.submit(request_json)
atexit.register(req.cancel)  # just in case we traceback

req.wait_for_state("running")

# artifacts URL doesn't appear instantly, wait for it
while "run" not in req:
    time.sleep(FastRequest.api_query_limit)
while "artifacts" not in req["run"]:
    time.sleep(FastRequest.api_query_limit)

artifacts_url = req["run"]["artifacts"]
logging.info(f"artifacts: {artifacts_url}")

# results.xml appears only after completion
req.wait_for_state("complete")
atexit.unregister(req.cancel)

# get results.xml for those artifacts, which is a XML representation of the
# HTML artifacts view and contains links to logs and workdir
reply = http.request("GET", f"{artifacts_url}/results.xml")
if reply.status != 200:
    raise RuntimeError("could not get results.xml")

# find which log is the workdir and get its URL
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
logging.info(f"HTML: {workdir_url}/dummy_plan/execute/data/guest/default-0/dummy_test-1/data/index.html?q=TRUE")

