# platform = Red Hat Enterprise Linux 7,Red Hat Enterprise Linux 8,Red Hat Virtualization 4,multi_platform_wrlinux,multi_platform_ol,multi_platform_sle

{{{ bash_package_install("aide") }}}

CRONTAB=/etc/crontab
CRONDIRS='/etc/cron.d /etc/cron.daily /etc/cron.weekly /etc/cron.monthly'

# NOTE: on some platforms, /etc/crontab may not exist
if [ -f /etc/crontab ]; then
	CRONTAB_EXIST=/etc/crontab
fi

if [ -f /var/spool/cron/root ]; then
	VARSPOOL=/var/spool/cron/root
fi

if ! grep -qR '^.*\/usr\/sbin\/aide\s*\-\-check.*|.*\/bin\/mail\s*-s\s*".*"\s*root@.*$' $CRONTAB_EXIST $VARSPOOL $CRONDIRS; then
{{% if product in ["sle12", "sle15"] %}}
	echo '0 5 * * * root /usr/bin/aide  --check | /bin/mail -s "$(hostname) - AIDE Integrity Check" root@localhost' >> $CRONTAB
{{% else %}}
	echo '0 5 * * * root /usr/sbin/aide  --check | /bin/mail -s "$(hostname) - AIDE Integrity Check" root@localhost' >> $CRONTAB
{{% endif %}}
fi

