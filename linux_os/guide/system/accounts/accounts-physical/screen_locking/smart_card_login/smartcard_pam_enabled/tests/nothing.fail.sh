#!/bin/bash
# platform = multi_platform_ubuntu,multi_platform_sle
# packages = libpam-pkcs11

echo "auth	[success=1 default=ignore]	pam_unix.so nullok" > /etc/pam.d/common-auth
