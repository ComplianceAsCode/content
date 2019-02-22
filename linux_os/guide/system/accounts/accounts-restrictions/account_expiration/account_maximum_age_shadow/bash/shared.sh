# platform = multi_platform_sle

. /usr/share/scap-security-guide/remediation_functions
populate var_accounts_maximum_age_login_defs

for user in $( awk -F':' '$5 > '"$var_accounts_maximum_age_login_defs"' { print $1 }' < /etc/shadow ) ; do
    passwd -x "$var_accounts_maximum_age_login_defs" "$user"
done
