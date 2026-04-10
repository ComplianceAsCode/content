# NIST 800-53 / CIS Synchronization Toolkit

Automated tooling to generate and maintain NIST 800-53 control files with CIS benchmark mappings and OSCAL metadata.

## Quick Start

```bash
# Run the complete workflow (generates reference files with OSCAL metadata)
./generate_cis_nist_workflow.sh

# Test locally before committing
./test_workflow_local.sh
```

## Architecture

The toolkit generates **split-by-family** control files:

```
controls/nist_800_53/          # 21 family files (AC, AU, CM, etc.)
  ├── ac.yml                   # Access Control (147 controls)
  ├── au.yml                   # Audit and Accountability (69 controls)
  ├── cm.yml                   # Configuration Management (66 controls)
  └── ... (18 more families)   # Total: 1,196 NIST controls + 102 unmapped CIS items
```

Each control includes:
- **OSCAL metadata**: description, parameters (ODPs), guidance, related controls
- **CIS rule mappings**: Rules extracted from CIS benchmark references
- **Product guards**: Jinja2 conditionals for RHEL family (rhel8, rhel9, rhel10)
- **Baseline levels**: Low, moderate, high applicability

## Scripts

### Main Workflow

- **`generate_cis_nist_workflow.sh`** - Master orchestration script
  - Downloads NIST OSCAL catalog
  - Scans CIS control files for mappings
  - Generates all 21 family files with OSCAL metadata
  - Applies product guards
  - Compares with previous version
  - Used by GitHub Actions weekly automation

### Core Components

- **`sync_nist_split.py`** - Generate split control files from OSCAL catalog
  - Extracts control metadata (description, parameters, guidance, related controls)
  - Inverts CIS→NIST mappings to populate rule selections
  - Escapes Jinja2 syntax in OSCAL text (`{{ }}` → `[[ ]]`)
  - Outputs 21 family files + metadata file

- **`harvest_cis_nist_mappings.py`** - Extract CIS→NIST mappings
  - Scans CIS benchmark PDFs/documents
  - Builds rule→NIST control mapping
  - Outputs `data/cis_nist_mappings.json`

- **`generate_product_family_guards.py`** - Add Jinja2 product guards
  - Scans CIS control files to determine rule availability per product
  - Generates family-based guards: `{{% if product.startswith('rhel') %}}`
  - Groups variable variants into if/elif blocks
  - Processes all 21 family files

- **`generate_variable_to_products.py`** - Build variable→products mapping
  - Scans CIS control files for variable assignments
  - Outputs `data/variable_to_products.json`
  - Used by guard generator for variable-specific guards

### Utilities

- **`download_oscal.py`** - Download NIST OSCAL catalog JSON
- **`compare_profile_rules.py`** - Validate CIS profile coverage
- **`generate_nist_based_cis_profile.py`** - Generate CIS-NIST profiles
- **`test_workflow_local.sh`** - Local testing script

## File Locations

```
controls/
├── nist_800_53.yml                    # Top-level metadata (points to subdirectory)
└── nist_800_53/*.yml                  # 👤 REAL family files (human-edited)

shared/references/controls/
├── nist_800_53_cis_reference.yml      # Reference metadata
└── nist_800_53_cis_reference/*.yml    # 🤖 REFERENCE family files (auto-generated)

utils/nist_sync/
├── *.py                               # Python scripts
├── *.sh                               # Bash orchestration
└── data/                              # Generated mappings
    ├── cis_nist_mappings.json         # CIS→NIST mappings
    └── variable_to_products.json      # Variable availability

.github/workflows/
└── cis-nist-sync.yml                  # Weekly automation workflow
```

## Workflows

### Weekly Automation (GitHub Actions)

Every Sunday at 2 PM UTC:
1. Downloads latest NIST OSCAL catalog
2. Regenerates reference family files with OSCAL metadata
3. Applies product guards for RHEL family
4. Compares with previous version
5. Creates PR if changes detected

**Reference files updated automatically. Real files require manual review.**

### Local Development

```bash
# Run full workflow
cd utils/nist_sync
./generate_cis_nist_workflow.sh

# Compare reference vs real files
diff -ur shared/references/controls/nist_800_53_cis_reference/ \
         controls/nist_800_53/

# Test profile coverage
python3 compare_profile_rules.py \
  ../../products/rhel9/profiles/cis.profile \
  ../../products/rhel9/profiles/cis_nist.profile \
  --product rhel9
```

### Manual Sync

To regenerate reference files manually:

```bash
cd utils/nist_sync

# Step 1: Download OSCAL catalog
python3 download_oscal.py

# Step 2: Generate family files with OSCAL metadata
python3 sync_nist_split.py

# Step 3: Generate variable mapping
python3 generate_variable_to_products.py

# Step 4: Apply product guards to all families
for f in ../../shared/references/controls/nist_800_53_cis_reference/*.yml; do
  python3 generate_product_family_guards.py --target rhel \
    --control-file "$f" --output "$f"
done
```

Then review diff and manually update real control files.

## Documentation

- **Main documentation**: `controls/README_nist_800_53.md`
- **Workflow details**: `.github/workflows/cis-nist-sync.yml`
- **Script usage**: Run any script with `--help` flag

## Requirements

```bash
pip install -r requirements.txt
```

Dependencies:
- `ruamel.yaml` - Round-trip YAML parsing
- Python 3.8+

## Key Concepts

### Split-by-Family Architecture

Controls are organized into 21 family directories instead of a single monolithic file:
- Easier to navigate and edit
- Clearer git diffs
- Parallel processing support
- Better organization for 1,196 controls

### OSCAL Metadata Enrichment

Each control includes metadata from the official NIST OSCAL catalog:
- **description**: Full control statement with sub-parts (a, b, c...)
- **parameters**: Organization-Defined Parameters with labels and guidelines
- **guidance**: Implementation advice (500-3000 characters)
- **related_controls**: Control dependency references

### Product Guards

Jinja2 conditionals enable cross-product rule sharing:
```yaml
{{% if product.startswith('rhel') %}}
- rule_for_all_rhel_versions
{{% endif %}}

{{% if product == "rhel9" %}}
- rhel9_specific_rule
{{% endif %}}
```

### Two File Sets

- **Reference files** (`shared/references/...`) - Auto-generated from OSCAL + CIS, used for comparison
- **Real files** (`controls/...`) - Human-edited, used for building, never touched by automation

This separation prevents automation from overwriting human edits while tracking upstream changes.

## Troubleshooting

**Build fails with "parameters is not allowed":**
- Update `ssg/controls.py` to include OSCAL fields in allowed keys

**Profile comparison shows missing rules:**
- Check that guards are applied: `grep "if product" controls/nist_800_53/*.yml`
- Verify variable mappings: `cat data/variable_to_products.json`

**OSCAL metadata has Jinja2 syntax errors:**
- Verify escaping: OSCAL uses `[[ ]]`, guards use `{{% %}}`
- Check `sync_nist_split.py` escape_jinja_syntax() function

## Contributing

When modifying scripts:
1. Test locally with `test_workflow_local.sh`
2. Verify builds succeed: `./build_product rhel9 --datastream-only`
3. Check profile coverage: `compare_profile_rules.py`
4. Update this README if workflow changes

## References

- NIST OSCAL: https://pages.nist.gov/OSCAL/
- NIST 800-53: https://csrc.nist.gov/publications/detail/sp/800-53/rev-5/final
- CIS Benchmarks: https://www.cisecurity.org/cis-benchmarks
