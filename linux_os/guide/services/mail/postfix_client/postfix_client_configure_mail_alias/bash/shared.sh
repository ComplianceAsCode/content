# platform = Red Hat Virtualization 4,multi_platform_sle
. /usr/share/scap-security-guide/remediation_functions
{{{ bash_instantiate_variables("var_postfix_root_mail_alias") }}}

replace_or_append '/etc/aliases' '^root' "$var_postfix_root_mail_alias" '@CCENUM@' '%s: %s'

newaliases
