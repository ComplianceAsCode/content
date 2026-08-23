---
name: test-rule
description: Run Automatus tests for a security rule
---

# Test Rule

Run Automatus tests for a ComplianceAsCode security rule.

**Rule ID**: $ARGUMENTS

## Tool Strategy

This skill uses `mcp__content-agent__*` tools when available (preferred — deterministic, structured results). When the MCP server is not configured, fall back to filesystem-based alternatives noted as **Fallback** in each step. See `.claude/skills/shared/mcp_fallbacks.md` for detailed fallback procedures. The skill must complete successfully either way.

## Phase 1: Validate Rule Exists

1. **Find the rule** using `mcp__content-agent__get_rule_details` with `rule_id=$ARGUMENTS`:
   - This returns the full rule metadata including template info, CCE identifiers, remediation types, and file location.
   - If the rule is not found, also use `mcp__content-agent__search_rules` with `query=$ARGUMENTS` to check for similar rule IDs.
   - **Fallback**: Use `Glob` to find `**/$ARGUMENTS/rule.yml`, then read the file to extract metadata. For similar rule search, use `Grep` to search for `$ARGUMENTS` across rule.yml files.

2. **If rule not found**:
   - Use `mcp__content-agent__list_templates` to check if it's a template name instead.
   **Fallback**: Run `ls shared/templates/` to check for template names.
   - Inform user and exit if not found

3. **From the rule details**, determine:
   - Is it templated? (has `template:` key)
   - What products have CCE identifiers? (determines applicable products)
   - What remediation types are available?

## Phase 2: Determine Test Scope

1. **Identify testable products** from CCE identifiers:
   - Only `rhel8`, `rhel9`, `rhel10` are supported by Automatus
   - Extract from rule.yml identifiers: `cce@rhel8`, `cce@rhel9`, `cce@rhel10`

2. **Ask user for testing scope** using AskUserQuestion:

   **Question**: "Which products do you want to test?"

   **Options** (show only products with CCE identifiers):
   - rhel10 (if CCE exists)
   - rhel9 (if CCE exists)
   - rhel8 (if CCE exists)
   - All applicable products

   Enable multi-select.

3. **Ask for remediation types** using AskUserQuestion:

   **Question**: "Which remediation types do you want to test?"

   **Options**:
   - **Bash only** - Test Bash remediation (faster)
   - **Ansible only** - Test Ansible remediation
   - **Both Bash and Ansible (Recommended)** - Test both remediation types

## Important: Sandbox Requirements

All `virsh` and `automatus.py` commands require `dangerouslyDisableSandbox: true` on the Bash tool. These commands use libvirt unix sockets and SSH connections to VMs, which are blocked by the default sandbox. Set this flag on **every** Bash call that runs `virsh` or `automatus.py`.

## Phase 3: Determine Libvirt Connection and VM Names

### 3.1 Detect Libvirt Connection URI

The libvirt connection URI depends on the user's VM setup. **Ask the user** using AskUserQuestion:

**Question**: "Which libvirt connection URI does your VM setup use?"

**Options**:
- **qemu:///session (Recommended)** - User session VMs, no root required
- **qemu:///system** - System-wide VMs, may require root/sudo

Store the selected URI as `<libvirt_uri>` for all subsequent commands.

### 3.2 Discover VM Names

VM names often differ from product names (e.g., `rhel9-test`, `ssg-rhel9`, `rhel-9.4`). Discover available VMs:

```bash
virsh -c <libvirt_uri> list --all 2>/dev/null
```

For each selected product, ask the user to confirm the VM name:

**Question**: "Which VM should be used for testing `<product>`? Available VMs are listed above."

**Options** (populated from `virsh list --all` output, filtered to relevant entries):
- Matching VMs from the list
- Allow user to type a custom name

Store the mapping of product → VM name for Phase 5.

**Note on sudo**: When using `qemu:///system`, some operations (starting VMs, creating snapshots) may require `sudo`. When using `qemu:///session`, `sudo` is not needed. Adjust commands accordingly.

## Phase 4: Verify Prerequisites

