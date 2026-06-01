---
name: create-template
description: Create a template for checks and remediations
argument-hint: template-name
---

# Create Template

Create a new template in `shared/templates/`. Templates generate checks (OVAL) and remediations (Bash, Ansible, etc.) from parameters, reducing code duplication across similar rules.

**Template name**: $ARGUMENTS

## Tool Strategy

Prefer `mcp__content-agent__*` tools when available. When the MCP server is not configured, use the filesystem-based alternatives noted as **Fallback** in each step. See `.claude/skills/shared/mcp_fallbacks.md` for detailed fallback procedures.

## Term Definitions

- **Template**: Parameterized checks, remediations, and metadata in `shared/templates/<name>/`.
- **Templated content**: Checks (OVAL) and remediations (Bash, Ansible, etc.) generated at build time by substituting parameters into templates. Not stored in git.
- **Static content**: Checks and remediations stored directly in rule subdirectories (e.g., `oval/shared.xml`, `bash/shared.sh`). The build system prefers static content over templated content when both exist.
- **Templated rule**: A rule with a `template:` key in `rule.yml` that generates content from a template instead of using static content.

## Phase 1: Design the Template

### 1.1 Read Existing Templates

Read the [Template Reference](../../../docs/templates/template_reference.md) to understand existing templates, their parameters, and structure.

Use `mcp__content-agent__list_templates` to get the full list of available templates.
**Fallback**: Run `ls shared/templates/` to list template directories.

### 1.2 Validate the Template Name

Verify the template name `$ARGUMENTS`:
- Must be `lowercase_with_underscores` (no hyphens, no uppercase)
- Must be short and descriptive
- Must NOT conflict with an existing template name

Use `mcp__content-agent__get_template_schema` with `template_name=$ARGUMENTS` to check if the name already exists.
**Fallback**: Check if `shared/templates/$ARGUMENTS/` already exists.

If the name already exists, inform the user and stop.

### 1.3 Design the Template Interface

Discuss and agree on the following with the user:

1. **Description**: What the template checks and/or remediates, as a short sentence.
2. **Parameters**: For each parameter, define:
   - Name (`lowercase_with_underscores`)
   - Required or optional (with default value if optional)
   - Data type and valid values
   - Whether it should be backed by an XCCDF Variable — use XCCDF Variables when the value should be changeable by the user or differ between profiles (e.g., password length, banner texts, hostnames)
3. **Supported languages**: Which output languages the template should generate. Common combinations:
   - Ansible, Bash, OVAL — most common for Linux rules
   - OVAL only — check-only, no remediation
   - Ansible, Bash, Kubernetes, OVAL — for Kubernetes/OpenShift rules

#### Design Principles

- Keep parameters between 1 and 5. More than 5 suggests the rules should use static content instead.
- Only create a template when multiple similar rules would benefit from it. A template for a single rule is not justified.
- Identify at least 2-3 existing rules that could use the template by searching for similar rules:
  Use `mcp__content-agent__search_rules` with a query matching the template's purpose.
  **Fallback**: `grep -rl` in `linux_os/guide/` or `applications/openshift/` for similar patterns.

### 1.4 Document the Template

Add the new template to [Template Reference](../../../docs/templates/template_reference.md), matching the existing format exactly:

```markdown
#### $ARGUMENTS
-   Description of what the template checks/remediates.

-   Parameters:

    -   **param_name** - description of the parameter

    -   **optional_param** - (optional) description. Default: `"default_value"`.

-   Languages: Ansible, Bash, OVAL
```

Insert the entry in alphabetical order among the existing templates, before the "Creating Templates" section.

## Phase 2: Create Template Skeleton

All template files go in `shared/templates/$ARGUMENTS/`.

### 2.1 Create `template.yml`

List all languages the template supports. The build system only generates content for languages listed here.

Valid language identifiers: `anaconda`, `ansible`, `bash`, `blueprint`, `bootc`, `ignition`, `kickstart`, `kubernetes`, `oval`, `puppet`, `sce-bash`.

```yaml
supported_languages:
  - ansible
  - bash
  - oval
```

### 2.2 Create `template.py`

This Python file preprocesses template parameters before they reach the Jinja2 engine. Every template **must** have a `template.py` with a `preprocess(data, lang)` function, even if it only returns `data` unchanged.

