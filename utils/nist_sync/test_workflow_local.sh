#!/bin/bash
# Local CIS-NIST Workflow Test
# Simulates the GitHub Actions workflow locally

set -e

echo "╔════════════════════════════════════════════════════════════╗"
echo "║  Local CIS-NIST Workflow Test                              ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

PRODUCTS="rhel8 rhel9 rhel10"

# Recursively count controls (base + nested enhancements) and rule
# selections across all family files in a directory. Uses ruamel.yaml
# instead of indentation-sensitive grep since enhancements are nested
# under their base control at varying indentation depths.
count_stats() {
    python3 - "$1" <<'PYEOF'
import glob
import sys

import ruamel.yaml

yaml = ruamel.yaml.YAML(typ="safe")


def count(controls):
    controls_n = 0
    rules_n = 0
    for control in controls:
        controls_n += 1
        rules_n += len(control.get("rules") or [])
        sub_controls, sub_rules = count(control.get("controls") or [])
        controls_n += sub_controls
        rules_n += sub_rules
    return controls_n, rules_n


total_controls = 0
total_rules = 0
for path in sorted(glob.glob(f"{sys.argv[1]}/*.yml")):
    data = yaml.load(open(path)) or {}
    controls, rules = count(data.get("controls") or [])
    total_controls += controls
    total_rules += rules

print(f"{total_controls} {total_rules}")
PYEOF
}

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
    read -r TOTAL_CONTROLS TOTAL_RULES < <(count_stats "shared/references/controls/nist_800_53_cis_reference_${product}")
    echo "    Total controls: $TOTAL_CONTROLS"
    echo "    Total rule selections: $TOTAL_RULES"

    echo "  Product control files (products/${product}/controls/nist_800_53):"
    read -r TOTAL_CONTROLS TOTAL_RULES < <(count_stats "products/${product}/controls/nist_800_53")
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
