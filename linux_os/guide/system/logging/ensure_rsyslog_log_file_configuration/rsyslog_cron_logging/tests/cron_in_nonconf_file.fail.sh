#!/bin/bash
# packages = rsyslog
{{{ setup_rsyslog_cron_logging() }}}

# The compliant-looking routing sits only in a file whose name does not end in
# .conf. rsyslog loads /etc/rsyslog.d/*.conf only, through the include glob of
# the stock configuration, so the daemon never reads this file and the machine
# does not log cron to /var/log/cron; the scan must fail.
echo 'cron.*    /var/log/cron' >> "$RSYSLOG_D_FOLDER/cron.conf.bak"
