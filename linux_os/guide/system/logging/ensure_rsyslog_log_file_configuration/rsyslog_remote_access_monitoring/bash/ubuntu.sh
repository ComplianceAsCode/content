# platform = multi_platform_ubuntu

if [ ! -f /etc/rsyslog.d/50-default.conf ]; then
    # Something is not right, create the file
    touch /etc/rsyslog.d/50-default.conf
fi

# Check to see if auth exists
if ! grep -Erq "^auth\.\*,authpriv\.\*" /etc/rsyslog.*; then
    echo "auth.*,authpriv.* /var/log/secure" >> /etc/rsyslog.d/50-default.conf
fi

if ! grep -Erq "^daemon\.\*" /etc/rsyslog.*; then
    echo "daemon.* /var/log/messages" >> /etc/rsyslog.d/50-default.conf
fi

systemctl restart rsyslog.service
