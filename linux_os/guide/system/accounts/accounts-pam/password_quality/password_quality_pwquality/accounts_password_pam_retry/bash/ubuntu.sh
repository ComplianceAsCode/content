# platform = multi_platform_ubuntu

{{{ bash_instantiate_variables("var_password_pam_retry") }}}

{{{ bash_pam_pwquality_enable() }}}
PAM_FILE_PATH=/usr/share/pam-configs/cac_pwquality
if grep -qE 'pam_pwquality\.so.*retry=[^[:space:]]' "$PAM_FILE_PATH"; then
    sed -i -E '/pam_pwquality\.so/ s/\bretry=[^[:space:]]*\b ?//' "$PAM_FILE_PATH"
fi
{{{ bash_pam_pwquality_parameter_value('retry', "$var_password_pam_retry") }}}
