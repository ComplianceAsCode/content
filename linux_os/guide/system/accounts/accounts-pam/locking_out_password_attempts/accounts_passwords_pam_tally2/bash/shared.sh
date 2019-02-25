# platform = multi_platform_sle
. /usr/share/scap-security-guide/remediation_functions

ensure_pam_module_options '/etc/pam.d/login' 'auth' 'required' 'pam_tally2.so' 'deny' '[123]' '3'
