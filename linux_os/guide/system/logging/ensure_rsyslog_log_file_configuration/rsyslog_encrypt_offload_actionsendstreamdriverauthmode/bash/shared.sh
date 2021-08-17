# platform = Red Hat Virtualization 4,multi_platform_fedora,multi_platform_rhel
# reboot = false
# strategy = configure
# complexity = low
# disruption = low

if ! grep -s "\$ActionSendStreamDriverAuthMode\s*x509/name" /etc/rsyslog.conf /etc/rsyslog.d/*.conf; then
	mkdir -p /etc/rsyslog.d
    sed -i '/^.*\$ActionSendStreamDriverAuthMode.*/d' /etc/rsyslog.conf /etc/rsyslog.d/*.conf
    echo "\$ActionSendStreamDriverAuthMode x509/name" > /etc/rsyslog.d/stream_driver_auth.conf
fi
