# platform = multi_platform_wrlinux,multi_platform_rhel,multi_platform_ol,multi_platform_rhv
. /usr/share/scap-security-guide/remediation_functions
populate var_accounts_minimum_age_login_defs

for SYS_USER in $(awk -F: '$4 < 1 {print $1}' /etc/shadow); do
	passwd -n $var_accounts_minimum_age_login_defs ${SYS_USER} &>/dev/null
done
