# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This repository produces SCAP data streams, Ansible playbooks, Bash scripts, and other artifacts for compliance scanning and remediation. Each supported OS or platform is a **product** (subdirectory under `products/`). The core Python library that drives the build system lives in `ssg/`.

## Build Commands

```bash
# Build a single product (full build including guides and tables)
./build_product rhel9

# Build data stream only (faster — skips guides and tables)
./build_product rhel9 --datastream-only

# Build targeting a single rule (fastest — for development)
./build_product rhel9 --datastream-only --rule-id accounts_password_minlen_login_defs

# Build output: build/ssg-<product>-ds.xml
```

## Linting and Testing

```bash
# Lint Python code
ruff check ssg utils tests build-scripts

# Lint YAML files
yamllint -c .yamllint <file>

# Auto-fix YAML lint issues
yamlfix -c yamlfix.toml <file>

# Run Python unit tests
python -m pytest tests/unit/ssg-module/

# Run utils that import ssg/ — must set PYTHONPATH first
PYTHONPATH=. python utils/controleval.py --help
PYTHONPATH=. python utils/find_duplicates.py --help
```

Python style: PEP 8 with a 99-character line limit. YAML style: 4-space indentation for new files (some older files use 2-space), `.yml` extension, one blank line between sections.

## Repository Structure

```
applications/openshift/    # OCP4/Kubernetes rules, organized by component (api-server/, kubelet/, etcd/, …)
linux_os/guide/            # Linux rules organized by area (system/, services/, auditing/, …)
controls/                  # Compliance framework mappings (CIS, STIG, SRG, NIST, …)
products/                  # Product definitions, profiles, and product-specific controls
shared/templates/          # ~40 reusable check/remediation templates
shared/macros/             # Jinja2 macro files for OVAL, Ansible, Bash generation
components/                # Component definitions mapping rules to packages (e.g., audit.yml)
ssg/                       # Python library used by build-scripts/ and utils/
build-scripts/             # CMake-invoked scripts that assemble the build artifacts
utils/                     # Developer utilities (controleval, find_duplicates, compare_ds, …)
```

## Discovering Rule Directories

- **OCP4/Kubernetes rules**: `applications/openshift/<component>/`, where the rule ID prefix matches the component name with hyphens → underscores (e.g., `api-server/` → `api_server_` prefix).
- **Linux rules**: `linux_os/guide/<area>/`, e.g., `system/accounts/`, `services/ssh/`, `auditing/`.
- Each rule lives in its own directory; the **directory name is the rule ID**. It contains `rule.yml` and optionally `tests/`.
- Each category directory contains a `group.yml` describing the group. Rules must belong to a group that covers the same software or service.

## Rule Format (`rule.yml`)

Sections **must appear in this order** when present:

```yaml
documentation_complete: true   # Must be true to be built

title: 'Title Case Short Title'   # One line; must match directory name

description: |-                   # HTML-Like: supports <b>, <pre>, <code>, <tt>, <ul>, <li>
rationale: |-
severity: medium                  # low | medium | high | unknown

identifiers:                      # Keys alphabetical order
    cce@rhel9: CCE-XXXXX-X

references:                       # Keys alphabetical order
    cis@rhel9: 1.2.3
    nist: CM-6,CM-6(1)
    stigid@rhel9: RHEL-09-XXXXXX

platform: machine                 # Use platform (not platforms) for new rules

ocil_clause: 'the value is not set'
ocil: |-                          # Manual check instructions (HTML-Like)

fixtext: |-                       # STIG fix instructions (HTML-Like)
checktext: |-                     # STIG check instructions (HTML-Like)
srg_requirement: '...'

warnings:
    - general: |-

conflicts:
    - some_rule_id
requires:
    - other_rule_id

template:
    name: <template_name>
    vars: ...
```

One rule = one configuration change. Create a variable (`.var` file) when a setting can take multiple valid values.

## Available Templates (`shared/templates/`)

Key templates for Linux: `sysctl`, `file_permissions`, `file_owner`, `file_groupowner`, `shell_lineinfile`, `sshd_lineinfile`, `service_enabled`, `service_disabled`, `package_installed`, `package_removed`, `audit_rules_*`, `kernel_module_disabled`, `grub2_bootloader_argument`, `sudo_defaults_option`, `sebool`, `dconf_ini_file`.

