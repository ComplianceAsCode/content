# Phase 2: implement the changes

## Step 0: select the run mode

For a normal run, create each product branch from the upstream default branch. For a test run,
do not create or switch branches, commit changes, push, or open a pull request. Modify only the
explicit target repository and retain all results in the work package.

## Step 1: create the product branch for a normal run

Create each product branch from the upstream default branch. Refuse to reuse an existing branch or
overwrite unrelated local changes.

```bash
git fetch origin master
git switch --create disa-stig-rhel8-v2r8 origin/master
```

Use `disa-stig-rhel9-v2r9` for the RHEL 9 branch. If either branch already exists, stop and ask
the user whether to continue with an explicitly chosen branch. Do not delete or reset it.

## Step 2: implement the classified changes

Read the completed CSV and classification report. Implement `oval`, `new-rule`, `removal`, and
`control-file` actions. Do not implement `prose`, `no-action`, or `ocil` entries unless the user
explicitly requests an exception. Do not wait for a separate action-table approval gate.

Mandatory delegation applies to rule mapping, variable resolution, rule creation, test creation,
rule testing, product builds, and validation. Invoke the owning skill for each applicable operation
and preserve the assessment and verification artifacts after every step so a failed implementation
can resume.

## Step 3: update the reference XML files last

```bash
git rm shared/references/<old>-xccdf-manual.xml
git add shared/references/<new>-xccdf-manual.xml
```

Only one `*-xccdf-manual.xml` per product is allowed in `shared/references/` - the build globs
on `disa-stig-${PRODUCT}-v[0-9]*r[0-9]*-xccdf-manual.xml`, and two matching files break it. Keep
the existing reference until the approved rule changes are complete because other automation may
consume it during the update. Make the replacement and profile metadata bump the final
implementation commit.

If DISA published a new `*-xccdf-scap.xml`, swap that too (needed for the Contest
`disa-alignment` test). If DISA didn't publish one for this release, skip it - the test simply
won't run.

Also bump the version string in `products/<product>/profiles/stig.profile` and
`stig_gui.profile` (`metadata.version`) in that final commit.

## Step 4: commit in reviewable units for a normal run

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

Default to one STIG ID per commit. Group multiple IDs only when one shared implementation makes
the change and splitting it would leave an incomplete or misleading commit. Examples include a
single product-level variable change satisfying several STIG IDs, or one shared rule change used
by RHEL 8 and RHEL 9. Name every affected STIG ID in the commit message when grouping is needed.

After each commit, run the narrowest relevant verification and push the branch. Never amend a
published commit; fix a problem in a new commit.

```bash
git push --set-upstream fork disa-stig-rhel9-v2r9
git push fork disa-stig-rhel9-v2r9
```

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

## Step 5: push the branch and write the PR draft for a normal run

- Push one branch per product to the user's fork after the first commit and after subsequent
  commits.
- Write the completed PR body to the product work package at `pr/description.md`.
- Do not open the GitHub PR automatically in this MVP. The user can review the Markdown and invoke
  `draft-pr` separately when ready.

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

- `build-product` after every relevant rule, remediation, template, variable, control, profile, or
  reference change. Use a datastream-only build for intermediate checks and a full product build for
  final validation.
- In a test run, invoke `build-product --datastream-only <product>` after each related implementation
  group, retain the result, and stop on a failure until the implementation is corrected.
- `test-rule` for changed or new rule behavior, and `run-tests` for final ctest validation before
  pushing.
- Store every build and test command, exit status, output, warnings, artifact list, and summary in
  a new directory under the product work package. Never overwrite an earlier result.
- After the final reference and profile update, invoke `build-product` again and run `run-tests`
  against that final build before pushing the branch.
- Contest and CI catch anything a local build/test pass misses; if a Contest failure only
  reproduces on CentOS Stream and not on RHEL, that doesn't block STIG compliance work - the STIG
  applies to RHEL, and a CentOS-only failure with a known cause can be waived separately (file a
  GitHub issue and open a Contest PR to waive it there).

See `reference/observations.md` for caveats that aren't obvious from the diff or the rule source
(daemons resetting file modes on reboot, SELinux inotify denials, container guards, and the
Contest ansible-vs-bash asymmetry).
