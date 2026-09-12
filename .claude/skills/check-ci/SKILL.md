---
description: Check the latest periodic CI compliance results for a given profile and OCP version.
---

Check the latest weekly compliance CI job results for a specific profile and OCP version, comparing actual scan results against the local assertion file.

Arguments: $ARGUMENTS

Expected arguments: `<product> <profile> <ocp-version> [arm]`

- `<product>` — The product to check. Either `ocp4` or `rhcos4`.
- `<profile>` — The compliance profile to check. Examples: `cis`, `stig`, `moderate`, `high`, `e8`, `pci-dss`, `pci-dss-4-0`, `cis-node`, `stig-node`, `moderate-node`, `high-node`, `pci-dss-node`, `pci-dss-node-4-0`.
- `<ocp-version>` — The OpenShift version (e.g., `4.16`, `4.18`, `4.21`).
- `[arm]` — (Optional) Pass `arm` to check the ARM architecture job. Defaults to x86.

For example:
- `check-ci ocp4 cis 4.18`
- `check-ci ocp4 stig-node 4.16`
- `check-ci rhcos4 e8 4.18 arm`

---

## Step 1: Run the fetch script

Run the Python script at `.claude/skills/check-ci/fetch_results.py` with the provided arguments:

```bash
python3 .claude/skills/check-ci/fetch_results.py <product> <profile> <ocp-version> [arm]
```

The script will:
1. Load the matching assertion file from `tests/assertions/ocp4/`
2. Query the Prow API for the latest periodic job (platform or node, depending on the profile)
3. Download the initial (pre-remediation) and final (post-remediation) scan results
4. Compare each rule in the assertion file against the actual scan results
5. Print a summary

Note: The periodic CI jobs run ALL platform rules or ALL node rules for a given OCP version — not per-profile. The script filters the combined results down to only the rules listed in the profile's assertion file.

## Step 2: Present the results

Present the script output to the user. If there are mismatches or missing rules, highlight them and suggest next steps:

- **Mismatches** (expected status differs from actual): The assertion file may need updating, or the rule itself needs investigation. Show the rule name, expected status, and actual status.
- **Missing from results** (rule listed in the assertion file but not found in the scan): The rule may have been removed, renamed, or excluded from the scan. Check whether the rule still exists in the repository.

## Step 3: Offer to update the assertion file

If there are mismatches, offer to update the assertion file at `tests/assertions/ocp4/<product>-<profile>-<version>.yml`. When updating:

- For **mismatches**: Update the `default_result` (and `result_after_remediation` if final results are available) to match the actual scan result.
- For **missing rules**: Ask the user whether to remove them from the assertion file or keep them.

Do NOT automatically update the file — always show the proposed changes and wait for approval.

### Important: profile membership

The periodic CI jobs run every rule in the product, not just the rules for a specific profile. If the user wants to know whether rules are **missing from the assertion file** (i.e., rules that should be tested for this profile but aren't listed), that requires checking the profile and control files in this repository — not the scan results. The profile and control files define which rules belong to a profile:

- Profile files: `products/ocp4/profiles/<profile-name>.profile`
- Control files referenced by profiles: `controls/` or `products/ocp4/controls/`

If the user asks about missing coverage, use those files to determine which rules should be in the assertion file.
