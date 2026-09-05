# platform = Ubuntu 26.04
# reboot = false
# strategy = restrict
# complexity = low
# disruption = low

{{{ bash_package_install("rsyslog") }}}

systemctl enable --now rsyslog.service
