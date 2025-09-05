#!/bin/bash
# platform = Oracle Linux 8,Oracle Linux 9,Red Hat Enterprise Linux 8,Red Hat Enterprise Linux 9
# profiles = xccdf_org.ssgproject.content_profile_ospp
# packages = crypto-policies-scripts

update-crypto-policies --set "FIPS:OSPP"

CRYPTO_POLICY_LIB_FILE="/etc/crypto-policies/back-ends/nss.config"
SYMLINK_TO_FOLDER="/usr/share/crypto-policies/FIPS/"
SYMLINK_TO_FILE="nss.txt"
rm -f $CRYPTO_POLICY_LIB_FILE
mkdir -p $SYMLINK_TO_FOLDER
cp $SYMLINK_TO_FOLDER$SYMLINK_TO_FILE $CRYPTO_POLICY_LIB_FILE
