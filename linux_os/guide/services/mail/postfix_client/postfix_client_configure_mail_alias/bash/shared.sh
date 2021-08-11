# platform = multi_platform_all
. /usr/share/scap-security-guide/remediation_functions
{{{ bash_instantiate_variables("var_postfix_root_mail_alias") }}}

{{{ bash_replace_or_append('/etc/aliases', '^root', "$var_postfix_root_mail_alias", '@CCENUM@', '%s: %s') }}}

newaliases
