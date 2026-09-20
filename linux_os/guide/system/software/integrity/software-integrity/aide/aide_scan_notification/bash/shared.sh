# platform = multi_platform_all

{{% set aide_service = 'aide.service' %}}
{{% set aide_notify_service = 'aidecheck-notify.service' %}}

{{{ bash_package_install("aide") }}}
{{{ bash_instantiate_variables("var_aide_scan_notification_email") }}}

{{% if product in ["sle16"] %}}
{{% set aide_service_unit = "/usr/lib/systemd/system/" ~ aide_service %}}
{{% set aide_notify_unit = "/usr/lib/systemd/system/" ~ aide_notify_service %}}
{{{ lineinfile_absent('/etc/aide.conf', 'report_url=file:/var/log/aide-report.log', sed_path_separator="#") }}}
{{{ lineinfile_present('/etc/aide.conf', 'report_url=file:/var/log/aide-report.log') }}}
{{% else %}}
{{% set aide_service_unit = "/etc/systemd/system/" ~ aide_service %}}
{{% set aide_notify_unit = "/etc/systemd/system/" ~ aide_notify_service %}}
{{% endif %}}

{{% if 'suse' in families and product != 'sle12' %}}
if [ -e "{{{ aide_service_unit }}}" ] ; then
{{{ bash_ensure_ini_config(aide_service_unit, "Unit", "Before", aide_notify_service) }}}
{{{ bash_ensure_ini_config(aide_service_unit, "Unit", "Wants", aide_notify_service) }}}
{{% if product in ["sle15", "slmicro5", "slmicro6"] %}}
{{{ bash_ensure_ini_config(aide_service_unit, "Service", "ExecStart", aide_bin_path ~ " --check -r file:/var/log/aide-report.log") }}}
{{% endif %}}
else
# create unit file for periodic aide database check
cat > {{{ aide_service_unit }}} <<CHECKEOF
[Unit]
Description=Aide Check
Before={{{ aide_notify_service }}}
Wants={{{ aide_notify_service }}}
[Service]
Type=forking
ExecStart={{{ aide_bin_path }}} --check -r file:/var/log/aide-report.log
[Install]
WantedBy=multi-user.target
CHECKEOF

chmod 0644 {{{ aide_service_unit }}}
fi

cat > {{{ aide_notify_unit }}} <<NOTIFYEOF
[Unit]
Description=Status email for AIDE check result
After={{{ aide_service }}}
[Service]
Type=forking
ExecStart=/bin/sh -c 'cat /var/log/aide-report.log | /bin/mail -s "$(hostname) - AIDE Integrity Check"  $var_aide_scan_notification_email'
NOTIFYEOF

chmod 0644 {{{ aide_notify_unit }}}
systemctl daemon-reload

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
