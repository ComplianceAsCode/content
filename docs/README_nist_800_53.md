# NIST 800-53 Control Files

This directory previously contained global NIST 800-53 control files. **These have been moved to product-specific locations.**

## 🔄 Architecture Change

NIST 800-53 control files are now **product-specific** instead of global:

### OLD Architecture (Deprecated)
```
controls/
├── nist_800_53.yml              # Global metadata with Jinja2 guards
└── nist_800_53/                 # Global family files with guards
    ├── ac.yml                   # {{% if product == "rhel9" %}}
    ├── au.yml                   # {{% if product.startswith('rhel') %}}
    └── ...
```

### NEW Architecture (Current)
```
products/rhel8/controls/
├── nist_800_53.yml              # RHEL8-specific metadata
└── nist_800_53/                 # RHEL8-specific family files (NO guards)
    ├── ac.yml                   # Only rules available in rhel8
    ├── au.yml
    └── ... (21 family files)

products/rhel9/controls/
├── nist_800_53.yml              # RHEL9-specific metadata
└── nist_800_53/                 # RHEL9-specific family files (NO guards)
    ├── ac.yml                   # Only rules available in rhel9
    ├── au.yml
    └── ... (21 family files)

products/rhel10/controls/
├── nist_800_53.yml              # RHEL10-specific metadata
└── nist_800_53/                 # RHEL10-specific family files (NO guards)
    ├── ac.yml                   # Only rules available in rhel10
    ├── au.yml
    └── ... (21 family files)
```

## Benefits of Product-Specific Controls

✅ **Cleaner files** - No Jinja2 conditional logic  
✅ **Better separation** - Each product can evolve independently  
✅ **Easier to read** - No guards cluttering the rule lists  
✅ **No build errors** - No NoneType errors from guards evaluating to None  
✅ **Smaller files** - Only rules that actually apply to the product  

## File Structure

### Product-Specific Control Files

Each product has its own dedicated NIST 800-53 control files:

**Metadata File**: `products/{product}/controls/nist_800_53.yml`
```yaml
policy: NIST 800-53 Revision 5
title: NIST Special Publication 800-53 Revision 5
id: nist_800_53
version: Revision 5
product: rhel9                    # Product-specific
controls_dir: nist_800_53         # Points to family files
levels:
  - id: low
  - id: moderate
  - id: high
```

**Family Files**: `products/{product}/controls/nist_800_53/*.yml` (21 files)

Example: `products/rhel9/controls/nist_800_53/au.yml`
```yaml
# NIST 800-53 AU Family: Audit and Accountability
controls:
  - id: au-2
    title: Event Logging
    levels:
      - low
      - moderate
      - high
    rules:
      - aide_build_database
      - aide_periodic_cron_checking
      - audit_rules_execution_chacl
      # ... only rules available in rhel9
    status: automated
```

**Key Differences from Old Format**:
- ❌ NO Jinja2 guards (`{{% if product == "rhel9" %}}`)
- ❌ NO OSCAL metadata fields (description, parameters, guidance, related_controls)
- ✅ Only rules/variables that exist for the specific product

### OSCAL Metadata

OSCAL metadata (description, parameters, guidance, related_controls) is **NOT included** in control files to keep them lean and focused on rule mappings.

