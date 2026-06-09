#!/usr/bin/env bash
# End-to-end complyctl test for NIST 800-53 Gemara content.
#
# Runs complyctl generate + scan inside a UBI9 container so the OpenSCAP
# provider auto-detects RHEL 9 and uses ssg-rhel9-ds.xml. The host's SCAP
# data stream is mounted into the container to avoid subscription requirements.
#
# Architecture:
#   Host (Fedora):  OCI registry + bundle generator + complyctl binary
#   Container (UBI9): complyctl generate + scan
#     /etc/os-release → "rhel9" → provider uses ssg-rhel9-ds.xml
#     Profile: stig (exists in the installed RHEL9 data stream)
#     complyctl tailors stig → selects only our 22 NIST assessment-plan rules
#
# Prerequisites:
#   - podman (or docker, set CONTAINER_TOOL=docker)
#   - oras CLI on PATH (https://oras.land)
#   - complyctl v1.0.0-alpha.0 binary at /tmp/complyctl
#   - complyctl-provider-openscap at ~/.complytime/providers/
#   - Local OCI registry:
#       podman run -d -p 5500:5000 --name gemara-registry docker.io/library/registry:2
#   - /usr/share/xml/scap/ssg/content/ssg-rhel9-ds.xml on the host
#     (install with: dnf install scap-security-guide or build with ./build_product rhel9 -d)
#
# Usage:
#   ./utils/nist_sync/test_complyctl_e2e.sh
#   BASELINE=high ./utils/nist_sync/test_complyctl_e2e.sh
#   BASE_PROFILE=cis ./utils/nist_sync/test_complyctl_e2e.sh

set -euo pipefail

PRODUCT="${PRODUCT:-rhel9}"
BASELINE="${BASELINE:-moderate}"
BASE_PROFILE="${BASE_PROFILE:-stig}"  # XCCDF base profile for tailoring
CONTAINER_TOOL="${CONTAINER_TOOL:-podman}"
REGISTRY_HOST="${REGISTRY_HOST:-127.0.0.1:5500}"
COMPLYCTL_BIN="${COMPLYCTL_BIN:-/tmp/complyctl}"
PROVIDER_BIN="${PROVIDER_BIN:-$HOME/.complytime/providers/complyctl-provider-openscap}"
SCAP_CONTENT_DIR="${SCAP_CONTENT_DIR:-/usr/share/xml/scap/ssg/content}"

# UBI9 — correct /etc/os-release for RHEL9 OS detection
UBI9_IMAGE="registry.access.redhat.com/ubi9/ubi:latest"

# Registry port (stripped from host:port)
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
[[ -x "$COMPLYCTL_BIN" ]] || die "complyctl binary not found at $COMPLYCTL_BIN"
[[ -f "$PROVIDER_BIN" ]] || die "complyctl-provider-openscap not found at $PROVIDER_BIN"
[[ -f "${SCAP_CONTENT_DIR}/ssg-rhel9-ds.xml" ]] || \
  die "ssg-rhel9-ds.xml not found in ${SCAP_CONTENT_DIR}. Install scap-security-guide or build with ./build_product rhel9 -d"
command -v oras >/dev/null 2>&1 || die "'oras' not on PATH. Install from https://oras.land"
command -v "$CONTAINER_TOOL" >/dev/null 2>&1 || die "'$CONTAINER_TOOL' not found"

log "=== NIST 800-53 Gemara E2E Test ==="
log "  Product:      ${PRODUCT}"
log "  Baseline:     ${BASELINE}"
log "  Base profile: ${BASE_PROFILE} (from ssg-rhel9-ds.xml)"
log "  Registry:     ${REGISTRY_HOST}"
log "  Container:    UBI9"

# -------------------------------------------------------------------------
# Step 1: Generate Gemara artifacts
# -------------------------------------------------------------------------
log ""
log "Step 1: Generating Gemara artifacts for ${PRODUCT}..."
(cd "$REPO_ROOT" && PYTHONPATH=. python3 utils/nist_sync/export_to_gemara.py \
  --products "$PRODUCT" \
  --output-dir build/gemara \
  --data-dir utils/nist_sync/data)

