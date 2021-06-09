# platform = multi_platform_ubuntu
. /usr/share/scap-security-guide/remediation_functions
{{{ bash_instantiate_variables("var_password_pam_unix_remember") }}}

ensure_pam_module_options '/etc/pam.d/common-password' 'password' '[success=1 default=ignore]' 'pam_unix.so' 'obsecure sha512 shadow remember' $var_password_pam_unix_remember $var_password_pam_unix_remember
