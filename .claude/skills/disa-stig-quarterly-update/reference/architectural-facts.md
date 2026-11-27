# Architectural facts that affect almost every STIG update

Misreading these leads to wrong or redundant changes.

## `audit_watches_style` is a product-level variable

`audit_watches_style` in `products/<product>/product.yml` controls whether audit rules generate
in old `-w` format or new `-a always,exit` format, for the entire product. Setting it to `modern`
satisfies every `-w` -> `-a always,exit` format change at once for rules using the
`audit_rules_watch` template - no per-rule edits needed. It's a build-time variable, not a
per-profile one, so check whether flipping it would also affect non-STIG profiles for the
product before changing it.

## `audit_rules_watch` template has no `auid` filter support

It cannot add `auid>=1000` or `auid!=unset` filters. If DISA adds those to a rule's audit line,
the rule needs custom OVAL and Bash/Ansible remediations, not just the `audit_watches_style` flip.

## `file_permissions` template: `allow_stricter_permissions`

With `allow_stricter_permissions: true`, modes stricter than `filemode` pass. Tightening
`filemode` (e.g. `0640` -> `0600`) removes previously-passing looser modes - this is the intended
effect when DISA tightens a permission requirement, not a regression.

`file_permissions` thresholds are per-rule, not per-profile. If two profiles need different
thresholds for the same underlying file, that requires separate rule variants (e.g. a `_stig`
suffix), not a single rule with a profile-conditional value.

## Control files can set XCCDF variables, not just select rules

```yaml
- id: RHEL-09-611010
  levels: [medium]
  rules:
      - accounts_password_pam_pwquality_retry
      - var_password_pam_retry=3     # sets the XCCDF variable for this profile
```

When a STIG changes a value (timeout, permission mode, threshold), check whether the rule
exposes an `xccdf_value()` (`grep xccdf_value rule.yml`) before hardcoding the new value anywhere
- the fix is often one control-file line.

## STIG IDs live in the control file only, for RHEL-family products

`products/<product>/controls/stig_<product>.yml` is the only place the STIG ID -> rule mapping
exists. Never add `stigid@<product>: RHEL-NN-XXXXXX` to `rule.yml` - that pattern is used only
for Oracle Linux and SLE (there are zero `stigid@rhel*` instances under `linux_os/guide/`).

## `policy/stig/<product>.yml` rule overrides

Some rules have `linux_os/guide/<area>/<rule>/policy/stig/<product>.yml`, overriding prose
specifically for the STIG profile:

```bash
find linux_os/guide -path "*/<rule_name>/policy/stig/<product>.yml"
```

If it exists and mirrors DISA's changed `vuldiscussion`/`fixtext`/`checktext`, update it. If it
doesn't exist, a `[description]`-only diff needs no action - CaC writes description/rationale
independently of DISA wording.

## `sysctl` template OVAL checks runtime + any matching `.conf` file

The static half of the check covers `/etc/sysctl.conf`, `/etc/sysctl.d/*.conf`, and similar glob
paths - any file in those directories with the correct value passes, regardless of filename.
DISA's fixtext may name a specific file (e.g. `99-kernel_randomize_va_space.conf`) while CaC
writes to a different one (e.g. `kernel_randomize_va_space.conf`) in the same directory - that's
a naming difference, not a functional gap, and needs no action.

## One reference XML file per product

The build globs `disa-stig-${PRODUCT}-v[0-9]*r[0-9]*-xccdf-manual.xml`. Two matching files break
`gen_stig_table.py`. Always `git rm` the old one in the same commit that adds the new one - see
`reference/03-implement.md`.

## Shared rules under `linux_os/guide/` cover multiple products

A change there can satisfy STIG IDs across several products at once. Land it in one PR only and
reference that PR from the other product's PR description - see `reference/03-implement.md`.
