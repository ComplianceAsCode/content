---
name: create-test-scenarios
description: Create Automatus test scenarios to test the given rule.
argument-hint: "<rule_id>"
---

# Create Test Scenarios

Create test scenarios for execution by the Automatus test framework. Automatus and test scenarios are documented in `tests/README.md`.

**Scope:** This skill covers Linux rules only. It does not cover OpenShift tests (e.g., tests in `ocp4` directories).

## Phase 1: Understand the Rule

**Goal:** Produce a summary of key information about the rule.

1. **Locate the rule directory** containing the `rule.yml` file. The directory name matches the rule ID.
2. **Read `rule.yml`.**
   - Focus on the `description` and `rationale` fields to identify what to test.
   - Determine whether the rule is templated (templated rules contain a `template` key in `rule.yml`)
3. **Analyze rendered content** (OVAL checks and remediations).
   - Call `mcp__content-agent__get_rendered_rule(product, rule_id)` to see the actual OVAL check and remediation code after Jinja2 expansion. This is the most important tool for understanding what to test -- the raw `rule.yml` does not show final file paths, config keys, or values after template expansion.
   - Identify exactly which files, directories, config options, and packages the OVAL check examines.
   - Identify exactly how the Bash and Ansible remediation scripts modify those items.
   - Test scenarios must exercise the exact paths and values from the rendered content.
4. **Determine target product**
   - Use `mcp__content-agent__get_rule_product_availability(rule_id)` to see which products include the rule.
5. **Find existing and similar tests.**
   - Read any existing test scenarios in the rule's `tests/` subdirectory.
   - Read test scenarios for similar rules (same template or same subsystem) to match conventions and avoid reinventing patterns.
   - For templated rules, read existing templated test scenarios in `shared/templates/${template_name}/tests`.
6. **Review shared helpers and macros.**
   - Browse `tests/shared/` to discover reusable Bash helper scripts (see "Shared test helpers" below).
   - Read `shared/macros/20-test-scenarios.jinja` to discover available Jinja macros for test setup (see "Jinja macros for test scenarios" below).
   - Prefer existing helpers and macros over custom setup code.

**MCP tools to use:**
- `mcp__content-agent__get_rule_details(rule_id)` -- quickly identifies template name and metadata
- `mcp__content-agent__get_rendered_rule(product, rule_id)` -- shows the actual OVAL check and remediation code after Jinja2 expansion
- `mcp__content-agent__search_rendered_content(query, product, limit)` -- searches rendered build artifacts (useful for finding actual values after template expansion)
- `mcp__content-agent__get_template_schema(template_name)` -- for templated rules, shows parameter schema

## Phase 2: Design Test Scenarios

**Goal:** Produce a design document describing the test scenarios to create.

Use the information gathered in Phase 1 to propose test scenarios.

### Pass and fail scenarios

Propose a set of "pass" and "fail" test scenarios:

- **Pass** scenarios configure the system to a compliant state. They do not test remediations, because a passing system does not need remediation.
- **Fail** scenarios configure the system to a non-compliant state. Automatus runs the fail script, scans (expects fail), remediates automatically, then rescans (expects pass). Therefore, a `.fail.sh` scenario must put the system in a state that is both **detectable as non-compliant by the OVAL check** and **fixable by the remediation**.
  - Before designing a fail scenario, verify that the remediation can actually fix the state you are creating. For example, if the remediation only appends a line but does not modify existing lines, a fail scenario with a wrong value (rather than a missing value) may not be fixable.

Do not create "notapplicable" test scenarios. They are valid but serve specialized purposes outside this skill's scope.

### Relationship between pass and fail scenarios

Pass and fail scenarios for the same rule typically share roughly 80% of their setup code. Fail scenarios differ from pass scenarios by:
- Omitting a critical setup step (e.g., not enabling a service)
- Setting a wrong or opposite value
- Removing or commenting out correct configuration
- Using a minimal setup to prove absence of required config

Design pass/fail pairs together to ensure consistency.

### How Automatus executes test scenarios

- pass.sh: execute script → scan → expect PASS (done)
- fail.sh: execute script → scan → expect FAIL → remediate → rescan → expect PASS
- notapplicable.sh: execute script → scan → expect NOTAPPLICABLE (done)

### How many scenarios to write

Every rule must have at least 1 pass and at least 1 fail test scenario. A typical rule has 5 to 10 test scenarios, but the exact number depends on the rule's complexity.

Suggested distribution:
- **Simple rules** (single file, single option): 2-3 pass, 2-3 fail
- **Medium rules** (multiple locations, `.d` directories): 2-3 pass, 4-5 fail
- **Complex rules** (multiple subsystems, product-specific logic): 3-4 pass, 5-7 fail

