# platform = multi_platform_all

{{{ bash_instantiate_variables("var_postfix_root_mail_alias") }}}

{{{ bash_replace_or_append('/etc/aliases', '^root', "$var_postfix_root_mail_alias", '%s: %s') }}}

if [ -f /usr/bin/newaliases ]; then
    newaliases
fi
