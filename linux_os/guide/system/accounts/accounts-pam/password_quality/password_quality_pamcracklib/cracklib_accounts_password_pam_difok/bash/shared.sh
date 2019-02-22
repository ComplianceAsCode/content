# platform = multi_platform_sle
. /usr/share/scap-security-guide/remediation_functions

populate var_password_pam_difok

ensure_pam_module_options '/etc/pam.d/common-password' 'password' 'requisite' 'pam_cracklib.so' 'difok' "$var_password_pam_difok" "$var_password_pam_difok"
