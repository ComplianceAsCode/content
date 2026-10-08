# platform = multi_platform_ubuntu,multi_platform_debian
# reboot = false
# strategy = configure
# complexity = low
# disruption = medium

{{{ bash_pam_unix_enable() }}}
config_file="/usr/share/pam-configs/cac_unix"
sed -i '/pam_unix\.so/s/nullok//g' "$config_file"

DEBIAN_FRONTEND=noninteractive pam-auth-update

# Fallback: remove nullok directly in case pam-auth-update was blocked
# by local modifications to /etc/pam.d/common-*
for pam_file in /etc/pam.d/common-password /etc/pam.d/common-auth \
                /etc/pam.d/common-account /etc/pam.d/common-session \
                /etc/pam.d/common-session-noninteractive; do
    [ -f "$pam_file" ] && sed -i '/pam_unix\.so/s/\bnullok\b//g' "$pam_file"
done
