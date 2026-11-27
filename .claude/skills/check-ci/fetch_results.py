#!/usr/bin/env python3
"""
Fetch the latest periodic CI compliance results and compare against local
assertion files.

Usage:
    python3 fetch_results.py <product> <profile> <ocp-version> [arm]

The product and profile map to the assertion filename:
    {product}-{profile}-{version}.yml

Examples:
    python3 fetch_results.py ocp4 cis 4.18
    python3 fetch_results.py ocp4 stig-node 4.16
    python3 fetch_results.py rhcos4 stig 4.18 arm
"""

import json
import os
import sys
import urllib.request

import yaml


PROW_API = (
    "https://prow.ci.openshift.org/prowjobs.js"
    "?repo=ComplianceAsCode%2Fcontent&type=periodic"
)
ASSERTIONS_DIR = os.path.join(
    os.path.dirname(__file__), "..", "..", "..", "tests", "assertions", "ocp4"
)


def parse_args(product, profile):
    """Determine job type, assertion prefix, and result prefix."""
    if product == "rhcos4":
        job_type = "node"
        result_prefix = "rhcos-node-"
    elif "node" in profile:
        job_type = "node"
        result_prefix = "ocp-node-"
    else:
        job_type = "platform"
        result_prefix = "platform-"

    assertion_prefix = f"{product}-{profile}-"
    return job_type, assertion_prefix, result_prefix


def find_latest_job(ocp_version, job_type, arch):
    """Query the Prow API and return the latest matching periodic job.

    Note: The Prow API does not support server-side filtering by job name.
    We must fetch all periodic jobs and filter client-side.
    """
    arch_suffix = "-arm-weekly" if arch == "arm" else "-weekly"
    target_job = (
        f"periodic-ci-ComplianceAsCode-content-master-{ocp_version}"
        f"-e2e-aws-openshift-{job_type}-compliance{arch_suffix}"
    )

    req = urllib.request.Request(PROW_API)
    with urllib.request.urlopen(req, timeout=30) as resp:
        data = json.loads(resp.read())

    matches = []
    for item in data.get("items", []):
        job = item.get("spec", {}).get("job", "")
        if job == target_job:
            status = item.get("status", {})
            matches.append({
                "job": job,
                "state": status.get("state", "unknown"),
                "build_id": status.get("build_id", ""),
                "start_time": status.get("startTime", ""),
                "url": status.get("url", ""),
            })

    if not matches:
        return None, target_job

    matches.sort(key=lambda x: x["start_time"], reverse=True)
    return matches[0], target_job


def build_artifact_url(job_url, job_name, job_type):
    """Build the base URL for artifacts from the Prow job URL."""
    # Extract GCS path from Prow URL
    # e.g. https://prow.ci.openshift.org/view/gs/test-platform-results/logs/job/123
    #   -> test-platform-results/logs/job/123
    marker = "/view/gs/"
    idx = job_url.find(marker)
    if idx == -1:
        raise ValueError(f"Cannot extract GCS path from Prow URL: {job_url}")
    gcs_path = job_url[idx + len(marker):]

    if job_type == "platform":
        step_name = "e2e-aws-openshift-platform-compliance-weekly"
    else:
        step_name = "e2e-aws-openshift-node-compliance-weekly"

    if "-arm-weekly" in job_name:
        step_name = step_name.replace("-weekly", "-arm-weekly")

    return (
        f"https://storage.googleapis.com/{gcs_path}"
        f"/artifacts/{step_name}/test/artifacts"
    )


def fetch_results_file(base_url, filename):
    """Download and parse a results file (rule-name: STATUS format)."""
    url = f"{base_url}/{filename}"
    try:
        req = urllib.request.Request(url)
        with urllib.request.urlopen(req, timeout=30) as resp:
            content = resp.read().decode("utf-8")
    except urllib.error.HTTPError:
        return None

    results = {}
    for line in content.strip().splitlines():
        line = line.strip()
        if not line or line.startswith("#"):
            continue
        parts = line.split(":", 1)
        if len(parts) == 2:
            rule_name = parts[0].strip()
            status = parts[1].strip()
            results[rule_name] = status
    return results


