#!/bin/bash
# Local CIS-NIST Workflow Test
# Simulates the GitHub Actions workflow locally

set -e

echo "╔════════════════════════════════════════════════════════════╗"
echo "║  Local CIS-NIST Workflow Test                              ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

PRODUCTS="rhel8 rhel9 rhel10"

# Step 1: Run the complete workflow
echo "Step 1: Running CIS-NIST workflow..."
cd utils/nist_sync
./generate_cis_nist_workflow.sh --products "$PRODUCTS"
cd ../..

# Step 2: Verify control files exist
echo ""
echo "Step 2: Verifying control files..."
for product in $PRODUCTS; do
    echo ""
    echo "Product: $product"
    echo "✓ Reference files (for comparison):"
    ls -lh "shared/references/controls/nist_800_53_cis_reference_${product}.yml"
    echo "  Family files:"
    ls -1 "shared/references/controls/nist_800_53_cis_reference_${product}/"*.yml | head -5
    echo "  ... (21 total families)"
    echo ""
    echo "✓ Product control files (used in builds):"
    ls -lh "products/${product}/controls/nist_800_53.yml"
    echo "  Family files:"
    ls -1 "products/${product}/controls/nist_800_53/"*.yml | head -5
    echo "  ... (21 total families)"
done

# Step 3: Verify profiles
echo ""
echo "Step 3: Verifying profiles..."
for product in $PRODUCTS; do
    if [ -f "products/$product/profiles/cis_nist.profile" ]; then
        echo "✓ products/$product/profiles/cis_nist.profile"
        # Show what it selects
        grep "nist_800_53:all" "products/$product/profiles/cis_nist.profile" && echo "  → Uses nist_800_53:all ✓"
    fi
done

# Step 4: Check datastreams
echo ""
echo "Step 4: Checking built datastreams..."
for product in $PRODUCTS; do
    if [ -f "build/ssg-$product-ds.xml" ]; then
        SIZE=$(du -h "build/ssg-$product-ds.xml" | cut -f1)
        echo "✓ build/ssg-$product-ds.xml ($SIZE)"

        # Count profiles in datastream
        PROFILE_COUNT=$(grep -c 'Profile id="xccdf_org.ssgproject.content_profile_' "build/ssg-$product-ds.xml" || true)
        echo "  → Contains $PROFILE_COUNT profiles"

        # Check if cis_nist profile exists
        if grep -q 'Profile id="xccdf_org.ssgproject.content_profile_cis_nist"' "build/ssg-$product-ds.xml"; then
            echo "  → cis_nist profile: ✓"
        else
            echo "  → cis_nist profile: NOT FOUND"
        fi
    else
        echo "✗ build/ssg-$product-ds.xml NOT FOUND"
    fi
done

# Step 5: Check rendered policies
echo ""
echo "Step 5: Checking rendered policies..."
for product in $PRODUCTS; do
    if [ -f "build/$product/rendered-policies/nist_800_53.html" ]; then
        SIZE=$(du -h "build/$product/rendered-policies/nist_800_53.html" | cut -f1)
        echo "✓ build/$product/rendered-policies/nist_800_53.html ($SIZE)"
    fi
done

# Step 6: Profile comparison results
echo ""
echo "Step 6: Profile comparison summary..."
echo "(Results from workflow run above)"

# Step 7: Show control file stats
echo ""
echo "Step 7: Control file statistics..."
for product in $PRODUCTS; do
    echo ""
    echo "Product: $product"
    echo "  Reference files (nist_800_53_cis_reference_${product}):"
    TOTAL_CONTROLS=0
    TOTAL_RULES=0
    for family in "shared/references/controls/nist_800_53_cis_reference_${product}/"*.yml; do
        CONTROLS=$(grep -c '^  - id:' "$family" || true)
        RULES=$(grep -c '^      -' "$family" || true)
        TOTAL_CONTROLS=$((TOTAL_CONTROLS + CONTROLS))
        TOTAL_RULES=$((TOTAL_RULES + RULES))
    done
    echo "    Total controls: $TOTAL_CONTROLS"
    echo "    Total rule selections: $TOTAL_RULES"

    echo "  Product control files (products/${product}/controls/nist_800_53):"
    TOTAL_CONTROLS=0
    TOTAL_RULES=0
    for family in "products/${product}/controls/nist_800_53/"*.yml; do
        CONTROLS=$(grep -c '^  - id:' "$family" || true)
        RULES=$(grep -c '^      -' "$family" || true)
        TOTAL_CONTROLS=$((TOTAL_CONTROLS + CONTROLS))
        TOTAL_RULES=$((TOTAL_RULES + RULES))
    done
    echo "    Total controls: $TOTAL_CONTROLS"
    echo "    Total rule selections: $TOTAL_RULES"
done

echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║  Test Complete ✓                                           ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""
echo "Next steps:"
echo "  - Review any diff between reference and product control files:"
for product in $PRODUCTS; do
    echo "    diff -ur shared/references/controls/nist_800_53_cis_reference_${product}/ \\"
    echo "             products/${product}/controls/nist_800_53/"
done
echo "  - Edit product-specific control files if needed"
echo "  - Run oscap to scan with cis_nist profile"
echo ""
