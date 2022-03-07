# platform = multi_platform_all
# reboot = false
# strategy = configure
# complexity = low
# disruption = medium

{{{ bash_ensure_ini_config("/etc/sssd/sssd.conf", "pam", "pam_cert_auth", "true") }}}
