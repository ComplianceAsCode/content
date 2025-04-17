# platform = multi_platform_rhel,multi_platform_fedora,multi_platform_ol,multi_platform_rhv,multi_platform_sle,multi_platform_debian,multi_platform_almalinux,multi_platform_ubuntu

{{{ bash_instantiate_variables("var_password_pam_unix_rounds") }}}

{{% if product in ["sle12", "sle15"] %}}
{{{ bash_ensure_pam_module_configuration('/etc/pam.d/common-password', 'password', 'sufficient', 'pam_unix.so', 'rounds', "$var_password_pam_unix_rounds", '') }}}
{{% elif product in ["debian12"] %}}
{{{ bash_ensure_pam_module_configuration('/etc/pam.d/common-password', 'password', '\[success=1 default=ignore\]', 'pam_unix.so', 'rounds', "$var_password_pam_unix_rounds", '') }}}
{{% elif product in ["ubuntu2404"] %}}
config_file="/usr/share/pam-configs/cac_unix"
{{{ bash_pam_unix_enable() }}}
sed -i -E '/^Password:/,/^[^[:space:]]/ {
    /pam_unix\.so/ {
        s/\s*rounds=[^[:space:]]*//g
        s/$/ rounds='"$var_password_pam_unix_rounds"'/g
    }
}' "$config_file"

sed -i -E '/^Password-Initial:/,/^[^[:space:]]/ {
    /pam_unix\.so/ {
        s/\s*rounds=[^[:space:]]*//g
        s/$/ rounds='"$var_password_pam_unix_rounds"'/g
    }
}' "$config_file"

DEBIAN_FRONTEND=noninteractive pam-auth-update

{{% else %}}
{{{ bash_ensure_pam_module_configuration('/etc/pam.d/password-auth', 'password', 'sufficient', 'pam_unix.so', 'rounds', "$var_password_pam_unix_rounds", '') }}}
{{% endif %}}
