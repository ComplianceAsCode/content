# platform = multi_platform_all
. /usr/share/scap-security-guide/remediation_functions
{{{ bash_instantiate_variables("var_password_pam_retry") }}}

if grep -q "retry=" /etc/pam.d/system-auth ; then
	sed -i --follow-symlinks "s/\(retry *= *\).*/\1$var_password_pam_retry/" /etc/pam.d/system-auth
else
	sed -i --follow-symlinks "/pam_pwquality.so/ s/$/ retry=$var_password_pam_retry/" /etc/pam.d/system-auth
fi

{{% if product == "rhel8" -%}}
if grep -q "retry=" /etc/pam.d/password-auth ; then
	sed -i --follow-symlinks "s/\(retry *= *\).*/\1$var_password_pam_retry/" /etc/pam.d/password-auth
else
	sed -i --follow-symlinks "/pam_pwquality.so/ s/$/ retry=$var_password_pam_retry/" /etc/pam.d/password-auth
fi
{{%- endif %}}
