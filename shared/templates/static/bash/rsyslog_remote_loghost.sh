# platform = multi_platform_rhel, multi_platform_fedora

. /usr/share/scap-security-guide/remediation_functions

populate rsyslog_remote_loghost_address

if [ "$rsyslog_remote_loghost_address" != "NULL" ]
then
    replace_or_append '/etc/rsyslog.conf' '^\*\.\*' "@@$rsyslog_remote_loghost_address" '@CCENUM@' '%s %s'
fi
