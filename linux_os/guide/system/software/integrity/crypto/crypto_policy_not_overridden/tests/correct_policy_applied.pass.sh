#!/bin/bash
# platform = multi_platform_rhel,multi_platform_fedora,Oracle Linux 8,Oracle Linux 9
# packages = crypto-policies-scripts,openscap-engine-sce

# Ensure the crypto policy is set and fully applied so --check passes
update-crypto-policies --set DEFAULT
