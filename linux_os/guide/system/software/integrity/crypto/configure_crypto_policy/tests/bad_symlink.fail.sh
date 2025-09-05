#!/bin/bash
# platform = multi_platform_fedora,Red Hat Enterprise Linux 8
# profiles = xccdf_org.ssgproject.content_profile_ospp, xccdf_org.ssgproject.content_profile_standard

CRYPTO_POLICY_LIB_FILE="/etc/crypto-policies/back-ends/gnutls.config"
SYMLINK_TO="/tmp/some_file"
rm -f $CRYPTO_POLICY_LIB_FILE
touch $SYMLINK_TO
ln -s $SYMLINK_TO $CRYPTO_POLICY_LIB_FILE
