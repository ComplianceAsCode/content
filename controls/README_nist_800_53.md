# NIST 800-53 Control Files

This directory contains the NIST 800-53 Revision 5 control framework with OSCAL metadata and CIS benchmark mappings.

## File Structure

### Split-by-Family Architecture

NIST 800-53 controls are organized into **21 family files** instead of a single monolithic file:

```
controls/
├── nist_800_53.yml              # Top-level metadata file (points to subdirectory)
└── nist_800_53/                 # Family files directory
    ├── ac.yml                   # Access Control (147 controls)
    ├── au.yml                   # Audit and Accountability (69 controls)
    ├── cm.yml                   # Configuration Management (66 controls)
    ├── ia.yml                   # Identification and Authentication (74 controls)
    ├── sc.yml                   # System and Communications Protection (162 controls)
    ├── si.yml                   # System and Information Integrity (119 controls)
    ├── other.yml                # CIS items without NIST mappings (102 items)
    └── ... (14 more families)   # AT, CA, CP, IR, MA, MP, PE, PL, PM, PS, PT, RA, SA, SR

shared/references/controls/
├── nist_800_53_cis_reference.yml              # Reference metadata file
└── nist_800_53_cis_reference/                 # Reference family files
    ├── ac.yml
    ├── au.yml
    └── ... (21 family files)
```

**Total: 1,196 NIST 800-53 controls + 102 unmapped CIS items**

### `controls/nist_800_53.yml` (Top-Level Metadata)

```yaml
policy: NIST 800-53 Revision 5
title: NIST Special Publication 800-53 Revision 5
id: nist_800_53
version: Revision 5
source: https://csrc.nist.gov/publications/detail/sp/800-53/rev-5/final
controls_dir: nist_800_53  # Points to subdirectory with family files
levels:
  - id: low
  - id: moderate
  - id: high
```

- **Purpose**: Metadata file that points to family files
- **Maintained By**: 👤 **Humans** (version info, policy name)
- **Size**: ~15 lines
- **Build System**: Automatically loads all family files from `controls_dir`

### `controls/nist_800_53/*.yml` (Real Family Files - Source of Truth)

Example: `controls/nist_800_53/au.yml`

```yaml
# NIST 800-53 AU Family: Audit and Accountability
controls:
  - id: au-2
    title: Event Logging
    description: |
      a. Identify the types of events that the system is capable of logging...
      b. Coordinate the event logging function with other organizational entities...
      c. Specify the following event types for logging...
      [12 sub-parts total]
    parameters:
      - id: au-02_odp.01
        label: event types
        guidelines:
          - the event types that the system is capable of logging...
      [3 more parameters]
    guidance: |
      An event is an observable occurrence in a system. The types of events
      that require logging are those events that are significant and relevant...
      [2,500+ characters of implementation advice]
    related_controls:
      - ac-2
      - ac-3
      - au-3
      [28 related controls total]
    levels:
      - low
      - moderate
      - high
    rules:
      - var_audit_backlog_limit=8192
      {{% if product == "rhel9" %}}
      - var_auditd_action_mail_acct=root
      {{% endif %}}
      {{% if product.startswith('rhel') %}}
      - aide_build_database
      - aide_periodic_cron_checking
      {{% endif %}}
    status: automated
```

- **Purpose**: Production control files used for building profiles
- **Maintained By**: 👤 **Humans (YOU)**
- **Format**: YAML with Jinja2 guards (`{{% if product... %}}`)
- **Edits**: Make all edits directly to these family files
- **Automation**: **NEVER** touched by automation
- **Contains**:
  - OSCAL metadata (description, parameters, guidance, related_controls)
  - Human-curated rule mappings
  - Product-specific Jinja2 guards
  - Manual notes and status fields
  - Rules not from CIS (human additions)

### `shared/references/controls/nist_800_53_cis_reference/*.yml` (Reference Family Files)

