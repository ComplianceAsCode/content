# platform = multi_platform_rhel,multi_platform_fedora,multi_platform_ol,multi_platform_rhv

{{{ bash_instantiate_variables("var_password_pam_unix_rounds") }}}

pamFile="/etc/pam.d/password-auth"

if grep -q "rounds=" $pamFile; then
    sed -iP --follow-symlinks "/password[[:space:]]\+sufficient[[:space:]]\+pam_unix\.so/ \
                                    s/rounds=[[:digit:]]\+/rounds=$var_password_pam_unix_rounds/" $pamFile
else
    sed -iP --follow-symlinks "/password[[:space:]]\+sufficient[[:space:]]\+pam_unix\.so/ s/$/ rounds=$var_password_pam_unix_rounds/" $pamFile
fi
