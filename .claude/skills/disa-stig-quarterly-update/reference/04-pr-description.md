# Phase 3: PR description

The diff report already shows WHAT changed. The PR description explains WHY DISA changed the
requirement and what behavior changes in ComplianceAsCode as a result. Don't restate file paths,
XML swaps, or version bumps - those are visible in the diff.

## Template

```markdown
## Description:

Updates the <Product> DISA STIG profile to <VERSION>.

### RHEL-NN-XXXXXX: short description of change

Framing sentence stating what the section covers and why DISA changed it.

- Active-voice bullet: "Removes X from Y", not "X was removed from Y".
- Backtick technical names: paths (`shared/references/`), modes (`0640`), variables
  (`inactivity_timeout_value`), commands (`cut -d: -f1,2`).

## Rationale:

DISA published STIG <VERSION> for <Product>; this PR brings the ComplianceAsCode content in sync.

## Review Hints:

[prose if one point; framing sentence + bullets if multiple]
```

## Style rules

**Headings**
- Top-level sections use `##`: `## Description:`, `## Rationale:`, `## Review Hints:`.
- Each STIG ID gets a `###` heading, colon-separated, sentence case: `### RHEL-09-255130: remove
  SSH compression rule`. No em dashes. Acronyms stay uppercase (OVAL, SSH, FIPS).

**References**
- Link every PR number: `[PR #14987](https://github.com/ComplianceAsCode/content/pull/14987)`.
  Never a bare `PR #N`.
- Expand abbreviated STIG ID lists: `040221, 040222` -> `RHEL-08-040221, RHEL-08-040222`.

**Abbreviations**
- Do not expand domain abbreviations: OVAL, DISA, STIG, XCCDF, OCIL, CCI, CCE, SRG, CaC, PAM,
  SELinux, NSS, NIS, LDAP, FIPS, NIST, OL, SLE are plain technical terms to this team - never
  write "Defense Information Systems Agency (DISA)".
- General terms a non-team reader may not know (e.g. PR) can be expanded on first use.

**Formatting**
- Active voice, present tense.
- No "Pending (not included)" section. Omit anything not part of this PR.
- Framing sentence before every bullet list. Single-bullet sections become prose.
- No hard-wrapping - one logical line per paragraph or bullet.
- Rationale section is one prose sentence, no bullets.
- Review Hints: prose if there's one point, framing sentence + bullets if there are several.

## What to explain per STIG ID

- Why DISA made the change (policy shift, FIPS version bump, new audit standard, a
  vendor-support-window update, etc.) - this is almost never visible from the diff alone.
- What behavior changes as a result (e.g. "removes the group-read bit from SSH host keys").
- The CaC rule name(s) involved.
- For a shared-file change covered in another PR: name that PR and link it explicitly (see
  `reference/03-implement.md`).

## Do not list

- File paths or XML file swaps - visible in the diff.
- Version bumps - visible in the diff.
- Line-by-line diff content - that's what the diff report from Phase 1 is for.
- Pending or future work.

## Jira and internal IDs

Never include an internal issue ID (`OPENSCAP-1234`, `RHEL-12345`, or similar) in the PR title,
body, commits, or comments. This is a public, upstream repository.
