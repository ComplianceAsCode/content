# platform = multi_platform_sle
. /usr/share/scap-security-guide/remediation_functions

populate var_password_pam_minlen

ensure_pam_module_options '/etc/pam.d/common-password' 'password' 'requisite' 'pam_cracklib.so' 'minlen' "$var_password_pam_minlen" "$var_password_pam_minlen"