The function:
- Receives `data`: a dictionary of template parameters from the rule's `template.vars`, plus the implicit `_rule_id` key
- Receives `lang`: the language being generated (e.g., `"oval"`, `"bash"`, `"ansible"`)
- **Must return** the `data` dictionary (a missing return silently breaks preprocessing)

Use the preprocessor to:
1. **Set default values** for optional parameters
2. **Validate** required parameters and their formats
3. **Transform** parameters (escape special characters, convert types, compute derived values)
4. **Create test parameters** — values used by templated test scenarios (e.g., `test_correct_value`, `test_wrong_value`)
5. **Perform language-specific transformations** by branching on `lang`

You can import helper functions from `ssg.utils` (e.g., `ssg.utils.escape_id()`).

#### Minimal `template.py`

```python
def preprocess(data, lang):
    return data
```

#### Typical `template.py` with Defaults, Validation and Test Data

```python
def preprocess(data, lang):
    # Validate required parameters
    if "key" not in data:
        raise ValueError(
            "Rule {0} is missing required 'key' parameter".format(
                data["_rule_id"]))

    # Set defaults for optional parameters
    if "separator" not in data:
        data["separator"] = "="

    # Language-specific transformations
    if lang == "oval":
        data["escaped_key"] = data["key"].replace(".", "_")

    # Create test scenario parameters
    data["test_correct_value"] = str(data.get("value", "correct_value"))
    data["test_wrong_value"] = "wrong_value"

    return data
```

**Common patterns in existing preprocessors:**
- `package_installed`: validates `evr` format with regex
- `key_value_pair_in_file`: sets defaults for `sep`, `sep_regex`, `prefix_regex`, `app`, creates `test_correct_value`/`test_wrong_value`
- `sysctl`: uses `ssg.utils.escape_id()` for ID sanitization, detects IPv6 from variable name, generates test values based on datatype
- `service_disabled`: sets `packagename` and `daemonname` defaults from `servicename`

### Implicit Variables Available in Templates

The build system injects these variables into every template (available in both `template.py` and `.template` files):

| Variable | Description |
|----------|-------------|
| `_rule_id` | The rule ID of the rule using the template |
| `rule_id` | Same as `_rule_id`, available in Jinja context |
| `rule_title` | The rule's title from `rule.yml` |
| `product` | Current product being built (e.g., `rhel9`) |
| `pkg_system` | Package system for the product (e.g., `rpm`, `dpkg`) |

**Casing note**: `_rule_id` is a template parameter, so it becomes `_RULE_ID` in `.template` files (like all parameters). The others (`rule_id`, `rule_title`, `product`, `pkg_system`) are environment/context variables that stay **lowercase**. In practice, both `{{{ _RULE_ID }}}` and `{{{ rule_id }}}` resolve to the same rule ID — use whichever is conventional for the context (existing templates typically use `_RULE_ID` in OVAL `id=` attributes and `rule_id` in macro arguments).

## Phase 3: Create Template Files for Checks and Remediations

For each language in `template.yml`, create a `<lang>.template` file. The file name must match the language identifier exactly.

### Jinja2 Conventions

This project uses **custom Jinja2 delimiters** (defined in `ssg/jinja.py`). Standard Jinja2 syntax will NOT work:
- **Expressions**: `{{{ expr }}}` (triple braces), NOT `{{ expr }}`
- **Statements**: `{{% stmt %}}`, NOT `{% stmt %}`
- **Comments**: `{{# comment #}}`, NOT `{# comment #}`

**Critical — variable casing in `.template` files**:
- **Template parameters** from `rule.yml` vars (and those set in `template.py`) must be in **UPPERCASE**. The build system converts all parameter keys to uppercase automatically. Example: `package_name` in `rule.yml` becomes `PACKAGE_NAME` in the template.
- **Environment/context variables** (`rule_id`, `rule_title`, `product`, `pkg_system`) stay **lowercase**.
- **Special case**: `_rule_id` is a parameter (becomes `_RULE_ID`), while `rule_id` is a context variable (stays lowercase). Both resolve to the same value.

### Remediation Template Headers

Bash and Ansible templates must start with these metadata comments:

```
# platform = multi_platform_all
# reboot = false
# strategy = configure
# complexity = low
# disruption = low
```

Adjust `platform` to match the template's applicability. Use specific platforms (e.g., `multi_platform_rhel,multi_platform_fedora`) if the template only applies to certain products.

### Bash Template (`bash.template`)

Use macros from `shared/macros/bash.jinja` for common operations:

```bash
# platform = multi_platform_all
# reboot = false
# strategy = configure
# complexity = low
# disruption = low

{{{ bash_replace_or_append(CONFIG_FILE, KEY, VALUE) }}}
```

Common Bash macros:
- `{{{ bash_package_install(package=PKGNAME) }}}`
- `{{{ bash_package_remove(package=PKGNAME) }}}`
- `{{{ bash_replace_or_append(config_file, key, value) }}}`
- `{{{ bash_instantiate_variables(XCCDF_VARIABLE) }}}`
- `{{{ set_config_file(path, key, value, ...) }}}`

### Ansible Template (`ansible.template`)

Use macros from `shared/macros/ansible.jinja`:

```yaml
# platform = multi_platform_all
# reboot = false
# strategy = configure
# complexity = low
# disruption = low

- name: Ensure {{{ KEY }}} is set to {{{ VALUE }}}
  ansible.builtin.lineinfile:
    path: "{{{ CONFIG_FILE }}}"
    regexp: '^{{{ KEY }}}'
    line: "{{{ KEY }}}={{{ VALUE }}}"
    state: present
    create: true
```

Common Ansible macros:
- `{{{ ansible_instantiate_variables(XCCDF_VARIABLE) }}}`
- `{{{ ansible_set_config_file(msg, path, key, value, ...) }}}`

### OVAL Template (`oval.template`)

OVAL templates use shorthand format. Use macros from `shared/macros/oval.jinja`:

```xml
<def-group>
  <definition class="compliance" id="{{{ _RULE_ID }}}" version="1">
    {{{ oval_metadata("Description of what is checked.", affected_platforms=["multi_platform_all"], rule_title=rule_title) }}}
    <criteria>
      <criterion comment="check description"
      test_ref="test_{{{ _RULE_ID }}}" />
    </criteria>
  </definition>
  <!-- Add OVAL tests, objects, and states here -->
</def-group>
```

Common OVAL macros:
- `{{{ oval_metadata(description, affected_platforms, rule_title) }}}`
- `{{{ oval_test_package_installed(package, evr, test_id) }}}`
- `{{{ oval_check_config_file(path, parameter, value, ...) }}}`

### Product-Specific Branching in Templates

Use Jinja conditionals for product-specific behavior:

```
{{% if product in ["sle12", "sle15"] %}}
# SUSE-specific implementation
{{% elif product in ["ubuntu2204", "ubuntu2404"] %}}
# Ubuntu-specific implementation
{{% else %}}
# Default implementation
{{% endif %}}
```

### XCCDF Variable Handling

Templates that support XCCDF variables typically branch on whether the variable is set:

```
{{% if XCCDF_VARIABLE %}}
{{{ bash_instantiate_variables(XCCDF_VARIABLE) }}}
# Use $XCCDF_VARIABLE
{{% else %}}
# Use hardcoded VALUE
{{% endif %}}
```

## Phase 4: Create Test Scenarios

Create templated test scenarios in `shared/templates/$ARGUMENTS/tests/`. These tests are automatically inherited by all rules using the template.

### 4.1 Design Test Scenarios

Every template needs at minimum:
- 1 pass scenario (system is compliant)
- 1 fail scenario (system is non-compliant but remediable)

Common test scenarios:
- `correct_value.pass.sh` — correct configuration is present
- `wrong_value.fail.sh` — incorrect value is configured
- `missing_value.fail.sh` — required configuration is absent
- `missing_file.fail.sh` — configuration file does not exist
- `duplicate_values.pass.sh` — multiple correct entries (if applicable)
- `conflicting_values.fail.sh` — correct and incorrect entries both present (if applicable)
- `commented_value.fail.sh` — correct value is commented out (if applicable)

### 4.2 Write Test Scenario Files

Test scenarios are Bash scripts with Jinja2 templating. They use the same custom delimiters as `.template` files, and template parameters must be in **UPPERCASE**.

Use test-specific parameters created in `template.py` (e.g., `TEST_CORRECT_VALUE`, `TEST_WRONG_VALUE`) rather than the rule's actual values — this ensures tests work correctly across all rules using the template.

**Pass scenario example** (`correct_value.pass.sh`):
```bash
#!/bin/bash

mkdir -p $(dirname {{{ PATH }}})
echo "{{{ KEY }}}{{{ SEP }}}{{{ TEST_CORRECT_VALUE }}}" > "{{{ PATH }}}"
```