### Typical situations to test

- Configuration option is absent
- Configuration option is commented out
- Configuration option has an incorrect value
- Multiple configuration options with different values
- Options in root configuration files
- Options in `.d` directories (test with and without files in the `.d` directory)
- File exists but is empty
- Correct value in wrong location (e.g., in a `.d` file when only the main file is checked, or vice versa)
- Runtime value differs from config file value (e.g., sysctl)

Focus on edge cases when designing test scenarios.

## Phase 3: Write Tests

**Goal:** Produce executable Bash test scenario files based on the Phase 2 design.

Every scenario file must start with `#!/bin/bash`.

### Jinja2 in test scenarios

Use Jinja2 macros and expressions in scenario files. This project uses non-standard delimiters:
- `{{{ }}}` for expressions
- `{{% %}}` for control flow

Use product properties such as `{{{ grub2_boot_path }}}` and `{{{ audit_watches_style }}}` to parametrize test scenarios across products.

Use product-specific conditionals when different products require different setup:
```
{{% if product in ["rhel9", "rhel10"] %}}
grubby --update-kernel=ALL --args="audit=1"
{{% elif "ubuntu" in product %}}
sed -i 's/GRUB_CMDLINE_LINUX="/&audit=1 /' /etc/default/grub
update-grub
{{% else %}}
grub2-editenv - set "$(grub2-editenv - list | grep kernelopts) audit=1"
{{% endif %}}
```

Additional Jinja macros for test scenarios are available in `shared/macros/20-test-scenarios.jinja` (see section below).

### Header

Each test scenario file begins with a comment header (lines starting with `#`). Include only the headers that apply:

- `packages` -- packages that must be installed before the test runs
- `platform` -- restricts the scenario to specific platforms
- `check` -- use only when the rule has both OVAL and SCE checks but the scenario works with only one check engine
- `remediation` -- set to `none` when the rule has no remediation or when remediation would break the test environment
- `variables` -- sets XCCDF Value parameters; format is `variable_name=actual_value` (use the actual value, not a selector name)
- `profiles` -- use only for profile-specific regression tests where the rule is not parametrized by an XCCDF Value

### File placement

**Non-templated rules:** Place test scenario files in the `tests/` subdirectory of the rule directory. Create the directory if it does not exist.

**Templated rules:** Determine whether the scenario is specific to a single rule or can be parametrized and reused by other rules using the same template. Reusable scenarios are far more common.
- **Rule-specific scenarios:** Place in the rule's `tests/` subdirectory.
- **Reusable scenarios:** Place in `shared/templates/${template_name}/tests/`.

In reusable test scenarios, use template parameters instead of specific values. Call `mcp__content-agent__get_template_schema()` to get the list of available parameters. Template parameters are substituted by Jinja. **Write template parameter names in CAPITAL letters.**

### Controlling templated scenarios with `test_config.yml`

A rule can include `tests/test_config.yml` to control which templated scenarios run. This is important when some templated tests do not apply to a specific rule. The file supports Jinja2 and is product-aware.

Use `deny_templated_scenarios` to block specific templated scenarios:
```yaml
deny_templated_scenarios:
  - wrong_runtime.fail.sh
  - missing_config.fail.sh
```

Use `allow_templated_scenarios` to allow only specific templated scenarios (all others are blocked). Use `- none` to disable all templated scenarios for the rule:
```yaml
allow_templated_scenarios:
  - none
```

### Shared test helpers

Source helper scripts from `tests/shared/` using the `$SHARED` variable (e.g., `. $SHARED/partition.sh`).

| Script | Functions | Use for |
|--------|-----------|---------|
| `partition.sh` | `create_partition()`, `mount_partition(path)`, `clean_up_partition(path)`, `make_fstab_given_partition_line(mountpoint, fstype, options)`, `make_fstab_correct_partition_line(mountpoint)` | Mount option tests |
| `dconf_test_functions.sh` | `clean_dconf_settings()`, `add_dconf_setting(path, setting, value, db, file)`, `add_dconf_lock(path, setting, db, file)` | GNOME/dconf tests |
| `utilities.sh` | `assert_directive_in_file(file, directive_start, full_directive)` | Config file directive management |
| `utils.sh` | `set_parameters_value(file, param, value)`, `delete_parameter(file, param)` | Key-value config file tests |
| `accounts_common.sh` | `run_foreach_noninteractive_shell_account()` | Account restriction tests |
| `grub2.sh` | Grub2 environment helpers | Bootloader tests |
| `rsyslog_log_utils.sh` | `create_rsyslog_test_logs()` | Rsyslog tests |
| `audit_rules_watch/` | Reusable audit watch scenarios (12 files, auditctl/augenrules variants) | Audit watch rule tests -- source these instead of recreating them |

