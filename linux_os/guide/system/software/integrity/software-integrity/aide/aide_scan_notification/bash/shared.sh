# platform = multi_platform_all

{{{ bash_package_install("aide") }}}
{{{ bash_instantiate_variables("var_aide_scan_notification_email") }}}

{{% if product in ["sle15", "slmicro5"] %}}
# create unit file for periodic aide database check
cat > /etc/systemd/system/aidecheck.service <<CHECKEOF
[Unit]
        Description=Aide Check
        Before=aidecheck-notify.service
        Wants=aidecheck-notify.service
        [Service]
        Type=forking
        ExecStart=/usr/bin/aide --check -r file:/tmp/aide-report.log
        [Install]
        WantedBy=multi-user.target
CHECKEOF
cat > /etc/systemd/system/aidecheck-notify.service <<NOTIFYEOF
[Unit]
        Description=Status email for AIDE check result
        After=aidecheck.service
        [Service]
        Type=forking
        ExecStart=/bin/sh -c 'cat /tmp/aide-report.log | /bin/mail -s "$(hostname) - AIDE Integrity Check"  $var_aide_scan_notification_email'
NOTIFYEOF
{{% else %}}
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
{{% endif %}}