# -------------------------------------------------------------------------
# Step 2: Generate complyctl Policy and push bundle
# -------------------------------------------------------------------------
log ""
log "Step 2: Building complyctl bundle (${BASELINE} baseline) and pushing to ${REGISTRY_HOST}..."
(cd "$REPO_ROOT" && PYTHONPATH=. python3 utils/nist_sync/generate_complyctl_bundle.py \
  --product "$PRODUCT" \
  --gemara-dir build/gemara \
  --output-dir "$BUNDLE_DIR" \
  --baseline "$BASELINE" \
  --registry "$REGISTRY_HOST" \
  --push)

RULE_COUNT=$(grep -c "requirement-id:" "${BUNDLE_DIR}/${PRODUCT}_policy.yaml" || echo "?")
log "  Pushed ${RULE_COUNT} assessment plans (XCCDF rule IDs)"

# -------------------------------------------------------------------------
# Step 3: Create container workspace
# -------------------------------------------------------------------------
log ""
log "Step 3: Preparing container workspace..."
WORKSPACE="$(mktemp -d)/complyctl-ws"
mkdir -p "${WORKSPACE}/providers"

# The container reaches the host registry via host.containers.internal
cat > "${WORKSPACE}/complytime.yaml" << EOF
# complyctl v1.0.0-alpha.0 workspace — generated for ${PRODUCT} ${BASELINE} test
policies:
  - url: http://host.containers.internal:${REGISTRY_PORT}/nist-800-53-rev5-${PRODUCT}
    id: nist-800-53-rev5-${PRODUCT}

targets:
  - id: local
    policies:
      - nist-800-53-rev5-${PRODUCT}
    variables:
      profile: ${BASE_PROFILE}
EOF

cp "$PROVIDER_BIN" "${WORKSPACE}/providers/complyctl-provider-openscap"
chmod +x "${WORKSPACE}/providers/complyctl-provider-openscap"
log "  Workspace: ${WORKSPACE}"

# -------------------------------------------------------------------------
# Step 4: Run in UBI9 container
# -------------------------------------------------------------------------
log ""
log "Step 4: Running complyctl in UBI9 container..."
log "  Mounts: complyctl binary + workspace + SCAP content dir"
log "  (First pull of UBI9 image may take a moment)"
log ""

$CONTAINER_TOOL run --rm \
  --name "nist-800-53-complyctl-test" \
  --add-host "host.containers.internal:host-gateway" \
  --security-opt label=disable \
  -v "${COMPLYCTL_BIN}:/usr/local/bin/complyctl:ro" \
  -v "${WORKSPACE}:/root/.complytime" \
  -v "${SCAP_CONTENT_DIR}:/usr/share/xml/scap/ssg/content:ro" \
  -v "${RESULTS_DIR}:/results" \
  "${UBI9_IMAGE}" \
  bash -c "
set -euo pipefail
echo '--- OS detection ---'
cat /etc/os-release | grep '^ID\|^VERSION_ID\|^PRETTY'
echo ''

echo '--- Installing openscap-scanner ---'
dnf install -y openscap-scanner 2>&1 | tail -2
echo ''

echo '--- complyctl version ---'
complyctl version
echo ''

echo '--- SCAP data stream check ---'
ls /usr/share/xml/scap/ssg/content/ssg-rhel9-ds.xml
echo ''

echo '--- complyctl get (pull bundle) ---'
cd /root/.complytime
complyctl get
echo ''

echo '--- complyctl generate (build XCCDF tailoring) ---'
complyctl generate --policy-id nist-800-53-rev5-${PRODUCT}
echo ''

echo '--- complyctl scan ---'
complyctl scan 2>&1 || true   # scan may have findings — that is expected

echo ''
echo '--- Results ---'
ls -la /results/ 2>/dev/null || echo '(no output files yet)'
"

log ""
log "Results written to: ${RESULTS_DIR}/"
ls -la "${RESULTS_DIR}/" 2>/dev/null || log "(no result files — check scan output above)"
log ""
log "=== E2E test complete ==="
log ""
log "Traceability: map scan results back to NIST controls via:"
log "  build/gemara/${PRODUCT}/rules_mapping.yaml"
log "  (rule PASS → check which NIST controls it satisfies)"
