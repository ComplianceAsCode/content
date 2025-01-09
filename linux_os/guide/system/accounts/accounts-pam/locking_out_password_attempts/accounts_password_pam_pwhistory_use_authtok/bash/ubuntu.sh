# platform = multi_platform_ubuntu

{{{ bash_pam_pwhistory_enable('cac_pwhistory','requisite') }}}
conf_file=/usr/share/pam-configs/cac_pwhistory
if ! grep -qE 'pam_pwhistory\.so\s+[^#]*\buse_authtok\b' "$conf_file"; then
	sed -i -E '/^Password:/,/^[^[:space:]]/ {
    /pam_pwhistory\.so/ {
        s/$/ use_authtok/g
    }
    }' "$conf_file"
fi

DEBIAN_FRONTEND=noninteractive pam-auth-update --enable cac_pwhistory
