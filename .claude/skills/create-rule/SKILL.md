---
name: create-rule
description: Create a new security rule with all required components
---

# Create Rule

Create a new security rule for ComplianceAsCode. This skill handles both templated and non-templated rules.

**Rule ID**: $ARGUMENTS

## Tool Strategy

This skill uses `mcp__content-agent__*` tools when available (preferred — deterministic, structured results). When the MCP server is not configured, fall back to filesystem-based alternatives noted as **Fallback** in each step. See `.claude/skills/shared/mcp_fallbacks.md` for detailed fallback procedures. The skill must complete successfully either way.

## Phase 1: Validate Input

1. **Validate rule ID format**:
   - Must be lowercase with underscores (no hyphens or uppercase)
   - Example valid IDs: `sshd_max_auth_tries`, `accounts_password_minlen`

2. **Check if rule already exists**:
   Use `mcp__content-agent__search_rules` with `query=$ARGUMENTS` to check if a rule with this ID already exists.
   **Fallback**: Use `Glob` to search for `**/$ARGUMENTS/rule.yml`.
   - If rule exists, inform user and ask if they want to modify it instead

3. **Determine rule location**:
   - Ask user where to create the rule within the guide hierarchy
   - Provide suggestions based on rule ID prefix (e.g., `sshd_*` goes under `linux_os/guide/services/ssh/ssh_server/`)

## Phase 2: Determine Rule Type

Use AskUserQuestion to ask the user:

**Question**: "What type of rule do you want to create?"

**Options**:
1. **Templated rule (Recommended)** - Uses an existing template for checks and remediations. Faster to create, inherits tests from template.
2. **Non-templated rule** - Custom OVAL, Bash, and Ansible implementations. Requires writing test scenarios.

## Phase 3: Template Selection (if templated)

If user chose templated rule:

1. **List available templates** using `mcp__content-agent__list_templates` to get all available templates with their descriptions.
   **Fallback**: Run `ls shared/templates/` to list available template directories.

2. **Present available templates** from the list obtained in step 1 and help the user select the right one based on their use case.

3. **Ask for template selection** using AskUserQuestion

4. **Get template parameter schema** using `mcp__content-agent__get_template_schema` with `template_name=<selected_template>` to get the full parameter schema, supported languages, and documentation.
   **Fallback**: Read `shared/templates/<template_name>/template.yml` or `template.py` for parameter definitions. Check existing rules using this template for usage examples.

5. **Collect template variables**:
   - Use the schema from step 4 to identify required and optional parameters
   - Ask user for each required variable

## Phase 4: Gather Rule Metadata

Collect the following information using AskUserQuestion or prompts:

### Required Fields

1. **Title**: Short descriptive title (displayed in scan results)
   - Example: "Disable SSH Root Login"

2. **Description**: Detailed description using Jinja2 templating
   - Can use macros like `{{{ sshd_config_file() }}}`, `{{{ describe_mount(...) }}}`

3. **Rationale**: Why this rule is important for security

4. **Severity**: One of `low`, `medium`, `high`, `unknown`. Default value would be `medium`.

### Identifiers

5. **CCE identifiers**: Ask which RHEL products need CCEs (rhel8, rhel9, rhel10)
   - Format: `cce@rhel9: CCE-XXXXX-X`
   - **Automatic CCE allocation**:
     1. Read available CCEs from `shared/references/cce-redhat-avail.txt`
     2. For each requested product, take the first available CCE from the file
     3. After adding the CCE to `rule.yml`, remove it from `cce-redhat-avail.txt` to prevent reuse
   - If user doesn't want CCEs now, leave blank (can be added later)

   ```bash
   # Read first available CCE
   head -1 shared/references/cce-redhat-avail.txt

   # After using a CCE, remove it from the file
   sed -i '1d' shared/references/cce-redhat-avail.txt
   ```

### References (Optional but Recommended)

6. **Security references** - ask if user has any of:
   - `nist`: NIST SP 800-53 controls (e.g., `AC-6(2),CM-6(a)`)
   - `srg`: DISA SRG IDs (e.g., `SRG-OS-000480-GPOS-00227`)
   - `stigid` and `cis` references are filled in automatically by placing the rule into an appropriate control file

### Additional Fields

7. **Platform** (optional): Platform applicability
   - Example: `platform: machine` (not for containers)
   - Example: `platform: package[openssh-server]`

8. **OCIL** (optional): OCIL check description
   - Often uses macros like `{{{ complete_ocil_entry_sshd_option(...) }}}`

## Phase 5: Generate Rule

### For Templated Rules

Use `mcp__content-agent__generate_rule_from_template` with:
- `template_name`: The selected template name
- `parameters`: Template variables collected from the user
- `rule_id`: $ARGUMENTS
- `product`: The target product

This generates the rule directory and rule.yml with the template configuration automatically.