**How to retrieve OSCAL metadata**:
1. **Direct from NIST OSCAL Catalog**: Download from [NIST OSCAL](https://pages.nist.gov/OSCAL/)
2. **On-demand retrieval**: Web application or API can load the OSCAL JSON catalog and extract metadata by control ID
3. **Build-time enrichment**: If needed for documentation, retrieve during build process

**Benefits**:
- Control files stay small (~50-200 lines per family vs. thousands)
- OSCAL data retrieved from authoritative source (NIST catalog)
- No duplication across products
- Updates to OSCAL catalog don't require regenerating control files

## Reference Files (Auto-Generated)

Reference files are auto-generated weekly for comparison:

```
shared/references/controls/
├── nist_800_53_cis_reference_rhel8.yml
├── nist_800_53_cis_reference_rhel8/    # 21 family files
│   ├── ac.yml
│   ├── au.yml
│   └── ...
├── nist_800_53_cis_reference_rhel9.yml
├── nist_800_53_cis_reference_rhel9/    # 21 family files
├── nist_800_53_cis_reference_rhel10.yml
└── nist_800_53_cis_reference_rhel10/   # 21 family files
```

- **Purpose**: Generated from CIS benchmark + NIST OSCAL for comparison
- **Maintained By**: 🤖 **Weekly automation** (DO NOT edit manually)
- **Usage**: Compare with product control files to detect changes

## Control File Content

Each control entry contains:

```yaml
- id: au-2                        # NIST control ID
  title: Event Logging            # Control title
  levels:                         # Baseline applicability
    - low
    - moderate
    - high
  rules:                          # Rules that implement this control
    - var_audit_backlog_limit=8192
    - aide_build_database
    - audit_rules_execution_chacl
  status: automated               # automated | manual | pending
```

**Field Descriptions**:
- `id`: NIST 800-53 control identifier (lowercase)
- `title`: Short descriptive title from NIST catalog
- `levels`: LOW/MODERATE/HIGH baseline applicability
- `rules`: Rule IDs and variable assignments that implement the control
- `status`: 
  - `automated` - Has rules/checks
  - `pending` - No rules yet
  - `manual` - Requires manual verification

## How Profiles Use Control Files

Product profiles reference their own NIST control files:

**Profile**: `products/rhel9/profiles/cis_nist.profile`
```yaml
selections:
  - nist_800_53:all    # References products/rhel9/controls/nist_800_53.yml
```

The build system automatically:
1. Loads `products/rhel9/controls/nist_800_53.yml` metadata
2. Reads `controls_dir: nist_800_53` field
3. Loads all `.yml` files from `products/rhel9/controls/nist_800_53/`
4. Merges into single control tree
5. Expands `nist_800_53:all` to include all rules from all controls

## Generating Control Files

Control files are generated using the NIST sync toolkit:

```bash
cd utils/nist_sync

# Generate reference files for all products
./generate_cis_nist_workflow.sh

# Generate for specific product
python3 sync_nist_split.py --product rhel9

# Copy reference to product directory
cp shared/references/controls/nist_800_53_cis_reference_rhel9.yml \
   products/rhel9/controls/nist_800_53.yml
cp -r shared/references/controls/nist_800_53_cis_reference_rhel9/* \
   products/rhel9/controls/nist_800_53/
```

See [utils/nist_sync/README.md](../utils/nist_sync/README.md) for details.

## Workflow

### Weekly Automated Sync

Every Sunday at 2 PM UTC, GitHub Actions:
1. Downloads latest NIST OSCAL catalog
2. Generates product-specific reference files for rhel8, rhel9, rhel10
3. Compares with previous version
4. Creates PR if changes detected

**Reference files updated automatically. Product control files require manual review.**

### Manual Updates

To update product control files:

```bash
# 1. Generate reference files
cd utils/nist_sync
./generate_cis_nist_workflow.sh

# 2. Compare reference vs. product files
diff -ur shared/references/controls/nist_800_53_cis_reference_rhel9/ \
         products/rhel9/controls/nist_800_53/

# 3. Review differences and manually update if needed
vim products/rhel9/controls/nist_800_53/au.yml

# 4. Test build
./build_product rhel9 --datastream-only

# 5. Commit changes
git add products/rhel9/controls/nist_800_53/
git commit -m "Update RHEL9 NIST 800-53 controls"
```

## Family Breakdown

| Family | Name | Controls | Description |
|--------|------|----------|-------------|
| AC | Access Control | 147 | User access, permissions, least privilege |
| AT | Awareness and Training | 17 | Security awareness, role-based training |
| AU | Audit and Accountability | 69 | Logging, monitoring, audit records |
| CA | Assessment, Authorization, Monitoring | 32 | Security assessments, continuous monitoring |
| CM | Configuration Management | 66 | Baseline configs, change control |
| CP | Contingency Planning | 56 | Backup, disaster recovery, continuity |
| IA | Identification and Authentication | 74 | User authentication, MFA, credentials |
| IR | Incident Response | 42 | Incident handling, response procedures |
| MA | Maintenance | 30 | System maintenance, tools, personnel |
| MP | Media Protection | 30 | Removable media, sanitization, disposal |
| PE | Physical and Environmental Protection | 59 | Physical access, environmental controls |
| PL | Planning | 17 | Security planning, architecture |
| PM | Program Management | 37 | Program-level controls, governance |
| PS | Personnel Security | 18 | Background checks, termination procedures |
| PT | PII Processing and Transparency | 21 | Privacy, personally identifiable information |
| RA | Risk Assessment | 26 | Vulnerability scanning, risk analysis |
| SA | System and Services Acquisition | 147 | SDLC, supply chain, developer controls |
| SC | System and Communications Protection | 162 | Network security, encryption, boundaries |
| SI | System and Information Integrity | 119 | Malware protection, security alerts |
| SR | Supply Chain Risk Management | 27 | Supply chain security, provenance |
| OTHER | CIS Items Without NIST Mapping | 102 | CIS rules not explicitly mapped to NIST |

**Total**: 1,196 NIST controls + 102 unmapped CIS items = **1,298 total controls**

## Troubleshooting

**Build fails with "Control file not found":**
- Ensure `products/{product}/controls/nist_800_53.yml` exists
- Check that `controls_dir: nist_800_53` points to correct subdirectory

**Profile shows missing rules:**
- Verify rules exist in product's CIS control file
- Regenerate control files: `./generate_cis_nist_workflow.sh`
- Check that profile references `nist_800_53:all`

**Want to add OSCAL metadata back:**
- OSCAL metadata is available in the NIST OSCAL catalog
- Download: `utils/nist_sync/download_oscal.py`
- Catalog location: `utils/nist_sync/data/nist_800_53_rev5_catalog.json`
- Retrieve on-demand rather than duplicating in control files

## References

- **NIST OSCAL**: https://pages.nist.gov/OSCAL/
- **NIST 800-53 Rev 5**: https://csrc.nist.gov/publications/detail/sp/800-53/rev-5/final
- **CIS Benchmarks**: https://www.cisecurity.org/cis-benchmarks
- **Sync Toolkit**: [utils/nist_sync/README.md](../utils/nist_sync/README.md)
- **GitHub Workflow**: [.github/workflows/cis-nist-sync.yml](../.github/workflows/cis-nist-sync.yml)
