# platform = Red Hat Virtualization 4,multi_platform_fedora,multi_platform_ol,multi_platform_rhel,multi_platform_almalinux

{{{ setup_rsyslog_cron_logging() }}}

echo "cron.*	/var/log/cron" >> $RSYSLOG_D_CONF

if {{{ bash_not_bootc_build() }}} ; then
    systemctl restart rsyslog.service
fi