- **Purpose**: Shows what CIS benchmark mappings say NIST controls should have
- **Maintained By**: 🤖 **Automation**
- **Format**: YAML with Jinja2 guards (auto-generated)
- **Edits**: **DO NOT** edit these files manually
- **Automation**: Regenerated weekly from OSCAL catalog + CIS mappings
- **Used For**: Comparison to detect changes in CIS mappings
- **Contains**:
  - Auto-generated CIS→NIST rule mappings
  - OSCAL catalog metadata (extracted from NIST JSON)
  - Baseline level assignments (low/moderate/high)
  - Product-specific Jinja2 guards

## OSCAL Metadata Enrichment

Each control includes metadata extracted from the official NIST OSCAL catalog:

### Control Fields

| Field | Description | Example Size |
|-------|-------------|--------------|
| `id` | Control identifier | `au-2` |
| `title` | Short control title | ~20-50 chars |
| `description` | Full control statement with sub-parts (a, b, c...) | ~500-2000 chars |
| `parameters` | Organization-Defined Parameters (ODPs) with labels, guidelines, choices | 0-10 per control |
| `guidance` | Implementation advice and discussion | ~500-3000 chars |
| `related_controls` | Control dependency references | 0-30 per control |
| `levels` | Baseline applicability (low, moderate, high) | 1-3 values |
| `rules` | Rule/variable selections with guards | 0-200 items |
| `status` | Implementation status | `automated`, `pending`, `manual`, etc. |

### Jinja2 Syntax Escaping

**Important**: OSCAL metadata uses `[[ ]]` instead of `{{ }}` for parameter references to avoid Jinja2 macro expansion:

```yaml
description: |
  a. Require [[ insert: param, ac-02_odp.01 ]] for group membership;
  b. Specify authorized users...
```

**Product guards** use double braces:
```yaml
rules:
  {{% if product == "rhel9" %}}
  - rule_name
  {{% endif %}}
```

## Product Guards

Family files include Jinja2 guards for product-specific rules:

### Family-Based Guards
```yaml
{{% if product.startswith('rhel') %}}
- rule_for_all_rhel_versions  # rhel8, rhel9, rhel10
{{% endif %}}
```

### Specific Product Guards
```yaml
{{% if product == "rhel9" %}}
- rhel9_specific_rule
{{% endif %}}
```

### Variable Variants (If/Elif/Endif)
```yaml
{{% if product == "rhel10" %}}
- var_auditd_space_left_action=cis_rhel10
{{% elif product == "rhel8" %}}
- var_auditd_space_left_action=cis_rhel8
{{% elif product == "rhel9" %}}
- var_auditd_space_left_action=cis_rhel9
{{% endif %}}
```

## Unmapped CIS Items

`controls/nist_800_53/other.yml` contains CIS benchmark items that don't have explicit NIST 800-53 mappings:

```yaml
- id: CIS_UNMAPPED
  title: CIS Benchmark Items Without NIST 800-53 Mapping
  notes: |
    These 102 CIS items do not have explicit NIST 800-53 mappings in the
    CIS benchmark. They are included here to ensure complete CIS coverage
    when using nist_800_53:all in profiles.
  rules:
    - account_disable_post_pw_expiration
    - var_accounts_tmout=15_min
    [115 total assignments including variable values]
  status: automated
```

This ensures that profiles using `nist_800_53:all` get **complete** CIS benchmark coverage (all 525 mapped + 102 unmapped items).

## Weekly Automation Workflow

Every Sunday at 2 PM UTC, the GitHub Actions workflow runs:

### Automation Steps

1. ✅ Downloads latest NIST OSCAL catalog (`NIST_SP-800-53_rev5_catalog.json`)
2. ✅ Scans CIS control files for current rule/variable mappings
3. ✅ Regenerates all 21 reference family files in `shared/references/controls/nist_800_53_cis_reference/`
4. ✅ Applies product guards for RHEL family (rhel8, rhel9, rhel10)
5. ✅ Compares reference files with previous version
6. ✅ Creates PR if changes detected
7. ⚠️  **PR requires manual review and action**

