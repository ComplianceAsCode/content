# Test fixtures

A cheap way to exercise the whole assess pipeline - `compare_ds.py` through
`build_diff_report.py` - without downloading a real quarterly release or diffing a
multi-thousand-rule benchmark.

## What's here

- `disa-stig-rhel9-test-v1-xccdf-manual.xml` / `-v2-xccdf-manual.xml` - two tiny, one-rule
  XCCDF benchmarks. The rule (`RHEL-09-211010`) is lifted verbatim from the real
  `shared/references/disa-stig-rhel9-v2r9-xccdf-manual.xml`. `v2` differs from `v1` by exactly
  one character: the title's `vendor-supported` loses its hyphen, becoming `vendor supported` -
  a punctuation-only change, i.e. a `no-action` classification per
  `reference/02-classify-diffs.md`.
- `compare_ds_diffs_sample/RHEL-09-211010` - the real, unmodified output of running
  `utils/compare_ds.py --disa-content --rule-diffs` against the two files above. Not
  hand-authored - regenerate it any time with the command below to confirm it still matches.

## Reproduce it

From the repo root:

```bash
PYTHONPATH=. python3 utils/compare_ds.py --disa-content --rule-diffs \
    --output-dir .claude/skills/disa-stig-quarterly-update/test-fixtures/compare_ds_diffs_sample \
    .claude/skills/disa-stig-quarterly-update/test-fixtures/disa-stig-rhel9-test-v1-xccdf-manual.xml \
    .claude/skills/disa-stig-quarterly-update/test-fixtures/disa-stig-rhel9-test-v2-xccdf-manual.xml \
    > /tmp/compare_ds_stdout.txt 2>&1
```

Expect exactly one output file, `RHEL-09-211010`, with a one-line diff in `[title]`.

## Exercise the report builder

```bash
python3 .claude/skills/disa-stig-quarterly-update/scripts/build_diff_report.py \
    .claude/skills/disa-stig-quarterly-update/test-fixtures/compare_ds_diffs_sample \
    /tmp/test-diff-report.md \
    --product rhel9-test --from-version v1 --to-version v2
```

This is the whole Phase 1 comparison and report pipeline in about a second, with no need for a
real STIG release, a full-size XML parse, or network access. Build the normalized review CSV from
the same fixture artifacts:

```bash
python3 .claude/skills/disa-stig-quarterly-update/scripts/build_review_csv.py \
    .claude/skills/disa-stig-quarterly-update/test-fixtures/compare_ds_diffs_sample \
    /tmp/compare_ds_stdout.txt \
    /tmp/test-review.csv \
    --html-base-url https://review.example.invalid/stig \
    --review-data .claude/skills/disa-stig-quarterly-update/test-fixtures/review-data.json
```

Add a second rule with a real (not punctuation-only) change to the fixture pair if you need to
test the `oval`/`new-rule`/`removal` classification paths as cheaply.

These fixtures are test-only: they never touch `shared/references/`, aren't wired into any
product build, and don't affect real STIG IDs.
