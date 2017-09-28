# platform = multi_platform_rhel
. /usr/share/scap-security-guide/remediation_functions

replace_or_append '/etc/yum.conf' '^gpgcheck' '1' '@CCENUM@'
