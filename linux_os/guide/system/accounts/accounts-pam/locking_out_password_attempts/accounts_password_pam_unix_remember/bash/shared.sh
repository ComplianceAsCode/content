# platform = multi_platform_all

{{{ bash_instantiate_variables("var_password_pam_unix_remember") }}}

{{% if "debian" in product or "sle12" in product %}}
{{%- set accounts_password_pam_unix_remember_file = '/etc/pam.d/common-password' -%}}
{{% elif "ubuntu" in product %}}
config_file="/usr/share/pam-configs/cac_unix"
{{% else %}}
{{%- set accounts_password_pam_unix_remember_file = '/etc/pam.d/system-auth' -%}}
{{% endif %}}

{{% if "debian" in product %}}

{{{ bash_ensure_pam_module_options(accounts_password_pam_unix_remember_file, 'password', '\[success=[[:alnum:]].*\]', 'pam_unix.so', 'remember', "$var_password_pam_unix_remember", "$var_password_pam_unix_remember") }}}

{{% elif "ubuntu" in product %}}
{{{ bash_pam_unix_enable() }}}
sed -i -E '/^Password:/,/^[^[:space:]]/ {
    /pam_unix\.so/ {
        s/\s*remember=[^[:space:]]*//g
        s/$/ remember='"$var_password_pam_unix_remember"'/g
    }
}' "$config_file"

sed -i -E '/^Password-Initial:/,/^[^[:space:]]/ {
    /pam_unix\.so/ {
        s/\s*remember=[^[:space:]]*//g
        s/$/ remember='"$var_password_pam_unix_remember"'/g
    }
}' "$config_file"

DEBIAN_FRONTEND=noninteractive pam-auth-update
{{% else %}}

{{{ bash_pam_pwhistory_enable(accounts_password_pam_unix_remember_file,
                              'requisite',
                              '^password.*requisite.*pam_pwquality\.so') }}}

{{{ bash_pam_pwhistory_parameter_value(accounts_password_pam_unix_remember_file,
                                       'remember',
                                       "$var_password_pam_unix_remember") }}}

{{% endif %}}