**Fallback**: Create the rule directory and `rule.yml` manually using `Write` tool. Include the `template:` key with `name:` and `vars:` based on the selected template.

### For Non-Templated Rules

Use `mcp__content-agent__generate_rule_boilerplate` with:
- `rule_id`: $ARGUMENTS
- `title`: The rule title
- `description`: The rule description
- `severity`: The severity level
- `product`: The target product
- `rationale`: The rationale (optional)
- `location`: The guide path (optional, e.g., `linux_os/guide/services/ssh`)

**Fallback**: Create the directory structure and all files manually using `Write` tool, following the skeleton templates below.

This generates the rule directory structure with skeleton files:
```
<location>/$ARGUMENTS/
├── rule.yml
├── oval/
│   └── shared.xml
├── bash/
│   └── shared.sh
├── ansible/
│   └── shared.yml
└── tests/
    ├── correct.pass.sh
    └── wrong.fail.sh
```

### Post-Generation Customization

After MCP generates the boilerplate, customize the generated files:
- Add CCE identifiers, references, and platform applicability to rule.yml
- For non-templated rules, implement the OVAL, Bash, Ansible, and test content

### Skeleton Files for Non-Templated Rules

**oval/shared.xml**:
```xml
<def-group>
  <definition class="compliance" id="{{{ rule_id }}}" version="1">
    {{{ oval_metadata("{DESCRIPTION}", rule_title=rule_title) }}}
    <criteria>
      <!-- Add OVAL criteria here -->
    </criteria>
  </definition>
  <!-- Add OVAL tests, objects, and states here -->
</def-group>
```

Note: `rule_id` and `rule_title` are automatically populated during build from the rule.yml.

**bash/shared.sh**:
```bash
# platform = multi_platform_all
# reboot = false
# strategy = configure
# complexity = low
# disruption = low

# Remediation script for $ARGUMENTS
# TODO: Implement remediation
```

**ansible/shared.yml**:
```yaml
# platform = multi_platform_all
# reboot = false
# strategy = configure
# complexity = low
# disruption = low

- name: "{TITLE}"
  # TODO: Implement remediation
  ansible.builtin.debug:
    msg: "Remediation not yet implemented"
```

**tests/correct.pass.sh**:
```bash
#!/bin/bash
# packages = {REQUIRED_PACKAGES}

# Set up compliant state
# TODO: Configure system to be compliant
```

**tests/wrong.fail.sh**:
```bash
#!/bin/bash
# packages = {REQUIRED_PACKAGES}

# Set up non-compliant state
# TODO: Configure system to be non-compliant
```

## Phase 6: Add to Component

Every rule must belong to a component. Components are defined in `components/*.yml` and map rules to their associated packages and groups.

### Step 1: Identify Appropriate Component

Based on the rule's purpose and location, suggest likely components:

```bash
# List all available components
ls components/*.yml | sed 's|components/||;s|\.yml||' | sort
```

**Finding the right component**: Search existing component files for rules with a similar prefix to identify the likely component:
```bash
# Find which component contains rules with a similar prefix
grep -l '<rule_prefix>' components/*.yml
```

### Step 2: Verify Component Exists

```bash
# Check if suggested component exists
cat components/<component_name>.yml
```

### Step 3: Ask User to Confirm or Select Component

Use AskUserQuestion with options:
1. Suggested component (if identified)
2. Browse/search for another component
3. Create a new component

### Step 4a: Add Rule to Existing Component

If user selects an existing component:

1. **Read the component file**:
   ```bash
   cat components/<component_name>.yml
   ```

2. **Add the rule ID** to the `rules:` list in alphabetical order:
   ```yaml
   rules:
   - existing_rule_1
   - existing_rule_2
   - $ARGUMENTS        # Add new rule here
   - existing_rule_3
   ```

3. **If using a template**, verify the template is listed in `templates:` section. If not, add it:
   ```yaml
   templates:
   - existing_template
   - {TEMPLATE_NAME}   # Add if not present
   ```

### Step 4b: Create New Component

If no suitable component exists:

1. **Ask for component details**:
   - Component name (lowercase, hyphenated, e.g., `my-service`)
   - Associated packages (list)
   - Associated groups (from rule hierarchy)

2. **Create the component file** `components/<component_name>.yml`:
   ```yaml
   groups:
   - <group_from_rule_hierarchy>
   name: <component_name>
   packages:
   - <package_name>
   rules:
   - $ARGUMENTS
   templates:
   - {TEMPLATE_NAME}   # If templated rule
   ```

3. **Verify the new component**:
   ```bash
   python3 -c "import yaml; yaml.safe_load(open('components/<component_name>.yml'))"
   ```

### Component File Structure Reference

