# platform = multi_platform_rhel,multi_platform_fedora,multi_platform_ol,multi_platform_rhv,multi_platform_almalinux,multi_platform_ubuntu
# reboot = false
# strategy = configure
# complexity = low
# disruption = medium

{{% if 'ubuntu' in product or 'debian' in product %}}
# Debian-based systems: Use pam-auth-update
{{{ bash_pam_unix_enable() }}}
config_file="/usr/share/pam-configs/cac_unix"
sed -i -E '/^Password(-Initial)?:/,/^[^[:space:]]/ {
    /pam_unix\.so/ {
        s/\s*\bremember=\d+\b//g
    }
}' "$config_file"

DEBIAN_FRONTEND=noninteractive pam-auth-update
{{% else %}}
# RHEL-based systems: Use authselect-aware approach
if [ -f /usr/bin/authselect ]; then
    {{{ bash_remove_pam_module_option_configuration('/etc/pam.d/system-auth', 'password', '.*', 'pam_unix.so', 'remember') }}}
    {{{ bash_remove_pam_module_option_configuration('/etc/pam.d/password-auth', 'password', '.*', 'pam_unix.so', 'remember') }}}
else
    {{{ bash_remove_pam_module_option('/etc/pam.d/system-auth', 'password', '.*', 'pam_unix.so', 'remember') }}}
    {{{ bash_remove_pam_module_option('/etc/pam.d/password-auth', 'password', '.*', 'pam_unix.so', 'remember') }}}
fi
{{% endif %}}
