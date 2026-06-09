#!/usr/bin/env bash
# End-to-end complyctl test for NIST 800-53 Gemara content.
#
# Architecture (discovered through reverse-engineering):
#   - complyctl v1.0.0-alpha.0 (go-gemara v0.0.1) uses assessment-plan 'id'
#     (not 'requirement-id') as AssessmentConfiguration.RequirementID
#   - The OpenSCAP provider strips 'xccdf_org.ssgproject.content_rule_' from
#     data stream rule IDs and compares against RequirementID — so plan IDs
#     must be short CaC rule names (e.g. 'accounts_tmout')
#   - The provider reads ID/ID_LIKE from /etc/os-release to auto-detect the
#     data stream (ID_LIKE takes precedence on UBI9, giving ssg-fedora-ds.xml)
#   - The 'datastream' target variable bypasses OS auto-detection entirely
#   - The 'profile' target variable is the short XCCDF profile name
#
# Usage:
#   ./utils/nist_sync/test_complyctl_e2e.sh
#   BASELINE=high ./utils/nist_sync/test_complyctl_e2e.sh
#   BASE_PROFILE=cis_server_l1 ./utils/nist_sync/test_complyctl_e2e.sh
#
# Prerequisites:
#   - podman (or set CONTAINER_TOOL=docker)
#   - oras CLI on PATH (https://oras.land)
#   - complyctl v1.0.0-alpha.0 at /tmp/complyctl
#     Download: https://github.com/complytime/complyctl/releases/download/v1.0.0-alpha.0/complyctl_linux_x86_64.tar.gz
#   - complyctl-provider-openscap at ~/.complytime/providers/
#   - Local OCI registry:
#       podman run -d -p 5500:5000 --name gemara-registry docker.io/library/registry:2
#   - ssg-rhel9-ds.xml in /usr/share/xml/scap/ssg/content/ (from scap-security-guide)

set -euo pipefail

PRODUCT="${PRODUCT:-rhel9}"
BASELINE="${BASELINE:-moderate}"
BASE_PROFILE="${BASE_PROFILE:-cis}"
CONTAINER_TOOL="${CONTAINER_TOOL:-podman}"
REGISTRY_HOST="${REGISTRY_HOST:-127.0.0.1:5500}"
COMPLYCTL_BIN="${COMPLYCTL_BIN:-/tmp/complyctl}"
PROVIDER_BIN="${PROVIDER_BIN:-$HOME/.complytime/providers/complyctl-provider-openscap}"
SCAP_DS="/usr/share/xml/scap/ssg/content/ssg-${PRODUCT}-ds.xml"

UBI9_IMAGE="registry.access.redhat.com/ubi9/ubi:latest"
REGISTRY_PORT="${REGISTRY_HOST##*:}"

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
BUNDLE_DIR="${REPO_ROOT}/build/gemara-bundle/${PRODUCT}"
RESULTS_DIR="${REPO_ROOT}/build/complyctl-results/${PRODUCT}"
mkdir -p "$BUNDLE_DIR" "$RESULTS_DIR"

die() { echo "ERROR: $*" >&2; exit 1; }
log() { echo "[$(date +%H:%M:%S)] $*"; }

# -------------------------------------------------------------------------
# Preflight checks
# -------------------------------------------------------------------------
[[ -x "$COMPLYCTL_BIN" ]] || die "complyctl not found at $COMPLYCTL_BIN. Download from: https://github.com/complytime/complyctl/releases/download/v1.0.0-alpha.0/complyctl_linux_x86_64.tar.gz"
[[ -f "$PROVIDER_BIN" ]] || die "complyctl-provider-openscap not found at $PROVIDER_BIN"
[[ -f "$SCAP_DS" ]] || die "$SCAP_DS not found. Install scap-security-guide or run: dnf install scap-security-guide"
command -v oras >/dev/null 2>&1 || die "'oras' not on PATH. Install from https://oras.land"
command -v "$CONTAINER_TOOL" >/dev/null 2>&1 || die "'$CONTAINER_TOOL' not found"

log "=== NIST 800-53 Gemara E2E Test ==="
log "  Product:      ${PRODUCT}"
log "  Baseline:     ${BASELINE} (${BASE_PROFILE} as XCCDF tailoring base)"
log "  Registry:     ${REGISTRY_HOST}"
log "  Container:    UBI9 (openscap provider uses ssg-${PRODUCT}-ds.xml)"

