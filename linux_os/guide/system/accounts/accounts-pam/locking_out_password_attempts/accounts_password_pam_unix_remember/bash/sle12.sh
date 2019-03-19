# platform = SUSE Linux Enterprise 12
. /usr/share/scap-security-guide/remediation_functions

populate var_password_pam_unix_remember


ensure_pam_module_options '/etc/pam.d/common-password' 'password' 'requisite' 'pam_pwhistory.so' 'remember' "$var_password_pam_unix_remember" "$var_password_pam_unix_remember"
ensure_pam_module_options '/etc/pam.d/common-password' 'password' 'requisite' 'pam_pwhistory.so' 'use_authtok' '' ''
