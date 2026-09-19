#!/bin/bash

# These fixtures replace logging configuration only in the disposable test guest.
rm -f /etc/rsyslog.d/*.conf
mkdir -p /etc/rsyslog.d /etc/systemd/journald.conf.d
cat > /etc/rsyslog.conf << 'EOF'
module(load="imuxsock")
$IncludeConfig /etc/rsyslog.d/*.conf
EOF
printf '%s\n' 'auth,authpriv.* /var/log/auth.log' > /etc/rsyslog.d/50-default.conf
touch /var/log/auth.log
chown syslog:adm /var/log/auth.log
chmod 0640 /var/log/auth.log

cat > /etc/systemd/journald.conf.d/zz-sudo-test.conf << 'EOF'
[Journal]
Storage=volatile
ForwardToSyslog=yes
MaxLevelStore=debug
MaxLevelSyslog=debug
EOF
systemctl restart systemd-journald.service
systemctl unmask rsyslog.service
systemctl enable --now rsyslog.service
systemctl restart rsyslog.service
