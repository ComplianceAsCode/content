# platform = multi_platform_ubuntu
. /usr/share/scap-security-guide/remediation_functions
{{{ bash_instantiate_variables("var_password_pam_delay") }}}

ensure_pam_module_options '/etc/pam.d/common-auth' 'auth' 'required' 'pam_faildelay.so' 'delay' $var_password_pam_delay $var_password_pam_delay
