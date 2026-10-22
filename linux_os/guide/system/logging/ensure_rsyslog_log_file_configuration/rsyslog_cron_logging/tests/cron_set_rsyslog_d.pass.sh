#!/bin/bash
# packages = rsyslog
{{{ setup_rsyslog_cron_logging() }}}

echo 'cron.*    /var/log/cron' >> $RSYSLOG_D_CONF
{{% if product == "rhel10" %}}
systemctl restart rsyslog.service
{{% endif %}}
