# platform = multi_platform_ubuntu

config_file="/usr/share/pam-configs/cac_unix"
{{{ bash_pam_unix_enable() }}}
sed -i -E '/^Password:/,/^[^[:space:]]/ {
    /pam_unix\.so/ {
        /use_authtok/! s/$/ use_authtok/g
    }
}'  "$config_file"


DEBIAN_FRONTEND=noninteractive pam-auth-update --remove unix --enable cac_unix


