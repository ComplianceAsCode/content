# platform = multi_platform_sle
. /usr/share/scap-security-guide/remediation_functions

ensure_pam_module_options '/etc/pam.d/common-auth' 'auth' 'required' 'pam_unix.so' 'sha512' '' ''
