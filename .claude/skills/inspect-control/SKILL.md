---
name: inspect-control
description: Inspect a control file showing requirement stats, mapping status, and cross-framework context. Use for triage before mapping.
---

# Inspect Control

Analyze a control file and report its current state: how many requirements are mapped, unmapped, manual, etc. Useful for understanding a control file before starting a mapping session.

**Arguments**: $ARGUMENTS (control file ID, e.g., `anssi`, `srg_gpos`, `hipaa`)

## Tool Strategy

This skill uses `mcp__content-mcp__*` tools when available (preferred — deterministic, structured results). When the MCP server is not configured, fall back to filesystem-based alternatives noted as **Fallback** in each step. See `.claude/skills/shared/mcp_fallbacks.md` for detailed fallback procedures. The skill must complete successfully either way.

## Phase 1: Validate and Load Control File

1. **Parse arguments**: Extract control_id from `$ARGUMENTS`.

2. **Validate control exists**: Call `mcp__content-mcp__get_control_stats` with `control_id=$ARGUMENTS`.
   - If the tool returns an error (control not found), call `mcp__content-mcp__list_controls` and present available control files via `AskUserQuestion`:
     - "Control file '$ARGUMENTS' not found. Which control file do you want to inspect?"
     - Options: top 4 most relevant from the list + Other
   - **Fallback**: Look for `controls/$ARGUMENTS.yml` or `products/**/controls/$ARGUMENTS.yml`. If not found, run `ls controls/*.yml` and `ls products/*/controls/*.yml` to list available control files. To compute stats, read the control YAML and count requirements grouped by `status` field.

3. **Display basic info**: Show the control file title, ID, and total requirement count from the stats result.

## Phase 2: Report Statistics

Using the `get_control_stats` result, present:

```
## Control File: {title} ({control_id})

| Status           | Count |
|------------------|-------|
| Total            | {total} |
| Mapped (rules)   | {mapped} |
| Unmapped (no rules) | {unmapped} |
| automated        | {by_status.automated} |
| pending          | {by_status.pending} |
| manual           | {by_status.manual} |
| not applicable   | {by_status.not_applicable} |
| partial          | {by_status.partial} |
| ...              | ... |

Coverage: {mapped}/{total} ({percentage}%)
```

Only show status rows that have non-zero counts.

## Phase 3: List Unmapped Requirements

1. Call `mcp__content-mcp__list_unmapped_requirements` with `control_id` and default `status_filter` (pending).
   **Fallback**: Read the control YAML and filter requirements where `status` is `pending` or where `rules:` is empty/missing.

2. Present the unmapped work queue:

```
### Unmapped Requirements (pending)

| # | ID | Title |
|---|-----|-------|
| 1 | R3  | Disk partitioning |
| 2 | R7  | Dedicated admin accounts |
| ... | ... | ... |
```

3. If there are requirements with status `partial` or `does not meet`, also call `list_unmapped_requirements` with `status_filter=["partial", "does not meet"]` and show them separately.
   **Fallback**: Filter the control YAML for requirements with `status: partial` or `status: does not meet`.

```
### Partially Mapped / Needs Work

| # | ID | Title | Status |
|---|-----|-------|--------|
| 1 | R12 | Audit logging | partial |
```

## Phase 4: Next Steps

Present actionable next steps based on the analysis:

```
### Next Steps

- To map all unmapped requirements interactively: `/map-controls {control_id} --product <product>`
- To map a single requirement: `/map-requirement {control_id} <requirement_id> --product <product>`
- To view full control details: use `mcp__content-mcp__get_control_details`

**Tip**: If you have the source security policy document (PDF, Markdown, or HTML), pass it with `--policy <path>` to enrich mapping with the original requirement text. This improves cross-framework matching by using the full policy context instead of just the control file's summary. Example:
  `/map-controls {control_id} --product <product> --policy security_policies/<file>`
```
