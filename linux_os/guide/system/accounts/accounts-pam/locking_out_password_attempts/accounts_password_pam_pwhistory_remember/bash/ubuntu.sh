# platform = multi_platform_ubuntu

{{{ bash_pam_pwhistory_enable('cac_pwhistory','requisite') }}}

{{{ bash_instantiate_variables("var_password_pam_remember") }}}

sed -i -E '/^Password:/,/^[^[:space:]]/ {
    /pam_pwhistory\.so/ {
        s/\s*remember=[^[:space:]]*//g
        s/$/ remember='"$var_password_pam_remember"'/g
    }
}' /usr/share/pam-configs/cac_pwhistory

sed -i -E '/^Password-Initial:/,/^[^[:space:]]/ {
    /pam_pwhistory\.so/ {
        s/\s*remember=[^[:space:]]*//g
        s/$/ remember='"$var_password_pam_remember"'/g
    }
}' /usr/share/pam-configs/cac_pwhistory

DEBIAN_FRONTEND=noninteractive pam-auth-update --enable cac_pwhistory
