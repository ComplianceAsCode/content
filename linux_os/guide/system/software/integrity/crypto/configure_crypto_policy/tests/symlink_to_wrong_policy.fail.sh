#!/bin/bash
# platform = multi_platform_fedora,Red Hat Enterprise Linux 8
# profiles = xccdf_org.ssgproject.content_profile_ospp, xccdf_org.ssgproject.content_profile_standard

CRYPTO_POLICY_LIB_FILE="/etc/crypto-policies/back-ends/openssh.config"
SYMLINK_TO_FOLDER="/usr/share/crypto-policies/LEGACY/"
SYMLINK_TO_FILE="openssh.txt"
rm -f $CRYPTO_POLICY_LIB_FILE
mkdir -p $SYMLINK_TO_FOLDER
touch $SYMLINK_TO_FOLDER$SYMLINK_TO_FILE
ln -s $SYMLINK_TO_FOLDER$SYMLINK_TO_FILE $CRYPTO_POLICY_LIB_FILE
