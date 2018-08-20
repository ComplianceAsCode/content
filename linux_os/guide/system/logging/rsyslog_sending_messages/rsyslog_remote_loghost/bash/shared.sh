# platform = multi_platform_rhel, multi_platform_fedora, Fedora Rawhide

. /usr/share/scap-security-guide/remediation_functions

populate rsyslog_remote_loghost_address

replace_or_append '/etc/rsyslog.conf' '^\*\.\*' "@@$rsyslog_remote_loghost_address" '@CCENUM@' '%s %s'
