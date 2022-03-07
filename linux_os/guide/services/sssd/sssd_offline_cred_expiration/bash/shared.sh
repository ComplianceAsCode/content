# platform = Red Hat Virtualization 4,multi_platform_fedora,multi_platform_ol,multi_platform_rhel,multi_platform_sle
# reboot = false
# strategy = configure
# complexity = low
# disruption = medium

{{{ bash_ensure_ini_config("/etc/sssd/sssd.conf", "pam", "offline_credentials_expiration", "1") }}}
