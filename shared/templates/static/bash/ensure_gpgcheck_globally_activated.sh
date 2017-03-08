# platform = multi_platform_rhel
replace_or_append '/etc/yum.conf' '^gpgcheck' '1' '$CCENUM'