def load_assertion_file(product, profile_name, ocp_version):
    """Load the local assertion YAML file."""
    filename = f"{product}-{profile_name}-{ocp_version}.yml"
    filepath = os.path.join(ASSERTIONS_DIR, filename)

    if not os.path.exists(filepath):
        return None, filepath

    with open(filepath) as f:
        data = yaml.safe_load(f)

    return data.get("rule_results", {}), filepath


def compare_results(assertions, initial_results, final_results,
                    assertion_prefix, result_prefix):
    """Compare assertion expectations against actual CI results.

    Returns both cluster compliance data (actual scan statuses) and
    assertion accuracy data (whether predictions matched).
    """
    mismatches_initial = []
    mismatches_final = []
    missing_from_results = []
    matched_initial = 0
    matched_final = 0
    total = len(assertions)

    # Count statuses from assertions
    status_counts = {}

    # Track actual scan results per rule for compliance posture display
    initial_actuals = {}   # rule -> actual status from scan
    final_actuals = {}     # rule -> actual status from scan

    for assertion_rule, expected in assertions.items():
        # Map assertion rule name to result rule name
        if assertion_rule.startswith(assertion_prefix):
            base_rule = assertion_rule[len(assertion_prefix):]
        else:
            base_rule = assertion_rule
        result_rule = result_prefix + base_rule

        default_expected = expected.get("default_result", "").strip()
        remediation_expected = expected.get("result_after_remediation", "")
        if remediation_expected:
            remediation_expected = remediation_expected.strip()

        # Track expected status distribution
        status_counts[default_expected] = (
            status_counts.get(default_expected, 0) + 1
        )

        # Check initial (pre-remediation) results
        if initial_results and result_rule in initial_results:
            actual = initial_results[result_rule]
            initial_actuals[assertion_rule] = actual
            # Handle "X or Y" expectations (e.g., "PASS or NOT-APPLICABLE")
            expected_options = [
                s.strip() for s in default_expected.split(" or ")
            ]
            if actual in expected_options:
                matched_initial += 1
            else:
                mismatches_initial.append({
                    "rule": assertion_rule,
                    "expected": default_expected,
                    "actual": actual,
                })
        elif initial_results is not None:
            # MANUAL rules are not scanned, so they're expected to be
            # absent from results
            if default_expected == "MANUAL":
                initial_actuals[assertion_rule] = "MANUAL"
            else:
                missing_from_results.append({
                    "rule": assertion_rule,
                    "expected": default_expected,
                })

        # Check final (post-remediation) results
        if final_results and result_rule in final_results:
            final_actuals[assertion_rule] = final_results[result_rule]
            if remediation_expected:
                actual = final_results[result_rule]
                expected_options = [
                    s.strip() for s in remediation_expected.split(" or ")
                ]
                if actual in expected_options:
                    matched_final += 1
                else:
                    mismatches_final.append({
                        "rule": assertion_rule,
                        "expected": remediation_expected,
                        "actual": actual,
                    })

    return {
        "total_rules": total,
        "manual_count": status_counts.get("MANUAL", 0),
        "status_counts": status_counts,
        "matched_initial": matched_initial,
        "matched_final": matched_final,
        "mismatches_initial": mismatches_initial,
        "mismatches_final": mismatches_final,
        "missing_from_results": missing_from_results,
        "_assertions": assertions,
        "initial_actuals": initial_actuals,
        "final_actuals": final_actuals,
    }


def get_terminal_width():
    """Get terminal width, defaulting to 80."""
    try:
        return os.get_terminal_size().columns
    except OSError:
        return 80


# ANSI color codes
GREEN = "\033[32m"
RED = "\033[31m"
YELLOW = "\033[33m"
CYAN = "\033[36m"
BOLD = "\033[1m"
DIM = "\033[2m"
RESET = "\033[0m"
BG_GREEN = "\033[42m"
BG_RED = "\033[41m"
BG_YELLOW = "\033[43m"
BLACK = "\033[30m"