```yaml
groups:        # Rule groups this component covers (from guide hierarchy)
- service_name
- service_name_server
name: component-name   # Matches filename without .yml
packages:      # Packages associated with this component
- package-name
- package-name-server
rules:         # Rule IDs belonging to this component (alphabetical)
- rule_id_1
- rule_id_2
templates:     # Templates used by rules in this component
- template_name
```

## Phase 7: Add to Profile(s) or Control File(s)

Most profiles in the project reference control files rather than listing rules directly. When adding a rule to a profile that uses a control file, add the rule to the control file instead.

### Step 1: List Available Profiles

Use `mcp__content-agent__list_profiles` with `product=<product>` to list all available profiles for each target product.
   **Fallback**: Run `ls products/<product>/profiles/*.profile` to list profiles.

### Step 2: Ask User Which Profile(s)

Use AskUserQuestion to ask which profile(s) to add the rule to. Allow multiple selection.

### Step 3: Detect Control File Reference

For each selected profile, read it and check if it references a control file:

```bash
grep -E "^\s+-\s+\w+:all" products/<product>/profiles/<profile>.profile
```

**Control file reference patterns**:
- `cis_rhel9:all` or `cis_rhel9:all:l2_server` → Control file: `products/rhel9/controls/cis_rhel9.yml`
- `stig_rhel9:all` → Control file: `products/rhel9/controls/stig_rhel9.yml`
- `hipaa:all` → Control file: `controls/hipaa.yml` (shared across products)

**How to find the control file**:
1. Extract the control ID from the selection (e.g., `cis_rhel9` from `cis_rhel9:all:l2_server`)
2. Look in `products/<product>/controls/<control_id>.yml` first
3. If not found, look in `controls/<control_id>.yml`

### Step 4a: Add to Control File (if profile uses control file)

If the profile references a control file:

1. **Read the control file** to understand its structure
2. **Ask user for control placement**:
   - For CIS: Ask for the section ID (e.g., `5.2.15` for SSH settings)
   - For STIG: Ask for the STIG ID (e.g., `RHEL-09-123456`)
   - Show the control file structure to help user decide

3. **Determine the level(s)** for the rule:
   - CIS: `l1_server`, `l2_server`, `l1_workstation`, `l2_workstation`
   - STIG: `high`, `medium`, `low`

4. **Add a new control entry** to the control file:

   **For CIS control files**:
   ```yaml
   - id: 5.2.15
     title: Ensure SSH MaxAuthTries is set to 4 or less (Automated)
     levels:
         - l1_server
         - l1_workstation
     status: automated
     rules:
         - $ARGUMENTS
   ```

   **For STIG control files**:
   ```yaml
   - id: RHEL-09-123456
     levels:
         - medium
     title: RHEL 9 must limit the number of SSH authentication attempts.
     rules:
         - $ARGUMENTS
     status: automated
   ```

5. **Insert in the correct position** (controls are typically ordered by ID)

### Step 4b: Add Directly to Profile (if no control file)

If the profile lists rules directly (no control file reference):

1. Read the profile file
2. Add the rule ID to the `selections:` list
3. Maintain alphabetical order if the profile uses it

### Control File Locations

**Product-specific** (preferred for product-specific benchmarks):
- `products/rhel8/controls/*.yml`
- `products/rhel9/controls/*.yml`
- `products/rhel10/controls/*.yml`

**Shared** (for cross-product policies):
- `controls/*.yml`

### Common Control Files by Profile

| Profile | Control File |
|---------|--------------|
| `cis.profile` (rhel9) | `products/rhel9/controls/cis_rhel9.yml` |
| `stig.profile` (rhel9) | `products/rhel9/controls/stig_rhel9.yml` |
| `hipaa.profile` | `controls/hipaa.yml` |
| `pci-dss.profile` | `controls/pcidss_4.yml` |
| `ospp.profile` | `controls/ospp.yml` |
| `anssi_bp28_*.profile` | `controls/anssi.yml` |

### Reference Security Policies

When adding to CIS or STIG control files, reference the corresponding security policy document to find the correct control ID:
- CIS RHEL 9: `security_policies/CIS_Red_Hat_Enterprise_Linux_9_Benchmark_v2.0.0.md`
- STIG RHEL 9: `security_policies/Red Hat Enterprise Linux 9 STIG V2R5 - STIG-A-View.md`

### Step 5: Update Profile Stability Test Data

**IMPORTANT**: Whenever a rule is added to a profile (whether directly or via control file), the profile stability test data must also be updated.

Profile stability test data is located in `tests/data/profile_stability/<product>/<profile>.profile` and contains a sorted list of rule IDs, one per line.

1. **Check if stability test file exists**:
   ```bash
   ls tests/data/profile_stability/<product>/<profile>.profile
   ```

