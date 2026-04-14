# NIST 800-53 / CIS Synchronization Toolkit

Automated tooling to generate and maintain NIST 800-53 control files from CIS benchmark mappings for ComplianceAsCode products.

## Quick Start

```bash
# Run the complete workflow (generates product-specific reference files)
./generate_cis_nist_workflow.sh

# Test locally before committing
./test_workflow_local.sh
```

## Architecture Overview

### Directory Structure

The toolkit generates **product-specific split-by-family** reference control files:

```
shared/references/controls/              # Reference files (auto-generated)
  ├── nist_800_53_cis_reference_rhel8.yml
  ├── nist_800_53_cis_reference_rhel8/  # 21 family files (rhel8-specific)
  │   ├── ac.yml
  │   ├── au.yml
  │   └── ... (19 more)
  ├── nist_800_53_cis_reference_rhel9.yml
  ├── nist_800_53_cis_reference_rhel9/  # 21 family files (rhel9-specific)
  ├── nist_800_53_cis_reference_rhel10.yml
  └── nist_800_53_cis_reference_rhel10/ # 21 family files (rhel10-specific)

products/rhel8/controls/                 # Product control files (human-maintained)
  ├── nist_800_53.yml
  └── nist_800_53/                       # 21 family files (rhel8-specific)
      ├── ac.yml
      └── ...

products/rhel9/controls/
  ├── nist_800_53.yml
  └── nist_800_53/                       # 21 family files (rhel9-specific)

products/rhel10/controls/
  ├── nist_800_53.yml
  └── nist_800_53/                       # 21 family files (rhel10-specific)
```

Each control file contains:
- **Product-specific rules**: Only rules available for that product
- **NO Jinja2 guards**: Clean, simple YAML
- **NO OSCAL metadata**: Lean files (OSCAL data retrieved separately when needed)
- **Baseline levels**: Low, moderate, high applicability

## Scripts

### Main Workflow

- **`generate_cis_nist_workflow.sh`** - Master orchestration script
  - Downloads NIST OSCAL catalog
  - Scans CIS control files for product-specific mappings
  - Generates product-specific family files (rhel8, rhel9, rhel10)
  - NO guards applied (product-specific filtering instead)
  - Compares with previous version
  - Used by GitHub Actions weekly automation

### Core Components

- **`sync_nist_split.py`** - Generate product-specific split control files
  - **NEW**: Requires `--product` argument (rhel8, rhel9, or rhel10)
  - Extracts control structure from OSCAL catalog (title, levels only)
  - Inverts CIS→NIST mappings to populate rule selections
  - **Filters rules to only those in target product's CIS control file**
  - **Does NOT include OSCAL metadata** (description, parameters, guidance, related_controls)
  - Outputs 21 family files per product
  - Example: `python3 sync_nist_split.py --product rhel9`

- **`harvest_cis_nist_mappings.py`** - Extract CIS→NIST mappings
  - Scans CIS benchmark PDFs/documents
  - Builds rule→NIST control mapping
  - Outputs `data/cis_nist_mappings.json`

- **`generate_variable_to_products.py`** - Build variable→products mapping
  - Scans CIS control files for variable assignments
  - Outputs `data/variable_to_products.json`
  - Used during generation to identify product-specific variables

### Utilities

- **`download_oscal.py`** - Download NIST OSCAL catalog JSON
- **`compare_profile_rules.py`** - Validate CIS profile coverage
- **`generate_nist_based_cis_profile.py`** - Generate CIS-NIST profiles
- **`test_workflow_local.sh`** - Local testing script

### Deprecated Scripts (Removed)

- ~~`generate_product_family_guards.py`~~ - No longer needed (product-specific files instead of guards)

## File Locations

```
products/{product}/controls/
├── nist_800_53.yml                    # 👤 Product-specific metadata (human-edited)
└── nist_800_53/*.yml                  # 👤 Product-specific family files (human-edited)

shared/references/controls/
├── nist_800_53_cis_reference_{product}.yml      # 🤖 Reference metadata (auto-generated)
└── nist_800_53_cis_reference_{product}/*.yml    # 🤖 Reference family files (auto-generated)

utils/nist_sync/
├── *.py                               # Python scripts
├── *.sh                               # Bash orchestration
└── data/                              # Generated mappings
    ├── cis_nist_mappings.json         # CIS→NIST mappings
    ├── variable_to_products.json      # Variable availability
    └── nist_800_53_rev5_catalog.json  # OSCAL catalog

.github/workflows/
└── cis-nist-sync.yml                  # Weekly automation workflow
```

## Workflows

### Weekly Automation (GitHub Actions)

Every Sunday at 2 PM UTC:
1. Downloads latest NIST OSCAL catalog
2. Generates product-specific reference family files for rhel8, rhel9, rhel10
3. Compares with previous week's version
4. Creates PR if changes detected

### Local Development

