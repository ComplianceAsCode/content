# platform = multi_platform_rhel,multi_platform_rhv,multi_platform_sle,multi_platform_slmicro,multi_platform_debian

{{{ bash_instantiate_variables("var_postfix_root_mail_alias") }}}

{{{ bash_replace_or_append('/etc/aliases', '^root', "$var_postfix_root_mail_alias", '%s: %s', cce_identifiers=cce_identifiers) }}}

if [ -f /usr/bin/newaliases ]; then
    newaliases
fi
