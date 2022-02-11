# platform = Red Hat Virtualization 4,multi_platform_fedora,multi_platform_ol,multi_platform_rhel,multi_platform_sle
# reboot = false
# strategy = configure
# complexity = low
# disruption = medium

{{{ bash_sssd_set_option("[pam]", "/etc/sssd/sssd.conf", "offline_credentials_expiration", "1", "[[:space:]]*\[pam]") }}}
