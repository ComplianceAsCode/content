# platform = multi_platform_rhel,multi_platform_rhv,multi_platform_sle

{{{ bash_instantiate_variables("var_postfix_root_mail_alias") }}}

{{{ bash_replace_or_append('/etc/aliases', '^root', "$var_postfix_root_mail_alias", '%s: %s') }}}

if [ -f /usr/bin/newaliases ]; then
    newaliases
fi
