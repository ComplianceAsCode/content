# platform = multi_platform_sle
. /usr/share/scap-security-guide/remediation_functions

populate var_accounts_fail_delay

# convert to microseconds
delay=$((var_accounts_fail_delay*1000000))

ensure_pam_module_options '/etc/pam.d/common-auth' 'auth' 'required' 'pam_faildelay.so' 'delay' "$delay" "$delay"
