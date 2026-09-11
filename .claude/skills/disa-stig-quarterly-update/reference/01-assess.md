# Phase 1: assess a new DISA STIG release

## 1. Request the assessment inputs

Before inspecting files, ask the user to provide all of the following explicitly:

- Work root for the retained product packages.
- Products and old/new release versions in scope.
- Exactly one old and one new manual XML path for every product.
- File-server directory URL for the generated HTML links.

Never infer any of these values from repository references, profile metadata, existing work
folders, branch names, or duplicate files. If a value is missing, stop and ask the user.

## 2. Validate the manually downloaded inputs

The user downloads the DISA manual XML files before invoking this skill. Validate only the paths
the user provided. Do not use the SCAP XML.

Require exactly one old and one new manual file for every product in scope. If discovery finds
zero or multiple candidates for a provided path, stop and report the candidates instead of
guessing.

Keep the discovered source paths in the product work package so the comparison can be rerun.

## 3. Note the current and target versions

Check the current version in `products/<product>/profiles/stig.profile` (`metadata.version`)
against the latest release on https://www.cyber.mil/stigs/downloads. Do this for every product
in scope for the update (e.g. rhel8, rhel9, rhel10 are updated together when their release
windows overlap).

## 4. Obtain the new STIG files

The user owns downloading the files. Use the `*-xccdf-manual.xml` file, not
`*-xccdf-scap.xml`:

- `*-xccdf-manual.xml` - complete requirements with human-readable procedures. Source of truth.
- `*-xccdf-scap.xml` - automated subset DISA ships with OVAL checks, not always published.
  Used later for the Contest `disa-alignment` test, not for diffing.

## 5. Diff the previous and new manual XML with `compare_ds.py`

```bash
# Create the retained per-product comparison directory before running the tool.
mkdir -p <work-root>/<product>-<old>-to-<new>/compare_ds/diffs
PYTHONPATH=. python3 utils/compare_ds.py \
    --disa-content --rule-diffs \
    --output-dir <work-root>/<product>-<old>-to-<new>/compare_ds/diffs \
    <path_to_previous_version>/<old>-xccdf-manual.xml \
    <path_to_new_version>/<new>-xccdf-manual.xml \
    > <work-root>/<product>-<old>-to-<new>/compare_ds/stdout.txt 2>&1
```

Keep the stdout capture - it lists rules that were added or removed outright (`"X was added in
new data stream."` / `"X is missing in new data stream."`), which the per-rule diff files don't
summarize on their own.

This produces one unified diff file per changed STIG ID, in the `[fieldname]: value` format
described in `reference/xccdf-format.md`. A STIG ID with no behavioral or prose change produces
no diff file at all - `compare_ds.py` only emits a file when something changed.

## 6. Build the retained review artifacts

The CSV is the primary review result. Generate it using the normalized columns documented in the
skill. Use a file-server directory URL supplied by the user for the HTML links; do not invent a
user name or upload destination.

```bash
python3 .claude/skills/disa-stig-quarterly-update/scripts/build_diff_report.py \
    <work-root>/<product>-<old>-to-<new>/compare_ds/diffs \
    <work-root>/<product>-<old>-to-<new>/assessment/diff_report.md \
    --product <product> --from-version <old> --to-version <new>
python3 .claude/skills/disa-stig-quarterly-update/scripts/build_html_diffs.py \
    <work-root>/<product>-<old>-to-<new>/compare_ds/diffs \
    <work-root>/<product>-<old>-to-<new>/html_diffs
python3 .claude/skills/disa-stig-quarterly-update/scripts/build_review_csv.py \
    <work-root>/<product>-<old>-to-<new>/compare_ds/diffs \
    <work-root>/<product>-<old>-to-<new>/compare_ds/stdout.txt \
    <work-root>/<product>-<old>-to-<new>/csv/review.csv \
    --html-base-url <review-host-directory-url>
```

The report writes one `## STIG-ID` section per changed rule, with the raw diff embedded verbatim
inside a collapsible `<details>` block. The HTML directory contains one uploadable file per
changed STIG ID. The CSV includes changed and added/removed STIG IDs from both the diff files and
the comparison stdout.

Fill in `Changes`, `Action Required`, `notes`, and the other review fields in the CSV, as well as
`CaC rule:`, `Classification:` (see `reference/02-classify-diffs.md`), and `Action:` in the
Markdown report. Fill `model-proposed-changes` with the concrete CaC change proposed from the raw
diff and current implementation, or `No change`. This proposal is not a separate approval gate.
Never edit the diff text itself - if a diff looks wrong, rerun `compare_ds.py` and regenerate the
derived artifacts.

Retain all artifacts even when assessment or implementation stops. Commit the completed review
package to the product branch without waiting for a separate action-table approval. The report and
CSV remain the record of the model's classification and proposed changes.

Record the command, exit status, output, and generated file list for each report, HTML, and CSV
command under the product work package. A failed command must produce a retained failure record
before the phase stops.

## 7. How to assess each changed rule

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