def print_progress_bar(segments, total, width=50):
    """Print a colored progress bar from a list of (count, bg_color) tuples.

    The first segment is treated as the 'good' segment and its percentage
    is displayed at the end of the bar.
    """
    if total == 0:
        return

    # Calculate segment lengths
    lengths = []
    for count, _ in segments:
        lengths.append(round(count / total * width))
    # Adjust first segment for rounding
    remainder = width - sum(lengths)
    lengths[0] += remainder

    bar = ""
    for i, (_, bg_color) in enumerate(segments):
        seg_len = lengths[i]
        if seg_len > 0:
            bar += f"{bg_color}{BLACK}" + " " * seg_len + RESET

    pct = segments[0][0] / total * 100
    if pct >= 95:
        pct_color = GREEN
    elif pct >= 80:
        pct_color = YELLOW
    else:
        pct_color = RED

    print(f"  {bar}  {BOLD}{pct_color}{pct:.1f}%{RESET}")



def _count_actuals(actuals):
    """Count occurrences of each status in actual scan results."""
    counts = {}
    for status in actuals.values():
        counts[status] = counts.get(status, 0) + 1
    return counts


def _print_compliance_section(label, actuals, manual_count):
    """Print a cluster compliance posture section (bar + legend)."""
    counts = _count_actuals(actuals)
    n_pass = counts.get("PASS", 0)
    n_fail = counts.get("FAIL", 0)
    n_na = counts.get("NOT-APPLICABLE", 0)
    n_other = sum(v for k, v in counts.items()
                  if k not in ("PASS", "FAIL", "NOT-APPLICABLE", "MANUAL"))
    scannable = n_pass + n_fail + n_na + n_other

    print(f"\n{BOLD}{label} - Cluster Compliance Posture:{RESET}")
    if manual_count > 0:
        print(f"  {DIM}({manual_count} MANUAL rules not scanned){RESET}")

    if scannable > 0:
        segments = [(n_pass, BG_GREEN)]
        if n_fail > 0:
            segments.append((n_fail, BG_RED))
        if n_na > 0:
            segments.append((n_na, "\033[46m"))  # BG_CYAN
        if n_other > 0:
            segments.append((n_other, BG_YELLOW))
        print_progress_bar(segments, scannable)

    # Legend
    parts = [f"  {GREEN}\u2588{RESET} PASS: {n_pass}",
             f"   {RED}\u2588{RESET} FAIL: {n_fail}"]
    if n_na > 0:
        parts.append(f"   {CYAN}\u2588{RESET} N/A: {n_na}")
    if manual_count > 0:
        parts.append(f"   {DIM}\u2588{RESET} MANUAL: {manual_count}")
    print("".join(parts))


def _print_assertion_section(label, matched, mismatches, missing,
                             assertions, total_checked):
    """Print an assertion accuracy section (bar + details)."""
    n_mismatch = len(mismatches)
    n_missing = len(missing)

    print(f"\n{BOLD}{label} - Assertion Accuracy:{RESET}")

    if total_checked > 0:
        segments = [(matched, BG_GREEN)]
        if n_mismatch > 0:
            segments.append((n_mismatch, BG_RED))
        if n_missing > 0:
            segments.append((n_missing, BG_YELLOW))
        print_progress_bar(segments, total_checked)

    print(f"  {GREEN}\u2588{RESET} Matched: {matched}"
          f"   {RED}\u2588{RESET} Mismatch: {n_mismatch}"
          f"   {YELLOW}\u2588{RESET} Missing: {n_missing}")

    if mismatches:
        print(f"\n  {RED}{BOLD}Mismatched rules (expected -> actual):{RESET}")
        for m in mismatches:
            print(f"    {RED}\u2718{RESET} {m['rule']}: "
                  f"{m['expected']} -> {BOLD}{m['actual']}{RESET}")

    if missing:
        print(f"\n  {YELLOW}{BOLD}Rules missing from scan results:{RESET}")
        for m in missing:
            print(f"    {YELLOW}?{RESET} {m['rule']} "
                  f"(expected {m['expected']})")