Key templates for OCP4: `yamlfile_value`.

When a template fits, always use it rather than writing custom OVAL/Ansible/Bash checks.

### `yamlfile_value` (primary OCP4 template)

```yaml
template:
    name: yamlfile_value
    vars:
        ocp_data: "true"
        filepath: '/apis/...'
        yamlpath: '.spec.field'
        check_existence: "at_least_one_exists"   # optional
        entity_check: "at least one"              # optional
        values:
          - value: 'expected'
            type: "string"                        # string | int | boolean
            operation: "pattern match"            # equals | not equal | pattern match | greater than or equal | less than or equal
```

### Other common templates

```yaml
# sysctl
template:
    name: sysctl
    vars:
        sysctlvar: net.ipv6.conf.all.accept_ra
        datatype: int

# file_permissions
template:
    name: file_permissions
    vars:
        filepath: /etc/ssh/sshd_config
        filemode: '0600'

# shell_lineinfile
template:
    name: shell_lineinfile
    vars:
        path: /etc/login.defs
        parameter: PASS_MIN_LEN
        value: '15'

# package_installed / package_removed
template:
    name: package_removed
    vars:
        pkgname: avahi
        pkgname@ubuntu2204: avahi-daemon   # product-scoped override
```

## Common Jinja2 Macros

```
{{{ full_name }}}                                        → product full name
{{{ xccdf_value("var_name") }}}                         → XCCDF variable reference
{{{ describe_sysctl_option_value(sysctl="key", value="val") }}}
{{{ complete_ocil_entry_sysctl_option_value(sysctl="key", value="val") }}}
{{{ fixtext_sysctl("key", "value") }}}
{{{ describe_service_disable(service="name") }}}
{{{ describe_service_enable(service="name") }}}
{{{ describe_file_permissions(file="/path", perms="0700") }}}
{{{ fixtext_directory_permissions(file="/path", mode="0600") }}}
{{{ complete_ocil_entry_package_installed("name") }}}
{{{ complete_ocil_entry_package_removed("name") }}}
{{{ fixtext_package_removed("name") }}}
{{{ weblink("https://...") }}}

# OCP4 specific
{{{ openshift_cluster_setting("/api/path") }}}
{{{ openshift_filtered_cluster_setting({'/api/path': jqfilter}) }}}
{{{ openshift_filtered_path('/api/path', jqfilter) }}}
```

## Control File Format

Two layouts exist:

**Single file** (`controls/<id>.yml` or `products/<product>/controls/<id>.yml`):
```yaml
policy: 'Policy Title'
title: 'Full Title'
id: policy_id
version: V1R1
reference_type: stigid   # or cis, srg, etc.
product: rhel9
levels:
    - id: high
controls:
    - id: RHEL-09-211010
      levels: [high]
      title: '...'
      rules: [installed_OS_is_vendor_supported]
      status: automated  # automated | manual | inherently met | does not meet | pending | not applicable
      notes: '...'
```

**Split directory** (`controls/<id>.yml` + `controls/<id>/section-N.yml`): used for large frameworks like CIS. The top-level file holds `policy`, `title`, `id`, `levels`; section files hold nested `controls:` lists.

## Profile Format

`products/<product>/profiles/<name>.profile`:

```yaml
documentation_complete: true
title: 'Profile Title'
description: |-
platform: rhel9
metadata:
    version: V2R7
    SMEs: [github_username]
selections:
    - stig_rhel9:all          # all rules from a control file
    - specific_rule_id
    - '!excluded_rule_id'
    - var_name=value
```

## Guidelines for Claude

1. **Always show proposals before making changes.** Present the full content of any new or modified file and wait for explicit approval.
2. **Follow existing patterns.** Before creating a rule, find 2-3 similar existing rules and match their style exactly.
3. **Check for duplicates.** Search before creating a new rule; use `PYTHONPATH=. python utils/find_duplicates.py`.
4. **Use the correct directory.** Find existing rules with the same prefix to locate the right subdirectory.
5. **Preserve formatting.** 4-space YAML indentation for new files; match surrounding file style.
6. **Don't invent references.** Only use CCE, CIS, STIG, SRG, NIST IDs the user provides or that exist in authoritative source documents.
7. **Use templates.** When a shared template covers the requirement, use it instead of writing custom checks.
8. **Rule sections order.** Follow the exact field order listed in the Rule Format section above.
