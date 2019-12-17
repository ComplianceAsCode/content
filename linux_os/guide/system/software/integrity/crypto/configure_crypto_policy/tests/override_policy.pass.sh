#!/bin/bash
# platform = multi_platform_fedora,Red Hat Enterprise Linux 8
# profiles = xccdf_org.ssgproject.content_profile_ospp

#using openssh server as example
CRYPTO_POLICY_OVERRIDE_FILE="/etc/crypto-policies/local.d/opensshserver-test.config"

echo "" > "$CRYPTO_POLICY_OVERRIDE_FILE"
echo "CRYPTO_POLICY=" >> "$CRYPTO_POLICY_OVERRIDE_FILE"

update-crypto-policies --set FIPS:OSPP
