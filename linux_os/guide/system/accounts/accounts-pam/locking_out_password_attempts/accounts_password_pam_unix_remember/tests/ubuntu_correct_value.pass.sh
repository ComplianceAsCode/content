#!/bin/bash
# platform = multi_platform_ubuntu
# variables = var_password_pam_unix_remember=5

config_file=/usr/share/pam-configs/cac_unix
remember_cnt=5

{{{ bash_pam_unix_enable() }}}
sed -i -E '/^Password:/,/^[^[:space:]]/ {
    /pam_unix\.so/ {
        s/\s*remember=[^[:space:]]*//g
        s/$/ remember='"$remember_cnt"'/g
    }
}' "$config_file"

sed -i -E '/^Password-Initial:/,/^[^[:space:]]/ {
    /pam_unix\.so/ {
        s/\s*remember=[^[:space:]]*//g
        s/$/ remember='"$remember_cnt"'/g
    }
}' "$config_file"

DEBIAN_FRONTEND=noninteractive pam-auth-update
