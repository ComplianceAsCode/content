# platform = Red Hat Virtualization 4,multi_platform_fedora,multi_platform_ol,multi_platform_rhel
# reboot = false
# strategy = configure
# complexity = low
# disruption = low

sed -i '/^.*\$ActionSendStreamDriverAuthMode.*/d' /etc/rsyslog.conf /etc/rsyslog.d/*.conf 2> /dev/null

{{{ set_config_file(path="/etc/rsyslog.d/stream_driver_auth.conf",
             parameter="\$ActionSendStreamDriverAuthMode", value="x509/name", create=true, separator=" ", separator_regex=" ")
}}}
