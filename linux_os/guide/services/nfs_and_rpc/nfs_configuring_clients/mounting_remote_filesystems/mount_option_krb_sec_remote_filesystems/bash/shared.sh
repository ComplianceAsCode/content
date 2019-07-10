#!/bin/bash
# platform = multi_platform_wrlinux,multi_platform_all

. /usr/share/scap-security-guide/remediation_functions
include_mount_options_functions

ensure_mount_option_for_vfstype "nfs[4]?" "sec=krb5:krb5i:krb5p"
