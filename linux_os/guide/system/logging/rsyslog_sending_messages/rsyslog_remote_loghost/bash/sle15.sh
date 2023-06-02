# platform = multi_platform_sle

{{{ bash_instantiate_variables("rsyslog_remote_loghost_address") }}}
RSYSLOG_CONF_FILES=$(ls /etc/rsyslog.d/*.conf)
RSYSLOG_CONF_FILES+=("/etc/rsyslog.conf")
for f in "${RSYSLOG_CONF_FILES[@]}"; do
    if grep -q -m 1 -i -e '^\*\.\*' "$f"; then
        sed -i --follow-symlinks "s/^\*\.\*.*/#&/g"
    fi
done
{{{ bash_replace_or_append('/etc/rsyslog.d/remote.conf', '^\*\.\*', "@@$rsyslog_remote_loghost_address", '%s %s') }}}
