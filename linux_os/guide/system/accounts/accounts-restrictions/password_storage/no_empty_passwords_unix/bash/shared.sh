# platform = multi_platform_ubuntu
# reboot = false
# strategy = configure
# complexity = low
# disruption = medium

{{{ bash_pam_unix_enable() }}}
config_file="/usr/share/pam-configs/cac_unix"
sed -i '/pam_unix\.so/s/nullok//g' "$config_file"

DEBIAN_FRONTEND=noninteractive pam-auth-update