# -------------------------------------------------------------------------
# Step 1: Generate Gemara artifacts
# -------------------------------------------------------------------------
log ""
log "Step 1: Generating Gemara artifacts..."
(cd "$REPO_ROOT" && PYTHONPATH=. python3 utils/nist_sync/export_to_gemara.py \
  --products "$PRODUCT" \
  --output-dir build/gemara \
  --data-dir utils/nist_sync/data)

# -------------------------------------------------------------------------
# Step 2: Build and push complyctl bundle
# -------------------------------------------------------------------------
log ""
log "Step 2: Building complyctl bundle and pushing to ${REGISTRY_HOST}..."
(cd "$REPO_ROOT" && PYTHONPATH=. python3 utils/nist_sync/generate_complyctl_bundle.py \
  --product "$PRODUCT" \
  --gemara-dir build/gemara \
  --output-dir "$BUNDLE_DIR" \
  --baseline "$BASELINE" \
  --base-profile "$BASE_PROFILE" \
  --registry "$REGISTRY_HOST" \
  --push)

RULE_COUNT=$(grep -c "requirement-id:" "${BUNDLE_DIR}/${PRODUCT}_policy.yaml" || echo "?")
log "  Bundle pushed: ${RULE_COUNT} assessment plans (short CaC rule names)"
log "  Key: plan.id == plan.requirement-id == short_rule_name (go-gemara v0.0.1 uses id)"

# -------------------------------------------------------------------------
# Step 3: Prepare container workspace
# -------------------------------------------------------------------------
log ""
log "Step 3: Preparing container workspace..."
WORKSPACE="$(mktemp -d)/complyctl-ws"
mkdir -p "${WORKSPACE}/providers"

# Use host.containers.internal to reach the host's registry from inside the container.
# The 'datastream' variable bypasses the provider's OS auto-detection (which would pick
# ssg-fedora-ds.xml on UBI9 due to ID_LIKE=fedora in /etc/os-release).
cat > "${WORKSPACE}/complytime.yaml" << EOF
policies:
  - url: http://host.containers.internal:${REGISTRY_PORT}/nist-800-53-rev5-${PRODUCT}
    id: nist-800-53-rev5-${PRODUCT}

targets:
  - id: local
    policies:
      - nist-800-53-rev5-${PRODUCT}
    variables:
      profile: ${BASE_PROFILE}
      datastream: ${SCAP_DS}
EOF

cp "$PROVIDER_BIN" "${WORKSPACE}/providers/complyctl-provider-openscap"
chmod +x "${WORKSPACE}/providers/complyctl-provider-openscap"
log "  Workspace: ${WORKSPACE}"

# -------------------------------------------------------------------------
# Step 4: Run complyctl get + generate + scan in UBI9 container
# -------------------------------------------------------------------------
log ""
log "Step 4: Running in UBI9 container (openscap installed from UBI repos)..."

$CONTAINER_TOOL run --rm \
  --privileged \
  --add-host "host.containers.internal:host-gateway" \
  -v "${COMPLYCTL_BIN}:/usr/local/bin/complyctl:ro" \
  -v "${WORKSPACE}:/root/.complytime" \
  -v "${SCAP_DS}:${SCAP_DS}:ro" \
  -v "${RESULTS_DIR}:/results" \
  "${UBI9_IMAGE}" \
  bash -c "
set -euo pipefail

echo '--- Installing openscap-scanner ---'
dnf install -y openscap-scanner 2>&1 | tail -2

echo ''
echo '--- complyctl get ---'
cd /root/.complytime
complyctl get

echo ''
echo '--- complyctl generate ---'
complyctl generate --policy-id nist-800-53-rev5-${PRODUCT}

echo ''
echo '--- complyctl scan ---'
complyctl scan --policy-id nist-800-53-rev5-${PRODUCT} 2>&1 || true

echo ''
echo '--- Copying results ---'
cp /root/.complytime/.complytime/openscap/results/arf.xml /results/ 2>/dev/null && echo 'Copied arf.xml' || true
cp /root/.complytime/.complytime/openscap/results/results.xml /results/ 2>/dev/null && echo 'Copied results.xml' || true
find /root/.complytime/.complytime/scan -name '*.yaml' 2>/dev/null | \
  while read f; do cp \"\$f\" /results/ && echo \"Copied \$(basename \$f)\"; done || true
"

log ""
log "=== Results ==="
ls -la "${RESULTS_DIR}/" 2>/dev/null || log "(no result files)"
log ""
log "Evaluation log written by complyctl maps results back to NIST controls via:"
log "  build/gemara/${PRODUCT}/rules_mapping.yaml"
log "  (rule PASS → which NIST controls it satisfies)"
log ""
log "=== E2E test complete ==="
