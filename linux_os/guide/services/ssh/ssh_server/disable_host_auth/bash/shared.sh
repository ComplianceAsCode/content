# platform = multi_platform_all
. /usr/share/scap-security-guide/remediation_functions
include_lineinfile

sshd_config_set "HostbasedAuthentication" "no"
