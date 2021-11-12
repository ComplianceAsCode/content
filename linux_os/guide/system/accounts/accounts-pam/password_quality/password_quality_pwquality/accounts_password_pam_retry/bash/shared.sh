# platform = multi_platform_all

{{{ bash_instantiate_variables("var_password_pam_retry") }}}

if grep -q "retry=" /etc/pam.d/system-auth ; then
	sed -i --follow-symlinks "s/\(retry *= *\).*/\1$var_password_pam_retry/" /etc/pam.d/system-auth
else
	sed -i --follow-symlinks "/pam_pwquality.so/ s/$/ retry=$var_password_pam_retry/" /etc/pam.d/system-auth
fi

{{% if product in ['rhel8', 'rhel9'] -%}}
if grep -q "retry=" /etc/pam.d/password-auth ; then
	sed -i --follow-symlinks "s/\(retry *= *\).*/\1$var_password_pam_retry/" /etc/pam.d/password-auth
else
	sed -i --follow-symlinks "/pam_pwquality.so/ s/$/ retry=$var_password_pam_retry/" /etc/pam.d/password-auth
fi
{{%- endif %}}
