---
name: disa-stig-quarterly-update
description: Assess, implement, and describe a DISA STIG quarterly benchmark update for a product in this repo. Use when a new DISA STIG release drops for a product already covered here, when diffing two xccdf-manual.xml versions with compare_ds.py, when classifying STIG diff changes (prose vs OVAL vs new rule vs removal), or when writing a DISA STIG update PR description.
---

# DISA STIG quarterly update

Three phases: **assess** the new release, **implement** the changes, **describe** them in the
PR. Each phase has its own reference doc; read only the one you're on.

- `reference/01-assess.md` - download, diff with `compare_ds.py`, build the diff report
- `reference/02-classify-diffs.md` - prose vs OVAL vs new-rule vs removal vs control-file
- `reference/03-implement.md` - commits, branches, PR, shared-file cross-PR pattern
- `reference/04-pr-description.md` - PR description template and style
- `reference/xccdf-format.md` - XCCDF XML structure, DISA-field-to-CaC mapping
- `reference/architectural-facts.md` - `audit_watches_style`, control-file variables,
  `policy/stig` overrides, `file_permissions` thresholds, one-reference-file-per-product build
  constraint
- `reference/observations.md` - daemons resetting file modes on reboot, SELinux inotify denials,
  Contest ansible/bash asymmetry, container guards

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
  `git add` as the first commit, not two files coexisting.
- **No pending-work sections in PR descriptions.** Describe only what the PR implements.

## The diff report replaces spreadsheet tracking and file-server hosting

The old process for this copy-pasted changed STIG IDs into a shared spreadsheet and `scp`'d
`diff2html` output to an internal file server, linking back to it from the spreadsheet. Neither
belongs to a change that lives entirely in this repo - a spreadsheet needs someone to have an
account and keep tabs and links in sync by hand, and a file-server upload is invisible to anyone
reviewing the PR itself.

`scripts/build_diff_report.py` replaces both: it turns raw `compare_ds.py --disa-content
--rule-diffs` output into one markdown file per product, with every raw diff embedded verbatim
in a collapsible section, ready to read (and review) inside the PR:

```bash
python3 .claude/skills/disa-stig-quarterly-update/scripts/build_diff_report.py \
    <compare_ds_diffs_dir> <output_report.md> \
    --product rhel9 --from-version v2r8 --to-version v2r9
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

GitHub and GitLab both render fenced ` ```diff ` blocks with the same red/green coloring
`diff2html` produced - nothing is lost by dropping the HTML step. Fill in `CaC rule:`,
`Classification:` (`reference/02-classify-diffs.md`), and `Action:` by hand once you've read
each diff; never edit the text inside the fence. Commit the report to the feature branch so it
travels with the PR - git history is the tracking record, there's no sheet tab or external link
to keep in sync.

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
- **`draft-pr`** - push the branch and open the PR with a prefilled title/labels/milestone. Its
  generic Description/Rationale/Review-Hints body should be replaced with the STIG-specific
  content from `reference/04-pr-description.md`.

## Testing this skill cheaply

Don't spend a full quarterly release cycle to sanity-check the pipeline. `test-fixtures/` has a
pair of one-rule benchmark files - built from a real rule lifted out of
`shared/references/disa-stig-rhel9-v2r9-xccdf-manual.xml` - that differ by exactly one character
(a hyphen removed from one rule's title), plus the real, regeneratable `compare_ds.py` output for
that pair. This exercises the full assess pipeline, including `build_diff_report.py`'s output
shape and the `no-action` (punctuation-only) classification path, in under a second and without
touching a real release. See `test-fixtures/README.md`.
