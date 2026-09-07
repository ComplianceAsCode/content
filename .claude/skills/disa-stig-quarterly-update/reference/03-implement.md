# Phase 2: implement the changes

## Step 0: swap the reference XML files first

```bash
git rm shared/references/<old>-xccdf-manual.xml
git add shared/references/<new>-xccdf-manual.xml
```

Only one `*-xccdf-manual.xml` per product is allowed in `shared/references/` - the build globs
on `disa-stig-${PRODUCT}-v[0-9]*r[0-9]*-xccdf-manual.xml`, and two matching files break it. Do
this swap as the very first commit on the branch, before any other change.

If DISA published a new `*-xccdf-scap.xml`, swap that too (needed for the Contest
`disa-alignment` test). If DISA didn't publish one for this release, skip it - the test simply
won't run.

Also bump the version string in `products/<product>/profiles/stig.profile` and
`stig_gui.profile` (`metadata.version`).

## One commit per STIG ID

```
{product}: DISA STIG {version}, {STIG-ID} - {short description}
```

Examples:
- `rhel9: DISA STIG v2r9, RHEL-09-255120 - update control file title`
- `rhel9: DISA STIG v2r9, RHEL-09-255130 - remove SSH Compression rule`
- `rhel8: DISA STIG v2r8, RHEL-08-030610 - update audit config file permissions`

For prose-only changes, use "prose update" as the description:
- `rhel9: DISA STIG v2r9, RHEL-09-671015 - prose update`

No parentheses, no before/after values in the message unless essential to disambiguate.

## Before hardcoding a changed value, check for an XCCDF variable

```bash
grep "xccdf_value" linux_os/guide/<area>/<rule>/rule.yml
```

If the rule already exposes a variable, the fix is usually one control-file line, not a rule
edit:

```yaml
- id: RHEL-09-611010
  levels: [medium]
  rules:
      - accounts_password_pam_pwquality_retry
      - var_password_pam_retry=3
```

Use the `resolve-rule-variables` skill to look up which variables a rule depends on and pick the
right value key.

## Branch and PR

- One branch per product (or per product+version if multiple are in flight at once).
- Open the PR as a draft immediately, before all commits land, so reviewers can follow along and
  comment early.
- Use `draft-pr` to open it once there's at least one commit - it derives the title, categorizes
  changes, and prefills the PR body from `.github/pull_request_template.md`. Its generic
  Description/Rationale/Review-Hints sections should be replaced with the STIG-specific content
  from `reference/04-pr-description.md` - `draft-pr` doesn't know about STIG IDs or DISA
  requirements, this skill does.

## Shared files (`linux_os/guide/`) go in one PR only

A prose fix or logic change in a shared rule under `linux_os/guide/` may satisfy the same STIG
ID across multiple products (e.g. a fix that resolves both a RHEL 8 and a RHEL 9 STIG ID). Make
that change in exactly one PR - land it in whichever product's PR is more advanced or more
directly affected - and reference that PR from the other product's PR description. Never
duplicate the change in both branches; it produces a merge conflict when both land on the base
branch.

Example pattern: a shared `accounts_password_all_shadowed_sha512` prose fix satisfies both
`RHEL-09-671015` and `RHEL-08-010120`. Commit it once in the RHEL 9 PR; the RHEL 8 PR description
notes "prose fix for RHEL-08-010120 covered by PR #N" and links to it.

## Verifying a change

- `build-product` to rebuild the affected product's data stream after an OVAL or template change.
- `test-rule` / `run-tests` for rule-level and ctest validation before pushing.
- Contest and CI catch anything a local build/test pass misses; if a Contest failure only
  reproduces on CentOS Stream and not on RHEL, that doesn't block STIG compliance work - the STIG
  applies to RHEL, and a CentOS-only failure with a known cause can be waived separately (file a
  GitHub issue and open a Contest PR to waive it there).

See `reference/observations.md` for caveats that aren't obvious from the diff or the rule source
(daemons resetting file modes on reboot, SELinux inotify denials, container guards, and the
Contest ansible-vs-bash asymmetry).
