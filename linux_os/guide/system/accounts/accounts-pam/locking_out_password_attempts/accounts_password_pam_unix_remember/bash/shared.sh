# platform = multi_platform_wrlinux,multi_platform_rhel,multi_platform_fedora,multi_platform_ol,multi_platform_rhv,multi_platform_sle

{{{ bash_instantiate_variables("var_password_pam_unix_remember") }}}

{{% if product in [ "sle15" ] %}}
AUTH_FILES[0]="/etc/pam.d/common-password"
{{% else %}}
AUTH_FILES[0]="/etc/pam.d/system-auth"
{{% endif %}}
AUTH_FILES[1]="/etc/pam.d/password-auth"

for pamFile in "${AUTH_FILES[@]}"
do
    if grep -q "pam_unix.so.*remember=" $pamFile; then
        {{{ bash_provide_pam_module_options("$pamFile", 'password', 'sufficient', 'pam_unix.so', 'remember', "$var_password_pam_unix_remember", "$var_password_pam_unix_remember") }}}
    fi
    if grep -q "pam_pwhistory.so.*remember=" $pamFile; then
	{{{ bash_provide_pam_module_options("$pamFile", 'password', 'required', 'pam_pwhistory.so', 'remember', "$var_password_pam_unix_remember", "$var_password_pam_unix_remember") }}}
    fi
done
