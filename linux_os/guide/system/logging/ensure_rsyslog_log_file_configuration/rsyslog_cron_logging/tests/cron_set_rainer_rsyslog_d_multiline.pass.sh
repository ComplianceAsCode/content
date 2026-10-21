#!/bin/bash
# packages = rsyslog
{{{ setup_rsyslog_cron_logging() }}}

cat << EOF >> "$RSYSLOG_D_CONF"
cron.* action(
    name="local-cron"
    type="omfile"
    fileCreateMode="0600"
    fileOwner="root"
    fileGroup="root"
    file="/var/log/cron"
)
EOF
{{% if product == "rhel9" %}}
systemctl restart rsyslog.service
{{% endif %}}
