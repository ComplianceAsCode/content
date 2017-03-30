# platform = multi_platform_rhel

# Include source function library.
. /usr/share/scap-security-guide/remediation_functions

# Set variables
declare var_accounts_fail_delay
populate var_accounts_fail_delay

replace_or_append '/etc/login.defs' '^FAIL_DELAY' '$var_accounts_fail_delay' '$CCENUM' '%s %s'
