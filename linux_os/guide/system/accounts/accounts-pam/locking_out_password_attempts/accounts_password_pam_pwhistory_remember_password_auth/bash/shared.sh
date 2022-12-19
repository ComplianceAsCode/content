# platform = multi_platform_rhel,multi_platform_fedora,multi_platform_ol,multi_platform_rhv

{{{ bash_instantiate_variables("var_password_pam_remember", "var_password_pam_remember_control_flag") }}}

var_password_pam_remember_control_flag="$(echo $var_password_pam_remember_control_flag | cut -d \, -f 1)"

{{{ bash_pam_pwhistory_enable('/etc/pam.d/password-auth',
                              "$var_password_pam_remember_control_flag",
                              '^password.*requisite.*pam_pwquality\.so') }}}

{{{ bash_pam_pwhistory_parameter_value('/etc/pam.d/password-auth',
                                       'remember',
                                       "$var_password_pam_remember") }}}
