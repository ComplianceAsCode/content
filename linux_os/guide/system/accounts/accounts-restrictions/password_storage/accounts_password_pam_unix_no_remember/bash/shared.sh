# platform = multi_platform_ubuntu
# reboot = false
# strategy = configure
# complexity = low
# disruption = medium

{{{ bash_pam_unix_enable() }}}
config_file="/usr/share/pam-configs/cac_unix"
sed -i -E '/^Password:/,/^[^[:space:]]/ {
    /pam_unix\.so/ {
        s/\s*\bremember=\d+\b//g
    }
}' "$config_file"

sed -i -E '/^Password-Initial:/,/^[^[:space:]]/ {
    /pam_unix\.so/ {
        s/\s*\bremember=\d+\b//g
    }
}' "$config_file"

{{{ bash_remove_pam_module_option('/etc/pam.d/common-auth', 'auth', '', 'pam_unix.so', 'remember') }}}
{{{ bash_remove_pam_module_option('/etc/pam.d/common-account', 'account', '', 'pam_unix.so', 'remember') }}}
{{{ bash_remove_pam_module_option('/etc/pam.d/common-password', 'password', '', 'pam_unix.so', 'remember') }}}
{{{ bash_remove_pam_module_option('/etc/pam.d/common-session', 'session', '', 'pam_unix.so', 'remember') }}}
{{{ bash_remove_pam_module_option('/etc/pam.d/common-session-noninteractive', 'session', '', 'pam_unix.so', 'remember') }}}

DEBIAN_FRONTEND=noninteractive pam-auth-update
