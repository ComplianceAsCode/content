#!/bin/bash
# platform = multi_platform_all

rm -rf /etc/rsyslog.d/*
true > /etc/rsyslog.conf

# Use RainerScript action() syntax with capitalized File property
echo '*.info;daemon.*;kern.*;auth.*;mail,authpriv,cron.none   action(name="local-messages" type="omfile" File="/var/log/messages")' >> /etc/rsyslog.conf
echo 'authpriv.*   action(name="local-authpriv" type="omfile" File="/var/log/secure")' >> /etc/rsyslog.conf
