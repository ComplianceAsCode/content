---
name: draft-pr
description: Open a pull request in the browser with prefilled title, description, and labels
---

# Open Pull Request

Analyze the current branch, generate a PR title/description/labels, push to the user's fork, and open the GitHub PR creation page in the browser with everything prefilled.

## Tool Strategy

This skill uses `mcp__content-agent__*` tools when available (preferred — deterministic, structured results). When the MCP server is not configured, fall back to filesystem-based alternatives noted as **Fallback** in each step. See `.claude/skills/shared/mcp_fallbacks.md` for detailed fallback procedures. The skill must complete successfully either way.

## Phase 1: Gather Branch Data

1. **Derive upstream repo identifier**:
   ```bash
   UPSTREAM_REPO=$(git remote get-url origin | sed -n 's|.*[:/]\([^/]*/[^/]*\)\.git$|\1|p; s|.*[:/]\([^/]*/[^/]*\)$|\1|p')
   ```

2. **Get current branch and branching point**:
   ```bash
   git branch --show-current
   git merge-base HEAD master
   ```

3. **Abort if not on a feature branch**:
   - If on `master`, or if `merge-base` equals `HEAD` (no diverging commits), inform the user:
     "No diverging commits found. Please switch to your feature branch first."
   - Stop execution.

4. **Collect commit history** (all commits since branching point):
   ```bash
   MERGE_BASE=$(git merge-base HEAD master)
   git log --no-merges --format="%H %s%n%b---" ${MERGE_BASE}..HEAD
   ```

5. **Collect diff information**:
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
- **Rules**: Use `mcp__content-agent__get_rule_details` with the rule ID to get title, description, rationale, template, severity, references, and platform info
- **Profiles**: Use `mcp__content-agent__get_profile_details` with product and profile ID to get profile structure and rule selections
- **Controls**: Use `mcp__content-agent__get_control_details` to understand control framework structure
- **Templates**: Use `mcp__content-agent__get_template_schema` to get template parameter info

**Fallback**: Read the files directly — `rule.yml`, `.profile`, control YAML, and template files in `shared/templates/<name>/`.

### 2.4 Check Test Coverage

- Look for added/modified test scenarios in `tests/` subdirectories
- Check if rules use templates (inheriting template tests)

### 2.5 Detect Issue References

Scan commit messages for patterns like `Fixes #N`, `Resolves #N`, `Closes #N`, or bare `#N` references.

## Phase 3: Generate PR Content

### 3.1 PR Title

Generate a PR title following project conventions:
- Under 70 characters
- Imperative mood ("Add", "Fix", "Update")
- Useful for changelog

### 3.2 PR Body

Read the PR template for reference:
```bash
cat .github/pull_request_template.md
```

Draft all three sections following the template format exactly:

#### Description Section

Auto-generate from analysis:

- **New rules**: "Add new rule `<rule_id>` that <what the rule checks>. The rule has `<severity>` severity and targets <products>. It uses the `<template>` template / includes custom OVAL and <Bash/Ansible/both> remediation."
- **Rule modifications**: "Modify rule `<rule_id>` to <what changed>."
- **Profile/control changes**: "Update <profile/control> for <product> to <what changed>."
- **Template changes**: "Modify template `<template_name>` to <what changed>."
- **Multi-change PRs**: List each major change as a separate bullet point.

#### Rationale Section

Attempt to infer from:
- Commit message bodies (look for explanations of "why")
- Rule `rationale` field in `rule.yml`
- Security references indicating compliance requirements
- Profile additions indicating framework alignment

If rationale cannot be fully inferred, include what was found and mark gaps for user input.

Include issue reference if detected in commit messages, otherwise leave a placeholder.

#### Review Hints Section

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

Write the body to `$TMPDIR/pr_body.md`. Do NOT write `PR_DESCRIPTION.md` to the repo root.

### 3.3 Infer Labels

1. Fetch available labels from the repository:
   ```bash
   gh label list -R ${UPSTREAM_REPO} --limit 200 --json name --jq '.[].name'
   ```

2. If `gh label list` fails (e.g., auth issue), skip label inference and tell the user why. Continue to Phase 4 without labels.

