#!/bin/bash
# platform = multi_platform_sle,multi_platform_slmicro,multi_platform_ubuntu
# packages = libpam-pkcs11

echo "auth	[success=1 default=ignore]	pam_unix.so nullok" > /etc/pam.d/common-auth
