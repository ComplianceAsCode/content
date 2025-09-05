#!/bin/bash
# platform = Red Hat Enterprise Linux 8
# profiles = xccdf_org.ssgproject.content_profile_ospp

update-crypto-policies --set "FIPS:OSPP"

CRYPTO_POLICY_LIB_FILE="/etc/crypto-policies/back-ends/nss.config"
SYMLINK_TO_FOLDER="/usr/share/crypto-policies/FIPS/"
SYMLINK_TO_FILE="nss.txt"
rm -f $CRYPTO_POLICY_LIB_FILE
mkdir -p $SYMLINK_TO_FOLDER
ln -s $SYMLINK_TO_FOLDER$SYMLINK_TO_FILE $CRYPTO_POLICY_LIB_FILE
