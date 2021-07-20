# platform = Red Hat Enterprise Linux 7,Red Hat Enterprise Linux 8,Red Hat Virtualization 4,multi_platform_wrlinux,multi_platform_ol,multi_platform_sle

. /usr/share/scap-security-guide/remediation_functions

{{{ bash_package_install("aide") }}}
{{{ bash_instantiate_variables("var_aide_scan_notification_email") }}}
{{% if product in ["sle12", "sle15"] %}}
    {{% set aide_path = "/usr/bin/aide" %}}
{{% else %}}
    {{% set aide_path = "/usr/sbin/aide" %}}
{{% endif %}}



CRONTAB=/etc/crontab
CRONDIRS='/etc/cron.d /etc/cron.daily /etc/cron.weekly /etc/cron.monthly'

# NOTE: on some platforms, /etc/crontab may not exist
if [ -f /etc/crontab ]; then
	CRONTAB_EXIST=/etc/crontab
fi

if [ -f /var/spool/cron/root ]; then
	VARSPOOL=/var/spool/cron/root
fi

if ! grep -qR '^.*{{{aide_path}}}\s*\-\-check.*|.*\/bin\/mail\s*-s\s*".*"\s*.*@.*$' $CRONTAB_EXIST $VARSPOOL $CRONDIRS; then
	echo "0 5 * * * root {{{ aide_path }}}  --check | /bin/mail -s \"\$(hostname) - AIDE Integrity Check\" $var_aide_scan_notification_email" >> $CRONTAB
fi

