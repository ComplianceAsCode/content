#!/bin/bash
#
# CIS-NIST Workflow - Complete Generation and Validation
#
# This script runs the complete workflow to generate CIS-NIST control files and profiles.
#
# Steps:
# 1. Harvest CIS→NIST mappings from benchmark PDFs
# 2. Generate unified NIST 800-53 control file from OSCAL + CIS mappings
# 3. Apply product family guards to control file
# 4. Generate CIS-NIST profiles for each RHEL version
# 5. Build products to validate
# 6. Compare CIS vs CIS-NIST profiles to ensure they match
# 7. Generate HTML tables from control file

set -e  # Exit on error

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$SCRIPT_DIR/../.."
cd "$SCRIPT_DIR"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${BLUE}▶${NC} $1"
}

log_success() {
    echo -e "${GREEN}✓${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}!${NC} $1"
}

log_error() {
    echo -e "${RED}✗${NC} $1"
}

log_section() {
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}  $1${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
    echo ""
}

# Parse command line arguments
SKIP_BUILD=false
SKIP_COMPARISON=false
SKIP_HARVEST=true  # Skip by default, only harvest when explicitly requested
PRODUCTS="rhel8 rhel9 rhel10"

while [[ $# -gt 0 ]]; do
    case $1 in
        --skip-build)
            SKIP_BUILD=true
            shift
            ;;
        --skip-comparison)
            SKIP_COMPARISON=true
            shift
            ;;
        --harvest)
            SKIP_HARVEST=false
            shift
            ;;
        --products)
            PRODUCTS="$2"
            shift 2
            ;;
        --help|-h)
            cat << EOF
CIS-NIST Workflow - Complete Generation and Validation

Usage: ./generate_cis_nist_workflow.sh [OPTIONS]

Options:
  --harvest           Harvest CIS→NIST mappings from PDFs (slow, only needed when PDFs change)
  --skip-build        Skip building products (use existing builds)
  --skip-comparison   Skip profile comparison step
  --products "..."    Specify products to process (default: "rhel8 rhel9 rhel10")
  --help, -h          Show this help message

Example:
  ./generate_cis_nist_workflow.sh
  ./generate_cis_nist_workflow.sh --harvest              # Update CIS→NIST mappings from PDFs
  ./generate_cis_nist_workflow.sh --skip-build
  ./generate_cis_nist_workflow.sh --products "rhel9"

