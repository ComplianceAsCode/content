#!/bin/bash
# packages = rsyslog
{{{ setup_rsyslog_cron_logging() }}}

echo 'cron.*    /var/log/cron' >> $RSYSLOG_D_CONF
{{% if product in ["rhel9", "rhel10"] %}}
systemctl restart rsyslog.service
{{% endif %}}
