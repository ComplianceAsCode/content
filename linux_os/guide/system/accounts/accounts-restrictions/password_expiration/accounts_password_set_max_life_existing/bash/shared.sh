# platform = multi_platform_wrlinux,multi_platform_rhel,multi_platform_ol,multi_platform_rhv
. /usr/share/scap-security-guide/remediation_functions
populate var_accounts_maximum_age_login_defs

for SYS_USER in $(awk -F: '$5 > 60 {print $1}' /etc/shadow); do
	passwd -x $var_accounts_maximum_age_login_defs ${SYS_USER} &>/dev/null
done
