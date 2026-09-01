#!/bin/bash
# platform = multi_platform_rhel,multi_platform_fedora,Oracle Linux 8,Oracle Linux 9
# packages = crypto-policies-scripts,openscap-engine-sce

# Start from a clean, fully applied state
update-crypto-policies --set DEFAULT

# Replace the gnutls backend symlink with a modified regular file to simulate
# a manual per-application override of the system crypto policy.
# update-crypto-policies --check regenerates the policy and byte-compares it
# against the back-ends directory, so any content change causes a failure.
BACKEND_FILE="/etc/crypto-policies/back-ends/gnutls.config"
content=$(cat "${BACKEND_FILE}")
rm -f "${BACKEND_FILE}"
printf '%s\n# manual override\n' "${content}" > "${BACKEND_FILE}"
