# platform = multi_platform_ubuntu

{{{ bash_instantiate_variables("var_password_pam_retry") }}}

{{{ bash_pam_pwquality_enable() }}}
{{% if product == 'ubuntu2404' %}}
sed -i -E '/^Password:/,/^[^[:space:]]/ {
    /pam_pwquality\.so/ {
        s/\s*\bretry=\d+\b//g
        s/$/ retry='"$var_password_pam_retry"'/g
    }
}' /usr/share/pam-configs/cac_pwquality

DEBIAN_FRONTEND=noninteractive pam-auth-update --enable cac_pwquality
{{% else %}}
{{{ bash_pam_pwquality_parameter_value('retry', "$var_password_pam_retry") }}}
{{% endif %}}
