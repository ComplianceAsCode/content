# platform = Red Hat Enterprise Linux 7,Red Hat Enterprise Linux 8,multi_platform_fedora,multi_platform_ol,multi_platform_sle
. /usr/share/scap-security-guide/remediation_functions
populate var_accounts_tmout


replace_or_append '/etc/profile' '^TMOUT' "$var_accounts_tmout" '@CCENUM@' '%s=%s'
