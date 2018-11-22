#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_standard

CRYPTO_POLICY_LIB_FILE="/etc/crypto-policies/back-ends/gnutls.config"
SYMLINK_TO="/tmp/some_file"
rm -f $CRYPTO_POLICY_LIB_FILE
touch $SYMLINK_TO
ln -s $SYMLINK_TO $CRYPTO_POLICY_LIB_FILE