3. Match available labels against the PR content using these heuristics:
   - **Product labels**: If changed files or CCE refs mention a product (rhel8, rhel9, rhel10, fedora, ocp4, etc.), look for a matching label
   - **New rule**: If new `rule.yml` files were added, look for a "new rule" or similar label
   - **Bug fix**: If commit messages indicate a fix (commit message starts with "fix", "Fix", contains "bug", etc.), look for a "bug fix" or "bug" label
   - **Profile changes**: If `.profile` files changed, look for a "profiles" label
   - **Control changes**: If `controls/` files changed, look for a "controls" label
   - **Template changes**: If `shared/templates/` files changed, look for a "templates" label
   - **Test changes**: If test scenarios were added/modified, look for a "tests" label
   - **Documentation**: If docs were changed, look for a "documentation" label

   Only select labels that actually exist in the fetched label list. Be conservative — pick labels that clearly apply rather than guessing.

### 3.4 Resolve Milestone

1. Fetch open milestones that look like version numbers:
   ```bash
   gh api repos/${UPSTREAM_REPO}/milestones --jq '[.[] | select(.title | test("^[0-9]+\\."))] | sort_by(.title) | reverse'
   ```

2. Apply selection logic:
   - **Exactly one match**: use it automatically. Note the milestone title for Phase 4.
   - **Zero matches**: warn the user ("No release milestone found — creating PR without one") and continue without a milestone.
   - **Multiple matches**: list the milestone titles and ask the user to pick one, or skip.

3. Store the resolved milestone title (or none) for use in Phase 4.

## Phase 4: Push & Open in Browser

### 4.1 Push to Fork

1. **Verify the `fork` remote exists**:
   ```bash
   git remote get-url fork
   ```
   If this fails, tell the user: "No `fork` remote found. Add it with: `git remote add fork <your-fork-url>`" and stop.

2. **Push the branch**:
   ```bash
   BRANCH=$(git branch --show-current)
   git push fork "${BRANCH}"
   ```

3. **If the push fails with a non-fast-forward error** (e.g., branch was rebased), retry with `--force-with-lease`:
   ```bash
   git push --force-with-lease fork "${BRANCH}"
   ```
   `--force-with-lease` is safe — it refuses to overwrite remote commits that you haven't seen locally, preventing accidental data loss while still allowing rebased branches to be pushed.

### 4.2 Open PR Creation Page

Construct and run the `gh pr create --web` command with all prefilled metadata:

```bash
BRANCH=$(git branch --show-current)
FORK_OWNER=$(git remote get-url fork | sed -n 's|.*[:/]\([^/]*\)/[^/]*\(\.git\)\{0,1\}$|\1|p')
gh pr create --web \
  --repo ${UPSTREAM_REPO} \
  --head "${FORK_OWNER}:${BRANCH}" \
  --base master \
  --title "<generated title>" \
  --body-file "$TMPDIR/pr_body.md" \
  --label "<label1>" --label "<label2>" \
  --milestone "<resolved milestone title>"
```

Determine `FORK_OWNER` by parsing the `fork` remote URL (extract the GitHub username from the URL).

- If no labels were inferred, omit the `--label` flags.
- If no milestone was resolved, omit the `--milestone` flag.
- If `--web` combined with other flags fails, fall back to:
  1. Create the PR directly (remove `--web`).
  2. Open the resulting PR URL in the browser: `xdg-open <pr_url>`.

### 4.3 Clean Up

Remove the temporary body file:
```bash
rm -f "$TMPDIR/pr_body.md"
```

### 4.4 Report

Tell the user:
- The PR title that was used
- The labels that were applied (or note if labels were skipped)
- The milestone that was set (or note if no milestone was found)
- That the browser should have opened to the PR creation page
- If fallback was used, mention the PR was created directly and the URL

## Important Notes

- **Run all `gh` and `git push` commands with `dangerouslyDisableSandbox: true`** — `gh` credentials may be stored in the system keyring, which the sandbox blocks, causing silent 401 auth failures.
- **Analyze ALL commits** in the branch, not just the latest one
- **Use `--no-merges`** when reading commit log to skip merge commits
- **Be specific about products** — use actual product names (rhel8, rhel9, rhel10)
- **Handle large diffs gracefully** — for branches with many changes, summarize by category rather than listing every file
- **Match the PR template format exactly** — the body must follow `.github/pull_request_template.md`
- The fork remote is `fork`, upstream is `origin` — determine the upstream repo from `git remote get-url origin`
- Derive the fork owner from the `fork` remote URL — never hardcode a GitHub username
