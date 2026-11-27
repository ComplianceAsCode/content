---
name: disa-stig-quarterly-update
description: Assess, implement, and describe a DISA STIG quarterly benchmark update for a product in this repo. Use when a new DISA STIG release drops for a product already covered here, when diffing two xccdf-manual.xml versions with compare_ds.py, when classifying STIG diff changes (prose vs OVAL vs new rule vs removal), or when writing a DISA STIG update PR description. Supports explicit test runs against a pre-update baseline and a separate target checkout.
---

# DISA STIG quarterly update

This skill produces a reviewable update package for each RHEL product in scope. The MVP expects the
user to download the DISA manual XML files. The model runs the comparison tools, retains every
intermediate artifact, delegates rule discovery, mapping, rule creation, variable resolution,
testing, and product builds to the owning skills, implements classified changes, and writes
Markdown PR drafts. A normal run may create a branch and push it; a test run never commits, pushes,
or opens a PR.

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
    verification/
      build/
      tests/
  rhel9-v2r8-to-v2r9/
    ...
```

The normalized CSV is the primary human-review result for the MVP. It uses these review columns:

```text
Requirement,HTML diff URL,STDOUT from compare_ds.py,Changes,Action Required,notes,Assignee,Status,Link,Pull request,model-proposed-changes
```

## Hard rules

- **Never infer inputs or scope.** Before starting any phase, ask the user to provide the work
  root, product list, pre-update baseline repository, target repository, old and new manual XML
  paths for each product, the requested phase, and the run mode. Ask for the HTML review base URL
  when assessment artifacts are requested. Do not derive these values from repository files,
  existing work folders, branch names, profile versions, or duplicate files.
  If any required value is missing, stop and ask for it.
- **Use the explicit baseline for analysis.** During a test run, inspect controls, rules, policies,
  remediations, and tests in the supplied pre-update baseline repository. Do not use the target
  repository's already-updated files to conclude that a change is unnecessary. Use the target
  repository only for the new reference input and the implementation under test.
- **Test runs do not publish changes.** A test run must not create commits, push branches, open PRs,
  or modify the baseline repository. It may modify the supplied target repository and the retained
  work package.
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
- **Delegation is mandatory.** For every changed or added STIG requirement, invoke the owning
  skill before implementing it: `find-rule` or `map-requirement`/`map-controls` for mapping,
  `create-rule` for confirmed new rules, `resolve-rule-variables` for variable-backed values,
  `create-test-scenarios` for missing coverage, `test-rule` for rule tests, `build-product` after
  relevant content changes, and `run-tests` for validation. Do not reproduce those workflows
  locally.
- **Build after relevant content changes.** Invoke `build-product` after changes to `rule.yml`,
  OVAL, Bash, Ansible, templates, variables, controls, profiles, or reference files that affect
  the product. Use the full product build for final validation; a datastream-only build is
  acceptable for intermediate checks.
- **Retain verification results.** Store each build and test command, exit status, output,
  warnings, produced artifact list, and summary under the product work package. Never discard
  failed results.
- **Build iteratively.** After each related implementation group, invoke `build-product
  --datastream-only rhel9` and retain the result before continuing. Run a full `build-product rhel9`
  after the implementation groups and again after the final reference/profile update.

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
    --html-base-url <review-host-directory-url> \
    --review-data <review-data.json>
```

Before running the CSV builder, create `review-data.json` with one object per changed STIG ID. Each
object must contain non-empty `Changes`, `Action Required`, `notes`, `Status`, and
`model-proposed-changes` fields. The builder fails if an ID or required field is missing, so the
uploaded CSV cannot silently contain blank proposals. Use `No change` when the raw diff does not
require a CaC change, and describe follow-up work explicitly when it is outside the current update.

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

Fill the JSON review data and the report's `CaC rule:`, `Classification:`, and `Action:` by reading
each embedded diff. In `model-proposed-changes`, state the concrete CaC change proposed from the
raw diff and current implementation, or `No change`. This is a model proposal, not human approval.
Never edit the diff text itself; if a diff looks wrong, rerun `compare_ds.py` and regenerate all
derived artifacts. Retain and commit the completed assessment artifacts to the product branch
without waiting for a separate action-table approval. The report, JSON review data, and CSV remain
the record of the model's classification and proposed changes.

## Delegate to neighboring skills, don't duplicate them

This skill owns the DISA-specific parts: obtaining and diffing STIG releases, classifying the
changes, and writing the STIG-specific parts of the PR description. For everything else, invoke
the skill that already owns it.

For each actionable STIG entry:

1. Invoke `find-rule` or `map-requirement`/`map-controls` to identify the existing rule or mapping.
2. Invoke `resolve-rule-variables` before hardcoding any changed XCCDF value.
3. Invoke `create-rule` only after confirming that no existing rule covers a genuine new rule.
4. Invoke `create-test-scenarios` when the changed or new rule lacks required scenarios.
5. Invoke `test-rule` for changed or new rule behavior.
6. Invoke `build-product` after each relevant content change and retain the result.
7. Invoke `run-tests` after the product build and retain the result.

A delegated skill may stop for an author decision required by its own workflow. This skill does
not add a separate action-table approval gate.

- **`find-rule`** / **`map-requirement`** / **`map-controls`** - check whether an existing rule
  already covers a STIG ID before treating it as a new rule.
- **`create-rule`** - once a STIG ID is confirmed to need a genuinely new rule.
- **`resolve-rule-variables`** - look up which XCCDF variable a rule exposes and pick a value key,
  instead of hardcoding a changed value.
- **`create-test-scenarios`** / **`test-rule`** / **`run-tests`** - test coverage and validation
  for a changed or new rule.
- **`build-product`** - mandatory after relevant rule, remediation, template, variable, control,
  profile, or reference changes; retain every result.
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
