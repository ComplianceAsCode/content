# platform = multi_platform_rhel,multi_platform_fedora,multi_platform_ol,multi_platform_sle

. /usr/share/scap-security-guide/remediation_functions

populate rsyslog_remote_loghost_address

if [[ "$rsyslog_remote_loghost_address" = "logcollector" ]] ; then
    echo 'Refusing to configure the set the remote host to the default value. Please set rsyslog_remote_loghost_address to a sensible value before continuing.' >&2
    exit 1
fi

replace_or_append '/etc/rsyslog.conf' '^\*\.\*' "@@$rsyslog_remote_loghost_address" '@CCENUM@' '%s %s'
