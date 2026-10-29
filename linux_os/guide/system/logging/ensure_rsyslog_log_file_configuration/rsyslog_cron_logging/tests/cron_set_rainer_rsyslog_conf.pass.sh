#!/bin/bash
# packages = rsyslog
{{{ setup_rsyslog_cron_logging() }}}

echo 'cron.* action(name="local-cron" type="omfile" fileCreateMode="0600" fileOwner="root" fileGroup="root" file="/var/log/cron")' >> "$RSYSLOG_CONF"
{{% if product in ["rhel9", "rhel10"] %}}
systemctl restart rsyslog.service
{{% endif %}}