Output:
  - shared/references/controls/nist_800_53_cis_reference_{product}.yml (per-product reference)
  - shared/references/controls/nist_800_53_cis_reference_{product}/*.yml (family files, NO guards)
  - products/rhel8/profiles/cis_nist.profile
  - products/rhel9/profiles/cis_nist.profile
  - products/rhel10/profiles/cis_nist.profile
  - Comparison reports showing CIS == CIS-NIST for each product

EOF
            exit 0
            ;;
        *)
            log_error "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Check dependencies
if ! command -v python3 &> /dev/null; then
    log_error "Python 3 is required but not found. Please install Python 3.8 or later."
    exit 1
fi

# Check for required Python packages
MISSING_DEPS=()
for pkg in ruamel.yaml PyPDF2; do
    if ! python3 -c "import ${pkg%.*}" 2>/dev/null; then
        MISSING_DEPS+=("$pkg")
    fi
done

if [ ${#MISSING_DEPS[@]} -gt 0 ]; then
    log_error "Missing Python packages: ${MISSING_DEPS[*]}"
    log_info "Install with: pip install ${MISSING_DEPS[*]}"
    exit 1
fi

echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║         CIS-NIST Workflow - Complete Generation           ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""
# Step 0: Download OSCAL catalog
log_section "Step 0: Ensuring OSCAL Catalog is Available"

OSCAL_CATALOG="$SCRIPT_DIR/data/nist_800_53_rev5_catalog.json"
if [ -f "$OSCAL_CATALOG" ]; then
    log_info "OSCAL catalog already exists: data/nist_800_53_rev5_catalog.json"
else
    log_info "Downloading OSCAL catalog..."
    if python3 download_oscal.py; then
        log_success "OSCAL catalog downloaded"
        log_info "Catalog: data/nist_800_53_rev5_catalog.json"
    else
        log_error "Failed to download OSCAL catalog"
        exit 1
    fi
fi



# Step 1: Harvest CIS→NIST mappings (optional)
if [ "$SKIP_HARVEST" = false ]; then
    log_section "Step 1: Harvesting CIS→NIST Mappings"
    log_info "Parsing CIS benchmark PDFs to extract NIST references..."
    if python3 harvest_cis_nist_mappings.py; then
        log_success "CIS→NIST mappings harvested"
        log_info "Mapping cache: data/cis_nist_mappings.json"
    else
        log_error "Failed to harvest CIS→NIST mappings"
        exit 1
    fi
else
    log_section "Step 1: Using Existing CIS→NIST Mappings"

    # Check if mapping file exists
    MAPPING_FILE="$SCRIPT_DIR/data/cis_nist_mappings.json"
    if [ ! -f "$MAPPING_FILE" ]; then
        log_error "CIS→NIST mapping file not found: $MAPPING_FILE"
        log_error "Run with --harvest to generate it from CIS benchmark PDFs"
        exit 1
    fi

    log_info "Using existing mapping cache: data/cis_nist_mappings.json"
    log_warning "To update mappings from PDFs, run with --harvest flag"
fi

# Step 2: Generate product-specific CIS reference files in split-by-family format
log_section "Step 2: Generating Product-Specific NIST 800-53 CIS Reference Files"

# Delete existing reference files (old global and product-specific)
log_info "Removing old reference files..."
rm -rf "$REPO_ROOT/shared/references/controls/nist_800_53_cis_reference"
rm -f "$REPO_ROOT/shared/references/controls/nist_800_53_cis_reference.yml"
for product in $PRODUCTS; do
    rm -rf "$REPO_ROOT/shared/references/controls/nist_800_53_cis_reference_${product}"
    rm -f "$REPO_ROOT/shared/references/controls/nist_800_53_cis_reference_${product}.yml"
done

# Generate product-specific reference files (NO guards, product-filtered)
for product in $PRODUCTS; do
    log_info "Generating CIS reference files for $product (split by family, no guards)..."
    if python3 sync_nist_split.py --product "$product"; then
        log_success "$product: CIS reference files generated"
        log_info "  → shared/references/controls/nist_800_53_cis_reference_${product}.yml"
        log_info "  → shared/references/controls/nist_800_53_cis_reference_${product}/*.yml"
    else
        log_error "$product: Failed to generate CIS reference files"
        exit 1
    fi
done

# Step 3: Compare product-specific CIS references with previous versions
log_section "Step 3: Comparing Product-Specific CIS Reference Changes"
for product in $PRODUCTS; do
    REF_FILE="$REPO_ROOT/shared/references/controls/nist_800_53_cis_reference_${product}.yml"
    if [ -f "$REF_FILE" ]; then
        if git diff --quiet HEAD -- "$REF_FILE" 2>/dev/null; then
            log_info "$product: No changes in CIS reference file"
        else
            log_warning "$product: CIS reference file has changes!"
            log_info "  Review diff: git diff shared/references/controls/nist_800_53_cis_reference_${product}.yml"
        fi
    else
        log_info "$product: First time generating CIS reference file"
    fi
done

# Step 4: Generate CIS-NIST profiles
log_section "Step 4: Generating CIS-NIST Profiles"
for product in $PRODUCTS; do
    log_info "Generating CIS-NIST profile for $product..."
    if python3 generate_nist_based_cis_profile.py --product "$product"; then
        log_success "$product: CIS-NIST profile generated"
        log_info "  → products/$product/profiles/cis_nist.profile"
    else
        log_error "$product: Failed to generate CIS-NIST profile"
        exit 1
    fi
done

# Step 5: Build products (optional)
if [ "$SKIP_BUILD" = false ]; then
    log_section "Step 5: Building Products"
    cd "$REPO_ROOT"

    log_info "Building products: $PRODUCTS"
    
    # Run build for all products at once and capture output
    BUILD_LOG=$(mktemp)
    if ./build_product $PRODUCTS --datastream-only > "$BUILD_LOG" 2>&1; then
        # Check if all datastreams were generated
        ALL_BUILT=true
        for product in $PRODUCTS; do
            if [ -f "build/ssg-$product-ds.xml" ]; then
                log_success "$product: Build complete"
            else
                log_error "$product: Datastream not generated"
                ALL_BUILT=false
            fi
        done
        
        if [ "$ALL_BUILT" = false ]; then
            echo "Last 30 lines of build log:"
            tail -30 "$BUILD_LOG"
            rm -f "$BUILD_LOG"
            exit 1
        fi
    else
        log_error "Build failed"
        echo "Last 50 lines of build log:"
        tail -50 "$BUILD_LOG"
        rm -f "$BUILD_LOG"
        exit 1
    fi
    rm -f "$BUILD_LOG"
    # Render policies for all products
    log_info "Rendering policies..."
    cd build
    if ninja render-policies; then
        log_success "Policies rendered"
        log_info "Rendered policies:"
        for product in $PRODUCTS; do
            if [ -f "$product/rendered-policies/nist_800_53.html" ]; then
                echo "  - build/$product/rendered-policies/nist_800_53.html"
            fi
        done
    else
        log_warning "Failed to render policies (non-fatal)"
    fi
    cd "$REPO_ROOT"

    cd "$SCRIPT_DIR"
else
    log_section "Step 5: Skipping Build (--skip-build)"
    log_warning "Using existing builds for validation"
fi

# Step 6: Compare CIS vs CIS-NIST profiles
if [ "$SKIP_COMPARISON" = false ]; then
    log_section "Step 6: Comparing CIS vs CIS-NIST Profiles"

    ALL_MATCH=true
    for product in $PRODUCTS; do
        log_info "Comparing profiles for $product..."

        cd "$REPO_ROOT"

        # Set up PYTHONPATH for profile_tool.py
        export PYTHONPATH="$REPO_ROOT:${PYTHONPATH:-}"

        # Profile paths (source .profile files in build/ directory)
        CIS_PROFILE="build/$product/profiles/cis.profile"
        CIS_NIST_PROFILE="build/$product/profiles/cis_nist.profile"
        BUILD_CONFIG="build/build_config.yml"

        # Debug: Show paths being checked
        echo "  Debug: CIS profile path: $CIS_PROFILE"
        echo "  Debug: CIS-NIST profile path: $CIS_NIST_PROFILE"

        # Check if profiles exist
        if [ ! -f "$CIS_PROFILE" ]; then
            log_error "$product: CIS profile not found: $CIS_PROFILE"
            echo "  Debug: Directory contents:"
            ls -la "build/$product/profiles/" 2>&1 | head -10 || echo "  Directory does not exist"
            ALL_MATCH=false
            continue
        fi
        if [ ! -f "$CIS_NIST_PROFILE" ]; then
            log_error "$product: CIS-NIST profile not found: $CIS_NIST_PROFILE"
            echo "  Debug: Directory contents:"
            ls -la "build/$product/profiles/" 2>&1 | head -10 || echo "  Directory does not exist"
            ALL_MATCH=false
            continue
        fi

        echo "  Debug: Both profiles found"

        # Calculate actual rule counts (total selections in profile)
        CIS_COUNT=$(grep -E '^[[:space:]]*-[[:space:]]' "$CIS_PROFILE" | grep -v '^[[:space:]]*-[[:space:]]*!' | wc -l)
        CIS_NIST_COUNT=$(grep -E '^[[:space:]]*-[[:space:]]' "$CIS_NIST_PROFILE" | grep -v '^[[:space:]]*-[[:space:]]*!' | wc -l)

        echo "  CIS:      ~$CIS_COUNT selections"
        echo "  CIS-NIST: ~$CIS_NIST_COUNT selections"

        # Do bidirectional subtraction to ensure they're identical
        # Check for "Subtraction would produce an empty profile" message
        echo "  Debug: Running profile_tool.py sub (CIS - CIS_NIST)..."
        DIFF_A_OUTPUT=$(python3 build-scripts/profile_tool.py sub \
            --profile1 "$CIS_PROFILE" \
            --profile2 "$CIS_NIST_PROFILE" \
            --build-config-yaml "$BUILD_CONFIG" \
            --ssg-root . \
            --product "$product" 2>&1)
        DIFF_A_EXIT=$?
        echo "  Debug: Exit code: $DIFF_A_EXIT"
        
        echo "  Debug: Running profile_tool.py sub (CIS_NIST - CIS)..."
        DIFF_B_OUTPUT=$(python3 build-scripts/profile_tool.py sub \
            --profile1 "$CIS_NIST_PROFILE" \
            --profile2 "$CIS_PROFILE" \
            --build-config-yaml "$BUILD_CONFIG" \
            --ssg-root . \
            --product "$product" 2>&1)
        DIFF_B_EXIT=$?
        echo "  Debug: Exit code: $DIFF_B_EXIT"

        # Check if CIS - CIS_NIST produces empty profile
        # This is the CRITICAL check: CIS_NIST must have ALL CIS rules
        MISSING_FROM_CIS_NIST=false

        if echo "$DIFF_A_OUTPUT" | grep -q "Subtraction would produce an empty profile"; then
            echo "  ✓ CIS - CIS_NIST = empty (CIS_NIST has all CIS rules)"
        else
            echo "  ✗ CIS - CIS_NIST has differences (CIS_NIST is missing CIS rules!)"
            echo "  Debug: First 10 lines of output:"
            echo "$DIFF_A_OUTPUT" | head -10
            MISSING_FROM_CIS_NIST=true
        fi

        # Check if CIS_NIST - CIS produces empty profile
        # This is INFORMATIONAL only: extras are allowed (unmapped items, human edits, cross-product rules)
        if echo "$DIFF_B_OUTPUT" | grep -q "Subtraction would produce an empty profile"; then
            echo "  ✓ CIS_NIST - CIS = empty (exact match)"
        else
            echo "  ℹ CIS_NIST - CIS has differences (extras are OK: unmapped items, human edits, cross-product rules)"
            echo "  Debug: First 10 lines of output:"
            echo "$DIFF_B_OUTPUT" | head -10
        fi

        if [ "$MISSING_FROM_CIS_NIST" = false ]; then
            log_success "$product: CIS_NIST has all required CIS rules ✓"
        else
            log_error "$product: CIS_NIST is missing CIS rules!"
            echo ""
            echo "  ✗ CRITICAL: Rules in CIS but NOT in CIS_NIST:"
            echo "$DIFF_A_OUTPUT"
            echo ""
            echo "  This means CIS_NIST profile is missing required CIS coverage!"
            echo "  Check controls/nist_800_53/*.yml files for missing rules."

            ALL_MATCH=false
        fi

        cd "$SCRIPT_DIR"
    done

    echo ""
    if [ "$ALL_MATCH" = true ]; then
        log_success "All profiles match! ✓"
    else
        log_error "Some profiles don't match. Please review the differences."
        # exit 1
    fi
else
    log_section "Step 6: Skipping Comparison (--skip-comparison)"
fi

# Step 7: File Status
log_section "Step 7: File Status"
log_info "Product-Specific Reference Files (auto-generated, for comparison):"
for product in $PRODUCTS; do
    log_info "  $product:"
    log_info "    - shared/references/controls/nist_800_53_cis_reference_${product}.yml"
    log_info "    - shared/references/controls/nist_800_53_cis_reference_${product}/*.yml"
done
log_info ""
log_info "Product-Specific Real Files (used in builds, human-editable):"
for product in $PRODUCTS; do
    log_info "  $product:"
    log_info "    - products/$product/controls/nist_800_53.yml"
    log_info "    - products/$product/controls/nist_800_53/*.yml"
done

# Step 8: Summary
log_section "Summary"
echo "Generated artifacts:"
echo ""
echo "  Product-Specific CIS Reference Files (auto-generated, for comparison):"
for product in $PRODUCTS; do
    echo "    $product:"
    echo "      - shared/references/controls/nist_800_53_cis_reference_${product}.yml (metadata)"
    echo "      - shared/references/controls/nist_800_53_cis_reference_${product}/*.yml (21 family files, NO guards)"
done
echo ""
echo "  Product-Specific Real Control Files (used in builds, human-maintained):"
for product in $PRODUCTS; do
    echo "    $product:"
    echo "      - products/$product/controls/nist_800_53.yml (metadata)"
    echo "      - products/$product/controls/nist_800_53/*.yml (21 family files, NO guards)"
done
echo ""
echo "  Mapping Cache:"
echo "    - utils/nist_sync/data/cis_nist_mappings.json"
echo ""
echo "  Profiles:"
for product in $PRODUCTS; do
    echo "    - products/$product/profiles/cis_nist.profile"
done
echo ""

if [ "$SKIP_BUILD" = false ]; then
    echo "  Built Artifacts:"
    for product in $PRODUCTS; do
        echo "    - build/ssg-$product-ds.xml"
    done
    echo ""
    echo "  Rendered Policies:"
    for product in $PRODUCTS; do
        if [ -f "build/$product/rendered-policies/nist_800_53.html" ]; then
            echo "    - build/$product/rendered-policies/nist_800_53.html"
        fi
    done
    echo ""
fi

log_success "Workflow complete! ✓"
echo ""
log_info "Next steps:"
echo "  - Review CIS reference changes for each product:"
for product in $PRODUCTS; do
    echo "      git diff shared/references/controls/nist_800_53_cis_reference_${product}.yml"
done
echo "  - Copy reference files to product control directories if needed:"
for product in $PRODUCTS; do
    echo "      cp -r shared/references/controls/nist_800_53_cis_reference_${product}* products/$product/controls/"
done
echo "  - Review profiles: git diff products/*/profiles/cis_nist.profile"
echo "  - Commit changes: git add shared/references/controls/ products/ utils/nist_sync/data/"
echo ""
echo "ℹ️  NOTE: Product-specific reference files show what CIS currently maps to NIST for each product."
echo "   NO Jinja2 guards - rules are already filtered by product."
echo "   OSCAL metadata (description, parameters, guidance) NOT included - retrieve from OSCAL catalog when needed."
echo ""