### What Gets Updated Automatically

**Reference files only:**
- `shared/references/controls/nist_800_53_cis_reference.yml`
- `shared/references/controls/nist_800_53_cis_reference/*.yml`

**Real files NEVER touched:**
- `controls/nist_800_53.yml`
- `controls/nist_800_53/*.yml`

## Manual Review Process

When you receive an automated PR:

### 1. Review the Reference File Diff

```bash
gh pr checkout <PR-NUMBER>

# View changes in reference files
git diff origin/master shared/references/controls/nist_800_53_cis_reference/
```

Look for:
- 📝 What rules were added?
- 🗑️ What rules were removed?
- 🔄 What controls changed?
- 📊 What OSCAL metadata updated?

### 2. Update Real Control Files

Compare reference changes against real files and decide what to apply:

```bash
# Example: Review AU family changes
diff -u \
  shared/references/controls/nist_800_53_cis_reference/au.yml \
  controls/nist_800_53/au.yml

# Edit real family file
vim controls/nist_800_53/au.yml
```

**What to preserve:**
- ✅ Human-added rules (not from CIS)
- ✅ Custom notes and status fields
- ✅ Manual Jinja2 guards
- ✅ Cross-product rules (OCP, Ubuntu, etc.)

**What to consider applying:**
- ➕ New CIS rules that make sense
- ➖ Removed CIS rules (check if still relevant)
- 📝 Updated OSCAL metadata
- 🔄 Changed baseline levels

### 3. Commit and Push

```bash
# Stage changes to real control files
git add controls/nist_800_53/*.yml

# Commit with descriptive message
git commit -m "Apply CIS mapping updates to AU, CM, IA families"

# Push to PR branch
git push
```

### 4. Merge the PR

Once both reference and real files are updated, merge the PR.

## Making Manual Edits

To add rules, notes, or guards to real control files:

```bash
# Edit the appropriate family file
vim controls/nist_800_53/ac.yml

# Example: Add a rule to AC-2
controls:
  - id: ac-2
    title: Account Management
    description: |
      a. Define and document the types of accounts...
      [OSCAL metadata preserved]
    rules:
      - existing_cis_rule_1
      - existing_cis_rule_2
      {{% if product in ["rhel9", "rhel10"] %}}
      - my_new_human_added_rule  # Your addition
      {{% endif %}}
    notes: "Added custom rule for internal security requirement XYZ-123"
    status: automated

# Commit your changes
git add controls/nist_800_53/ac.yml
git commit -m "Add custom rule to AC-2 for requirement XYZ-123"
```

## Why Two Sets of Files?

### The Problem

- CIS benchmarks change over time (new rules added/removed)
- NIST OSCAL catalog updates periodically
- We need to track what CIS/NIST *currently* say
- But we also have human-curated content that shouldn't be overwritten
- Automation can't distinguish "human addition" from "old CIS mapping"

### The Solution

- **Reference files** (`shared/references/...`) = What CIS/NIST currently say
- **Real files** (`controls/...`) = What we actually use (CIS + human edits)
- **Diff** = What changed in CIS/NIST that we might want to apply

### Benefits

- ✅ Human edits are never overwritten by automation
- ✅ CIS/NIST changes are tracked and reviewable
- ✅ Clear separation between automated and manual content
- ✅ Both file sets committed for full transparency
- ✅ OSCAL metadata enrichment for better documentation
- ✅ Product guards enable cross-platform sharing

## Example Scenario: Family File Update

### Initial State

**Real file** (`controls/nist_800_53/au.yml`):
```yaml
- id: au-2
  title: Event Logging
  description: |
    a. Identify the types of events...
    [OSCAL metadata]
  guidance: |
    An event is an observable occurrence...
    [2500 chars of guidance]
  rules:
    - audit_rules_execution_chacl
    - my_custom_audit_rule  # Human added
  notes: "Custom rule for internal audit requirement"
  status: automated
```