def print_summary(job_info, comparison, assertion_filepath,
                   initial_available, final_available):
    """Print a summary with cluster posture and assertion accuracy separated."""
    width = get_terminal_width()
    sep = "=" * min(width, 70)

    print(sep)
    print(f"Job:      {job_info['job']}")
    print(f"State:    {job_info['state'].upper()}")
    print(f"Started:  {job_info['start_time']}")
    print(f"Build ID: {job_info['build_id']}")
    print(f"URL:      {job_info['url']}")
    print(f"Assertion file: {os.path.relpath(assertion_filepath)}")
    print(sep)

    total = comparison["total_rules"]
    manual_count = comparison["manual_count"]
    assertions = comparison.get("_assertions", {})

    if not initial_available:
        print(f"\n{RED}{BOLD}** No initial results found (job may have "
              f"failed before scanning) **{RESET}")
        return

    # --- Pre-remediation ---
    initial_actuals = comparison["initial_actuals"]
    matched = comparison["matched_initial"]
    mismatches = comparison["mismatches_initial"]
    missing = comparison["missing_from_results"]
    scannable = total - manual_count

    _print_compliance_section("Pre-Remediation", initial_actuals,
                              manual_count)

    print()
    _print_assertion_section("Pre-Remediation", matched, mismatches,
                             missing, assertions, scannable)

    # --- Post-remediation ---
    if final_available:
        final_actuals = comparison["final_actuals"]
        matched_f = comparison["matched_final"]
        mismatches_f = comparison["mismatches_final"]
        total_f = matched_f + len(mismatches_f)

        print()
        _print_compliance_section("Post-Remediation", final_actuals,
                                  manual_count)

        if total_f > 0:
            print()
            _print_assertion_section("Post-Remediation", matched_f,
                                     mismatches_f, [], assertions, total_f)
    else:
        print(f"\n{DIM}** No final (post-remediation) results found **"
              f"{RESET}")



def main():
    if len(sys.argv) < 4:
        print(__doc__)
        sys.exit(1)

    product = sys.argv[1]
    profile = sys.argv[2]
    ocp_version = sys.argv[3]
    arch = sys.argv[4] if len(sys.argv) > 4 else "x86"

    job_type, assertion_prefix, result_prefix = (
        parse_args(product, profile)
    )

    # Load assertion file
    assertions, assertion_filepath = load_assertion_file(
        product, profile, ocp_version
    )
    if assertions is None:
        print(f"Assertion file not found: {assertion_filepath}")
        print(f"\nAvailable assertion files:")
        for f in sorted(os.listdir(ASSERTIONS_DIR)):
            if f.endswith(".yml") and ocp_version in f:
                print(f"  {f}")
        sys.exit(1)

    # Find latest periodic job
    print(f"Querying Prow API for {job_type} compliance job "
          f"(OCP {ocp_version}, {arch})...")
    job_info, target_job = find_latest_job(ocp_version, job_type, arch)
    if job_info is None:
        print(f"No periodic job found matching: {target_job}")
        sys.exit(1)

    # Build artifact URL
    artifact_base = build_artifact_url(
        job_info["url"], job_info["job"], job_type
    )

    # Download results
    type_label = job_type  # "platform" or "node"
    print(f"Fetching initial-{type_label}-results.yaml...")
    initial = fetch_results_file(
        artifact_base, f"initial-{type_label}-results.yaml"
    )
    print(f"Fetching final-{type_label}-results.yaml...")
    final = fetch_results_file(
        artifact_base, f"final-{type_label}-results.yaml"
    )

    # Compare
    comparison = compare_results(
        assertions, initial, final, assertion_prefix, result_prefix
    )

    # Print summary
    print()
    print_summary(
        job_info, comparison, assertion_filepath,
        initial is not None, final is not None,
    )


if __name__ == "__main__":
    main()
