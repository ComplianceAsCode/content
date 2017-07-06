# platform = Red Hat Enterprise Linux 7
. /usr/share/scap-security-guide/remediation_functions

package_command install aide

CRONTAB=/etc/crontab
CRONDIRS='/etc/cron.d /etc/cron.daily /etc/cron.weekly /etc/cron.monthly'

if [ -f /var/spool/cron/root ]; then
	VARSPOOL=/var/spool/cron/root
fi

if ! grep -qR '^.*\/usr\/sbin\/aide\s*\-\-check.*\|.*\/bin\/mail\s*-s\s*".*"\s*root@.*$' $CRONTAB $VARSPOOL $CRONDIRS; then
	echo '0 5 * * * /usr/sbin/aide  --check | /bin/mail -s "$(hostname) - AIDE Integrity Check" root@localhost' >> $CRONTAB
fi