### Jinja macros for test scenarios

Macros from `shared/macros/20-test-scenarios.jinja`:

| Macro | Purpose |
|-------|---------|
| `setup_auditctl_environment()` | Configure audit service to use auditctl for rule loading (product-aware) |
| `setup_augenrules_environment()` | Configure audit service to use augenrules (product-aware) |
| `tests_init_faillock_vars(state, prm_name, ext_variable, lower_bound, upper_bound)` | Initialize faillock test variables for `correct`, `stricter`, `lenient_high`, or `lenient_low` states |
| `setup_rsyslog_common()` | Set up rsyslog environment variables (`RSYSLOG_CONF`, `RSYSLOG_D_FOLDER`, `RSYSLOG_D_CONF`) |
| `remove_rsyslog_entry(pattern)` | Remove matching lines from rsyslog config files |
| `remove_rsyslog_legacy_entry(legacy_parameter)` | Remove legacy-format rsyslog entries (starting with `$`) |
| `remove_rsyslog_rainerscript_block_entry(block_type, pattern)` | Remove RainerScript blocks containing a pattern |
| `setup_rsyslog_remote_loghost(loghost_line)` | Set up remote loghost in rsyslog.conf |

Specialized composition macros for specific rsyslog rules also exist (e.g., `setup_rsyslog_encrypt_offload_actionsendstreamdriverauthmode()`).

### Tips for writing test code

- Create directories before writing files to them.
- Clean up unwanted values from configuration files before inserting correct values.
- Clean up all files from `.d` directories.
- When setting sysctl values, set both the config file (`/etc/sysctl.conf` or `/etc/sysctl.d/`) and the runtime value (`sysctl -w key=value`).
- When cleaning sysctl config, remove from all locations: `/etc/sysctl.conf`, `/etc/sysctl.d/*`, `/usr/lib/sysctl.d/*`, `/run/sysctl.d/*`.
- Use `sed -i '/pattern/d'` to remove existing config lines before adding new ones to prevent duplicate entries.
- Put each test scenario in a separate file with a short but descriptive name.
- File naming convention:
  - Pass scenarios: file name ends with `.pass.sh`
  - Fail scenarios: file name ends with `.fail.sh`

### Examples

#### Example 1: Basic fail scenario (`wrong_value.fail.sh`)
```
#!/bin/bash
# packages = openssh-server
# platform = multi_platform_rhel

# Set the sshd option to a wrong value so the rule fails
sed -i '/KerberosAuthentication/d' /etc/ssh/sshd_config
echo "KerberosAuthentication yes" >> /etc/ssh/sshd_config
```

#### Example 2: Basic pass scenario (`correct.pass.sh`)
```
#!/bin/bash
# platform = Ubuntu 24.04

getent group "adm" &>/dev/null || groupadd adm
mkdir -p /var/log/apt
touch /var/log/apt/testfile
chgrp adm /var/log/apt/testfile
```

#### Example 3: Scenario with advanced features (`augenrules_correct_extra_permission.pass.sh`)

This example demonstrates:
- `packages` header to ensure the `audit` RPM package is installed
- `platform` header limiting applicability to RHEL products (rhel8, rhel9, rhel10)
- `variables` header setting an actual value (not a selector) for the XCCDF Value `var_accounts_passwords_pam_faillock_dir`
- Jinja macro `setup_auditctl_environment()` generating Bash code
- Product property `audit_watches_style` substituted into the code
- Sourcing a shared Bash script via the `$SHARED` variable

```
#!/bin/bash
# packages = audit
# platform = multi_platform_rhel
# variables = var_accounts_passwords_pam_faillock_dir=/var/log/faillock

{{{ setup_auditctl_environment() }}}

path="/var/log/faillock"
style="{{{ audit_watches_style }}}"
filter_type="path"
. $SHARED/audit_rules_watch/auditctl_correct_without_key.pass.sh
```

#### Example 4: Templated scenario for `service_enabled` template (`service_disabled.fail.sh`)

Template parameters are substituted by Jinja and must be written in CAPITAL letters.

```
#!/bin/bash
{{% if SERVICENAME in ["ssh", "sshd"] %}}
# platform = Not Applicable
{{% endif %}}
# packages = {{{ PACKAGENAME }}}

SYSTEMCTL_EXEC='/usr/bin/systemctl'
"$SYSTEMCTL_EXEC" stop '{{{ DAEMONNAME }}}.service'
"$SYSTEMCTL_EXEC" disable '{{{ DAEMONNAME }}}.service'
```

#### Example 5: Sysctl scenario (`correct_value.pass.sh`)

