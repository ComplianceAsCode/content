# platform = SUSE Linux Enterprise 12
. /usr/share/scap-security-guide/remediation_functions

ensure_pam_module_options '/etc/pam.d/common-password' 'password' 'required' 'pam_unix.so' 'sha512' '' ''
