# Phase 1: assess a new DISA STIG release

## 1. Note the current and target versions

Check the current version in `products/<product>/profiles/stig.profile` (`metadata.version`)
against the latest release on https://www.cyber.mil/stigs/downloads. Do this for every product
in scope for the update (e.g. rhel8, rhel9, rhel10 are updated together when their release
windows overlap).

## 2. Obtain the new STIG files

Download from https://www.cyber.mil/stigs/downloads. Use the `*-xccdf-manual.xml` file, not
`*-xccdf-scap.xml`:

- `*-xccdf-manual.xml` - complete requirements with human-readable procedures. Source of truth.
- `*-xccdf-scap.xml` - automated subset DISA ships with OVAL checks, not always published.
  Used later for the Contest `disa-alignment` test, not for diffing.

## 3. Diff the previous and new manual XML with `compare_ds.py`

```bash
mkdir -p /tmp/<product>-<old>-to-<new>-diffs
python3 utils/compare_ds.py \
    --disa-content --rule-diffs \
    --output-dir /tmp/<product>-<old>-to-<new>-diffs \
    <path_to_previous_version>/<old>-xccdf-manual.xml \
    shared/references/<new>-xccdf-manual.xml \
    > /tmp/<product>-<old>-to-<new>-stdout.txt 2>&1
```

Keep the stdout capture - it lists rules that were added or removed outright (`"X was added in
new data stream."` / `"X is missing in new data stream."`), which the per-rule diff files don't
summarize on their own.

This produces one unified diff file per changed STIG ID, in the `[fieldname]: value` format
described in `reference/xccdf-format.md`. A STIG ID with no behavioral or prose change produces
no diff file at all - `compare_ds.py` only emits a file when something changed.

## 4. Build the diff report (no spreadsheet, no file-server upload)

The previous version of this process copy-pasted changed STIG IDs into a shared spreadsheet
tab and `scp`'d `diff2html` output to an internal file server, linking back to it from the
spreadsheet. Both are external dependencies that don't belong to a change that lives entirely
in this git repo. Replace both with one markdown file, generated straight from the diffs:

```bash
python3 .claude/skills/disa-stig-quarterly-update/scripts/build_diff_report.py \
    /tmp/<product>-<old>-to-<new>-diffs \
    <product>-<old>-to-<new>-diff-report.md \
    --product <product> --from-version <old> --to-version <new>
```

This writes one `## STIG-ID` section per changed rule, each with a `CaC rule:` /
`Classification:` placeholder and the raw diff embedded verbatim inside a collapsible
`<details>` block (see the skill's `SKILL.md` for the exact shape). GitHub and GitLab both
render fenced ` ```diff ` blocks with the same red/green coloring `diff2html` produced, so the
report is just as readable while being a single file that lives and travels with the PR.

Fill in `CaC rule:`, `Classification:` (see `reference/02-classify-diffs.md`), and `Action:` by
reading each embedded diff. Never edit the diff text itself - if a diff looks wrong, re-run
`compare_ds.py` and regenerate the report, don't hand-patch the fenced block.

Commit the report to the feature branch (repo root or wherever the team keeps working notes) so
reviewers can see the full reasoning in the PR diff. There is no sheet tab to duplicate and no
external link to keep in sync - git history is the record.

## 5. Update the reference XML files (once assessment is approved)

```bash
git rm shared/references/<old>-xccdf-manual.xml
git add shared/references/<new>-xccdf-manual.xml
```

Do this as the first commit on the branch - see `reference/03-implement.md`. If DISA published a
new `*-xccdf-scap.xml`, swap that too; if not, the Contest `disa-alignment` test simply won't run
for this release, which is expected.

## How to assess each changed rule

For every STIG ID in the report, in priority order:

1. **Read `[fixtext]` and `[check]` first.** These are the source of truth for what the rule
   requires: actual command changes, audit rule format changes, changed values (permissions,
   sysctl params, timeouts), new/removed commands. See `reference/02-classify-diffs.md` for how
   to tell a real command change from reformatted example output.
2. **Check for a `policy/stig/<product>.yml` override**:
   ```bash
   find linux_os/guide -path "*/<rule_name>/policy/stig/<product>.yml"
   ```
   If it exists and mirrors DISA's changed `vuldiscussion`/`fixtext`/`checktext`, update it to
   match. If it doesn't exist, a `[description]`-only change needs no action - this project
   writes its own description/rationale independently of DISA's wording.
3. **`[title]` changes**: update `title:` only if CaC's title mirrors DISA's wording verbatim.

If a STIG ID has no existing CaC rule at all, use `find-rule` or `map-requirement` to check
whether an existing rule already covers it before treating it as a new-rule case.
