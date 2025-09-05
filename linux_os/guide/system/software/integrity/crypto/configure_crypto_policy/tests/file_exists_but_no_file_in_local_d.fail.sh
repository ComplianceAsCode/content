#!/bin/bash
# platform = multi_platform_fedora,Red Hat Enterprise Linux 8
# profiles = xccdf_org.ssgproject.content_profile_ospp

#using example of openssh server
CRYPTO_POLICY_FILE="/etc/crypto-policies/back-ends/opensshserver.config"

update-crypto-policies --set "FIPS"

rm -f /etc/crypto-policies/local.d/opensshserver-*.config
rm -f "$CRYPTO_POLICY_FILE"

echo "pretend that we overide the crrypto policy but no related file is in /etc/crypto-policies/local.d, smart, right?" > "$CRYPTO_POLICY_FILE"