**Fail scenario example** (`wrong_value.fail.sh`):
```bash
#!/bin/bash

mkdir -p $(dirname {{{ PATH }}})
echo "{{{ KEY }}}{{{ SEP }}}{{{ TEST_WRONG_VALUE }}}" > "{{{ PATH }}}"
```

**XCCDF variable handling in tests**:
```bash
#!/bin/bash

{{%- if XCCDF_VARIABLE %}}
# variables = {{{ XCCDF_VARIABLE }}}={{{ TEST_CORRECT_VALUE }}}
{{% endif %}}

mkdir -p $(dirname {{{ PATH }}})
echo "{{{ KEY }}}{{{ SEP }}}{{{ TEST_CORRECT_VALUE }}}" > "{{{ PATH }}}"
```

The `# variables = VAR_NAME=value` comment tells the test framework to set the XCCDF variable to the specified value during the test.

### 4.3 Test File Conventions

- File naming: `description.pass.sh` or `description.fail.sh`
- Do NOT make test files executable — the test framework handles this
- Pass scenarios set up a compliant state; no remediation runs
- Fail scenarios set up a non-compliant state that the remediation **can fix** — never create fail scenarios that the remediation cannot remediate
- Use Bash macros (e.g., `{{{ bash_package_install(PKGNAME) }}}`) when available
- Always clean up prior state before writing test values (e.g., use `sed` to remove existing config entries)

## Phase 5: Verify Template by Using It in a Rule

### 5.1 Find or Create a Rule

Ask the user for a rule ID to use with the template.

If no suitable rule exists, suggest using the `create-rule` skill to create one.

### 5.2 Add Template to a Rule

Add the `template` key to the rule's `rule.yml`:

```yaml
template:
    name: $ARGUMENTS
    vars:
        param1: value1
        param2: value2
```

Use `@product` syntax for product-specific parameter values:

```yaml
template:
    name: $ARGUMENTS
    vars:
        param1: value1
        param1@rhel9: different_value
        param1@ubuntu2404: another_value
```

### 5.3 Remove Conflicting Static Content

If the rule has static content (files in `oval/`, `bash/`, `ansible/` subdirectories), those files **override** templated content. Remove any static files that the template now generates, unless the rule intentionally needs static content to override the template for a specific language.

### 5.4 Build and Test

1. Build the product to verify the template generates correctly:
   ```bash
   ./build_product <product> --datastream --rule-id <rule_id>
   ```

2. Verify correct template expansion in the rendered output:
   Use `mcp__content-agent__get_rendered_rule` with `product=<product>` and `rule_id=<rule_id>`.
   **Fallback**: Inspect `build/<product>/rules/<rule_id>/` for generated content.

3. Run tests using the `test-rule` skill to verify that both checks and remediations work correctly.

## Phase 6: Report

Report to the user:
- All created files (list with paths)
- Template parameters and their defaults
- Supported languages
- Test scenarios created
- Rule(s) updated to use the template
- Next steps:
  - "Use `/build-product <product>` to build"
  - "Use `/test-rule <rule_id>` to run tests"
  - "Convert other similar rules to use this template"

## Common Issues

- **Parameters not substituted**: Template parameters must be UPPERCASE in `.template` files. The build system converts parameter keys to uppercase automatically.
- **Template output missing for a language**: The `.template` file exists but the language is not listed in `template.yml`. Every supported language must be listed there.
- **Preprocessing not applied**: The `preprocess` function in `template.py` must `return data`. A missing return statement silently breaks preprocessing.
- **Static content overrides template**: If a rule has both static content (e.g., `oval/shared.xml`) and a template, static content takes priority. Remove static files when switching to a template.
- **Wrong Jinja delimiters**: Use `{{{ }}}` for expressions, `{{% %}}` for statements. Standard Jinja2 `{{ }}` / `{% %}` will NOT work.
- **Test scenarios use hardcoded values**: Use test-specific parameters from `template.py` (e.g., `TEST_CORRECT_VALUE`) instead of the rule's actual values to ensure tests work across all rules using the template.

## File Structure Summary

After completion, the template directory should look like:

```
shared/templates/$ARGUMENTS/
    template.yml          # Supported languages
    template.py           # Parameter preprocessing
    ansible.template      # Ansible remediation (if supported)
    bash.template         # Bash remediation (if supported)
    oval.template         # OVAL check (if supported)
    tests/
        correct_value.pass.sh    # At least 1 pass scenario
        wrong_value.fail.sh      # At least 1 fail scenario
        ...                      # Additional scenarios
```