```bash
# Run full workflow for all products
cd utils/nist_sync
./generate_cis_nist_workflow.sh

# Generate for specific product only
python3 sync_nist_split.py --product rhel9

# Compare reference vs product files
diff -ur shared/references/controls/nist_800_53_cis_reference_rhel9/ \
         products/rhel9/controls/nist_800_53/

# Test profile coverage
python3 compare_profile_rules.py \
  ../../products/rhel9/profiles/cis.profile \
  ../../products/rhel9/profiles/cis_nist.profile \
  --product rhel9
```

### Manual Sync

When you need to manually sync changes:

```bash
cd utils/nist_sync

# Step 1: Regenerate reference files
python3 download_oscal.py  # Update OSCAL catalog if needed
python3 sync_nist_split.py --product rhel9

# Step 2: Review and copy to product files if needed
# Compare reference vs product files to see differences
diff -ur ../../shared/references/controls/nist_800_53_cis_reference_rhel9/ \
         ../../products/rhel9/controls/nist_800_53/

# Step 3: Test build
cd ../..
./build_product rhel9 --datastream-only
```

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

### Product-Specific Architecture

Controls are generated separately for each product instead of using a single global file with Jinja2 guards:

**Benefits**:
- ✅ Cleaner files without conditional logic
- ✅ Each product can evolve independently
- ✅ No NoneType build errors from guards evaluating to None
- ✅ Easier to understand (no guards cluttering rule lists)

**Trade-offs**:
- ❌ More files to maintain (3x sets of family files)
- ❌ Changes to shared controls require updating multiple products
- ✅ But files are auto-generated weekly, so duplication manageable

### Split-by-Family Architecture

Controls are organized into 21 family files instead of a single monolithic file:
- Easier to navigate and edit
- Clearer git diffs
- Parallel processing support
- Better organization for 1,196 controls

Families: AC, AT, AU, CA, CM, CP, IA, IR, MA, MP, PE, PL, PM, PS, PT, RA, SA, SC, SI, SR, OTHER

### OSCAL Metadata (Excluded)

OSCAL metadata fields are **NOT included** in generated control files:
- ❌ `description` - Full control statement with sub-parts
- ❌ `parameters` - Organization-Defined Parameters (ODPs)
- ❌ `guidance` - Implementation advice text
- ❌ `related_controls` - Control dependency references

**Why excluded?**:
- Control files stay small and focused (~50-200 lines per family vs. thousands)
- OSCAL data retrieved from authoritative source when needed
- No duplication of large text blocks across products
- Updates to OSCAL catalog don't require regenerating control files

**How to retrieve OSCAL metadata**:
1. Load OSCAL catalog: `utils/nist_sync/data/nist_800_53_rev5_catalog.json`
2. Look up control by ID (e.g., "ac-2")
3. Extract description, parameters, guidance, related_controls
4. Display in web application or documentation

### Product-Specific Filtering

During generation, rules are filtered to only those available in the target product:

```python
# sync_nist_split.py filters rules by:
1. Reading target product's CIS control file (e.g., products/rhel9/controls/cis_rhel9.yml)
2. Extracting all rules/variables defined for that product
3. Filtering NIST control rules to only those in the product's CIS file
4. Handling variables with product-specific values (var_x=value)
```

Result: Each product's control files contain only rules that actually exist for that product.

### Two File Sets

- **Reference files** (`shared/references/...`) - Auto-generated from OSCAL + CIS, for comparison
- **Product files** (`products/{product}/controls/...`) - Human-editable, used for building

This separation prevents automation from overwriting human edits while tracking upstream changes.

## Troubleshooting

**Build fails with "Control file not found":**
- Ensure product-specific control file exists: `products/{product}/controls/nist_800_53.yml`
- Check `controls_dir` field points to `nist_800_53`

**Profile comparison shows missing rules:**
- Regenerate controls: `./generate_cis_nist_workflow.sh`
- Verify variable mappings: `cat data/variable_to_products.json`
- Check that CIS control file includes the rule

**Want to add OSCAL metadata:**
- OSCAL metadata is not in control files (kept separate)
- Download catalog: `python3 download_oscal.py`
- Catalog location: `data/nist_800_53_rev5_catalog.json`
- Retrieve on-demand for web application or documentation

**Sync script requires --product argument:**
- Old: `python3 sync_nist_split.py` (generated global file with guards)
- New: `python3 sync_nist_split.py --product rhel9` (generates product-specific files)
- Must specify product: rhel8, rhel9, or rhel10

## Contributing

When modifying scripts:
1. Test locally with `test_workflow_local.sh`
2. Verify builds succeed for all products:
   ```bash
   ./build_product rhel8 rhel9 rhel10 --datastream-only
   ```
3. Check profile coverage: `compare_profile_rules.py` for each product
4. Update this README if workflow changes

## References

- NIST OSCAL: https://pages.nist.gov/OSCAL/
- NIST 800-53: https://csrc.nist.gov/publications/detail/sp/800-53/rev-5/final
- CIS Benchmarks: https://www.cisecurity.org/cis-benchmarks
