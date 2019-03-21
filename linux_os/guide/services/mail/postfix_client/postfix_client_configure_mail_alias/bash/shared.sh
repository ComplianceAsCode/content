# platform = multi_platform_sle

. /usr/share/scap-security-guide/remediation_functions
populate var_postfix_root_mail_alias

if grep -q -i -E '^root\s*:|^"root"\s*:' /etc/aliases ; then
    sed -i --follow-symlinks -E -e 's/^(root|"root")\s*:.+$/\1: '"$var_postfix_root_mail_alias"'/I' /etc/aliases
else
    printf "\n%s\n" "root: $var_postfix_root_mail_alias" >> /etc/aliases
fi

newaliases
