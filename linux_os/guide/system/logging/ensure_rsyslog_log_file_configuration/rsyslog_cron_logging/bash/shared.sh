# platform = Red Hat Virtualization 4,multi_platform_fedora,multi_platform_ol,multi_platform_rhel,multi_platform_almalinux

if ! grep -s "^\s*cron\.\*\s*/var/log/cron$" /etc/rsyslog.conf /etc/rsyslog.d/*.conf; then
	mkdir -p /etc/rsyslog.d
	echo "cron.*	/var/log/cron" >> /etc/rsyslog.d/cron.conf
fi

if {{{ bash_not_bootc_build() }}} ; then
    systemctl restart rsyslog.service
fi
