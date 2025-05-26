# platform = Red Hat Virtualization 4,multi_platform_fedora,multi_platform_ol,multi_platform_rhel,multi_platform_almalinux

{{% if 'ol' in families %}}
if ! grep -Pzo '(?m)^\s*(cron|\*)\.\*\s*(/var/log/(cron|messages)|action\(\s*.*(?i:\btype\b)="omfile"\s*.*(?i:\bfile\b)="/var/log/(cron|messages)"\s*\))\s*$' /etc/rsyslog.conf /etc/rsyslog.d/*.conf; then
{{% else %}}
if ! grep -Pzo '(?m)^\s*cron\.\*\s*(/var/log/cron|action\(\s*.*(?i:\btype\b)="omfile"\s*.*(?i:\bfile\b)="/var/log/cron"\s*\))\s*$' /etc/rsyslog.conf /etc/rsyslog.d/*.conf; then
{{% endif %}}
	mkdir -p /etc/rsyslog.d
	echo "cron.*	/var/log/cron" >> /etc/rsyslog.d/cron.conf
fi

if {{{ bash_not_bootc_build() }}} ; then
    systemctl restart rsyslog.service
fi
