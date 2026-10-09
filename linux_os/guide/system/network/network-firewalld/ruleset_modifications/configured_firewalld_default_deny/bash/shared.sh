# platform = multi_platform_all
# reboot = false
# strategy = configure
# complexity = low
# disruption = low

{{{ bash_replace_or_append('/etc/firewalld/firewalld.conf', '^DefaultZone', 'drop', '%s=%s') }}}
