# platform = multi_platform_ubuntu
# reboot = false
# strategy = configure
# complexity = low
# disruption = medium

{{{ bash_pam_unix_enable() }}}
config_file="/usr/share/pam-configs/cac_unix"
sed -i -E '/^Password(-Initial)?:/,/^[^[:space:]]/ {
    /pam_unix\.so/ {
        s/\s*\bremember=\d+\b//g
    }
}' "$config_file"

DEBIAN_FRONTEND=noninteractive pam-auth-update
