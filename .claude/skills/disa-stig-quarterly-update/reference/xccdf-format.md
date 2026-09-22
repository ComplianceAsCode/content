# DISA XCCDF format and field mapping

## DISA publishes two files per release

- `*-xccdf-manual.xml` - complete requirements with human-readable procedures. "Manual" refers
  to the checklist documentation format, not manual remediation steps. Source of truth.
- `*-xccdf-scap.xml` - automated subset containing only rules DISA ships with an OVAL check. Not
  every manual-file rule has one, and DISA doesn't always publish this file for a given release.

## XCCDF structure

```xml
<Benchmark>
    <Group id="V-257777">
        <Rule id="SV-257777r1155676_rule" severity="high">
            <version>RHEL-09-211010</version>
            <title>RHEL 9 must be a vendor-supported release.</title>
            <ident system="http://cyber.mil/cci">CCI-000366</ident>
            <description>&lt;VulnDiscussion&gt;...&lt;/VulnDiscussion&gt;</description>
            <fixtext>Steps a sysadmin follows to remediate...</fixtext>
            <check>Steps an auditor follows to verify compliance...</check>
        </Rule>
    </Group>
</Benchmark>
```

- `Group/@id` - DISA's V-ID, unique across all STIGs, can change between releases.
- `Rule/@id` - internal XCCDF rule ID in `SV-<num>r<num>_rule` format. `compare_ds.py --disa-content`
  matches old/new rules by the `SV-<num>` portion, since only the release-number suffix changes
  between STIG releases.
- `Rule/@severity` - `low`, `medium`, or `high`.
- `<version>` - the STIG Rule ID (e.g. `RHEL-09-211010`). Product-scoped and stable across
  releases; this is the join key with the control file.
- `<title>` - one-line rule name.
- `<description>` - contains `<VulnDiscussion>`, explaining why the requirement exists.
- `<ident system="http://cyber.mil/cci">` - CCI, links to NIST 800-53.
- `<fixtext>` - remediation steps for a sysadmin; source of truth for what CaC should automate.
- `<check>` - verification steps for an auditor; source of truth for what the OVAL check verifies.

## STIG Rule ID format

`RHEL-{VERSION}-{CATEGORY}{NUMBER}`, e.g. `RHEL-08-010120`: product, RHEL version, category,
number within category. IDs ending in `0` are typically the original entry; `1`/`2`/`3` variants
are usually related rules in the same group.

## How `compare_ds.py` produces diffs

`compare_ds.py --disa-content --rule-diffs` parses each `<Rule>` with `join_text_elements`
(`ssg/xml.py`) into an INI-like block, then unified-diffs old vs new per STIG ID:

```
[severity]
[version]
[title]
[description]
[ident]           (one block per CCI)
[reference]       (benchmark metadata: DISA target, DPMS ID)
[fixtext]
[check]
```

`<fix>` elements (embedded Ansible/Bash) are skipped - DISA manual XMLs don't contain them.

## Mapping DISA fields to ComplianceAsCode

| DISA field | Becomes |
|---|---|
| `[fixtext]` | Ansible/Bash remediation with the same intent, written as automation |
| `[check]` | OVAL check with the same intent, written as machine-executable XML |
| `[title]` | `title:` in `rule.yml` |
| `[description]` | `description:` and `rationale:` in `rule.yml` |
| `[severity]` | `severity:` in `rule.yml` |
| `[ident]` (CCI) | `references:` in `rule.yml` |
| `[version]` (STIG Rule ID) | `id:` in the control file - not written into the rule itself |
| `[reference]` (DPMS metadata) | not used |

`[fixtext]` and `[check]` are the source of truth. When they change, the OVAL check and
Ansible/Bash remediations must follow.
