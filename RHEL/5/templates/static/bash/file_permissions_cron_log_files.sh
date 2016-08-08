grep ^cron /etc/syslog.conf | awk '{ print $2 }' | xargs chmod 0600
