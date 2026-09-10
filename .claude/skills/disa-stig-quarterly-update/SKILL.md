---
name: disa-stig-quarterly-update
description: Assess, implement, and describe a DISA STIG quarterly benchmark update for a product in this repo. Use when a new DISA STIG release drops for a product already covered here, when diffing two xccdf-manual.xml versions with compare_ds.py, when classifying STIG diff changes (prose vs OVAL vs new rule vs removal), or when writing a DISA STIG update PR description.
---

# DISA STIG quarterly update

This skill produces a reviewable, pushed update branch for each RHEL product in scope. The MVP
expects the user to download the DISA manual XML files. The model runs the comparison tools,
retains every intermediate artifact, implements approved changes commit by commit, pushes the
branches, and writes Markdown PR drafts. It does not open GitHub PRs automatically.

Three phases: **assess** the new release, **implement** the changes, **describe** them in the
PR. Each phase has its own reference doc; read only the one you're on.

- `reference/01-assess.md` - locate inputs, diff with `compare_ds.py`, build review artifacts
- `reference/02-classify-diffs.md` - prose vs OVAL vs new-rule vs removal vs control-file
- `reference/03-implement.md` - commits, branches, PR, shared-file cross-PR pattern
- `reference/04-pr-description.md` - PR description template and style
- `reference/xccdf-format.md` - XCCDF XML structure, DISA-field-to-CaC mapping
- `reference/architectural-facts.md` - `audit_watches_style`, control-file variables,
  `policy/stig` overrides, `file_permissions` thresholds, one-reference-file-per-product build
  constraint
- `reference/observations.md` - daemons resetting file modes on reboot, SELinux inotify denials,
  Contest ansible/bash asymmetry, container guards

## MVP result layout

Keep a separate work package for each product. Do not delete a work package when a later step
fails; partial results are useful for review and debugging.

```text
<work-root>/
  rhel8-v2r7-to-v2r8/
    compare_ds/
      stdout.txt
      diffs/
    html_diffs/
    csv/
      review.csv
    assessment/
      diff_report.md
      action_table.md
    pr/
      description.md
  rhel9-v2r8-to-v2r9/
    ...
```

The normalized CSV is the primary human-review result for the MVP. It uses these review columns:

```text
Requirement,HTML diff URL,STDOUT from compare_ds.py,Changes,Action Required,notes,Assignee,Status,Link,Pull request,model-proposed-changes
```

## Hard rules

- **Diffs are copied verbatim, never from memory.** Every diff embedded in a report, analysis,
  or comment must be the exact text `compare_ds.py` produced. If a diff looks wrong, re-run
  `compare_ds.py`; don't hand-patch or reconstruct it from a prior read.
- **OVAL and Ansible/Bash remediations are the priority; OCIL is not.** Red Hat does not update
  OCIL entries.
- **No internal issue IDs in this repo.** Never write an internal tracker ID into a commit, PR,
  or comment here - this is a public upstream repository.
- **Symbolic file modes, not octal**, in Ansible `mode:` and Bash `chmod` (`u=rw,g=r,o=r`, not
  `0644`).
- **STIG ID -> rule mapping lives only in the control file** for RHEL-family products
  (`products/<product>/controls/*.yml`). Never add `stigid@<product>:` to `rule.yml` there -
  that's for Oracle Linux and SLE.
- **One `*-xccdf-manual.xml` per product** in `shared/references/`. Swap it with `git rm` +
  `git add` as the final implementation commit, not two files coexisting.
- **No pending-work sections in PR descriptions.** Describe only what the PR implements.
- **Do not open GitHub PRs automatically.** Push the branches and write `pr/description.md`;
  opening the PR is a separate user action.

## Assessment artifacts

The MVP keeps the existing spreadsheet and HTML-review workflow, but makes every input and output
reproducible in the work package. The CSV is the spreadsheet upload. The HTML files are retained
for publication on the review host. Markdown is retained as the detailed local assessment.

`scripts/build_diff_report.py` turns raw `compare_ds.py --disa-content --rule-diffs` output into
one Markdown report per product, with every raw diff embedded verbatim in a collapsible section:

```bash
python3 .claude/skills/disa-stig-quarterly-update/scripts/build_diff_report.py \
    <compare_ds_diffs_dir> <output_report.md> \
    --product rhel9 --from-version v2r8 --to-version v2r9
```

Generate the retained HTML and normalized CSV beside it:

```bash
python3 .claude/skills/disa-stig-quarterly-update/scripts/build_html_diffs.py \
    <compare_ds_diffs_dir> <html_output_dir>
python3 .claude/skills/disa-stig-quarterly-update/scripts/build_review_csv.py \
    <compare_ds_diffs_dir> <compare_stdout.txt> <review.csv> \
    --html-base-url <review-host-directory-url>
```

Output shape (one section per STIG ID):

```markdown
## RHEL-09-255120

CaC rule: `TODO`
Classification: `TODO`  <!-- prose | oval | new-rule | removal | control-file | no-action -->

<details>
<summary>Diff: RHEL-09-255120</summary>

```diff
--- RHEL-09-255120
+++ RHEL-09-255120
...
```

</details>

Action: TODO
```

Fill in the CSV review fields and the report's `CaC rule:`, `Classification:`, and `Action:` by
reading each embedded diff. In `model-proposed-changes`, state the concrete CaC change proposed
from the raw diff and current implementation, or `No change`. This is a model proposal, not human
approval. Never edit the diff text itself; if a diff looks wrong, rerun `compare_ds.py` and
regenerate all derived artifacts. Commit the completed assessment artifacts to the product branch
after the user approves the action table.

## Delegate to neighboring skills, don't duplicate them

This skill owns the DISA-specific parts: obtaining and diffing STIG releases, classifying the
changes, and writing the STIG-specific parts of the PR description. For everything else in the
implementation phase, use the skill that already owns it:

- **`find-rule`** / **`map-requirement`** / **`map-controls`** - check whether an existing rule
  already covers a STIG ID before treating it as a new rule.
- **`create-rule`** - once a STIG ID is confirmed to need a genuinely new rule.
- **`resolve-rule-variables`** - look up which XCCDF variable a rule exposes and pick a value key,
  instead of hardcoding a changed value.
- **`create-test-scenarios`** / **`test-rule`** / **`run-tests`** - test coverage and validation
  for a changed or new rule.
- **`build-product`** - rebuild the product's data stream to sanity-check an OVAL or template
  change.
- **`draft-pr`** - optional follow-up after this skill writes the Markdown PR draft. Do not invoke
  it automatically; this MVP pushes branches but does not open GitHub PRs.

## Testing this skill cheaply

Don't spend a full quarterly release cycle to sanity-check the pipeline. `test-fixtures/` has a
pair of one-rule benchmark files - built from a real rule lifted out of
`shared/references/disa-stig-rhel9-v2r9-xccdf-manual.xml` - that differ by exactly one character
(a hyphen removed from one rule's title), plus the real, regeneratable `compare_ds.py` output for
that pair. This exercises the assessment pipeline, including the Markdown report and normalized
CSV, in under a second and without touching a real release. HTML generation additionally requires
the external `diff2html` command. See `test-fixtures/README.md`.
