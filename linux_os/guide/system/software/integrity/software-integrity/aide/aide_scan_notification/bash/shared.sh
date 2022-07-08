# platform = multi_platform_all

{{{ bash_package_install("aide") }}}
{{{ bash_instantiate_variables("var_aide_scan_notification_email") }}}

CRONTAB=/etc/crontab
CRONDIRS='/etc/cron.d /etc/cron.daily /etc/cron.weekly /etc/cron.monthly'

# NOTE: on some platforms, /etc/crontab may not exist
if [ -f /etc/crontab ]; then
	CRONTAB_EXIST=/etc/crontab
fi

if [ -f /var/spool/cron/root ]; then
	VARSPOOL=/var/spool/cron/root
fi

if ! grep -qR '^.*{{{ aide_bin_path }}}\s*\-\-check.*|.*\/bin\/mail\s*-s\s*".*"\s*.*@.*$' $CRONTAB_EXIST $VARSPOOL $CRONDIRS; then
	echo "0 5 * * * root {{{ aide_bin_path }}}  --check | /bin/mail -s \"\$(hostname) - AIDE Integrity Check\" $var_aide_scan_notification_email" >> $CRONTAB
fi

