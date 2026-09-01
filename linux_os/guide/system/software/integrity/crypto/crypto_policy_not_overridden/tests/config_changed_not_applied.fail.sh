#!/bin/bash
# platform = multi_platform_rhel,multi_platform_fedora,Oracle Linux 8,Oracle Linux 9
# packages = crypto-policies-scripts,openscap-engine-sce

# Start from a clean, fully applied DEFAULT state
update-crypto-policies --set DEFAULT

# Change the config to a different policy without running update-crypto-policies.
# --check regenerates the policy from /etc/crypto-policies/config (now LEGACY)
# and compares it against the back-ends still generated for DEFAULT, so they
# will not match.
echo "LEGACY" > /etc/crypto-policies/config
