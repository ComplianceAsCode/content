# platform = multi_platform_rhel
. /usr/share/scap-security-guide/remediation_functions

replace_or_append '/etc/yum.conf' '^repo_gpgcheck' '1' '@CCENUM@'
