#!/bin/bash
# Test script: build Ansible roles then generate an Ansible collection.
#
# Usage: utils/test_ansible_collection.sh [OUTPUT_DIR] [PRODUCT]
#   OUTPUT_DIR  destination for the generated collection (default: /tmp/test-collection)
#   PRODUCT     ComplianceAsCode product to build roles for (default: rhel9)
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SSG_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
OUTPUT_DIR="${1:-/tmp/test-collection}"
PRODUCT="${2:-rhel9}"
BUILD_DIR="${SSG_ROOT}/build"

echo "=== Step 1: Configure and build ${PRODUCT} with Ansible roles ==="
cd "${SSG_ROOT}"

# Use build_product only for the cmake configuration step; the --datastream flag
# limits what gets built so we follow up with an explicit roles target below.
ADDITIONAL_CMAKE_OPTIONS="-DSSG_ANSIBLE_ROLES_ENABLED=TRUE" \
    ./build_product "${PRODUCT}" --datastream

echo ""
echo "=== Step 2: Build Ansible roles target ==="
cd "${BUILD_DIR}"
ninja "generate-$(echo "${PRODUCT}" | tr '[:upper:]' '[:lower:]')-ansible-roles"
cd "${SSG_ROOT}"

echo ""
echo "=== Step 3: Generate Ansible collection ==="
rm -rf "${OUTPUT_DIR}"
python3 utils/ansible_roles_to_collection.py \
    --roles-dir "${BUILD_DIR}/ansible_roles" \
    --output-dir "${OUTPUT_DIR}" \
    --build

echo ""
echo "=== Step 4: Verify output ==="
COLLECTION_DIR="${OUTPUT_DIR}/ansible_collections/redhat/rhel_hardening_roles"

echo "--- Vendored modules ---"
ls "${COLLECTION_DIR}/plugins/modules/"

echo ""
echo "--- FQCN rewrite check ---"
if grep -rq "community\.general\.\|ansible\.posix\." "${COLLECTION_DIR}/roles/" 2>/dev/null; then
    echo "FAIL: unrewritten FQCNs found:"
    grep -rn "community\.general\.\|ansible\.posix\." "${COLLECTION_DIR}/roles/"
else
    echo "OK: no unrewritten FQCNs in roles"
fi

echo ""
echo "--- galaxy.yml ---"
python3 -c "
import yaml
d = yaml.safe_load(open('${COLLECTION_DIR}/galaxy.yml'))
print('  namespace:', d['namespace'])
print('  name:     ', d['name'])
print('  version:  ', d['version'])
"

echo ""
echo "=== Done ==="
echo "Artifact: $(ls "${OUTPUT_DIR}"/redhat-rhel_hardening_roles-*.tar.gz 2>/dev/null || echo 'not found')"
