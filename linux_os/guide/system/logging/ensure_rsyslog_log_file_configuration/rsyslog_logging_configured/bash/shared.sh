# platform = multi_platform_sle
# reboot = false
# strategy = restrict
# complexity = low
# disruption = low

{{{ bash_replace_or_append('/etc/rsyslog.conf', '^\*\.\*', "/var/log/messages", '%s %s') }}}