1. **Check for existing datastreams**:
   Use `mcp__content-agent__list_built_products` to see which products have been built.
   **Fallback**: Run `ls build/ssg-*-ds.xml 2>/dev/null` to list built datastreams.

2. **For each selected product**, check if datastream exists and get details:
   Use `mcp__content-agent__get_datastream_info` with `product=<product>` to verify the datastream exists and get its details.
   **Fallback**: Run `ls -la build/ssg-<product>-ds.xml` to check if the datastream exists.

3. **Build datastreams if needed**:
   - If datastream doesn't exist or is older than rule.yml modifications
   - Ask user: "Datastream for <product> is missing/outdated. Build it now?"

   ```bash
   ./build_product --rule-id $ARGUMENTS <product>
   ```

4. **Verify VMs are available and running** (CRITICAL — Automatus requires the VM to be running):
   ```bash
   virsh -c <libvirt_uri> list --all 2>/dev/null | grep -E "rhel[0-9]+"
   ```

   - Inform user of available VMs
   - If required VM not found, provide guidance on VM setup
   - **Check that the required VM is in "running" state**. If the VM exists but is shut off, **start it before proceeding**:
     ```bash
     # For qemu:///system, prefix with sudo if needed
     virsh -c <libvirt_uri> start <vm_name>
     ```
   - Wait a moment after starting the VM and verify it is running:
     ```bash
     virsh -c <libvirt_uri> list --all 2>/dev/null | grep <vm_name>
     ```
   - **Do NOT proceed to Phase 5 until the VM is confirmed running.** Automatus will fail if the VM is not started.

5. **Verify VM has a snapshot** (CRITICAL — Automatus reverts to a snapshot between test scenarios):
   ```bash
   virsh -c <libvirt_uri> snapshot-list <vm_name>
   ```

   - Automatus needs at least one snapshot to restore clean state between test scenarios.
   - If no snapshots exist, inform the user and suggest creating one:
     ```bash
     # For qemu:///system, prefix with sudo if needed
     virsh -c <libvirt_uri> snapshot-create-as <vm_name> clean
     ```
   - **Do NOT proceed to Phase 5 if no snapshot exists.** Automatus will fail or leave the VM in a dirty state.

## Phase 5: Run Automatus Tests

### For Rule Testing

Run tests for each selected product and remediation type, using the `<libvirt_uri>` and `<vm_name>` determined in Phase 3:

**Bash remediation**:
```bash
cd tests
./automatus.py rule --libvirt <libvirt_uri> <vm_name> \
    --datastream ../build/ssg-<product>-ds.xml \
    $ARGUMENTS
```

**Ansible remediation**:
```bash
cd tests
./automatus.py rule --libvirt <libvirt_uri> <vm_name> \
    --datastream ../build/ssg-<product>-ds.xml \
    --remediate-using ansible \
    $ARGUMENTS
```

### For Template Testing

If testing a template instead of a rule:
```bash
cd tests
./automatus.py template --libvirt <libvirt_uri> <vm_name> \
    --datastream ../build/ssg-<product>-ds.xml \
    $ARGUMENTS
```

## Phase 6: Monitor Test Execution

1. **Tests run in foreground** - output is streamed

2. **Test phases to expect**:
   - Initial scan (check if rule is evaluated)
   - Remediation application
   - Final scan (verify remediation worked)

3. **For each test scenario** (e.g., `correct.pass.sh`, `wrong.fail.sh`):
   - `.pass.sh` scenarios: Should pass on initial scan
   - `.fail.sh` scenarios: Should fail initially, then pass after remediation

## Phase 7: Analyze Results

1. **Find results directory**:
   ```bash
   ls -td tests/logs/rule-custom-* 2>/dev/null | head -1
   ```

2. **Read results.json**:
   ```bash
   cat tests/logs/rule-custom-*/results.json
   ```

3. **Parse and summarize results**:

   | Scenario | Initial Scan | Remediation | Final Scan | Status |
   |----------|--------------|-------------|------------|--------|
   | wrong.fail | FAIL | APPLIED | PASS | OK |
   | correct.pass | PASS | SKIPPED | N/A | OK |

