# platform = multi_platform_rhel, multi_platform_ol, multi_platform_fedora
. /usr/share/scap-security-guide/remediation_functions

replace_or_append '/etc/yum.conf' '^gpgcheck' '1' '@CCENUM@'