2. **If the file exists**, add the rule ID in alphabetical order:
   ```bash
   # Read current file, add new rule, sort, and write back
   (cat tests/data/profile_stability/<product>/<profile>.profile; echo "$ARGUMENTS") | sort -u > /tmp/profile_stability_tmp
   mv /tmp/profile_stability_tmp tests/data/profile_stability/<product>/<profile>.profile
   ```

3. **If the file doesn't exist**, this may be a new profile or a product without stability tests. Check if the product directory exists:
   ```bash
   ls tests/data/profile_stability/<product>/
   ```
   - If the product directory exists but the profile file doesn't, create it with just the new rule
   - If the product directory doesn't exist, skip this step (stability tests may not be set up for this product)

**Profile stability test file format**:
```
rule_id_1
rule_id_2
rule_id_3
...
```

Rules are listed one per line, sorted alphabetically, with no duplicates.

**Discover products with stability tests**:
```bash
ls tests/data/profile_stability/
```

## Phase 8: Verify and Report

1. **Verify created files**:
   ```bash
   ls -la <rule_directory>/
   cat <rule_directory>/rule.yml
   ```

2. **Validate rule YAML** using `mcp__content-agent__validate_rule_yaml` with the content of the generated rule.yml. This validates syntax, structure, and reference formats.
   **Fallback**: Validate against the JSON schema:
   ```bash
   python3 -c "
   import json, yaml, sys
   from jsonschema import validate, ValidationError
   schema = json.load(open('shared/schemas/rule.json'))
   data = yaml.safe_load(open(sys.argv[1]))
   try:
       validate(instance=data, schema=schema)
       print('Valid')
   except ValidationError as e:
       print(f'Invalid: {e.message}')
   " <path_to_rule.yml>
   ```

   For control files, use `mcp__content-agent__validate_control_file` with the control file path.
   **Fallback**: Validate against the control schema:
   ```bash
   python3 -c "
   import json, yaml, sys
   from jsonschema import validate, ValidationError
   schema = json.load(open('shared/schemas/control.json'))
   data = yaml.safe_load(open(sys.argv[1]))
   try:
       validate(instance=data, schema=schema)
       print('Valid')
   except ValidationError as e:
       print(f'Invalid: {e.message}')
   " <path_to_control.yml>
   ```

3. **Verify CCE was removed** from available list (if CCE was allocated):
   ```bash
   grep "<allocated_cce>" shared/references/cce-redhat-avail.txt  # should return nothing
   ```

4. **Verify rule is in component**:
   ```bash
   grep "$ARGUMENTS" components/<component>.yml
   ```

5. **Verify profile stability test data** (if profile was modified):
   ```bash
   grep "$ARGUMENTS" tests/data/profile_stability/<product>/<profile>.profile
   ```

7. **Report to user**:
   - List all created files
   - Show CCE allocations (and confirm removal from available list)
   - Show component file modification
   - Show control file or profile modifications
   - Show profile stability test data updates
   - Explain that `stigid` and `cis` references will be automatically populated from the control file
   - Provide next steps:
     - For templated rules: "Use `/test-rule $ARGUMENTS` to test"
     - For non-templated rules: "Complete the OVAL, Bash, Ansible, and test files, then use `/test-rule $ARGUMENTS`"
     - "Use `/build-product <product>` to build and `/run-tests` to validate"

## Important Notes

- **Do NOT make test files executable** - the test framework handles this
- **Use the project's custom Jinja2 delimiters** — this project does NOT use standard Jinja2 syntax. The custom delimiters (defined in `ssg/jinja.py`) avoid conflicts with YAML/XML curly braces:
  - **Variables/expressions**: `{{{ expr }}}` (triple braces), NOT `{{ expr }}`
  - **Statements** (if/for/set): `{{% stmt %}}`, NOT `{% stmt %}`
  - **Comments**: `{{# comment #}}`, NOT `{# comment #}`
  - Examples: `{{{ full_name }}}`, `{{{ describe_service_enable(service="auditd") }}}`, `{{% if product in ["rhel9"] %}}`, `{{% set var="value" %}}`
- **Check existing similar rules** for reference on structure and content
- **Templated rules are preferred** when a suitable template exists
- **Every rule must belong to a component** - add to existing component or create new one
- **Control files are preferred over direct profile modification** - they provide better structure and automatic reference population
- **CCE identifiers must be unique** - always remove allocated CCEs from `cce-redhat-avail.txt`
- **Update profile stability test data** - when adding to a profile, also update `tests/data/profile_stability/<product>/<profile>.profile`

## Error Handling

- If rule creation fails, clean up any partially created files
- If CCE allocation fails, do not remove CCEs from the available list
- Validate YAML syntax before writing
- Check for common mistakes:
  - Missing required fields
  - Invalid template names
  - Malformed references
  - Duplicate control IDs in control files
  - Invalid level names in control files
  - Rule not added to any component
  - Component file syntax errors
  - Profile stability test data not updated
