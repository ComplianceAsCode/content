# platform = multi_platform_sle
. /usr/share/scap-security-guide/remediation_functions

ensure_pam_module_options '/etc/pam.d/common-auth' 'auth' 'required' 'pam_tally2.so' 'deny' '[123]' '3'
ensure_pam_module_options '/etc/pam.d/common-auth' 'auth' 'required' 'pam_tally2.so' 'onerr' '(fail)' 'fail'
ensure_pam_module_options '/etc/pam.d/common-account' 'account' 'required' 'pam_tally2.so' '' '' ''
