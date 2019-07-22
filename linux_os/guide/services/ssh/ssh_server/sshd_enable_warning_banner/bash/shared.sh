# platform = multi_platform_wrlinux,multi_platform_all
. /usr/share/scap-security-guide/remediation_functions
include_lineinfile

sshd_config_set "Banner" "/etc/issue"
