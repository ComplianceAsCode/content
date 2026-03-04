---
name: draft-pr
description: Draft a PR description based on branch changes and the project PR template
---

# Draft Pull Request Description

Generate a pull request description for the current branch by analyzing commits since the branching point from master, following the project's PR template format.

## Tool Strategy

This skill uses `mcp__content-mcp__*` tools when available (preferred — deterministic, structured results). When the MCP server is not configured, fall back to filesystem-based alternatives noted as **Fallback** in each step. See `.claude/skills/shared/mcp_fallbacks.md` for detailed fallback procedures. The skill must complete successfully either way.

## Phase 1: Gather Branch Data

1. **Get current branch and branching point**:
   ```bash
   git branch --show-current
   git merge-base HEAD master
   ```

2. **Abort if not on a feature branch**:
   - If on `master`, or if `merge-base` equals `HEAD` (no diverging commits), inform the user:
     "No diverging commits found. Please switch to your feature branch first."
   - Stop execution.

3. **Collect commit history** (all commits since branching point):
   ```bash
   MERGE_BASE=$(git merge-base HEAD master)
   git log --no-merges --format="%H %s%n%b---" ${MERGE_BASE}..HEAD
   ```

4. **Collect diff information**:
   ```bash
   MERGE_BASE=$(git merge-base HEAD master)
   git diff --stat ${MERGE_BASE}..HEAD
   git diff ${MERGE_BASE}..HEAD
   git diff --name-only ${MERGE_BASE}..HEAD
   ```

## Phase 2: Analyze Changes

### 2.1 Categorize Change Type

Determine which categories apply based on changed files and diff content:
- New rule (new `rule.yml` added)
- Modified rule (existing `rule.yml` changed)
- New or modified template (`shared/templates/`)
- Remediation changes (Bash/Ansible files)
- Profile changes (`.profile` files)
- Control file changes (`controls/`)
- Test scenario changes (`tests/`)
- Build system or infrastructure changes
- Documentation changes

### 2.2 Identify Affected Products

Look for product indicators:
- CCE identifiers in `rule.yml` files (`cce@rhel8`, `cce@rhel9`, `cce@rhel10`, etc.)
- Product-specific paths (`products/<product>/`)
- Profile or control file names containing product identifiers
- Platform applicability in rule definitions

### 2.3 Read Key Changed Files

For significant changed files, use MCP functions to get structured metadata:
- **Rules**: Use `mcp__content-mcp__get_rule_details` with the rule ID to get title, description, rationale, template, severity, references, and platform info
- **Profiles**: Use `mcp__content-mcp__get_profile_details` with product and profile ID to get profile structure and rule selections
- **Controls**: Use `mcp__content-mcp__get_control_details` to understand control framework structure
- **Templates**: Use `mcp__content-mcp__get_template_schema` to get template parameter info

**Fallback**: Read the files directly — `rule.yml`, `.profile`, control YAML, and template files in `shared/templates/<name>/`.

### 2.4 Check Test Coverage

- Look for added/modified test scenarios in `tests/` subdirectories
- Check if rules use templates (inheriting template tests)

### 2.5 Detect Issue References

Scan commit messages for patterns like `Fixes #N`, `Resolves #N`, `Closes #N`, or bare `#N` references.

## Phase 3: Draft PR Description

Read the PR template:
```bash
cat .github/pull_request_template.md
```

Draft all three sections following the template format exactly:

### 3.1 Description Section

Auto-generate from analysis:

- **New rules**: "Add new rule `<rule_id>` that <what the rule checks>. The rule has `<severity>` severity and targets <products>. It uses the `<template>` template / includes custom OVAL and <Bash/Ansible/both> remediation."
- **Rule modifications**: "Modify rule `<rule_id>` to <what changed>."
- **Profile/control changes**: "Update <profile/control> for <product> to <what changed>."
- **Template changes**: "Modify template `<template_name>` to <what changed>."
- **Multi-change PRs**: List each major change as a separate bullet point.

### 3.2 Rationale Section

Attempt to infer from:
- Commit message bodies (look for explanations of "why")
- Rule `rationale` field in `rule.yml`
- Security references indicating compliance requirements
- Profile additions indicating framework alignment

If rationale cannot be fully inferred, include what was found and mark gaps for user input.

Include issue reference if detected in commit messages, otherwise leave a placeholder.

### 3.3 Review Hints Section

Auto-generate:
- **Affected products** with build commands: `./build_product --datastream-only <product>`
- **Test commands** if test scenarios exist:
  ```
  ./tests/automatus.py rule --libvirt qemu:///session <product_vm_name> --datastream build/ssg-<product>-ds.xml <rule_id>
  ```
  Note: Adjust `qemu:///session` to `qemu:///system` and `<product_vm_name>` to the actual VM name based on reviewer's local setup.
- **Key files to review**: highlight the most important changed files
- **Review approach**: suggest reviewing all commits together or in sequence, based on how related the commits are
- **Related issues/PRs**: include any references found in commit messages

## Phase 4: Write Output File

### 4.1 Write PR_DESCRIPTION.md

Write the final description to `PR_DESCRIPTION.md` in the repository root. If the file already exists, inform the user and ask whether to overwrite.

The file must begin with the suggested PR title on the first line, followed by a blank line, then the PR template sections:

```
<suggested PR title>

#### Description:

- <description content>

#### Rationale:

- <rationale content>

- Fixes #<number> (only if user provided one, otherwise omit this line)

#### Review Hints:

- <review hints content>
```

### 4.2 PR Title

Generate a PR title following project conventions:
- Under 70 characters
- Imperative mood ("Add", "Fix", "Update")
- Useful for changelog

The title is included at the top of `PR_DESCRIPTION.md` so the user can edit it alongside the body.

### 4.3 Report Next Steps

Tell the user:
- Path to the output file (`PR_DESCRIPTION.md`)
- Suggested PR title
- Commands to create the PR:
  ```bash
  git push -u origin <current_branch>
  gh pr create --title "<suggested title>" --body-file PR_DESCRIPTION.md
  ```
- Reminder: do not commit `PR_DESCRIPTION.md` to the repository

## Important Notes

- **Do NOT push or create the PR** — only draft the description file
- **Match the PR template format exactly** — the output must be drop-in compatible with `.github/pull_request_template.md`
- **Analyze ALL commits** in the branch, not just the latest one
- **Use `--no-merges`** when reading commit log to skip merge commits
- **Be specific about products** — use actual product names (rhel8, rhel9, rhel10)
- **Handle large diffs gracefully** — for branches with many changes, summarize by category rather than listing every file