**Reference file** (`shared/references/.../au.yml`):
```yaml
- id: au-2
  title: Event Logging
  description: |
    a. Identify the types of events...
    [OSCAL metadata]
  guidance: |
    An event is an observable occurrence...
    [2500 chars of guidance]
  rules:
    - audit_rules_execution_chacl
  status: automated
```

### CIS Benchmark Updates

New CIS version adds `audit_rules_execution_newcmd`, removes `audit_rules_execution_chacl`.

Automation regenerates reference:
```yaml
- id: au-2
  title: Event Logging
  description: |
    [Updated OSCAL metadata - NIST catalog Rev 5.1]
  guidance: |
    [Updated guidance text]
  rules:
    - audit_rules_execution_newcmd  # NEW
  status: automated
```

### You Review the PR

You see in the reference file diff:
- ❌ `audit_rules_execution_chacl` removed
- ✅ `audit_rules_execution_newcmd` added
- 📝 OSCAL description updated
- 📚 Guidance text expanded

### You Manually Update Real File

```yaml
- id: au-2
  title: Event Logging
  description: |
    [Apply updated OSCAL metadata from reference]
  guidance: |
    [Apply updated guidance from reference]
  rules:
    - audit_rules_execution_newcmd    # Added based on CIS update
    - audit_rules_execution_chacl     # KEPT (still relevant for our use case)
    - my_custom_audit_rule            # PRESERVED (your addition)
  notes: "Custom rule for internal audit requirement. Kept old chacl rule intentionally."
  status: automated
```

### Result

- ✅ CIS updates applied (new rule added)
- ✅ OSCAL metadata updated
- ✅ Human edits preserved (custom rule)
- ✅ Informed decision made (kept old rule with note)
- ✅ Full control over what goes in real files

## Integration with Profiles

Profiles reference the real control files using `controls:all`:

```yaml
# products/rhel9/profiles/cis_nist.profile
documentation_complete: true
title: 'CIS Red Hat Enterprise Linux 9 Benchmark - NIST 800-53 Aligned'
description: 'This profile includes all NIST 800-53 controls...'

selections:
  - nist_800_53:all  # Selects ALL controls from nist_800_53/*.yml
```

The build system:
1. Loads `controls/nist_800_53.yml` metadata
2. Reads `controls_dir: nist_800_53` field
3. Automatically loads all 21 family files from `controls/nist_800_53/`
4. Evaluates Jinja2 guards for the target product (e.g., `product="rhel9"`)
5. Includes matching rules in the final profile

## File Locations Summary

```
controls/
├── nist_800_53.yml                    # 👤 Top-level metadata (edit version info)
├── nist_800_53/                       # 👤 REAL FAMILY FILES (edit these)
│   ├── ac.yml                         #    Access Control (147 controls)
│   ├── au.yml                         #    Audit and Accountability (69 controls)
│   ├── cm.yml                         #    Configuration Management (66 controls)
│   ├── ia.yml                         #    Identification and Authentication (74 controls)
│   ├── sc.yml                         #    System and Communications Protection (162 controls)
│   ├── si.yml                         #    System and Information Integrity (119 controls)
│   ├── other.yml                      #    Unmapped CIS items (102 items)
│   └── ... (14 more)                  #    AT, CA, CP, IR, MA, MP, PE, PL, PM, PS, PT, RA, SA, SR
└── README_nist_800_53.md              # This file

shared/references/controls/
├── nist_800_53_cis_reference.yml      # 🤖 Reference metadata (auto-generated)
└── nist_800_53_cis_reference/         # 🤖 REFERENCE FAMILY FILES (auto-generated)
    ├── ac.yml
    ├── au.yml
    └── ... (21 family files)

utils/nist_sync/
├── sync_nist_split.py                 # Main generation script (OSCAL + CIS)
├── generate_product_family_guards.py  # Adds Jinja2 product guards
├── generate_variable_to_products.py   # Variable→products mapping
├── harvest_cis_nist_mappings.py       # Extract CIS→NIST mappings
├── compare_profile_rules.py           # Validate profile coverage
└── generate_cis_nist_workflow.sh      # Complete orchestration workflow

.github/workflows/
└── cis-nist-sync.yml                  # Weekly automation workflow
```

