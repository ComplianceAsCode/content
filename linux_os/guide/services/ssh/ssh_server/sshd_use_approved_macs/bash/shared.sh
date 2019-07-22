# platform = multi_platform_wrlinux,Red Hat Enterprise Linux 7,Oracle Linux 7,multi_platform_rhv
. /usr/share/scap-security-guide/remediation_functions
include_lineinfile
populate sshd_approved_macs

sshd_config_set "MACs" "$sshd_approved_macs"
