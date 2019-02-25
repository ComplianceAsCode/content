# platform = multi_platform_sle

. /usr/share/scap-security-guide/remediation_functions

replace_or_append '/etc/login.defs' '^SHA_CRYPT_MIN_ROUNDS' '5000' '@CCENUM@' '%s %s'
replace_or_append '/etc/login.defs' '^SHA_CRYPT_MAX_ROUNDS' '5000' '@CCENUM@' '%s %s'