Demonstrates proper cleanup of all sysctl config locations and setting both config and runtime values:

```
#!/bin/bash
# variables = sysctl_{{{ SYSCTLID }}}_value={{{ SYSCTL_CORRECT_VALUE }}}

rm -rf /usr/lib/sysctl.d/* /run/sysctl.d/* /etc/sysctl.d/*
sed -i "/{{{ SYSCTLVAR }}}/d" /etc/sysctl.conf

echo "{{{ SYSCTLVAR }}} = {{{ SYSCTL_CORRECT_VALUE }}}" >> /etc/sysctl.conf
sysctl -w {{{ SYSCTLVAR }}}="{{{ SYSCTL_CORRECT_VALUE }}}"
```

#### Example 6: Mount option test using shared helpers (`fstab.fail.sh`)

```
#!/bin/bash
# platform = multi_platform_all

. $SHARED/partition.sh

clean_up_partition {{{ MOUNTPOINT }}}
create_partition
make_fstab_given_partition_line {{{ MOUNTPOINT }}} ext2 nodev
mount_partition {{{ MOUNTPOINT }}} || true
```

#### Example 7: Dconf test using shared helpers (`correct_value.pass.sh`)

```
#!/bin/bash
# packages = dconf,gdm

. $SHARED/dconf_test_functions.sh

clean_dconf_settings
add_dconf_setting "{{{ SECTION }}}" "{{{ PARAMETER }}}" "{{{ VALUE }}}" "{{{ DCONF_DATABASE_DIRECTORY }}}" "00-security-settings"
add_dconf_lock "{{{ SECTION }}}" "{{{ PARAMETER }}}" "{{{ DCONF_DATABASE_DIRECTORY }}}" "00-security-settings-lock"
dconf update
```

## Phase 4: Verify by Running Automatus Tests

Run the created test scenarios using Automatus. Use the [test-rule](../test-rule/SKILL.md) skill. Verify that all test scenarios pass.
Run tests with both oscap and ansible remediations. Don't run the test with the bash remediations.

### How to interpret Automatus results

For fail test scenarios, don't check only the initial scan results, watch for failures in the scan after remediation.

#### Example 1: Pass test scenario - PASS

The rule returned the expected result `pass` result during the initial scan.

```
INFO - Script banner_etc_issue_disa_dod_short.pass.sh using profile (all) OK
```

#### Example 2: Pass test scenario - FAIL

The rule didn't return the expected result `pass` result during the initial scan, instead it returned the `fail` result.

```
ERROR - Script banner_etc_issue_disa_dod_short.pass.sh using profile (all) found issue:
ERROR - Rule evaluation resulted in fail, instead of expected pass during initial stage 
ERROR - The initial scan failed for rule 'xccdf_org.ssgproject.content_rule_banner_etc_issue'.
```


#### Example 3: Fail test scenario - PASS

OpenSCAP evaluated the rule as `fail` during the first run, which was expected by the test scenario. Then, the remediation was executed, and after the remediation, the rule was evaluated as `pass` so `oscap` returned the `fixed` result in the second run.

```
INFO - Script banner_etc_issue_disa_dod_short.fail.sh using profile (all) OK
```


#### Example 4: Remediation doesn't work correctly - FAIL

A "fail" test scenario returned the expected `fail` results in the initial scan. Then, it executed the remediation, but after the remediation the rule was evaluated as `fail` again, which means that the scanner reported the `error` result for the rule. 
This signalizes that the remediation for this rule doesn't work correctly.

```
INFO - Script banner_etc_issue_disa_dod_short.fail.sh using profile (all) OK
ERROR - Rule evaluation resulted in error, instead of expected fixed during remediation stage 
ERROR - The remediation failed for rule 'xccdf_org.ssgproject.content_rule_banner_etc_issue'.
```

## Common Pitfalls

- Forgetting to clean up `.d` directories before setting up the test state
- Writing fail scenarios that the remediation cannot fix (always verify that the remediation logic can handle the state you create)
- Writing tests that check paths or values not matching what the OVAL actually checks (always base tests on rendered content, not assumptions)
- Using the `profiles` header when the `variables` header should be used instead
- Using a selector name instead of the actual value in the `variables` header (e.g., `# variables = var_name=selector` instead of `# variables = var_name=10`)
- Using default Jinja syntax (`{{ }}`, `{% %}`) instead of the project's custom syntax (`{{{ }}}`, `{{% %}}`)
- Missing shebang (`#!/bin/bash`)
- Using lowercase letters for template parameters in templated test scenarios
- Not setting the runtime value alongside the config file value (e.g., forgetting `sysctl -w` after editing sysctl.conf)
- Recreating shared helpers or audit watch scenarios instead of sourcing them from `$SHARED`