## Troubleshooting

### Q: I edited `shared/references/controls/nist_800_53_cis_reference/*.yml` directly, what do I do?

**A:** Don't do that! The reference files are auto-generated. Instead:
1. Revert your changes to the reference files
2. Make the same changes in `controls/nist_800_53/*.yml` (the real family files)

### Q: The automation PR removes rules I added manually, what happened?

**A:** The automation only updates the *reference* files. Your manually-added rules in `controls/nist_800_53/*.yml` are safe! The PR is showing you what CIS currently says, but you decide what to keep in the real files.

### Q: Should I keep rules that CIS removed?

**A:** Maybe! Consider:
- Is the rule still security-relevant?
- Is it used in other profiles (STIG, OSPP, etc.)?
- Do you have an internal requirement for it?
- Is it applicable to other products?

You decide what goes in the real files. Add a note explaining why you kept it.

### Q: Can I add Jinja2 guards to the real files?

**A:** Yes! The real files (`controls/nist_800_53/*.yml`) can have any guards you want. The automation never touches them. Use:
- `{{% if product == "rhel9" %}}` for specific products
- `{{% if product.startswith('rhel') %}}` for product families
- `{{% if product in ["rhel9", "rhel10"] %}}` for multiple products

### Q: How do I regenerate the CIS reference files manually?

**A:**
```bash
cd utils/nist_sync

# Full workflow (downloads OSCAL, generates families, applies guards)
./generate_cis_nist_workflow.sh

# Or individual steps:
python3 sync_nist_split.py                          # Generate from OSCAL + CIS
python3 generate_variable_to_products.py            # Variable mapping
for f in ../../shared/references/controls/nist_800_53_cis_reference/*.yml; do
  python3 generate_product_family_guards.py --target rhel --control-file "$f" --output "$f"
done
```

Then review the diff and manually update real files.

### Q: How do I verify my edits are correct?

**A:**
```bash
# Build the product to verify syntax
./build_product rhel9 --datastream-only

# Compare CIS profile coverage
cd utils/nist_sync
python3 compare_profile_rules.py \
  ../../products/rhel9/profiles/cis.profile \
  ../../products/rhel9/profiles/cis_nist.profile \
  --product rhel9
```

Expected output: "CIS_NIST has all required CIS rules ✓"

### Q: What if OSCAL metadata has Jinja2 syntax?

**A:** OSCAL text uses `[[ ]]` instead of `{{ }}` to avoid conflicts:
- **OSCAL parameters**: `[[ insert: param, ac-02_odp.01 ]]`
- **Product guards**: `{{% if product == "rhel9" %}}`

This escaping is handled automatically by `sync_nist_split.py`.

### Q: Can I add controls that aren't in NIST 800-53?

**A:** Yes! Add them to the appropriate family file or create a custom family. The build system loads all YAML files in the `controls_dir`. Just maintain the same control structure.

### Q: How do I add rules for other products (OCP, Ubuntu)?

**A:**
1. Add the product to target list in guards generation
2. Update `generate_cis_nist_workflow.sh` to include other products
3. Add rules with appropriate guards:
```yaml
{{% if product == "ocp4" %}}
- ocp_specific_rule
{{% endif %}}
```

## Additional Resources

- **NIST OSCAL Catalog**: https://csrc.nist.gov/publications/detail/sp/800-53/rev-5/final
- **CIS Benchmarks**: https://www.cisecurity.org/cis-benchmarks
- **GitHub Actions Workflow**: `.github/workflows/cis-nist-sync.yml`
- **Build System Docs**: `docs/manual/developer/`
