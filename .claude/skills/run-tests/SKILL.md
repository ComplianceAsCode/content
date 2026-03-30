---
name: run-tests
description: Run ctest validation tests on a built product
---

# Run Validation Tests

Run the ctest validation suite against built content in `build/`.

## Tool Strategy

This skill uses `mcp__content-mcp__*` tools when available (preferred — deterministic, structured results). When the MCP server is not configured, fall back to filesystem-based alternatives noted as **Fallback** in each step. See `.claude/skills/shared/mcp_fallbacks.md` for detailed fallback procedures. The skill must complete successfully either way.

## Phase 1: Verify Build Exists

1. **Check that the build directory exists and contains content**:
   Use `mcp__content-mcp__list_built_products` to check which products have been built and have artifacts available.
   **Fallback**: Run `ls build/ssg-*-ds.xml 2>/dev/null` to check for built datastreams.

2. **If no build artifacts found**, inform the user:
   - No built products found in `build/`
   - Suggest running `/build-product <product>` first

## Phase 2: Run Validation Tests

Run the full test suite:
```bash
cd build && ctest -j$(nproc) --output-on-failure
```

This includes:
- YAML syntax validation
- Schema validation
- Reference checking
- Python unit tests
- Content validation
- Cross-reference checking

## Phase 3: Analyze Test Results

### Success Output

```
Test Results Summary
====================

Tests: ALL PASSED

Validation: COMPLETE
```

### Failure Output

```
Test Results Summary
====================

Tests: FAILURES DETECTED
  - X/Y tests passed

Failed Tests:
  1. test-yaml-syntax-<product>
     - File: linux_os/guide/.../rule.yml
     - Error: Invalid YAML at line 15

  2. test-oval-schema-<product>
     - File: build/ssg-<product>-oval.xml
     - Error: Element 'object': Missing required attribute 'id'

Suggested Fixes:
  1. Check YAML syntax in the indicated file
  2. Review OVAL generation for the affected rule
```

## Phase 4: Lint Checks (Optional)

Ask if user wants additional lint checks:

### ShellCheck (Bash scripts)

```bash
find linux_os/guide -name "*.sh" -exec shellcheck {} \;
```

### ansible-lint (Ansible playbooks)

```bash
ansible-lint build/ansible/*-playbook-*.yml
```

### yamllint (YAML files)

```bash
yamllint linux_os/guide/
```

### Python linting

```bash
ruff check ssg/
# or
tox -e flake8
```

## Phase 5: Generate Statistics (Optional)

Ask if user wants build statistics:

```bash
cd build
make <product>-stats
```

This generates:
- Rule count per profile
- Coverage statistics
- Reference mapping summary

## Phase 6: Report Results

### Full Success Report

```
Validation Complete
===================

Test Status: ALL PASSED

Ready for:
  - Automatus testing: /test-rule <rule_id>
  - PR creation
```

### Failure Report

```
Validation Complete
===================

Test Status: FAILURES DETECTED
  - See details above

Action Required:
  1. Fix the failing tests before proceeding
  2. Re-run: /run-tests

Common fixes:
  - YAML syntax: Check indentation and special characters
  - OVAL errors: Review template usage in rule.yml
  - Missing references: Add required identifiers
```
