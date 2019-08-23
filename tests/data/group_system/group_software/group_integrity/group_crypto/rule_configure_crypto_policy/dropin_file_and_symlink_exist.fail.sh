#!/bin/bash
# platform = multi_platform_fedora,Red Hat Enterprise Linux 8
# profiles = xccdf_org.ssgproject.content_profile_ospp, xccdf_org.ssgproject.content_profile_standard

# using example of opensshserver
DROPIN_FILE="/etc/crypto-policies/local.d/opensshserver-test.config"

update-crypto-policies --set "FIPS"

echo "testing testing" > "$DROPIN_FILE"
