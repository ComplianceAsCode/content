# Phase 1: classifying a STIG diff

Every changed STIG ID gets one classification. Use these labels in the diff report's
`Classification:` field:

- `prose` - documentation-only (capitalization, punctuation, rephrasing with no meaning change).
  No rule update.
- `oval` - the check or fixtext logic changed; the OVAL check and/or remediations need updating.
- `new-rule` - DISA added a requirement with no existing CaC rule covering it.
- `removal` - DISA removed the requirement; drop or mark `status: not applicable` in the
  control file.
- `control-file` - the fix is in the control file only (a title correction, an `xccdf_value`
  assignment, adding/removing a rule from the selection) with no rule.yml or OVAL change.
- `no-action` - CaC's existing implementation already satisfies the new wording; nothing to do.
- `ocil` - DISA changed manual/OCIL-only text. Red Hat does not maintain OCIL entries; skip.

## Always needs action (`oval`, `new-rule`, `removal`, or `control-file`)

- The actual command changed in `[fixtext]` or `[check]` - not example output, the command itself.
- Audit rule format changed: `-w /path -p wa` -> `-a always,exit -F arch=... -F path=... -F perm=...`.
- A sysctl parameter, file path, or permission value changed.
- `[severity]` changed.
- A rule was added (all `+` lines) or removed (all `-` lines) between versions.
- A SELinux filter was added to a check or fixtext (`subj_type=...`).
- A deprecated command was replaced with a newer equivalent (e.g. `awk /etc/passwd` ->
  `getent passwd`) - even if the intent is unchanged, the old approach may now miss cases (LDAP/NIS
  users, for example) that CaC's remediation should also handle.

## Skip (`prose` or `no-action`)

- Capitalization or punctuation only: `"IPsec"` vs `"ipsec"`, a hyphen added or removed, a comma
  or trailing period.
- Blank lines added or removed inside `[check]` or `[fixtext]`.
- Example output reformatted (indentation, spacing of command output) with the command itself
  unchanged.
- Prose rephrased with no change in meaning.
- Inclusive-language updates: "whitelist" -> "allow list", "Non-privileged" -> "Nonprivileged".
- FIPS 140-2 -> FIPS 140-3 terminology only, unless it changes an actual required value.

## Read carefully - may or may not need action

- `[title]` changed: usually prose, but check whether it signals a technical scope change.
- `[description]` changed: usually no action (CaC writes its own rationale); read for
  requirement shifts if a `policy/stig/` override exists for that rule.
- `[fixtext]` or `[check]` changed: read the actual command lines, not just the surrounding prose.

## Distinguishing commands from example output

`[fixtext]` and `[check]` mix real commands with the output those commands print. A diff on
example output looks identical to a diff on a real command unless you check which is which:

- Actual commands start with `$` or `#`.
- Example output does not start with `$`/`#`, and follows a command line.

**No action** - only the `grep` filter and expected output changed, `auditctl -l` itself is the same:
```diff
-$ sudo auditctl -l | grep /etc/cron.d
--w /etc/cron.d -p wa -k cronjobs
+$ sudo auditctl -l | grep crond_t
+-a always,exit -F arch=b64 -S execve -F subj_type=crond_t -F euid=0 -k cron_exec
```

**Action needed** - the actual audit rule line changed:
```diff
-[fixtext]: -w /etc/sudoers -p wa -k identity
+[fixtext]: -a always,exit -F arch=b32 -F path=/etc/sudoers -F perm=wa -k identity
+           -a always,exit -F arch=b64 -F path=/etc/sudoers -F perm=wa -k identity
```

## Only implement what's in the diff

Three traps come up repeatedly:

- Don't add ownership (`chown`) enforcement unless the diff explicitly adds one. "For
  completeness" is a reviewer style preference, not a STIG requirement - verify against the raw
  diff before acting on it.
- Don't add `stigid@<product>:` to `rule.yml` for RHEL-family products. The STIG ID -> rule
  mapping lives in the control file only (`products/<product>/controls/*.yml`); `stigid@` in
  `rule.yml` is for Oracle Linux and SLE.
- Don't treat an example-output change as a command change (see above).

## Investigating when there's no obvious mapping

When a STIG ID has no notes and no obvious existing rule:

1. Use `find-rule` to search for an existing rule that already implements the requirement text.
2. If nothing matches, use `map-requirement` (single ID) or `map-controls` (batch) for
   cross-framework rule suggestions before concluding it's a genuinely new rule.
3. Only fall back to `create-rule` once you've confirmed no existing rule covers it.

## Implementation flexibility

There is real wiggle room in how strictly a STIG wording is implemented, particularly for
requirements that resist a strict, checkable definition (a `not applicable` determination doesn't
need to be airtight against DISA's exact phrasing). When a requirement is genuinely ambiguous or
unautomatable, prefer `status: pending` or `status: not applicable` in the control file with a
`notes:` explanation over forcing a rigid check that will false-positive or false-negative.
