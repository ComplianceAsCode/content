# platform = multi_platform_sle
. /usr/share/scap-security-guide/remediation_functions

ensure_pam_module_options '/etc/pam.d/common-password' 'password' 'requisite' 'pam_cracklib.so' 'lcredit' '-1' '-1'
