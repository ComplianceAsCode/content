# platform = Red Hat Enterprise Linux 7

if ! grep "^\s*cron\.\*\s*/var/log/cron$" /etc/rsyslog.conf /etc/rsyslog.d/*.conf; then
	echo "cron.*                                                  /var/log/cron\n" >> /etc/rsyslog.d/cron.conf
fi
