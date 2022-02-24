# platform = multi_platform_all
# reboot = false
# strategy = configure
# complexity = low
# disruption = medium

{{{ bash_sssd_set_option("[pam]", "/etc/sssd/sssd.conf", "pam_cert_auth", "true") }}}
