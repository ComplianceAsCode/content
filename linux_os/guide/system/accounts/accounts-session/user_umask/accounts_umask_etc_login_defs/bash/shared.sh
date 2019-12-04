# platform = multi_platform_rhel,multi_platform_sle,multi_platform_wrlinux
. /usr/share/scap-security-guide/remediation_functions
populate var_accounts_user_umask

replace_or_append '/etc/login.defs' '^UMASK' "$var_accounts_user_umask" '@CCENUM@' '%s %s'