4. **Check for common issues**:
   - **Initial scan passed on .fail scenario**: Test scenario didn't properly set up non-compliant state
   - **Remediation failed**: Bash/Ansible script has errors
   - **Final scan failed after remediation**: Remediation incomplete or incorrect
   - **Not applicable**: Platform check excluded the rule

## Phase 8: Report Results

### Success Report

```
Test Results for $ARGUMENTS
==============================

Product: rhel9
Remediation: Bash

Scenarios:
  - wrong.fail.sh: PASSED (fail -> remediate -> pass)
  - correct.pass.sh: PASSED (already compliant)

Overall: ALL TESTS PASSED

---

Product: rhel9
Remediation: Ansible

Scenarios:
  - wrong.fail.sh: PASSED (fail -> remediate -> pass)
  - correct.pass.sh: PASSED (already compliant)

Overall: ALL TESTS PASSED

==============================
Summary: 4/4 tests passed across all products and remediation types
```

### Failure Report

```
Test Results for $ARGUMENTS
==============================

Product: rhel9
Remediation: Bash

Scenarios:
  - wrong.fail.sh: FAILED
    - Initial scan: FAIL (expected)
    - Remediation: APPLIED
    - Final scan: FAIL (unexpected!)
    - Issue: Remediation did not properly configure the setting

  - correct.pass.sh: PASSED

Log files: tests/logs/rule-custom-2024-01-15-1423/

Suggested debugging:
1. Check remediation script: find linux_os/guide -path "*/$ARGUMENTS/bash/*"
2. Review test scenario: find linux_os/guide -path "*/$ARGUMENTS/tests/*"
3. SSH into VM to inspect: virsh console rhel9

==============================
Summary: 1/2 tests failed
```

## Phase 9: Provide Next Steps

Based on results:

**If all tests passed**:
- "Rule is ready. Use `/build-product <product>` to build and `/run-tests` to validate."
- "Consider testing on additional products if applicable."

**If tests failed**:
- Provide specific debugging guidance based on failure type
- Suggest files to check/modify
- Offer to help fix the issues

**If no tests exist** (non-templated rule without tests):
- "This rule has no test scenarios. Create tests in `<rule_dir>/tests/`"
- "Required: At least one `.pass.sh` and one `.fail.sh` scenario"

## Troubleshooting

### Common Issues

1. **VM not found**:
   ```
   Error: VM '<vm_name>' not found
   ```
   - Ensure VM exists: `virsh -c <libvirt_uri> list --all`
   - Check connection URI — re-run Phase 3 if needed

2. **Datastream not found**:
   ```
   Error: build/ssg-<product>-ds.xml not found
   ```
   - Build with: `./build_product --rule-id $ARGUMENTS <product>`

3. **Permission denied**:
   - If using `qemu:///system`, may need sudo
   - Switch to `qemu:///session` for user VMs

4. **Rule not in datastream**:
   - Verify rule is in at least one profile
   - Rebuild datastream after adding to profile

5. **Test scenario errors**:
   - Check bash syntax in test files
   - Verify required packages are specified: `# packages = <pkg>`

6. **No snapshot available**:
   ```
   Error: No snapshot found for domain
   ```
   - Automatus needs a snapshot to revert between test scenarios
   - Create one: `virsh -c <libvirt_uri> snapshot-create-as <vm_name> clean` (prefix with `sudo` for `qemu:///system`)

### Debug Mode (Manual Only)

**Note**: Debug mode requires interactive input and must be run manually by the user, not through this skill.

When tests fail, suggest the user run with `--debug` in their own terminal:

```bash
cd tests
./automatus.py rule --libvirt <libvirt_uri> <vm_name> \
    --datastream ../build/ssg-<product>-ds.xml \
    --debug \
    $ARGUMENTS
```

How `--debug` works:
1. When an error occurs (e.g., remediation applied but rule still fails), Automatus **pauses** and keeps the VM running
2. User can SSH into the VM to inspect system state:
   ```bash
   ssh root@<vm-ip>   # No password required on test VMs
   ```
3. Press **Enter** in the Automatus terminal to continue to the next test, or **Ctrl+C** to abort
